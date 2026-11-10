<#
.SYNOPSIS
    初始化 QTimer 本地开发环境：创建 .venv 虚拟环境并安装依赖。

.DESCRIPTION
    1. 检查 Python 解释器版本（PySide6 6.12 要求 Python 3.10 ~ 3.15）
    2. 在项目根目录创建 .venv 虚拟环境（已存在则复用）
    3. 升级 pip，并安装 requirements-dev.txt（含 PyInstaller 打包工具）
    4. 验证 PySide6 等依赖可正常导入

.PARAMETER PythonExe
    用于创建虚拟环境的 Python 解释器路径。
    默认依次尝试 py -3、python。

.PARAMETER Mirror
    下载依赖使用的 PyPI 镜像源：none（默认）/ tsinghua（清华）/ aliyun（阿里云）。
    仅作用于本次安装，不会修改全局 pip 配置。

.PARAMETER Runtime
    只安装运行时依赖（requirements.txt），跳过 PyInstaller。

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File scripts\setup_env.ps1

.EXAMPLE
    .\scripts\setup_env.ps1 -Mirror tsinghua
#>
[CmdletBinding()]
param(
    [string]$PythonExe = '',
    [ValidateSet('none', 'tsinghua', 'aliyun')]
    [string]$Mirror = 'none',
    [switch]$Runtime
)

$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $PSScriptRoot
$VenvDir = Join-Path $Root '.venv'
$VenvPython = Join-Path $VenvDir 'Scripts\python.exe'

function Write-Step {
    param([string]$Message)
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

function Write-Ok {
    param([string]$Message)
    Write-Host "    [OK] $Message" -ForegroundColor Green
}

Write-Step '1/4 检查 Python 解释器'

$PythonArgs = @()
if (-not $PythonExe) {
    if (Get-Command py -ErrorAction SilentlyContinue) {
        $PythonExe = 'py'
        $PythonArgs = @('-3')
    }
    elseif (Get-Command python -ErrorAction SilentlyContinue) {
        $PythonExe = 'python'
    }
    else {
        throw '未找到 Python。请先安装 Python 3.10+ 并勾选 "Add Python to PATH"：https://www.python.org/downloads/'
    }
}

$versionOutput = & $PythonExe @PythonArgs -c "import sys; print('%d.%d.%d' % sys.version_info[:3])"
if ($LASTEXITCODE -ne 0) {
    throw "无法运行 Python 解释器：$PythonExe $PythonArgs"
}
$versionParts = $versionOutput.Trim().Split('.')
$major = [int]$versionParts[0]
$minor = [int]$versionParts[1]
$pyVersion = "$major.$minor.$($versionParts[2])"

if ($major -lt 3 -or ($major -eq 3 -and $minor -lt 10)) {
    throw "当前 Python 版本为 $pyVersion，PySide6 6.12 至少需要 Python 3.10（推荐 3.11 ~ 3.14）。"
}
if ($major -gt 3 -or ($major -eq 3 -and $minor -gt 15)) {
    Write-Host "    [警告] Python $pyVersion 超出 PySide6 6.12 官方支持范围（3.10 ~ 3.15），可能安装失败。" -ForegroundColor Yellow
}
Write-Ok "Python $pyVersion（$PythonExe）"

Write-Step '2/4 创建虚拟环境 .venv'

if (Test-Path $VenvPython) {
    Write-Ok '.venv 已存在，直接复用'
}
else {
    & $PythonExe @PythonArgs -m venv $VenvDir
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path $VenvPython)) {
        throw '创建虚拟环境失败。请确认已安装 venv 模块（Debian/Ubuntu 需 apt install python3-venv）。'
    }
    Write-Ok "已创建 $VenvDir"
}

Write-Step '3/4 安装依赖'

$requireFile = Join-Path $Root 'requirements-dev.txt'
if ($Runtime) {
    $requireFile = Join-Path $Root 'requirements.txt'
}

$pipIndexArgs = @()
switch ($Mirror) {
    'tsinghua' { $pipIndexArgs = @('--index-url', 'https://pypi.tuna.tsinghua.edu.cn/simple') }
    'aliyun'   { $pipIndexArgs = @('--index-url', 'https://mirrors.aliyun.com/pypi/simple/') }
}

Write-Host "    依赖清单：$requireFile"
if ($pipIndexArgs.Count -gt 0) {
    Write-Host "    镜像源：$($pipIndexArgs[1])"
}

& $VenvPython -m pip install --upgrade pip @pipIndexArgs
if ($LASTEXITCODE -ne 0) {
    throw '升级 pip 失败，请检查网络或改用 -Mirror tsinghua。'
}

& $VenvPython -m pip install -r $requireFile @pipIndexArgs
if ($LASTEXITCODE -ne 0) {
    throw '安装依赖失败，请检查网络后重试（PySide6 首次下载约 200 MB）。'
}

Write-Step '4/4 验证环境'

$checkCode = @'
import sys
import PySide6
from PySide6 import QtCore, QtGui, QtWidgets, QtSvg

from importlib.metadata import version as pkg_version

print("    Python  : %d.%d.%d" % sys.version_info[:3])
print("    PySide6 : %s (Qt %s)" % (PySide6.__version__, QtCore.qVersion()))

def report(module_name, label, missing_hint):
    try:
        __import__(module_name)
    except Exception:
        print("    %s: 未安装（%s）" % (label, missing_hint))
        return
    try:
        resolved = pkg_version(module_name)
    except Exception:
        resolved = "已安装"
    print("    %s: %s" % (label, resolved))

report("keyboard", "keyboard", "将自动降级为 Qt 窗口快捷键")
report("PyInstaller", "PyInstaller", "无法打包 EXE")
'@

$checkCode | & $VenvPython -
if ($LASTEXITCODE -ne 0) {
    throw '环境验证失败：PySide6 无法正常导入，请检查安装日志。'
}

& $VenvPython -m pip check
if ($LASTEXITCODE -ne 0) {
    Write-Host '    [警告] 存在依赖冲突，请检查上面的 pip check 输出。' -ForegroundColor Yellow
}

Write-Host "`n环境已就绪。" -ForegroundColor Green
Write-Host '  运行程序：.\scripts\run.ps1' -ForegroundColor Gray
Write-Host '  打包 EXE：.\scripts\build.ps1' -ForegroundColor Gray
