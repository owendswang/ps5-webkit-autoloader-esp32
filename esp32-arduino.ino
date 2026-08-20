#include <Arduino.h>
#include <WiFi.h>
#include <DNSServer.h>
#include <WebServer.h>
#include <LittleFS.h>
#include "esp_wifi.h"
#include "esp_https_server.h"
#include "esp_arduino_version.h"
#include "esp_idf_version.h"
#include "server_certs.h"

httpd_handle_t httpsServer = NULL;

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

static void setHttpsNoCacheHeaders(httpd_req_t *req)
{
    httpd_resp_set_hdr(req, "Cache-Control", NO_CACHE_VALUE);
    httpd_resp_set_hdr(req, "Pragma", "no-cache");
    httpd_resp_set_hdr(req, "Expires", "0");
}

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
    if (path.endsWith(".js"))
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
    if (path.endsWith(".appcache"))
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

esp_err_t httpsFileHandler(httpd_req_t *req)
{
    logHeap("HTTPS file begin");

    Serial.printf(
        "[HTTPS] method=%d uri=%s\n",
        req->method,
        req->uri
    );

    char buf[256];

    if (httpd_req_get_hdr_value_str(req, "Host", buf, sizeof(buf)) == ESP_OK)
        Serial.printf("[HTTPS] Host: %s\n", buf);

    if (httpd_req_get_hdr_value_str(req, "User-Agent", buf, sizeof(buf)) == ESP_OK)
        Serial.printf("[HTTPS] UA: %s\n", buf);

    String path = normalizePath(req->uri);

    if (path.startsWith(PAYLOAD_MIRROR_PREFIX))
    {
        String originalPath = path;
        path = String(PAYLOAD_LOCAL_PREFIX) +
               path.substring(strlen(PAYLOAD_MIRROR_PREFIX));

        Serial.printf(
            "[HTTPS] Rewrite: %s -> %s\n",
            originalPath.c_str(),
            path.c_str()
        );
    }

    File file;

    if (path.endsWith("/"))
    {
        path += "index.html";
    }
    else
    {
        file = LittleFS.open(path, "r");

        if (!isRegularFile(file))
        {
            if (file)
                file.close();

            String indexPath = path + "/index.html";
            if (LittleFS.exists(indexPath))
                path = indexPath;
        }
    }

    bool gzip = false;
    String gzPath = path + ".gz";
    File gzFile = LittleFS.open(gzPath, "r");

    if (isRegularFile(gzFile)) {
        if (file)
            file.close();
        file = gzFile;
        gzip = true;
    } else {
        if (gzFile)
            gzFile.close();
        if (!isRegularFile(file))
            file = LittleFS.open(path, "r");
    }

    if (!isRegularFile(file))
    {
        if (file)
            file.close();

        Serial.printf("[HTTPS] 404: %s", path.c_str());

        if (path.startsWith("/document/") && path.indexOf("/ps5") >= 0)
        {
            Serial.printf(" | Redirect: %s -> %s\n", path.c_str(), PORTAL_REDIRECT_URL);

            httpd_resp_set_status(req, "302 Found");
            httpd_resp_set_hdr(req, "Location", PORTAL_REDIRECT_URL);
            httpd_resp_send(req, nullptr, 0);
        }
        else
        {
            Serial.print("\n");

            httpd_resp_set_status(req, "404 Not Found");
            httpd_resp_set_type(req, "text/plain");
            httpd_resp_send(req, "404 Not Found", HTTPD_RESP_USE_STRLEN);
        }
/*
        Serial.printf("[HTTPS] 302: %s\n", path.c_str());
        httpd_resp_set_status(req, "302 Found");
        httpd_resp_set_hdr(req, "Location", PORTAL_REDIRECT_URL);
        httpd_resp_set_hdr(req, "Cache-Control", "no-store");
        httpd_resp_send(req, nullptr, 0);
*/
        return ESP_OK;
    }

    if (gzip) {
        httpd_resp_set_hdr(req, "Content-Encoding", "gzip");
    }

    httpd_resp_set_type(req, getMimeType(path).c_str());

    char buffer[1024];

    while (file.available())
    {
        size_t len = file.readBytes(buffer, sizeof(buffer));

        if (httpd_resp_send_chunk(req, buffer, len) != ESP_OK)
        {
            file.close();
            return ESP_FAIL;
        }
    }

    file.close();

    httpd_resp_send_chunk(req, NULL, 0);
    logHeap("HTTPS file end");

    return ESP_OK;
}

