#!/usr/bin/env python3

import argparse
from pathlib import Path


def c_array(name, path):
    data = path.read_bytes()
    values = ",".join(f"0x{byte:02x}" for byte in data + b"\0")
    return (
        f"static const uint8_t {name}[] = {{{values}}};\n"
        f"static const size_t {name}_len = sizeof({name});\n"
    )


parser = argparse.ArgumentParser(description="Embed a PEM certificate and key in a C header")
parser.add_argument("certificate", type=Path)
parser.add_argument("private_key", type=Path)
parser.add_argument("output", type=Path)
args = parser.parse_args()

content = (
    "#pragma once\n\n"
    "#include <stddef.h>\n"
    "#include <stdint.h>\n\n"
    + c_array("server_crt", args.certificate)
    + "\n"
    + c_array("server_key", args.private_key)
)
args.output.write_text(content, encoding="ascii")
