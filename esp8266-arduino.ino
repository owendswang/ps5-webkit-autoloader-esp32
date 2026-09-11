#include <Arduino.h>
#include <ESP8266WiFi.h>
#include <DNSServer.h>
#include <ESP8266WebServer.h>
#include <ESP8266WebServerSecure.h>
#include <LittleFS.h>
#include "server_certs.h"

static const char *AP_SSID = "ESP32_PORTAL";
static const char *AP_PASSWORD = "12345678";
static const char *PORTAL_REDIRECT_URL = "http://192.168.4.1/";
static const char *PAYLOAD_MIRROR_PREFIX = "/ps5-payloads-mirror/";
static const char *PAYLOAD_LOCAL_PREFIX = "/pldmrr/";
static const IPAddress AP_IP(192, 168, 4, 1);
static const IPAddress AP_GATEWAY(192, 168, 4, 1);
static const IPAddress AP_SUBNET(255, 255, 255, 0);
static const char *NO_CACHE_VALUE = "no-store, no-cache, must-revalidate, max-age=0";

DNSServer dnsServer;
ESP8266WebServer webServer(80);
BearSSL::ESP8266WebServerSecure httpsServer(443);

static void logHeap(const char *where) {
    Serial.printf("[HEAP] %s: free=%u\n", where, ESP.getFreeHeap());
}

static String normalizePath(const String &uri) {
    String path = uri;
    int q = path.indexOf('?');
    if (q >= 0) path = path.substring(0, q);
    if (!path.length()) path = "/";
    return path;
}

static String contentType(const String &path) {
    if (path.endsWith(".html") || path.endsWith(".htm")) return "text/html; charset=utf-8";
    if (path.endsWith(".css")) return "text/css";
    if (path.endsWith(".js") || path.endsWith(".mjs")) return "application/javascript";
    if (path.endsWith(".json")) return "application/json";
    if (path.endsWith(".png")) return "image/png";
    if (path.endsWith(".jpg") || path.endsWith(".jpeg")) return "image/jpeg";
    if (path.endsWith(".gif")) return "image/gif";
    if (path.endsWith(".svg")) return "image/svg+xml";
    if (path.endsWith(".ico")) return "image/x-icon";
    if (path.endsWith(".appcache") || path.endsWith(".manifest") || path.endsWith(".cache")) return "text/cache-manifest";
    if (path.endsWith(".woff")) return "font/woff";
    if (path.endsWith(".woff2")) return "font/woff2";
    return "application/octet-stream";
}

template <typename Server>
static void noCache(Server &server) {
    server.sendHeader("Cache-Control", NO_CACHE_VALUE);
    server.sendHeader("Pragma", "no-cache");
    server.sendHeader("Expires", "0");
}

template <typename Server>
static void logRequest(Server &server) {
    Serial.printf("[HTTP] %s %s", server.method() == HTTP_GET ? "GET" :
                  server.method() == HTTP_POST ? "POST" : "OTHER", server.uri().c_str());
    for (int i = 0; i < server.args(); i++)
        Serial.printf("%c%s=%s", i ? '&' : '?', server.argName(i).c_str(), server.arg(i).c_str());
    Serial.println();
}

template <typename Server>
static void fileHandler(Server &server) {
    logHeap("file begin");
    logRequest(server);
    String path = normalizePath(server.uri());

    if (path.startsWith("/networktest/")) {
        noCache(server);
        server.send(200, "text/plain", "OK");
        return;
    }

    if (path.startsWith(PAYLOAD_MIRROR_PREFIX)) {
        String original = path;
        path = String(PAYLOAD_LOCAL_PREFIX) + path.substring(strlen(PAYLOAD_MIRROR_PREFIX));
        Serial.printf("[HTTP] Rewrite: %s -> %s\n", original.c_str(), path.c_str());
    }
    if (path.endsWith("/")) path += "index.html";
    else if (!LittleFS.exists(path) && LittleFS.exists(path + "/index.html")) path += "/index.html";

    bool gzip = false;
    File file = LittleFS.open(path + ".gz", "r");
    if (file && !file.isDirectory()) {
        gzip = true;
    } else {
        if (file) file.close();
        file = LittleFS.open(path, "r");
    }
    if (!file || file.isDirectory()) {
        if (file) file.close();
        if (path.startsWith("/document/") && (path.indexOf("/ps5") >= 0 || path.indexOf("/ps4") >= 0)) {
            server.sendHeader("Location", PORTAL_REDIRECT_URL, true);
            server.send(302, "text/plain", "");
        } else server.send(404, "text/plain", "404 Not Found");
        return;
    }
    String type = contentType(path);

    if (gzip && type == "application/octet-stream")
        server.sendHeader("Content-Encoding", "gzip");

    server.streamFile(file, type);

    file.close();
    logHeap("file end");
}

