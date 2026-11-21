#!/usr/bin/env python3
"""
从本机《战场兄弟》安装目录提取原版 UI 贴图，供 docs/ui-preview 下的 HTML 预览参考使用。

- 输出目录 docs/ui-preview/_vanilla/（已加入 .gitignore，原版美术资源不得提交到公开仓库）
- 游戏内 mod 直接用 coui://gfx/ui/skin/xxx.png 引用同名原版贴图即可，无需复制

用法：python tools/extract_vanilla_ui_ref.py [游戏根目录]
"""

import sys
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "docs" / "ui-preview" / "_vanilla"
DEFAULT_GAME = Path(r"F:\SteamLibrary\steamapps\common\Battle Brothers")

PREFIXES = (
    "gfx/ui/skin/",
    "gfx/ui/buttons/",
    "gfx/ui/items/slots/",
    "gfx/ui/perks/selection_frame.png",
    "gfx/fonts/free_universal/",
)


def want(name: str) -> bool:
    if name.endswith("/"):
        return False
    if name.startswith(PREFIXES):
        return True
    if name.startswith("gfx/ui/icons/") and name.count("/") == 3:
        return True
    if name.startswith("ui/extern/") and name.endswith(".png"):
        return True
    return False


def main() -> int:
    game = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_GAME
    dat = game / "data" / "data_001.dat"
    if not dat.exists():
        print(f"找不到 {dat}，请传入游戏根目录。")
        return 1
    count = 0
    with zipfile.ZipFile(dat) as z:
        for name in z.namelist():
            if want(name):
                dst = OUT / name
                dst.parent.mkdir(parents=True, exist_ok=True)
                dst.write_bytes(z.read(name))
                count += 1
    l10n = game / "data" / "mod_bbmod_zhcn.zip"
    if l10n.exists():
        with zipfile.ZipFile(l10n) as z:
            for name in z.namelist():
                if name.endswith(".ttf"):
                    dst = OUT / "fonts" / Path(name).name
                    dst.parent.mkdir(parents=True, exist_ok=True)
                    dst.write_bytes(z.read(name))
                    count += 1
    print(f"已提取 {count} 个文件到 {OUT}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
