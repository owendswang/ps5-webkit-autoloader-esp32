#include <Arduino.h>
#include <WiFi.h>
#include <DNSServer.h>
#include <WebServer.h>
#include <LittleFS.h>
#include "esp_wifi.h"
#include "esp_arduino_version.h"
#include "esp_idf_version.h"

static const char *AP_SSID = "ESP32_PORTAL";
static const char *AP_PASSWORD = "12345678";
static const char *PORTAL_REDIRECT_URL = "http://192.168.4.1/";

static const char *PAYLOAD_MIRROR_PREFIX = "/ps5-payloads-mirror/";
static const char *PAYLOAD_LOCAL_PREFIX = "/pldmrr/";

static const IPAddress AP_IP(192, 168, 4, 1);
static const IPAddress AP_GATEWAY(192, 168, 4, 1);
static const IPAddress AP_SUBNET(255, 255, 255, 0);

DNSServer dnsServer;
WebServer webServer(80);

static const char *NO_CACHE_VALUE =
    "no-store, no-cache, must-revalidate, max-age=0";

static void setHttpNoCacheHeaders()
{
    webServer.sendHeader("Cache-Control", NO_CACHE_VALUE);
    webServer.sendHeader("Pragma", "no-cache");
    webServer.sendHeader("Expires", "0");
}

static void logHeap(const char *context)
{
    Serial.printf(
        "[HEAP] %s: free=%u, min=%u\n",
        context,
        ESP.getFreeHeap(),
        ESP.getMinFreeHeap()
    );
}

static void logHttpRequest()
{
    const char *method = webServer.method() == HTTP_GET ? "GET" :
                         webServer.method() == HTTP_POST ? "POST" : "OTHER";

    Serial.printf("[HTTP] %s %s", method, webServer.uri().c_str());

    for (int i = 0; i < webServer.args(); i++)
    {
        Serial.printf(
            "%c%s=%s",
            i == 0 ? '?' : '&',
            webServer.argName(i).c_str(),
            webServer.arg(i).c_str()
        );
    }

    Serial.println();
}

static String getMimeType(const String &path)
{
    if (path.endsWith(".html") || path.endsWith(".htm"))
        return "text/html; charset=utf-8";
    if (path.endsWith(".css"))
        return "text/css";
    if (path.endsWith(".js") || path.endsWith(".mjs"))
        return "application/javascript";
    if (path.endsWith(".json"))
        return "application/json";
    if (path.endsWith(".png"))
        return "image/png";
    if (path.endsWith(".jpg") || path.endsWith(".jpeg"))
        return "image/jpeg";
    if (path.endsWith(".gif"))
        return "image/gif";
    if (path.endsWith(".svg"))
        return "image/svg+xml";
    if (path.endsWith(".ico"))
        return "image/x-icon";
    if (path.endsWith(".appcache") || path.endsWith(".manifest") || path.endsWith(".cache"))
        return "text/cache-manifest";
    if (path.endsWith(".woff"))
        return "font/woff";
    if (path.endsWith(".woff2"))
        return "font/woff2";

    return "application/octet-stream";
}

static String normalizePath(const char *uri)
{
    String path = uri;

    int q = path.indexOf('?');
    if (q >= 0)
        path = path.substring(0, q);

    if (path.length() == 0)
        path = "/";

    return path;
}

static bool isRegularFile(File &file)
{
    return file && !file.isDirectory();
}

static String buildPs4UpdateXml(const String &region)
{
    const String version = "05.050.000";
    const String shortVersion = "05.050.000";
    const String labelVersion = "5.05";
    const String imageSize = "0";
    const String imagePath = "";

    return
        "<?xml version=\"1.0\" ?>"
        "<update_data_list>"
        "<region id=\"" + region + "\">"
        "<force_update>"
        "<system "
        "level0_system_ex_version=\"0\" "
        "level0_system_version=\"" + version + "\" "
        "level1_system_ex_version=\"0\" "
        "level1_system_version=\"" + version + "\"/>"
        "</force_update>"
        "<system_pup "
        "ex_version=\"0\" "
        "label=\"" + labelVersion + "\" "
        "sdk_version=\"" + shortVersion + "\" "
        "version=\"" + version + "\">"
        "<update_data update_type=\"full\">"
        "<image size=\"" + imageSize + "\">" + imagePath + "</image>"
        "</update_data>"
        "</system_pup>"
        "<recovery_pup type=\"default\">"
        "<system_pup "
        "ex_version=\"0\" "
        "label=\"" + labelVersion + "\" "
        "sdk_version=\"" + shortVersion + "\" "
        "version=\"" + version + "\"/>"
        "<image size=\"" + imageSize + "\">" + imagePath + "</image>"
        "</recovery_pup>"
        "</region>"
        "</update_data_list>";
}

