<#
.SYNOPSIS
    本地打包 QTimer 为 Windows 可执行文件（构建参数与 GitHub Actions 一致）。

.DESCRIPTION
    1. 定位 Python 解释器（默认使用 .venv）并检查 PyInstaller
    2. 从 main.py 的 __version__ 生成 version.txt 版本资源
    3. 调用 PyInstaller 打包（默认单文件、无控制台）
    4. 校验产物并输出大小与 SHA-256

    产物默认位于 dist\QTimer.exe，可直接分发；无需目标机器安装 Python。

.PARAMETER PythonExe
    指定用于打包的 Python 解释器，默认 .venv\Scripts\python.exe。

.PARAMETER Onedir
    生成目录版（dist\QTimer\），启动更快、体积分散，便于排查缺库问题。

.PARAMETER NoVersionInfo
    跳过生成 version.txt，不向 EXE 写入版本/版权信息。

.EXAMPLE
    .\scripts\build.ps1

.EXAMPLE
    .\scripts\build.ps1 -Onedir
#>
[CmdletBinding()]
param(
    [string]$PythonExe = '',
    [switch]$Onedir,
    [switch]$NoVersionInfo
)

$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

# ---------- 1. 解释器 ----------
if (-not $PythonExe) {
    $venvPython = Join-Path $Root '.venv\Scripts\python.exe'
    if (Test-Path $venvPython) {
        $PythonExe = $venvPython
    }
    elseif (Get-Command python -ErrorAction SilentlyContinue) {
        $PythonExe = 'python'
    }
    else {
        throw '未找到 Python 解释器，请先运行 scripts\setup_env.ps1。'
    }
}

Write-Host "==> 使用解释器：$PythonExe" -ForegroundColor Cyan

& $PythonExe -c "import importlib.util, sys; sys.exit(0 if importlib.util.find_spec('PyInstaller') else 1)"
if ($LASTEXITCODE -ne 0) {
    throw '当前环境未安装 PyInstaller。请运行：.\.venv\Scripts\python.exe -m pip install -r requirements-dev.txt'
}

& $PythonExe -c "import importlib.util, sys; sys.exit(0 if importlib.util.find_spec('PySide6') else 1)"
if ($LASTEXITCODE -ne 0) {
    throw '当前环境缺少 PySide6。请运行：.\.venv\Scripts\python.exe -m pip install -r requirements-dev.txt'
}

# ---------- 2. 版本信息 ----------
$versionFile = Join-Path $Root 'version.txt'
if (-not $NoVersionInfo) {
    $genScript = Join-Path $Root 'scripts\gen_version_info.py'
    & $PythonExe $genScript --output $versionFile
    if ($LASTEXITCODE -ne 0) {
        throw '生成 version.txt 失败。'
    }
}

# ---------- 3. 打包 ----------
$pyiArgs = @()
if ($Onedir) {
    $pyiArgs += '-D'
}
else {
    $pyiArgs += '-F'
}
$pyiArgs += @('-w', '--clean', '--noconfirm', '-n', 'QTimer')

$iconFile = Join-Path $Root 'icon.ico'
if (Test-Path $iconFile) {
    $pyiArgs += "--icon=$iconFile"
}

if ((-not $NoVersionInfo) -and (Test-Path $versionFile)) {
    $pyiArgs += "--version-file=$versionFile"
}

$pyiArgs += (Join-Path $Root 'main.py')

Write-Host "==> PyInstaller $($pyiArgs -join ' ')" -ForegroundColor Cyan
& $PythonExe -m PyInstaller @pyiArgs
if ($LASTEXITCODE -ne 0) {
    throw 'PyInstaller 打包失败，请查看上方日志。'
}

# ---------- 4. 校验产物 ----------
if ($Onedir) {
    $artifact = Join-Path $Root 'dist\QTimer\QTimer.exe'
}
else {
    $artifact = Join-Path $Root 'dist\QTimer.exe'
}

if (-not (Test-Path $artifact)) {
    throw "打包命令已结束，但未找到产物：$artifact"
}

$item = Get-Item $artifact
$sizeMb = [math]::Round($item.Length / 1MB, 1)
$hash = (Get-FileHash -Path $artifact -Algorithm SHA256).Hash

Write-Host "`n打包完成" -ForegroundColor Green
Write-Host "  产物：$($item.FullName)"
Write-Host "  大小：$sizeMb MB"
Write-Host "  SHA256：$hash"
Write-Host "  提示：双击 EXE 即可运行；首次启动如遇杀毒软件拦截，可改用 -Onedir 目录版。" -ForegroundColor Gray
