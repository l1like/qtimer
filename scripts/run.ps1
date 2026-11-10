<#
.SYNOPSIS
    在本地虚拟环境中启动 QTimer（开发调试用）。

.DESCRIPTION
    优先使用项目根目录的 .venv 解释器运行 main.py。
    若尚未创建环境，会提示先执行 scripts\setup_env.ps1。

.PARAMETER NoWindow
    使用 pythonw.exe 启动，不显示黑色控制台窗口（更接近打包后的运行效果）。

.EXAMPLE
    .\scripts\run.ps1

.EXAMPLE
    .\scripts\run.ps1 -NoWindow
#>
[CmdletBinding()]
param(
    [switch]$NoWindow,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$AppArgs = @()
)

$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

$VenvPython = Join-Path $Root '.venv\Scripts\python.exe'
if (-not (Test-Path $VenvPython)) {
    throw '未找到 .venv 虚拟环境。请先运行：powershell -ExecutionPolicy Bypass -File scripts\setup_env.ps1'
}

$MainPy = Join-Path $Root 'main.py'
if (-not (Test-Path $MainPy)) {
    throw "未找到入口文件：$MainPy"
}

$exe = $VenvPython
if ($NoWindow) {
    $pythonw = Join-Path $Root '.venv\Scripts\pythonw.exe'
    if (Test-Path $pythonw) { $exe = $pythonw }
}

Write-Host "启动 QTimer：$exe main.py" -ForegroundColor Cyan
& $exe $MainPy @AppArgs
exit $LASTEXITCODE
