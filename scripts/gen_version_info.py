#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""生成 PyInstaller 使用的 Windows 版本信息资源文件。

版本号唯一来源是 ``main.py`` 中的 ``__version__``，避免应用与 EXE 元数据不一致。

用法::

    python scripts/gen_version_info.py                 # 输出到项目根目录 version.txt
    python scripts/gen_version_info.py -o build/v.txt  # 指定输出路径
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MAIN_PY = ROOT / "main.py"
DEFAULT_OUTPUT = ROOT / "version.txt"

_META_FIELDS = (
    "__version__",
    "__app_name__",
    "__author__",
    "__company__",
    "__description__",
)
_META_PATTERNS = {
    name: re.compile(r'^{name}\s*=\s*"([^"]*)"'.format(name=re.escape(name)), re.MULTILINE)
    for name in _META_FIELDS
}


def read_metadata(main_py: Path) -> dict:
    """从 main.py 读取 __version__ 等元数据（只做正则解析，不执行代码）。"""
    try:
        source = main_py.read_text(encoding="utf-8")
    except OSError as exc:
        sys.exit("[gen_version_info] 无法读取 {}: {}".format(main_py, exc))

    meta = {}
    for name, pattern in _META_PATTERNS.items():
        match = pattern.search(source)
        meta[name] = match.group(1).strip() if match else ""

    if not meta["__version__"]:
        sys.exit("[gen_version_info] {} 中未找到 __version__".format(main_py))
    return meta


def to_version_tuple(version: str):
    """把 '1.4.0' / '1.4.0-beta' 之类的版本号转成 4 元组 (1, 4, 0, 0)。"""
    numbers = [int(part) for part in re.findall(r"\d+", version)[:4]]
    if not numbers:
        sys.exit("[gen_version_info] 无法解析版本号: {!r}".format(version))
    return tuple(numbers + [0] * (4 - len(numbers)))


def build_version_info(meta: dict) -> str:
    version = meta["__version__"]
    filevers = to_version_tuple(version)
    app = meta["__app_name__"] or "QTimer"
    company = meta["__company__"] or meta["__author__"] or app
    description = meta["__description__"] or app
    copyright_text = "Copyright (C) 2026 {}. GPL-3.0".format(company)

    return """# UTF-8
# 由 scripts/gen_version_info.py 自动生成，请勿手动修改。
VSVersionInfo(
  ffi=FixedFileInfo(
    filevers={filevers},
    prodvers={filevers},
    mask=0x3f,
    flags=0x0,
    OS=0x40004,
    fileType=0x1,
    subtype=0x0,
    date=(0, 0),
  ),
  kids=[
    StringFileInfo(
      [
        StringTable(
          '080404b0',
          [
            StringStruct('CompanyName', '{company}'),
            StringStruct('FileDescription', '{description}'),
            StringStruct('FileVersion', '{version}'),
            StringStruct('InternalName', '{app}'),
            StringStruct('LegalCopyright', '{copyright}'),
            StringStruct('OriginalFilename', '{app}.exe'),
            StringStruct('ProductName', '{app}'),
            StringStruct('ProductVersion', '{version}'),
          ],
        )
      ]
    ),
    VarFileInfo([VarStruct('Translation', [2052, 1200])]),
  ],
)
""".format(
        filevers=filevers,
        prodvers=filevers,
        company=company,
        description=description,
        version=version,
        app=app,
        copyright=copyright_text,
    )


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(description="生成 PyInstaller --version-file 资源文件")
    parser.add_argument("-o", "--output", default=str(DEFAULT_OUTPUT), help="输出文件路径（默认 version.txt）")
    parser.add_argument("--main-py", default=str(MAIN_PY), help="main.py 路径（默认项目根目录）")
    parser.add_argument("--print-version", action="store_true", help="只打印版本号后退出（供打包脚本使用）")
    args = parser.parse_args(argv)

    meta = read_metadata(Path(args.main_py))

    if args.print_version:
        print(meta["__version__"])
        return 0

    content = build_version_info(meta)

    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(content, encoding="utf-8", newline="\n")

    print("[gen_version_info] 已生成 {}（{} v{}）".format(output, meta["__app_name__"], meta["__version__"]))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
