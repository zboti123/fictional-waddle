#!/usr/bin/env python3
"""Pack the Luau sources in game/ into .rbxmx model files for Roblox Studio.

Studio-only workflow: run this script (or use the committed files in build/),
then in Studio right-click the target service -> "Insert from File..." and pick
the matching .rbxmx file.

File naming:
  Name.server.luau -> Script
  Name.client.luau -> LocalScript
  Name.luau        -> ModuleScript
  directory        -> Folder

Output (one file per Studio service, containing that service's children):
  build/ReplicatedStorage.rbxmx      -> insert into ReplicatedStorage
  build/ServerScriptService.rbxmx    -> insert into ServerScriptService
  build/StarterPlayerScripts.rbxmx   -> insert into StarterPlayer > StarterPlayerScripts
"""

from __future__ import annotations

import itertools
import sys
from pathlib import Path
from xml.sax.saxutils import escape

ROOT = Path(__file__).resolve().parent.parent
GAME = ROOT / "game"
BUILD = ROOT / "build"

TARGETS = {
    "ReplicatedStorage.rbxmx": GAME / "ReplicatedStorage",
    "ServerScriptService.rbxmx": GAME / "ServerScriptService",
    "StarterPlayerScripts.rbxmx": GAME / "StarterPlayer" / "StarterPlayerScripts",
}

_referents = itertools.count()


def classify(path: Path) -> tuple[str, str]:
    name = path.name
    if name.endswith(".server.luau"):
        return "Script", name[: -len(".server.luau")]
    if name.endswith(".client.luau"):
        return "LocalScript", name[: -len(".client.luau")]
    if name.endswith(".luau"):
        return "ModuleScript", name[: -len(".luau")]
    raise ValueError(f"Unsupported file: {path}")


def cdata(source: str) -> str:
    # "]]>" cannot appear inside CDATA; split it across two sections if it ever does.
    return "<![CDATA[" + source.replace("]]>", "]]]]><![CDATA[>") + "]]>"


def item_xml(path: Path, indent: str) -> str:
    referent = f"RBX{next(_referents)}"
    if path.is_dir():
        children = "".join(
            item_xml(child, indent + "\t")
            for child in sorted(path.iterdir())
            if child.is_dir() or child.suffix == ".luau"
        )
        return (
            f'{indent}<Item class="Folder" referent="{referent}">\n'
            f"{indent}\t<Properties>\n"
            f'{indent}\t\t<string name="Name">{escape(path.name)}</string>\n'
            f"{indent}\t</Properties>\n"
            f"{children}"
            f"{indent}</Item>\n"
        )
    class_name, name = classify(path)
    source = path.read_text(encoding="utf-8")
    return (
        f'{indent}<Item class="{class_name}" referent="{referent}">\n'
        f"{indent}\t<Properties>\n"
        f'{indent}\t\t<string name="Name">{escape(name)}</string>\n'
        f'{indent}\t\t<ProtectedString name="Source">{cdata(source)}</ProtectedString>\n'
        f"{indent}\t</Properties>\n"
        f"{indent}</Item>\n"
    )


def build_file(source_dir: Path) -> str:
    items = "".join(
        item_xml(child, "\t")
        for child in sorted(source_dir.iterdir())
        if child.is_dir() or child.suffix == ".luau"
    )
    return (
        '<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" '
        'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
        'xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">\n'
        f"{items}"
        "</roblox>\n"
    )


def main() -> int:
    BUILD.mkdir(exist_ok=True)
    for file_name, source_dir in TARGETS.items():
        if not source_dir.is_dir():
            print(f"missing {source_dir}", file=sys.stderr)
            return 1
        (BUILD / file_name).write_text(build_file(source_dir), encoding="utf-8")
        print(f"wrote build/{file_name}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