template <typename Server>
static void remoteLog(Server &server) {
    String body = server.arg("plain");
    Serial.printf(
        "[REMOTE LOG] uri=%s content_len=%u\n",
        server.uri().c_str(),
        (unsigned)body.length()
    );
    Serial.print("[REMOTE LOG BODY] ");
    Serial.println(body);

    noCache(server);
    server.send(200, "text/plain", "OK");
}

template <typename Server>
static void setupRoutes(Server &server) {
    server.on("/generate_204", HTTP_GET, [&server]() { logRequest(server); noCache(server); server.send(204); });
    server.on("/gen_204", HTTP_GET, [&server]() { logRequest(server); noCache(server); server.send(204); });
    server.on("/hotspot-detect.html", HTTP_GET, [&server]() { logRequest(server); noCache(server); server.send(200, "text/html", "Success"); });
    server.on("/connecttest.txt", HTTP_GET, [&server]() { logRequest(server); noCache(server); server.send(200, "text/plain", "Microsoft Connect Test"); });
    server.on("/ncsi.txt", HTTP_GET, [&server]() { logRequest(server); noCache(server); server.send(200, "text/plain", "Microsoft NCSI"); });
    server.on("/redirect", HTTP_GET, [&server]() { logRequest(server); noCache(server); server.send(200, "text/plain", "Success"); });
    server.on("/netstart/icst", HTTP_GET, [&server]() { logRequest(server); noCache(server); server.send(200, "text/plain", "Success"); });
    // server.on("/__poops_log", HTTP_POST, [&server]() { remoteLog(server); });
    server.onNotFound([&server]() { fileHandler(server); });
    server.begin();
}

void setup() {
    Serial.begin(115200);
    Serial.setDebugOutput(false);
    delay(1000);

    Serial.println("\nBOOT ESP8266");
    Serial.printf("Core: %s, SDK: %s\n", ESP.getCoreVersion().c_str(), ESP.getSdkVersion());
    Serial.printf("Reset: %s\n", ESP.getResetReason().c_str());
    Serial.printf("Flash: configured=%u MB, detected=%u MB, CPU=%u MHz\n",
                  ESP.getFlashChipSize() / 1024 / 1024,
                  ESP.getFlashChipRealSize() / 1024 / 1024,
                  ESP.getCpuFreqMHz());

    if (!LittleFS.begin()) Serial.println("LittleFS: FAILED");
    else {
        FSInfo info;
        LittleFS.info(info);
        Serial.printf("LittleFS: OK, total=%u, used=%u bytes\n", info.totalBytes, info.usedBytes);
    }

    WiFi.persistent(false);
    WiFi.mode(WIFI_OFF);
    delay(200);
    WiFi.mode(WIFI_AP);

    Serial.printf("softAPConfig: %s\n", WiFi.softAPConfig(AP_IP, AP_GATEWAY, AP_SUBNET) ? "OK" : "FAILED");
    bool ap = WiFi.softAP(AP_SSID, AP_PASSWORD);
    Serial.printf("softAP: %s\n", ap ? "OK" : "FAILED");
    if (!ap) while (true) delay(1000);

    Serial.printf("AP IP: %s\n", WiFi.softAPIP().toString().c_str());
    Serial.printf("SSID: %s\n", WiFi.softAPSSID().c_str());
    Serial.printf("Channel: %d\n", WiFi.channel());
    Serial.printf("MAC: %s\n", WiFi.softAPmacAddress().c_str());

    Serial.printf("DNS: %s\n", dnsServer.start(53, "*", AP_IP) ? "OK" : "FAILED");

    Serial.println("Starting HTTP");
    setupRoutes(webServer);
    logHeap("HTTP ready");

    Serial.println("Starting HTTPS");
    static BearSSL::X509List serverCertificate((const char *)server_crt);
    static BearSSL::PrivateKey serverPrivateKey((const char *)server_key);
    httpsServer.getServer().setECCert(&serverCertificate, BR_KEYTYPE_KEYX | BR_KEYTYPE_SIGN, &serverPrivateKey);
    setupRoutes(httpsServer);
    logHeap("HTTPS ready");
    Serial.println("READY");
}

void loop() {
    dnsServer.processNextRequest();
    webServer.handleClient();
    httpsServer.handleClient();
    delay(2);
}
