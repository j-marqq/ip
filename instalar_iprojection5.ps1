$url = "https://github.com/j-marqq/ip/releases/download/v2.22/iProj_2.22.1.exe"
$installer = "C:\Windows\Temp\iProj_2.22.exe"
$log = "C:\Logs\iProjection.log"

New-Item -ItemType Directory -Force -Path "C:\Logs" | Out-Null

# Descargar instalador
try {
    Import-Module BitsTransfer
    Start-BitsTransfer -Source $url -Destination $installer
    "DESCARGA: OK - $((Get-Item $installer).Length) bytes" | Out-File $log -Encoding ASCII
} catch {
    "FAIL DESCARGA: $_" | Out-File $log -Encoding ASCII
    exit 1
}

# Cargar ensamblado para SendKeys
Add-Type -AssemblyName Microsoft.VisualBasic
Add-Type -AssemblyName System.Windows.Forms

# Funcion para esperar ventana y enviar tecla
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

# Lanzar instalador
Start-Process -FilePath $installer
"INSTALADOR: Lanzado" | Out-File $log -Append -Encoding ASCII

Start-Sleep -Seconds 3

# Pantalla 1: "Epson Instalador" - boton Aceptar = Enter
EsperarYPresionar "Epson Instalador" "{ENTER}" 30
"CLICK: Aceptar inicial" | Out-File $log -Append -Encoding ASCII
Start-Sleep -Seconds 3

# Pantalla 2: Idioma - bajar hasta Espanol y Siguiente
# Espanol ya viene seleccionado por defecto, solo presionar Enter (Siguiente)
EsperarYPresionar "iProjection" "{ENTER}" 30
"CLICK: Idioma Siguiente" | Out-File $log -Append -Encoding ASCII
Start-Sleep -Seconds 3

# Pantalla 3: Bienvenida InstallShield - Siguiente
EsperarYPresionar "Instalacion" "{ENTER}" 30
"CLICK: Bienvenida Siguiente" | Out-File $log -Append -Encoding ASCII
Start-Sleep -Seconds 3

# Pantalla 4: Tipo edicion - Estandar ya seleccionado, Siguiente
EsperarYPresionar "Instalacion" "{ENTER}" 30
"CLICK: Edicion Siguiente" | Out-File $log -Append -Encoding ASCII
Start-Sleep -Seconds 3

# Pantalla 5: Licencia - Tab para llegar a SI, Enter
EsperarYPresionar "Instalacion" "{TAB}{ENTER}" 30
"CLICK: Licencia Si" | Out-File $log -Append -Encoding ASCII
Start-Sleep -Seconds 30

# Pantalla 6: Finalizar
EsperarYPresionar "Instalacion" "{ENTER}" 60
"CLICK: Finalizar" | Out-File $log -Append -Encoding ASCII
Start-Sleep -Seconds 5

Remove-Item $installer -Force -ErrorAction SilentlyContinue

# Verificar instalacion
$app = Get-ItemProperty "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" |
       Where-Object { $_.DisplayName -like "*iProjection*" }

if ($app) {
    "OK: $($app.DisplayName) $($app.DisplayVersion)" | Out-File $log -Append -Encoding ASCII
} else {
    "FAIL: No encontrado en registro" | Out-File $log -Append -Encoding ASCII
}