static esp_err_t httpsFixedUrlHandler(httpd_req_t *req)
{
    logHeap("HTTPS fixed URL");
    setHttpsNoCacheHeaders(req);

    String uri = req->uri;

    if (uri == "/generate_204" || uri == "/gen_204")
    {
        httpd_resp_set_status(req, "204 No Content");
        return httpd_resp_send(req, nullptr, 0);
    }

    if (uri == "/hotspot-detect.html")
        httpd_resp_set_type(req, "text/html");
    else
        httpd_resp_set_type(req, "text/plain");

    if (uri == "/connecttest.txt")
        return httpd_resp_send(req, "Microsoft Connect Test", HTTPD_RESP_USE_STRLEN);

    if (uri == "/ncsi.txt")
        return httpd_resp_send(req, "Microsoft NCSI", HTTPD_RESP_USE_STRLEN);

    return httpd_resp_send(req, "Success", HTTPD_RESP_USE_STRLEN);
}

static esp_err_t httpsRemoteLogHandler(httpd_req_t *req)
{
    Serial.printf(
        "[HTTPS REMOTE LOG] uri=%s content_len=%d\n",
        req->uri,
        req->content_len
    );
    Serial.print("[HTTPS REMOTE LOG BODY] ");

    char buffer[1024];
    int remaining = req->content_len;

    while (remaining > 0)
    {
        int len = httpd_req_recv(
            req,
            buffer,
            min(remaining, (int)sizeof(buffer))
        );

        if (len <= 0)
        {
            if (len == HTTPD_SOCK_ERR_TIMEOUT)
                continue;

            Serial.println("\n[HTTPS REMOTE LOG] receive failed");
            return ESP_FAIL;
        }

        Serial.write((const uint8_t *)buffer, len);
        remaining -= len;
    }

    Serial.println();
    setHttpsNoCacheHeaders(req);
    httpd_resp_set_type(req, "text/plain");
    return httpd_resp_send(req, "OK", HTTPD_RESP_USE_STRLEN);
}

static esp_err_t httpsNetworkTestHandler(httpd_req_t *req)
{
    logHeap("HTTPS network test");

    Serial.printf(
        "[HTTPS %s] uri=%s content_len=%d\n",
        req->method == HTTP_GET ? "GET" : "POST",
        req->uri,
        req->content_len
    );

    char buffer[1024];
    int remaining = req->content_len;

    while (remaining > 0)
    {
        int len = httpd_req_recv(
            req,
            buffer,
            min(remaining, (int)sizeof(buffer))
        );

        if (len <= 0)
        {
            if (len == HTTPD_SOCK_ERR_TIMEOUT)
                continue;

            return ESP_FAIL;
        }

        remaining -= len;
    }

    setHttpsNoCacheHeaders(req);
    httpd_resp_set_type(req, "text/plain");

    return httpd_resp_send(
        req,
        "OK",
        HTTPD_RESP_USE_STRLEN
    );
}