static void httpPs4UpdateHandler()
{
    logHttpRequest();

    String path = webServer.uri();

    const String prefix = "/update/ps4/list/";
    int start = path.indexOf(prefix);

    if (start < 0)
    {
        webServer.send(404, "text/plain", "404 Not Found");
        return;
    }

    start += prefix.length();

    int end = path.indexOf('/', start);

    String region;

    if (end >= 0)
        region = path.substring(start, end);
    else
        region = path.substring(start);

    setHttpNoCacheHeaders();

    webServer.send(
        200,
        "text/xml",
        buildPs4UpdateXml(region)
    );
}

void httpFileHandler()
{
    logHeap("HTTP file begin");
    logHttpRequest();

    String path = normalizePath(webServer.uri().c_str());

    if (path.startsWith("/update/ps4/list/"))
    {
        int start = strlen("/update/ps4/list/");
        int end = path.indexOf('/', start);

        String region;

        if (end >= 0)
            region = path.substring(start, end);
        else
            region = path.substring(start);

        String xml = buildPs4UpdateXml(region);

        Serial.printf(
            "[HTTP PS4 UPDATE] region=%s uri=%s\n",
            region.c_str(),
            path.c_str()
        );

        setHttpNoCacheHeaders();

        webServer.send(
            200,
            "text/xml",
            xml
        );

        return;
    }

    if (path.startsWith("/networktest/"))
    {
        httpNetworkTestHandler();
        return;
    }

    if (path.startsWith(PAYLOAD_MIRROR_PREFIX))
    {
        String originalPath = path;

        path = String(PAYLOAD_LOCAL_PREFIX) +
               path.substring(strlen(PAYLOAD_MIRROR_PREFIX));

        Serial.printf(
            "[HTTP] Rewrite: %s -> %s\n",
            originalPath.c_str(),
            path.c_str()
        );
    }

    if (path.endsWith("/"))
    {
        path += "index.html";
    }
    else
    {
        if (!LittleFS.exists(path))
        {
            String indexPath = path + "/index.html";

            if (LittleFS.exists(indexPath))
                path = indexPath;
        }
    }

    bool gzip = false;

    String gzPath = path + ".gz";

    File file = LittleFS.open(gzPath, "r");

    if (file && !file.isDirectory()) {
        gzip = true;
    } else {
        file = LittleFS.open(path, "r");
    }

    if (!file || file.isDirectory())
    {
        if (file)
            file.close();

        Serial.printf("[HTTP] 404: %s", path.c_str());

        if (path.startsWith("/document/") && (path.indexOf("/ps5") >= 0 || path.indexOf("/ps4") >= 0))
        {
            Serial.printf(" | Redirect: %s -> %s\n", path.c_str(), PORTAL_REDIRECT_URL);

            webServer.sendHeader("Location", PORTAL_REDIRECT_URL, true);
            webServer.send(302, "text/plain", "");
        }
        else
        {
            Serial.print("\n");

            webServer.send(404, "text/plain", "404 Not Found");
        }
/*
        Serial.printf("[HTTP] 302: %s\n", path.c_str());
        webServer.sendHeader("Location", PORTAL_REDIRECT_URL, true);
        webServer.sendHeader("Cache-Control", "no-store");
        webServer.send(302, "text/plain", "");
*/
        return;
    }

    String contentType = getMimeType(path);

    if (gzip && contentType == "application/octet-stream")
        webServer.sendHeader("Content-Encoding", "gzip");

    webServer.streamFile(file, contentType);

    file.close();
    logHeap("HTTP file end");
}

