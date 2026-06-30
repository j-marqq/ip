# Epson iProjection - Instalacion silenciosa
# Deep Freeze Enterprise Custom Script

$url = "https://ftp.epson.com/drivers/iProj_2.22.exe"
$installer = "C:\Windows\Temp\iProj_2.22.exe"
$log = "C:\Logs\iProjection.log"

New-Item -ItemType Directory -Force -Path "C:\Logs" | Out-Null

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $url -OutFile $installer -UseBasicParsing

if (Test-Path $installer) {
    Start-Process -FilePath $installer -ArgumentList "/quiet /norestart" -Wait
    Remove-Item $installer -Force

    $app = Get-ItemProperty "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" |
           Where-Object { $_.DisplayName -like "*iProjection*" }

    if ($app) {
        "OK: $($app.DisplayName) $($app.DisplayVersion)" | Out-File -FilePath $log -Encoding ASCII
    } else {
        "FAIL: Instalador ejecutado pero iProjection no encontrado en registro" | Out-File -FilePath $log -Encoding ASCII
    }
} else {
    "FAIL: No se pudo descargar el instalador desde $url" | Out-File -FilePath $log -Encoding ASCII
}