bool setupHttpsServer()
{
    httpd_ssl_config_t config = HTTPD_SSL_CONFIG_DEFAULT();

    config.transport_mode = HTTPD_SSL_TRANSPORT_SECURE;
    config.port_secure = 443;

    config.cacert_pem = server_crt;
    config.cacert_len = server_crt_len;

    config.prvtkey_pem = server_key;
    config.prvtkey_len = server_key_len;

    config.httpd.uri_match_fn = httpd_uri_match_wildcard;
    config.httpd.max_uri_handlers = 12;
    // config.httpd.max_open_sockets = 2;
    // config.httpd.backlog_conn = 2;

    Serial.printf(
        "cert len: %u, last: %02X\n",
        (unsigned)server_crt_len,
        server_crt[server_crt_len - 1]
    );

    Serial.printf(
        "key len: %u, last: %02X\n",
        (unsigned)server_key_len,
        server_key[server_key_len - 1]
    );

    Serial.println("Starting httpd_ssl_start...");

    esp_err_t err = httpd_ssl_start(
        &httpsServer,
        &config
    );

    if (err != ESP_OK) {
        Serial.printf(
            "HTTPS start failed: %s\n",
            esp_err_to_name(err)
        );

        return false;
    }

    Serial.println("HTTPS socket started");

    httpd_uri_t netstart_uri = {
        .uri       = "/netstart/icst",
        .method    = HTTP_GET,
        .handler   = httpsFixedUrlHandler,
        .user_ctx  = NULL
    };

    httpd_uri_t generate_uri = {
        .uri       = "/generate_204",
        .method    = HTTP_GET,
        .handler   = httpsFixedUrlHandler,
        .user_ctx  = NULL
    };

    httpd_uri_t gen_uri = {
        .uri       = "/gen_204",
        .method    = HTTP_GET,
        .handler   = httpsFixedUrlHandler,
        .user_ctx  = NULL
    };

    httpd_uri_t hotspot_uri = {
        .uri       = "/hotspot-detect.html",
        .method    = HTTP_GET,
        .handler   = httpsFixedUrlHandler,
        .user_ctx  = NULL
    };

    httpd_uri_t connecttest_uri = {
        .uri       = "/connecttest.txt",
        .method    = HTTP_GET,
        .handler   = httpsFixedUrlHandler,
        .user_ctx  = NULL
    };

    httpd_uri_t redirect_uri = {
        .uri       = "/redirect",
        .method    = HTTP_GET,
        .handler   = httpsFixedUrlHandler,
        .user_ctx  = NULL
    };

    httpd_uri_t ncsi_uri = {
        .uri       = "/ncsi.txt",
        .method    = HTTP_GET,
        .handler   = httpsFixedUrlHandler,
        .user_ctx  = NULL
    };

    httpd_uri_t post_uri = {
        .uri       = "/networktest/*",
        .method    = HTTP_POST,
        .handler   = httpsNetworkTestHandler,
        .user_ctx  = NULL
    };

    httpd_uri_t networktest_get_uri = {
        .uri       = "/networktest/*",
        .method    = HTTP_GET,
        .handler   = httpsNetworkTestHandler,
        .user_ctx  = NULL
    };

    httpd_uri_t remote_log_uri = {
        .uri       = "/__poops_log",
        .method    = HTTP_POST,
        .handler   = httpsRemoteLogHandler,
        .user_ctx  = NULL
    };

    httpd_uri_t file_uri = {
        .uri       = "/*",
        .method    = HTTP_GET,
        .handler   = httpsFileHandler,
        .user_ctx  = NULL
    };

    const httpd_uri_t *handlers[] = {
        &netstart_uri,
        &generate_uri,
        &gen_uri,
        &hotspot_uri,
        &connecttest_uri,
        &redirect_uri,
        &ncsi_uri,
        &post_uri,
        &networktest_get_uri,
        // &remote_log_uri,
        &file_uri
    };

    for (size_t i = 0; i < sizeof(handlers) / sizeof(handlers[0]); i++)
    {
        err = httpd_register_uri_handler(httpsServer, handlers[i]);

        if (err != ESP_OK)
        {
            Serial.printf(
                "HTTPS route registration failed: method=%d uri=%s error=%s\n",
                handlers[i]->method,
                handlers[i]->uri,
                esp_err_to_name(err)
            );
            httpd_ssl_stop(httpsServer);
            httpsServer = NULL;
            return false;
        }
    }

    Serial.println("HTTPS: OK");

    return true;
}

void httpFileHandler()
{
    logHeap("HTTP file begin");
    logHttpRequest();

    String path = normalizePath(webServer.uri().c_str());

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

        if (path.startsWith("/document/") && path.indexOf("/ps5") >= 0)
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

    webServer.streamFile(file, contentType);

    file.close();
    logHeap("HTTP file end");
}

static void httpRemoteLogHandler()
{
    String body = webServer.arg("plain");
    Serial.printf(
        "[HTTP REMOTE LOG] uri=%s content_len=%u\n",
        webServer.uri().c_str(),
        (unsigned)body.length()
    );
    Serial.print("[HTTP REMOTE LOG BODY] ");
    Serial.println(body);

    setHttpNoCacheHeaders();
    webServer.send(200, "text/plain", "OK");
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

    // webServer.on("/__poops_log", HTTP_POST, httpRemoteLogHandler);

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

    Serial.println("Starting HTTPS Server");

    setupHttpsServer();

    Serial.println("READY");
}

void loop()
{
    dnsServer.processNextRequest();

    webServer.handleClient();

    delay(2);
}