static void httpNetworkTestHandler()
{
    logHeap("HTTP network test");
    logHttpRequest();

    Serial.printf(
        "[HTTP] content_len=%d\n",
        webServer.client().available()
    );

    setHttpNoCacheHeaders();
    webServer.send(200, "text/plain", "OK");
}

void setupWebServer()
{
    webServer.on("/generate_204", HTTP_GET, [](){
        logHttpRequest();
        setHttpNoCacheHeaders();
        webServer.send(204);
    });

    webServer.on("/gen_204", HTTP_GET, [](){
        logHttpRequest();
        setHttpNoCacheHeaders();
        webServer.send(204);
    });

    webServer.on("/hotspot-detect.html", HTTP_GET, [](){
        logHttpRequest();
        setHttpNoCacheHeaders();
        webServer.send(200, "text/html", "Success");
    });

    webServer.on("/connecttest.txt", HTTP_GET, [](){
        logHttpRequest();
        setHttpNoCacheHeaders();
        webServer.send(200, "text/plain", "Microsoft Connect Test");
    });

    webServer.on("/ncsi.txt", HTTP_GET, [](){
        logHttpRequest();
        setHttpNoCacheHeaders();
        webServer.send(200, "text/plain", "Microsoft NCSI");
    });

    webServer.on("/redirect", HTTP_GET, [](){
        logHttpRequest();
        setHttpNoCacheHeaders();
        webServer.send(200, "text/plain", "Success");
    });

    webServer.on("/netstart/icst", HTTP_GET, [](){
        logHttpRequest();
        setHttpNoCacheHeaders();
        webServer.send(200, "text/plain", "Success");
    });

    webServer.onNotFound(httpFileHandler);

    webServer.begin();

    Serial.println("HTTP: OK");
}

void setup()
{
    Serial.begin(115200);

    delay(1000);
    
    Serial.printf(
        "Arduino ESP32: %d.%d.%d\n",
        ESP_ARDUINO_VERSION_MAJOR,
        ESP_ARDUINO_VERSION_MINOR,
        ESP_ARDUINO_VERSION_PATCH
    );

    Serial.print("IDF version: ");
    Serial.println(IDF_VER);

    Serial.printf("Flash size: %d MB\n", ESP.getFlashChipSize()/1024/1024);

    Serial.println();
    Serial.println("BOOT");

    if (!LittleFS.begin(false, "/littlefs", 10, "littlefs")) {
        Serial.println("LittleFS mount failed");
    }
    else {
        Serial.println("LittleFS mounted");
    }

    WiFi.persistent(false);

    WiFi.mode(WIFI_OFF);

    delay(200);

    // esp_wifi_set_max_tx_power(78);
    WiFi.mode(WIFI_AP);

    bool configResult = WiFi.softAPConfig(
        AP_IP,
        AP_GATEWAY,
        AP_SUBNET
    );

    Serial.printf(
        "softAPConfig: %s\n",
        configResult ? "OK" : "FAILED"
    );

    bool apResult = WiFi.softAP(
        AP_SSID,
        AP_PASSWORD
    );

    Serial.printf(
        "softAP: %s\n",
        apResult ? "OK" : "FAILED"
    );

    if (!apResult) {
        while (true) {
            delay(1000);
        }
    }

    Serial.print("AP IP: ");
    Serial.println(WiFi.softAPIP());

    Serial.printf(
        "SSID: %s\n",
        WiFi.softAPSSID().c_str()
    );

    Serial.printf(
        "Channel: %d\n",
        WiFi.channel()
    );

    Serial.printf(
        "MAC: %s\n",
        WiFi.softAPmacAddress().c_str()
    );

    Serial.println("Starting DNS");

    dnsServer.setTTL(30);
    dnsServer.setErrorReplyCode(DNSReplyCode::ServerFailure);
    bool dnsResult =
        dnsServer.start(
            53,
            "*",
            AP_IP
        );

    Serial.printf(
        "DNS: %s\n",
        dnsResult ? "OK" : "FAILED"
    );

    Serial.println("Starting WebServer");

    setupWebServer();

    Serial.println("READY");
}

void loop()
{
    dnsServer.processNextRequest();

    webServer.handleClient();

    delay(2);
}
