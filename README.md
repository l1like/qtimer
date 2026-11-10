# ⏱️ QTimer - 极简流线型桌面悬浮计时器

> **⚠️ 关于本仓库（请先阅读）**
>
> 本仓库是原项目 **[Qwejay/QTimer](https://github.com/Qwejay/QTimer)** 的 **macOS 打包版（非官方二次分发）**。
>
> - **原作者 / 版权持有人**：[QwejayHuang](https://github.com/Qwejay) · 原项目地址：<https://github.com/Qwejay/QTimer>
> - **本仓库只做一件事**：为 macOS 用户提供开箱即用的预编译安装包（`.dmg` / `.zip`），并补充 macOS 兼容性修复与打包脚本。**软件功能、界面与代码主体均来自原项目**，未做功能性改动或商业化。
> - **与原作者无关**：本仓库由第三方维护，与原作者无隶属、合作或背书关系，不代表原作者立场；使用中遇到问题请优先到原项目反馈。
> - **许可证**：原项目与本仓库均遵循 [GNU GPL v3.0](LICENSE)，分发时保留原始版权声明与许可证文本。
> - **侵权即删**：若原作者认为本仓库的存在或分发方式不妥，请通过 [Issues](https://github.com/l1like/qtimer/issues) 联系，**收到通知后 24 小时内删除仓库、Release 及全部预编译产物，并停止一切分发**。
> - **官方版本**：Windows 版请使用原项目官方发布：<https://github.com/Qwejay/QTimer/releases>

![Python Version](https://img.shields.io/badge/Python-3.10%20~%203.15-blue.svg)
![PyQt5](https://img.shields.io/badge/PyQt5-Supported-brightgreen.svg)
![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS-lightgrey.svg)
![High DPI](https://img.shields.io/badge/High%20DPI-4K%2F2K%20Ready-ff69b4.svg)
![Portable](https://img.shields.io/badge/Portable-Supported-orange.svg)

**QTimer** 是一款专为**说课、答辩、演讲、会议**等场景打造的桌面悬浮倒计时工具。它采用极简的无边框半透明设计，平时安静地悬浮在屏幕角落，鼠标悬停时如丝滑拉开的抽屉般展示控制面板。

---

### 📝 更新日志 (Changelog)

### [1.4.0] - 2026-08-26

#### 新增
- **自定义提示音效**：支持为“节点预警”与“环节结束”自定义选择本地音频文件（Windows 支持 WAV，macOS 支持 WAV / MP3 / AIFF），内置试听与一键重置功能。
- **窗口位置记忆**：支持自动保存与恢复浮窗在屏幕上的最后摆放位置，重启应用无需重新调整。
- **小时级时间显示**：倒计时/正计时时长超过 1 小时（≥ 3600s）时，自动切换为 `HH:MM:SS` 格式，并自适应扩展文本框宽度防止文字截断。

#### 改进
- **多显示器交互优化**：重构拖拽边界与吸附算法，智能识别当前鼠标所在屏幕（`screenAt`），大幅提升跨屏幕移动与边缘防越界体验。
- **全透明背景支持**：将背景透明度调节范围扩展至 0% ~ 100%，并对完全透明状态下的背景色渲染进行了容错处理。
- **视觉排版与投影**：为环节名称和时间文字增加微投影效果，优化控件垂直居中对齐与间距，文字显示更加立体清晰。

#### 修复
- **修复闪烁结束颜色还原**：优化预警闪烁停止（`stop_flash`）时的颜色刷新逻辑，确保预警状态平稳过渡。

## [1.3.3] - 2026-08-21

#### 改进
* **UI 适配**：优化多屏高分屏缩放，修复图标模糊与窗口抖动。
* **兼容性**：继续优化设置界面配色，保证文字显示清晰。
* **PPT 检测**：修复并增强了对 PowerPoint 和 WPS 幻灯片播放状态的识别。
* **稳定性**：重构配置加载逻辑，增加损坏文件拦截，提升运行可靠性。
* **细节微调**：微调计时区宽度，确保各类字体显示完整。

## [1.3.2.1] - 2026-08-13

#### 改进
* **修复Windows暗黑模式下显示问题**：修改UI样式以实现一致性和清晰度。感谢 @yu2n 的提交。

## [1.3.2] - 2026-08-05

#### 改进
* **全面迁移至 PySide6**：替换原 PyQt5 依赖，全面适配 PySide6 规范。
* **清理废弃特性**：移除了 PyQt5 时代的 HighDPI 手动缩放配置，改由 PySide6 原生托管。
* **PPT 演示检测优化**：
  * **响应更敏捷**：将 PPT 全屏放映的检测判定阈值从 3 次降至 2 次，缩短自动开始计时的延迟。
  * **兼容性增强**：扩充了放映窗口类名与标题的匹配规则，对 WPS 及其他演示软件的识别更精准。
* **单实例运行机制优化**：防止重复启动时发生异常。
* **设置窗口布局微调**：
  * 增大设置窗口默认尺寸（780x560）与侧边导航栏宽度（160px），提升显示效果。

---

## ✨ 核心特性

- 🎯 **无误差精准计时 (Drift-Free Engine)**
  - 彻底抛弃传统的“累加扣减”计时法。底层采用**绝对系统时间戳锚定**技术，即使你的电脑瞬间卡顿或 UI 线程阻塞，倒计时也绝对不会产生哪怕 1 秒的误差。
- 🎨 **自适应防挤压 UI (Canvas Masking)**
  - 首创的“底层画布隔离”机制确保文字与倒计时数字绝对不会发生重叠。配合 `QPropertyAnimation` 带来极致丝滑的折叠/展开动画。
- 🔄 **多环节无缝流转**
  - 支持自定义多个流程（如：说课 5 分钟 ➔ 答辩 2 分钟）。可开启**自动流转**模式，倒计时结束自动无缝衔接下一个环节。
- 🔔 **多线程智能提醒**
  - **原生系统音效**：支持 Windows (`winsound`) 和 macOS (`afplay`)，采用独立守护线程异步播放声音，绝对不卡主界面。支持全局声音一键总控。
  - **动态变色闪烁**：可自定义时间节点（如剩余 30 秒变黄，剩余 10 秒变红并伴随最后 10 秒倒数滴答声）。
- 🛡️ **焦点防抢夺与单例锁**
  - 引入 `Qt.WA_ShowWithoutActivating` 属性，计时器变色闪烁时**绝对处于静默状态**，绝不打断您在 Word/PPT 中的打字流。
  - 工业级 `QSharedMemory` 单例锁，彻底阻止程序多开导致的悬浮条重叠。
- 💾 **原子化保存与便携模式 (Portable)**
  - 配置默认保存在程序同级目录，方便打包放进 U 盘带走！具备**权限智能降级**功能，在 C 盘等无权限目录时自动降级保存至 User 目录，杜绝崩溃。
- ⌨️ **快捷键支持**
  - 支持自定义全局快捷键（播放/暂停、重置、上一环节、下一环节）。

---

## 🚀 快速上手 (Quick Start)

- **macOS 用户（Apple Silicon / Intel）**：下载本仓库的预编译安装包 —— [本仓库 Releases](https://github.com/l1like/qtimer/releases)（`QTimer_v*_arm64.dmg` / `QTimer_v*_x86_64.dmg`）
- **Windows 用户**：请使用原项目官方发布 —— [Qwejay/QTimer Releases](https://github.com/Qwejay/QTimer/releases)
- **源码与最新更新**：以原项目 [Qwejay/QTimer](https://github.com/Qwejay/QTimer) 为准

---

## 🛠️ 本地开发环境与打包 (Build from Source)

不想使用预编译版本、希望自行运行或二次开发时，按下面步骤操作。仓库已内置依赖清单与自动化脚本，**一条命令即可完成环境初始化**。

### 1. 环境要求

| 项目 | 要求 | 本项目验证环境 |
| --- | --- | --- |
| 操作系统 | Windows 10 / 11；macOS 14+（打包需在对应系统上进行） | Windows 11 |
| Python | **3.10 ~ 3.15**（PySide6 6.12 官方支持范围） | 3.14.7 |
| PySide6 | 6.10 及以上 | 6.12.0 |
| 磁盘空间 | 约 700 MB（虚拟环境 + PySide6） | — |

> 仅运行程序时无需 PyInstaller；需要生成 `QTimer.exe` 时再安装开发依赖。

### 2. 一键初始化环境（推荐）

```powershell
cd QTimer
powershell -ExecutionPolicy Bypass -File scripts\setup_env.ps1
```

脚本会自动完成：检查 Python 版本 → 创建 `.venv` 虚拟环境 → 升级 pip → 安装 `requirements-dev.txt` → 导入 PySide6 验证环境。

下载较慢时可指定国内镜像（仅本次生效，不修改全局 pip 配置）：

```powershell
powershell -ExecutionPolicy Bypass -File scripts\setup_env.ps1 -Mirror tsinghua   # 或 aliyun
```

### 3. 运行程序

```powershell
.\scripts\run.ps1              # 前台运行，保留控制台便于查看日志
.\scripts\run.ps1 -NoWindow    # 无控制台窗口运行（接近打包后的效果）
```

等价的手动命令：

```powershell
.\.venv\Scripts\python.exe main.py
```

### 4. 打包为可执行文件

```powershell
.\scripts\build.ps1            # 单文件版：dist\QTimer.exe
.\scripts\build.ps1 -Onedir    # 目录版：dist\QTimer\QTimer.exe（启动更快，便于排查缺库）
```

构建参数与 `.github/workflows/build.yml` 完全一致：`-F -w --clean --noconfirm -n QTimer --icon=icon.ico --version-file=version.txt`。

- `version.txt` 由 `scripts/gen_version_info.py` 自动从 `main.py` 的 `__version__` 生成，保证应用与 EXE 版本信息一致；发版时请一并提交。
- 产物为单个 EXE（本机实测约 47 MB），目标机器无需安装 Python，双击即可运行。

### 5. 打包为 macOS 应用（.app / .dmg）

> macOS 版**必须在 macOS 上打包**（PyInstaller 不支持交叉编译）。日常发版推荐直接交给 GitHub Actions 自动出包。

#### 方式一：GitHub Actions 自动出包（推荐）

推送 `v*` 标签（或在 Actions 页面手动触发 `workflow_dispatch`）即可：

```powershell
git tag v1.4.0
git push origin v1.4.0
```

workflow 会并行构建两个架构，并把产物附到 Release：

| 产物 | 适用机型 |
| --- | --- |
| `QTimer_v<版本>_arm64.dmg` / `.zip` | Apple Silicon（M1/M2/M3/M4…） |
| `QTimer_v<版本>_x86_64.dmg` / `.zip` | Intel Mac |

构建矩阵：`macos-26`（arm64）+ `macos-26-intel`（x86_64），Python 3.13，采用 `--onedir --windowed`（PyInstaller 官方推荐 macOS 用 onedir，而非 onefile）。

#### 方式二：在 Mac 本地打包

```bash
# 1) 环境（Python 3.10+；CI 使用 3.13）
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements-dev.txt

# 2) 打包：生成 dist/QTimer.app、QTimer_v<版本>_<架构>.zip、.dmg
bash scripts/build_macos.sh

# 可选：通用二进制（Intel + Apple Silicon 单包，需要 universal2 版 Python）
TARGET_ARCH=universal2 bash scripts/build_macos.sh

# 可选：使用 Developer ID 证书签名（正式分发 / 公证时需要）
CODESIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)" bash scripts/build_macos.sh
```

脚本流程：检查依赖 → 从 `main.py` 读取版本号 → PyInstaller（`--onedir --windowed --icon=icon.icns`）→ 写入 `Info.plist` 版本 → 重新签名 → 生成 `.zip`（`ditto` 保留符号链接与权限）与 `.dmg`（内含 Applications 快捷方式），最后打印产物大小。

本地产物 `dist/QTimer.app` 可直接双击运行；`.dmg` 可发给其他 Mac 安装。

#### macOS 版注意事项

- **最低系统版本：macOS 14（Sonoma）**。PySide6 6.12 的 macOS wheel 标签为 `macosx_14_0_universal2`，Qt 6.12 官方要求 macOS 14.4+；如需支持 macOS 13，请把 `requirements.txt` 中的 `PySide6` 降到 `6.11.3`（`macosx_13_0_universal2`）。
- **默认是 ad-hoc 签名**：PyInstaller 6 会自动做 ad-hoc 签名，本机运行没问题；但用户从网络下载后，Gatekeeper 会提示「无法验证开发者」，需在「系统设置 → 隐私与安全性」点 **仍要打开**，或执行 `xattr -dr com.apple.quarantine /Applications/QTimer.app`。
- **正式分发**建议走 Apple 公证：Developer ID Application 证书（`CODESIGN_IDENTITY`）签名 → `xcrun notarytool submit --wait` → `xcrun stapler staple`。注意 `.zip` 无法 staple，应分发公证后的 `.dmg`。
- **全局热键**：macOS 默认不安装 `keyboard`（其 macOS 后端依赖 PyObjC/Quartz，且需要「辅助功能」授权），因此自动降级为 Qt 窗口快捷键；如需全局热键可自行 `pip install keyboard pyobjc` 并在系统设置中授权。
- **功能差异**：PPT/WPS 全屏放映的自动开始/暂停检测是 Windows 专属功能（macOS 上该检测直接返回未激活），其余计时、提醒、样式功能两端一致。macOS 的默认中文字体自动切换为 `PingFang SC`。

### 6. 手动步骤（不使用脚本时）

```powershell
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install --upgrade pip
.\.venv\Scripts\python.exe -m pip install -r requirements-dev.txt
.\.venv\Scripts\python.exe main.py

# 打包
.\.venv\Scripts\python.exe scripts\gen_version_info.py --output version.txt
.\.venv\Scripts\python.exe -m PyInstaller -F -w --clean --noconfirm -n QTimer --icon=icon.ico --version-file=version.txt main.py
```

macOS 手动命令：

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements-dev.txt
python main.py

# 打包（等价于 scripts/build_macos.sh 的核心步骤）
python scripts/gen_version_info.py --print-version          # 取版本号
python -m PyInstaller --noconfirm --clean --windowed --onedir \
    --name QTimer --icon=icon.icns --osx-bundle-identifier com.qwejay.qtimer main.py
codesign --force --deep --sign - dist/QTimer.app
ditto -c -k --sequesterRsrc --keepParent dist/QTimer.app QTimer.zip
hdiutil create -volname "QTimer" -srcfolder dist/QTimer.app -ov -format UDZO QTimer.dmg
```

### 7. 目录结构

```
main.py                      # 程序全部代码（单文件）
requirements.txt             # 运行时依赖
requirements-dev.txt         # 开发/打包依赖（含 PyInstaller）
scripts/setup_env.ps1        # Windows：创建虚拟环境并安装依赖
scripts/run.ps1              # Windows：本地启动程序
scripts/build.ps1            # Windows：打包 EXE
scripts/build_macos.sh       # macOS：打包 .app / .zip / .dmg
scripts/gen_version_info.py  # 生成 Windows 版本资源 / 读取版本号
version.txt                  # Windows EXE 版本/版权信息（自动生成，需提交）
icon.ico                     # Windows 程序图标
icon.icns                    # macOS 程序图标
```

### 8. 常见问题 (FAQ)

**Q1：安装 PySide6 很慢或报 SSL 错误怎么办？**
使用镜像：`.\scripts\setup_env.ps1 -Mirror tsinghua`；PySide6 会连带下载 Addons / WebEngine 等组件（合计约 200 MB），网络中断时 pip 会自动断点续传，重新执行同一命令即可。

**Q2：可以只安装精简版 PySide6 吗？**
本项目仅使用 `QtCore / QtGui / QtWidgets / QtSvg`（都在 PySide6-Essentials 中），把 `requirements.txt` 里的 `PySide6` 换成 `PySide6-Essentials` 可显著减小体积；但为与 CI 保持一致，默认安装完整版 `PySide6`。

**Q3：配置文件保存在哪里？**
Qt 的 `QStandardPaths::AppConfigLocation`，即 Windows 为 `%LOCALAPPDATA%\QTimer\config.json`，macOS 为 `~/Library/Preferences/QTimer/config.json`。删除该文件即可恢复默认配置。

**Q4：没有安装 `keyboard` 模块会怎样？**
不影响运行。程序检测不到 `keyboard` 时会自动降级为 Qt 窗口快捷键（仅窗口聚焦时生效），并在控制台打印提示。

**Q5：运行脚本提示"禁止运行脚本"？**
用 `powershell -ExecutionPolicy Bypass -File scripts\setup_env.ps1` 执行，或先运行 `Set-ExecutionPolicy -Scope Process Bypass`。

**Q6：打包后的 EXE 被杀毒软件误报？**
PyInstaller 单文件包偶发误报属常见现象。可改用 `.\scripts\build.ps1 -Onedir` 目录版，或为 EXE 添加代码签名 / 向厂商提交误报申诉。

**Q7：如何在 PyCharm 中运行/调试？**
将 `Settings → Project → Python Interpreter` 指向项目根目录的 `.venv\Scripts\python.exe`（本仓库的 `.idea` 已配置该解释器），然后直接运行/调试 `main.py` 即可。

**Q8：macOS 版双击提示「已损坏，无法打开」怎么办？**
这是未公证应用的 Gatekeeper 提示。执行 `xattr -dr com.apple.quarantine /Applications/QTimer.app` 即可；或右键 App → 打开。若准备长期分发，建议按上文配置 Developer ID 签名 + 公证。

---
## 💖 赞助支持 (Sponsorship)

QTimer 是一款完全开源且免费的项目，由作者利用业余时间开发与维护。如果本项目帮助您提高了开发效率或解决了打包难题，欢迎通过以下方式对项目进行**自愿赞助**。您的支持将是本项目持续更新的重要动力：

- ⚡ **请作者喝奶茶**：[赞助支持 QTimer](https://www.ifdian.net/a/qwejay)（支持微信 / 支付宝）

> **赞助说明**：赞助完全出于自愿，属于对开源项目的无偿鼓励，不包含任何商业服务绑定或特定功能开发承诺。非常感谢每一位支持开源创作的朋友！

---

## 📄 开源协议 (License)

本项目基于 [GNU General Public License v3.0](LICENSE) 开源，允许在遵循协议条款的前提下自由分发、修改和二次开发。

> **版权归属**：QTimer 的著作权归原作者 **QwejayHuang** 所有。本仓库仅是其 **macOS 打包/二次分发版本**，在原项目基础上补充了 macOS 兼容性修复、打包脚本与 CI 工作流，未改变软件的授权方式，仍以 GPLv3 对外分发，并完整保留原版权声明与许可证文本。

> **侵权处理（Notice & Takedown）**：本仓库为个人非商业性质的分发，**若原作者或任何权利人认为本仓库、其 Release 产物或分发方式侵犯了您的权益，请通过 [Issues](https://github.com/l1like/qtimer/issues) 联系我们，我们将在收到通知后 24 小时内删除相关仓库、Release 及全部预编译产物，并停止一切分发**。在收到通知前，本仓库不对原作者的立场、支持或背书作任何暗示。

> **致谢**：感谢原作者 QwejayHuang 开源并持续维护 QTimer。

<p align="right">Copyright (C) 2026 QwejayHuang.</p>
