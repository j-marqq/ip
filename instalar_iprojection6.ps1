$url = "https://github.com/j-marqq/ip/releases/download/v2.22/iProj_2.22.1.exe"
$installer = "C:\Windows\Temp\iProj_2.22.exe"
$log = "C:\Logs\iProjection.log"

New-Item -ItemType Directory -Force -Path "C:\Logs" | Out-Null

# Descargar con WebClient usando proxy del sistema
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $wc = New-Object System.Net.WebClient
    $wc.Proxy = [System.Net.WebRequest]::GetSystemWebProxy()
    $wc.Proxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials
    $wc.Headers.Add("User-Agent", "Mozilla/5.0")
    $wc.DownloadFile($url, $installer)
    "DESCARGA: OK - $((Get-Item $installer).Length) bytes" | Out-File $log -Encoding ASCII
} catch {
    # Segundo intento con certutil (viene en todos los Windows)
    "WebClient fallo, intentando certutil..." | Out-File $log -Encoding ASCII
    $result = & certutil -urlcache -split -f $url $installer 2>&1
    if (Test-Path $installer) {
        "DESCARGA certutil: OK - $((Get-Item $installer).Length) bytes" | Out-File $log -Append -Encoding ASCII
    } else {
        "FAIL DESCARGA: $result" | Out-File $log -Append -Encoding ASCII
        exit 1
    }
}

if ((Get-Item $installer).Length -lt 1000000) {
    "FAIL: Archivo muy pequeno" | Out-File $log -Append -Encoding ASCII
    exit 1
}

Add-Type -AssemblyName Microsoft.VisualBasic
Add-Type -AssemblyName System.Windows.Forms

function EsperarYPresionar($titulo, $tecla, $segundos) {
    $limite = (Get-Date).AddSeconds($segundos)
    while ((Get-Date) -lt $limite) {
        $hwnd = (Get-Process | Where-Object { $_.MainWindowTitle -like "*$titulo*" } | Select-Object -First 1)
        if ($hwnd) {
            Start-Sleep -Milliseconds 800
            [Microsoft.VisualBasic.Interaction]::AppActivate($hwnd.Id)
            Start-Sleep -Milliseconds 500
            [System.Windows.Forms.SendKeys]::SendWait($tecla)
            return $true
        }
        Start-Sleep -Milliseconds 500
    }
    return $false
}

Start-Process -FilePath $installer
"INSTALADOR: Lanzado" | Out-File $log -Append -Encoding ASCII
Start-Sleep -Seconds 3

EsperarYPresionar "Epson Instalador" "{ENTER}" 30
"CLICK: Aceptar inicial" | Out-File $log -Append -Encoding ASCII
Start-Sleep -Seconds 3

EsperarYPresionar "iProjection" "{ENTER}" 30
"CLICK: Idioma Siguiente" | Out-File $log -Append -Encoding ASCII
Start-Sleep -Seconds 3

EsperarYPresionar "Instalacion" "{ENTER}" 30
"CLICK: Bienvenida Siguiente" | Out-File $log -Append -Encoding ASCII
Start-Sleep -Seconds 3

EsperarYPresionar "Instalacion" "{ENTER}" 30
"CLICK: Edicion Siguiente" | Out-File $log -Append -Encoding ASCII
Start-Sleep -Seconds 3

EsperarYPresionar "Instalacion" "{TAB}{ENTER}" 30
"CLICK: Licencia Si" | Out-File $log -Append -Encoding ASCII
Start-Sleep -Seconds 30

EsperarYPresionar "Instalacion" "{ENTER}" 60
"CLICK: Finalizar" | Out-File $log -Append -Encoding ASCII
Start-Sleep -Seconds 5

Remove-Item $installer -Force -ErrorAction SilentlyContinue

$app = Get-ItemProperty "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" |
       Where-Object { $_.DisplayName -like "*iProjection*" }

if ($app) {
    "OK: $($app.DisplayName) $($app.DisplayVersion)" | Out-File $log -Append -Encoding ASCII
} else {
    "FAIL: No encontrado en registro" | Out-File $log -Append -Encoding ASCII
}
