# Cursor-Type 卸载：恢复 Windows Black 系统方案光标
#   powershell -NoProfile -ExecutionPolicy Bypass -File .\uninstall.ps1

Unregister-ScheduledTask -TaskName "CursorType-EoaWatch" -Confirm:$false -ErrorAction SilentlyContinue

$roles = "Arrow","Help","AppStarting","Wait","Crosshair","IBeam","NWPen","No","SizeNS","SizeWE","SizeNWSE","SizeNESW","SizeAll","UpArrow","Hand","Pin","Person"
foreach ($k in $roles) {
    reg delete "HKCU\Control Panel\Cursors" /v $k /f 2>$null | Out-Null
}
reg add "HKCU\Control Panel\Cursors" /v "Scheme Source" /t REG_DWORD /d 0 /f | Out-Null

Add-Type -ReferencedAssemblies System.Drawing 'using System; using System.Runtime.InteropServices; public class C { [DllImport("user32.dll")] public static extern bool SystemParametersInfo(int a, int b, IntPtr c, int d); }'
[void][C]::SystemParametersInfo(0x0057, 0, [IntPtr]::Zero, 0)

Write-Host ""
Write-Host "已恢复为 Windows 默认光标方案。" -ForegroundColor Green
Write-Host "光标文件仍保留在 %USERPROFILE%\Cursors，可手动删除。"
