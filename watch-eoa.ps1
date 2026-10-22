# Cursor-Type EoA 守护进程（随登录自启，隐藏运行）
# 作用：设置->辅助功能->鼠标指针->大小 滑块每次变动时，Windows 会用内置 aero
# 源重新生成 %LocalAppData%\Microsoft\Windows\Cursors\*_eoa.cur 并把光标方案
# 重定向过去，导致主题丢失。本脚本：
#   1. 监听 eoa 目录，文件一被重新生成就用主题版覆盖回去；
#   2. 每 3 秒自检 HKCU 光标方案：指到 eoa 但内容不是主题版 -> 覆盖；
#      指到既非主题也非 eoa 的第三方值（如滑块归零重置）-> 重新应用主题方案。
# 指针大小的调整不受影响（eoa 文件内置 48/72/96/144/192 五档，系统按滑块取值）。
$ErrorActionPreference = "SilentlyContinue"

$dst      = Join-Path $env:USERPROFILE "Cursors"
$payload  = Join-Path $dst "eoa"
$eoaDir   = Join-Path $env:LOCALAPPDATA "Microsoft\Windows\Cursors"

Add-Type 'using System; using System.Runtime.InteropServices; public class CW { [DllImport("user32.dll")] public static extern bool SystemParametersInfo(int a, int b, IntPtr c, int d); }'

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

function Reload-Cursors {
    [void][CW]::SystemParametersInfo(0x0057, 0, [IntPtr]::Zero, 0)
}

function Apply-Eoa {
    if (-not (Test-Path $eoaDir)) { return }
    Copy-Item (Join-Path $payload "*.cur") $eoaDir -Force
    Reload-Cursors
}

function Apply-Scheme {
    foreach ($k in $map.Keys) {
        reg add "HKCU\Control Panel\Cursors" /v $k /t REG_EXPAND_SZ /d $map[$k] /f | Out-Null
    }
    reg add "HKCU\Control Panel\Cursors" /v "Scheme Source" /t REG_DWORD /d 2 /f | Out-Null
    Reload-Cursors
}

function Eoa-IsThemed {
    $live = Join-Path $eoaDir "arrow_eoa.cur"
    $ref  = Join-Path $payload "arrow_eoa.cur"
    if (-not (Test-Path $live)) { return $false }
    return ((Get-FileHash $live -Algorithm MD5).Hash -eq (Get-FileHash $ref -Algorithm MD5).Hash)
}

# 文件系统监听：eoa 文件被重新生成时触发（去抖 1.5 秒）
$script:pending = $false
$script:lastEvent = [DateTime]::MinValue
$watcher = $null

function Ensure-Watcher {
    if ($script:watcher -ne $null) { return }
    if (-not (Test-Path $eoaDir)) { return }
    $script:watcher = New-Object System.IO.FileSystemWatcher $eoaDir, "*_eoa.cur"
    $script:watcher.NotifyFilter = "LastWrite, FileName, Size"
    $action = { $script:pending = $true; $script:lastEvent = Get-Date }
    Register-ObjectEvent $script:watcher Changed -Action $action | Out-Null
    Register-ObjectEvent $script:watcher Created -Action $action | Out-Null
    Register-ObjectEvent $script:watcher Renamed -Action $action | Out-Null
    $script:watcher.EnableRaisingEvents = $true
}

Ensure-Watcher

while ($true) {
    Start-Sleep -Seconds 3
    Ensure-Watcher

    if ($script:pending -and ((Get-Date) - $script:lastEvent).TotalSeconds -gt 1.5) {
        $script:pending = $false
        Apply-Eoa
        continue
    }

    $arrow = (Get-ItemProperty "HKCU:\Control Panel\Cursors" -Name Arrow).Arrow
    if ($arrow -like "*kimi_arrow*") {
        continue                                   # 主题方案正常
    } elseif ($arrow -like "*_eoa.cur") {
        if (-not (Eoa-IsThemed)) { Apply-Eoa }     # eoa 被重新生成 -> 覆盖回主题版
    } else {
        Apply-Scheme                               # 方案被重置 -> 重新应用主题
        if (Test-Path $eoaDir) { Apply-Eoa }
    }
}
