# Epson iProjection - Instalacion silenciosa
# Deep Freeze Enterprise Custom Script

$installer = "$env:TEMP\iProj_2.22.exe"
$log = "C:\Logs\iProjection.log"

New-Item -ItemType Directory -Force -Path "C:\Logs" | Out-Null

Start-Process -FilePath $installer -ArgumentList "/quiet /norestart" -Wait

$app = Get-ItemProperty "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" |
       Where-Object { $_.DisplayName -like "*iProjection*" }

if ($app) {
    "OK: $($app.DisplayName) $($app.DisplayVersion)" | Out-File -FilePath $log -Encoding ASCII
} else {
    "FAIL: iProjection no encontrado tras la instalacion" | Out-File -FilePath $log -Encoding ASCII
}
