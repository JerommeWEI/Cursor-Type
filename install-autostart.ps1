# 注册登录时自动应用 Cursor-Type 的计划任务（防止系统更新/主题同步重置光标配置）
#   powershell -NoProfile -ExecutionPolicy Bypass -File .\install-autostart.ps1

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$install = Join-Path $root "install.ps1"

$action = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$install`""
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit ([TimeSpan]::FromMinutes(2))

Register-ScheduledTask -TaskName "CursorType-Apply" -Action $action -Trigger $trigger -Settings $settings -Force | Out-Null
Write-Host "已注册计划任务 CursorType-Apply（每次登录时自动应用光标主题）" -ForegroundColor Green
