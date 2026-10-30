#!/usr/bin/env python3
"""Generate Studio Command Bar installers from the Luau sources in game/.

Fallback when "Insert from File" with the .rbxmx files does not work:
open View -> Command Bar in Studio, paste the whole content of one installer
file, press Enter, and repeat for the others. Each installer creates (or
updates) the folders and scripts it contains.

Output (run in this order):
  build/install_1_ReplicatedStorage.lua
  build/install_2_ServerScriptService.lua     (everything except Packages)
  build/install_3_StarterPlayerScripts.lua
  build/install_4_Packages.lua                (third-party ProfileStore; large, kept separate)
"""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
GAME = ROOT / "game"
BUILD = ROOT / "build"

SSS = 'game:GetService("ServerScriptService")'

# (output file, source dir, Lua expression for the parent, child names to skip)
TARGETS = [
    ("install_1_ReplicatedStorage.lua", GAME / "ReplicatedStorage",
     'game:GetService("ReplicatedStorage")', set()),
    ("install_2_ServerScriptService.lua", GAME / "ServerScriptService", SSS, {"Packages"}),
    ("install_3_StarterPlayerScripts.lua", GAME / "StarterPlayer" / "StarterPlayerScripts",
     'game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")', set()),
    ("install_4_Packages.lua", GAME / "ServerScriptService" / "Packages",
     f'{SSS}:FindFirstChild("Packages") or (function() local f = Instance.new("Folder"); '
     f'f.Name = "Packages"; f.Parent = {SSS}; return f end)()', set()),
]

HEADER = """-- Hatch a Dragon installer: paste this whole file into Studio's Command Bar
-- (View -> Command Bar) and press Enter. Safe to run again: it updates in place.
local function ensure(parent, className, name)
\tlocal existing = parent:FindFirstChild(name)
\tif existing and existing.ClassName == className then
\t\treturn existing
\tend
\tif existing then
\t\texisting:Destroy()
\tend
\tlocal instance = Instance.new(className)
\tinstance.Name = name
\tinstance.Parent = parent
\treturn instance
end
local function setSource(parent, className, name, source)
\tlocal script = ensure(parent, className, name)
\tscript.Source = source
end
local count = 0
"""


def classify(path: Path) -> tuple[str, str]:
    name = path.name
    if name.endswith(".server.luau"):
        return "Script", name[: -len(".server.luau")]
    if name.endswith(".client.luau"):
        return "LocalScript", name[: -len(".client.luau")]
    if name.endswith(".luau"):
        return "ModuleScript", name[: -len(".luau")]
    raise ValueError(f"Unsupported file: {path}")


def long_string(text: str) -> str:
    level = 1
    while f"]{'=' * level}]" in text:
        level += 1
    eq = "=" * level
    # A newline right after the opening bracket is dropped by Lua, so add one to keep line 1 intact.
    return f"[{eq}[\n{text}]{eq}]"


def emit(path: Path, parent_var: str, lines: list[str], counter: list[int], skip: set[str]) -> None:
    for child in sorted(path.iterdir()):
        if child.name in skip:
            continue
        if child.is_dir():
            counter[0] += 1
            var = f"folder{counter[0]}"
            lines.append(f'local {var} = ensure({parent_var}, "Folder", "{child.name}")')
            emit(child, var, lines, counter, set())
        elif child.suffix == ".luau":
            class_name, name = classify(child)
            source = child.read_text(encoding="utf-8")
            lines.append(f'setSource({parent_var}, "{class_name}", "{name}", {long_string(source)})')
            lines.append("count += 1")


def main() -> int:
    BUILD.mkdir(exist_ok=True)
    for file_name, source_dir, service_expr, skip in TARGETS:
        if not source_dir.is_dir():
            print(f"missing {source_dir}", file=sys.stderr)
            return 1
        lines = [HEADER, f"local root = {service_expr}"]
        emit(source_dir, "root", lines, [0], skip)
        lines.append(f'print(("[Installer] {source_dir.name}: %d scripts installed"):format(count))')
        lines.append('game:GetService("ChangeHistoryService"):SetWaypoint("Hatch a Dragon install")')
        (BUILD / file_name).write_text("\n".join(lines) + "\n", encoding="utf-8")
        print(f"wrote build/{file_name}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
