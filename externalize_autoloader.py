#!/usr/bin/env python3
"""Extract embedded ELF/BIN files from the ESP32 autoloader's two HTML pages.

Usage: python3 externalize_autoloader.py [autoloader-directory]
Run after the installer/pointer have been adapted for ESP32 split AppCache.
Backups stay outside the web directory, so they are not packed into LittleFS.
"""

import argparse
import base64
import hashlib
import json
from pathlib import Path
import re
import sys


def js_json(value):
    # Match upstream tools/build_standalone.py and protect script closing tags.
    return json.dumps(value, ensure_ascii=False).replace("</", "<\\/")


def assignment(html, name, required=True):
    matches = list(re.finditer(r"^[ \t]*window\." + re.escape(name) + r"\s*=\s*", html, re.M))
    if not matches and not required:
        return None
    if len(matches) != 1:
        raise ValueError(f"expected exactly one window.{name} assignment")
    match = matches[0]
    value, end = json.JSONDecoder().raw_decode(html, match.end())
    tail = re.match(r"[ \t]*;[ \t]*(?:\r?\n|$)", html[end:])
    if not tail:
        raise ValueError(f"unexpected format after window.{name}")
    return match.start(), end + tail.end(), value


def verify(data, info, name):
    if (not isinstance(info, dict) or info.get("size") != len(data) or
            info.get("sha256") != hashlib.sha256(data).hexdigest()):
        raise ValueError(f"size/SHA-256 mismatch: {name}")


def resource_path(key):
    name = Path(key).name
    if name.startswith("kexp") and name.endswith(".bin"):
        return "shared/kexp-ps5.bin"
    if name.startswith("elfldr") and name.endswith(".elf"):
        return "shared/elfldr-ps5.elf"
    if name in ("autoload.elf", "autoloader.elf") or (
        name.startswith("ps5-unified-autoloader-") and name.endswith(".elf")
    ):
        return "payloads/autoloader.elf"
    raise ValueError(f"unrecognized embedded resource: {key}")


def convert_page(html, version_dir):
    base = "/app/" + version_dir.name + "/"
    embedded = assignment(html, "EMBEDDED_BINARIES", required=False)
    if embedded is None:
        # A repeated run verifies extracted files instead of rewriting the page.
        metadata = assignment(html, "EXTERNAL_BINARY_INFO")[2]
        files = {}
        for url, info in metadata.items():
            if not url.startswith(base) or ".." in Path(url).parts:
                raise ValueError(f"unexpected external resource URL: {url}")
            relative = url[len(base):]
            data = (version_dir / relative).read_bytes()
            verify(data, info, url)
            files[relative] = data
        if set(files) != {"shared/kexp-ps5.bin", "shared/elfldr-ps5.elf", "payloads/autoloader.elf"}:
            raise ValueError("expected exactly the three external ELF/BIN resources")
        return html, files

    old_info = assignment(html, "EMBEDDED_BINARY_INFO")
    files, urls, metadata = {}, {}, {}
    for key, encoded in embedded[2].items():
        relative = resource_path(key)
        if relative in files:
            raise ValueError(f"duplicate embedded resource for {relative}")
        data = base64.b64decode(encoded, validate=True)
        verify(data, old_info[2].get(key, {}), key)
        files[relative] = data
        urls[key] = base + relative
        metadata[urls[key]] = old_info[2][key]
    if set(files) != {"shared/kexp-ps5.bin", "shared/elfldr-ps5.elf", "payloads/autoloader.elf"}:
        raise ValueError("expected exactly the three embedded ELF/BIN resources")

    config = assignment(html, "LOADER_CONFIG", required=False)
    loader = dict(config[2]) if config else {}
    loader.update(KEXP_BIN=base + "shared/kexp-ps5.bin", ELFLDR_ELF=base + "shared/elfldr-ps5.elf")
    config_line = "  window.LOADER_CONFIG = " + js_json(loader) + ";\n"
    edits = [(embedded[0], embedded[1], "" if config else config_line)]
    if config:
        edits.append((config[0], config[1], config_line))
    edits.append((old_info[0], old_info[1], "  window.EXTERNAL_BINARY_INFO = " + js_json(metadata) + ";\n"))

    queue = assignment(html, "STANDALONE")
    changed_args = 0
    for payload in queue[2]["payloads"]:
        for index, arg in enumerate(payload.get("args", [])):
            if arg in urls:
                payload["args"][index] = urls[arg]
                changed_args += 1
    if changed_args != 1:
        raise ValueError("expected one autoload payload argument referencing the embedded ELF")
    edits.append((queue[0], queue[1], "  window.STANDALONE = " + js_json(queue[2]) + ";\n"))

    # No embedded table means native fetch stays intact. Suppress the upstream
    # standalone warning: these pages deliberately use external cached files.
    modules = assignment(html, "__modules")
    region = html[modules[0]:modules[1]]
    matches = list(re.finditer(r'"src/site\.js"\s*:\s*', region))
    if len(matches) != 1:
        raise ValueError("cannot locate the src/site.js module")
    start = modules[0] + matches[0].end()
    source, end = json.JSONDecoder().raw_decode(html, start)
    old = "} else if (standalone) {"
    if source.count(old) != 1:
        raise ValueError("unexpected inline-fetch setup in src/site.js")
    source = source.replace(old, "} else if (standalone && !window.EXTERNAL_BINARY_INFO) {")
    edits.append((start, end, js_json(source)))
    for start, end, replacement in sorted(edits, reverse=True):
        html = html[:start] + replacement + html[end:]
    return html, files


