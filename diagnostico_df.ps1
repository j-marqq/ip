# Diagnostico - Buscar donde Deep Freeze dejo el instalador

$log = "C:\Logs\diagnostico.log"
New-Item -ItemType Directory -Force -Path "C:\Logs" | Out-Null

$resultado = @()
$resultado += "TEMP sistema: $env:TEMP"
$resultado += "TEMP usuario: $env:USERPROFILE\AppData\Local\Temp"
$resultado += "Directorio actual: $(Get-Location)"
$resultado += "Usuario ejecutando: $env:USERNAME"
$resultado += ""
$resultado += "--- Archivos .exe en TEMP ---"
$resultado += Get-ChildItem "$env:TEMP\*.exe" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
$resultado += ""
$resultado += "--- Archivos .exe en C:\Windows\Temp ---"
$resultado += Get-ChildItem "C:\Windows\Temp\*.exe" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
$resultado += ""
$resultado += "--- Archivos .exe en directorio actual ---"
$resultado += Get-ChildItem ".\*.exe" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName

$resultado | Out-File -FilePath $log -Encoding ASCII
