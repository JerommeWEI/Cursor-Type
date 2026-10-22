# Cursor-Type 一键安装（无需管理员权限，只改当前用户 HKCU）
# 用法：右键 install.ps1 -> 使用 PowerShell 运行；或
#   powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$dst  = Join-Path $env:USERPROFILE "Cursors"

New-Item -ItemType Directory -Force (Join-Path $dst "Bibata") | Out-Null
New-Item -ItemType Directory -Force (Join-Path $dst "eoa")    | Out-Null
Copy-Item (Join-Path $root "cursors\kimi_arrow_*.cur")    $dst -Force
Copy-Item (Join-Path $root "cursors\bibata\*")             (Join-Path $dst "Bibata") -Force
Copy-Item (Join-Path $root "cursors\eoa\*.cur")            (Join-Path $dst "eoa") -Force
Copy-Item (Join-Path $root "watch-eoa.ps1")                $dst -Force

$map = @{
    Arrow       = "$dst\kimi_arrow_teal.cur"
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

# 注册命名方案，让经典"鼠标属性 -> 指针"对话框的方案下拉框能按名字选到本主题
#（现代"设置 -> 辅助功能"页的 4 个样式块为系统写死，任何自定义主题都无法出现在那里）
$schemeOrder = "Arrow","Help","AppStarting","Wait","Crosshair","IBeam","NWPen","No","SizeNS","SizeWE","SizeNWSE","SizeNESW","SizeAll","UpArrow","Hand","Pin","Person"
$schemePaths = ($schemeOrder | ForEach-Object { $map[$_] }) -join ","
New-Item -Path "HKCU:\Control Panel\Cursors\Schemes" -Force | Out-Null
reg add "HKCU\Control Panel\Cursors\Schemes" /v "Cursor-Type" /t REG_EXPAND_SZ /d $schemePaths /f | Out-Null

Add-Type -ReferencedAssemblies System.Drawing 'using System; using System.Runtime.InteropServices; public class C { [DllImport("user32.dll")] public static extern bool SystemParametersInfo(int a, int b, IntPtr c, int d); }'
[void][C]::SystemParametersInfo(0x0057, 0, [IntPtr]::Zero, 0)

# 辅助功能"鼠标指针大小"滑块会用内置 aero 源重建 *_eoa.cur 并抢占方案。
# 若该目录已存在（滑块被用过），立即用主题版覆盖，避免安装后仍显示默认样式。
$eoaDir = Join-Path $env:LOCALAPPDATA "Microsoft\Windows\Cursors"
if (Test-Path $eoaDir) {
    Copy-Item (Join-Path $dst "eoa\*.cur") $eoaDir -Force
    [void][C]::SystemParametersInfo(0x0057, 0, [IntPtr]::Zero, 0)
}

# 注册 EoA 守护任务：登录后常驻，滑块变动导致主题被抢时自动恢复
$watch = Join-Path $dst "watch-eoa.ps1"
$action = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$watch`""
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit ([TimeSpan]::Zero)
Register-ScheduledTask -TaskName "CursorType-EoaWatch" -Action $action -Trigger $trigger -Settings $settings -Force | Out-Null
# 本次会话立即启动（若尚未运行）
$running = Get-ScheduledTask -TaskName "CursorType-EoaWatch" | Select-Object -ExpandProperty State
if ($running -ne "Running") { Start-ScheduledTask -TaskName "CursorType-EoaWatch" }

Write-Host ""
Write-Host "Cursor-Type 安装完成，已立即生效。" -ForegroundColor Green
Write-Host "EoA 守护任务 CursorType-EoaWatch 已启动（辅助功能大小滑块不再顶掉主题）。"
Write-Host "如需还原：运行 uninstall.ps1"
