$url = "https://ftp.epson.com/drivers/iProj_2.22.exe"
$installer = "C:\Windows\Temp\iProj_2.22.exe"
$log = "C:\Logs\iProjection.log"

New-Item -ItemType Directory -Force -Path "C:\Logs" | Out-Null

try {
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($url, $installer)
    "DESCARGA: OK - $((Get-Item $installer).Length) bytes" | Out-File $log -Encoding ASCII
} catch {
    "FAIL DESCARGA: $_" | Out-File $log -Encoding ASCII
    exit 1
}

if ((Get-Item $installer).Length -lt 1000000) {
    "FAIL: Archivo descargado muy pequeno, posiblemente corrupto" | Out-File $log -Append -Encoding ASCII
    exit 1
}

try {
    $proc = Start-Process -FilePath $installer -ArgumentList "/quiet /norestart" -Wait -PassThru
    "INSTALADOR: ExitCode $($proc.ExitCode)" | Out-File $log -Append -Encoding ASCII
} catch {
    "FAIL INSTALACION: $_" | Out-File $log -Append -Encoding ASCII
    exit 1
}

Remove-Item $installer -Force -ErrorAction SilentlyContinue

$app = Get-ItemProperty "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" |
       Where-Object { $_.DisplayName -like "*iProjection*" }

if ($app) {
    "OK: $($app.DisplayName) $($app.DisplayVersion)" | Out-File $log -Append -Encoding ASCII
} else {
    "FAIL: No encontrado en registro tras instalacion" | Out-File $log -Append -Encoding ASCII
}
