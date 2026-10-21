# 移除 Cursor-Type 登录自动应用任务
#   powershell -NoProfile -ExecutionPolicy Bypass -File .\uninstall-autostart.ps1

Unregister-ScheduledTask -TaskName "CursorType-Apply" -Confirm:$false -ErrorAction SilentlyContinue
Write-Host "已移除计划任务 CursorType-Apply" -ForegroundColor Green
