# Cursor-Type 一键安装（无需管理员权限，只改当前用户 HKCU）
# 用法：右键 install.ps1 -> 使用 PowerShell 运行；或
#   powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$dst  = Join-Path $env:USERPROFILE "Cursors"

New-Item -ItemType Directory -Force (Join-Path $dst "Bibata") | Out-Null
Copy-Item (Join-Path $root "cursors\kimi_arrow_black.cur") $dst -Force
Copy-Item (Join-Path $root "cursors\kimi_arrow.cur")       $dst -Force
Copy-Item (Join-Path $root "cursors\bibata\*")             (Join-Path $dst "Bibata") -Force

$map = @{
    Arrow       = "$dst\kimi_arrow_black.cur"
    AppStarting = "$dst\Bibata\Work.ani"
    Wait        = "$dst\Bibata\Busy.ani"
    Hand        = "$dst\Bibata\Link.cur"
    IBeam       = "$dst\Bibata\Text.cur"
    Crosshair   = "$dst\Bibata\Cross.cur"
    Help        = "$dst\Bibata\Help.cur"
    NWPen       = "$dst\Bibata\Handwriting.cur"
    No          = "$dst\Bibata\Unavailable.cur"
    SizeNS      = "$dst\Bibata\Vert.cur"
    SizeWE      = "$dst\Bibata\Horz.cur"
    SizeNWSE    = "$dst\Bibata\Dgn1.cur"
    SizeNESW    = "$dst\Bibata\Dgn2.cur"
    SizeAll     = "$dst\Bibata\Move.cur"
    UpArrow     = "$dst\Bibata\Alternate.cur"
    Pin         = "$dst\Bibata\Pin.cur"
    Person      = "$dst\Bibata\Person.cur"
}
foreach ($k in $map.Keys) {
    reg add "HKCU\Control Panel\Cursors" /v $k /t REG_EXPAND_SZ /d $map[$k] /f | Out-Null
}
reg add "HKCU\Control Panel\Cursors" /v "Scheme Source" /t REG_DWORD /d 2 /f | Out-Null

Add-Type -ReferencedAssemblies System.Drawing 'using System; using System.Runtime.InteropServices; public class C { [DllImport("user32.dll")] public static extern bool SystemParametersInfo(int a, int b, IntPtr c, int d); }'
[void][C]::SystemParametersInfo(0x0057, 0, [IntPtr]::Zero, 0)

Write-Host ""
Write-Host "Cursor-Type 安装完成，已立即生效。" -ForegroundColor Green
Write-Host "如需还原：运行 uninstall.ps1"