def update_manifest(text, base, resources):
    lines = text.splitlines(keepends=True)
    if not lines or lines[0].strip() != "CACHE MANIFEST":
        raise ValueError("invalid AppCache manifest")
    marker = base + "__complete__"
    cached, marker_index, section = set(), None, "CACHE:"
    for index, line in enumerate(lines):
        value = line.strip()
        if value.endswith(":"):
            section = value
        elif section == "CACHE:":
            cached.add(value)
            if value == marker:
                if marker_index is not None:
                    raise ValueError("duplicate completion marker")
                marker_index = index
    if marker_index is None:
        raise ValueError("manifest must cache the current version's __complete__ marker")
    additions = [base + path + "\n" for path in sorted(resources) if base + path not in cached]
    lines[marker_index:marker_index] = additions
    return "".join(lines)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("directory", nargs="?", type=Path,
                        default=Path(__file__).resolve().parent / "autoloader")
    args = parser.parse_args()
    root = args.directory.resolve()
    pages = list((root / "app").glob("*/poops.html"))
    if len(pages) != 1:
        raise ValueError("expected exactly one app version containing poops.html")
    version_dir = pages[0].parent
    pages.append(version_dir / "relapse.html")
    changes, resources, before_size = {}, {}, 0
    for page in pages:
        original = page.read_bytes()
        before_size += len(original)
        converted, files = convert_page(original.decode("utf-8"), version_dir)
        for path, data in files.items():
            if path in resources and resources[path] != data:
                raise ValueError(f"the two pages disagree on {path}; no files changed")
            resources[path] = data
        changes[page] = converted.encode("utf-8")
    for path, data in resources.items():
        changes[version_dir / path] = data
        if (version_dir / path).exists():
            before_size += (version_dir / path).stat().st_size
    base = "/app/" + version_dir.name + "/"
    for name in ("slopkit.appcache", "relapse.appcache"):
        path = root / name
        changes[path] = update_manifest(path.read_bytes().decode("utf-8"), base, resources).encode("utf-8")

    # Validate everything above before any write. Keep backups OUTSIDE LittleFS.
    changes = {path: data for path, data in changes.items() if not path.exists() or path.read_bytes() != data}
    backup_dir = root.parent / (root.name + "-externalize-backup") / version_dir.name
    for path in changes:
        if path.exists():
            backup = backup_dir / path.relative_to(root)
            if not backup.exists():
                backup.parent.mkdir(parents=True, exist_ok=True)
                backup.write_bytes(path.read_bytes())
    for path, data in changes.items():
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(data)
        print(f"Updated: {path}")
    after_size = sum(page.stat().st_size for page in pages) + sum(len(data) for data in resources.values())
    print(f"HTML + ELF/BIN: {before_size:,} -> {after_size:,} bytes (resources shared by both pages)")
    if changes:
        print(f"Backups: {backup_dir}")
    else:
        print("Already converted; files verified, nothing changed.")


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, KeyError, TypeError) as error:
        print(f"Error: {error}", file=sys.stderr)
        sys.exit(1)
