Start-Transcript -Path U:\NUVEM\LOGS\NUVEM_DIARIO.TXT
CLS
get-date -format F | add-content  U:\NUVEM\DIARIO\NUVEM_DIARIO.txt
add-content U:\NUVEM\DIARIO\NUVEM_DIARIO.txt "ACIMA.: INICIO"

#LOCAL DE ARMAZENAMENTO DIARIO COM INTERVALOS DE 7 DIAS
$TargetFolderClean = "U:\NUVEM\DIARIO"

#
#
#ENDEREÇOS A SEREM BACKPEADOS
$TARGUETS = "\\srvfl01\pastas$", "\\srvadd01\c$\AddsoftSQL", "\\srvadd01\SistemasAddSoft$"
#
#
#Pega a data do sistema e da um formato a ela 'permitido por ter o -uformat antes.
$data = Get-Date -uformat " - (%d-%m-%Y)"
#PEGA HORA DO BKP
$horario = Get-Date
$horas = $horario.Hour
$seraBkpeado = Get-Item -Path $TARGUETS
$unidadeBackup = "U:\NUVEM\DIARIO\" + "BACKUP AGENDADO" + $data + " " + $horas + " HORAS"

Function DeleteByDate{
#----Definindo os paramentros----#
#----Obtendo a data atual----#
$Now = Get-Date
$Days = "3" #----Intervalos em dias----#
$LastWrite = $Now.AddDays(-$Days)
#----Obtem os arquivos baseado na ultima modificação sofrida. #LastWriteTime# filtro e pasta especifica.
$Files = Get-ChildItem $TargetFolderClean -Recurse | where {$_.CreationTime -le "$LastWrite" }
foreach($File in $Files)
{
if($File -ne $null)
{
Write-host "Deletando... File $File" -BackgroundColor DarkRed
Remove-Item -Path $File.FullName -Force -Recurse -Confirm:$false
}
else
{
Write-Host "Não existem arquivos a serem deletados." -ForegroundColor Green

}
}
}
Function DeleteEmptyFolders{
$Empty = Get-ChildItem $TargetFolderClean -Directory -Recurse | Where-Object {(Get-ChildItem $_.FullName -File -Recurse -Force).Count -eq 0 }
foreach ($Dir in $Empty)
{
if (Test-Path $Dir.FullName)
{
write-host ("Removendo pastas Vazias..." + $Dir.FullName)
Remove-Item -LiteralPath $Dir.FullName -Recurse -Force
}
}
}
DeleteByDate
DeleteEmptyFolders

#MATA SERVIÇO DO SQL PARA EXECUTAR BACKUP
#Get-Service -ComputerName SRVADD01 -Name "MSSQL`$ADDSOFT" | Stop-Service -Verbose
#Get-Service -ComputerName SRVADD01 -Name "MSSQL`$ADDSOFT" | Stop-Service -Verbose
cls
#COPIANDO OS DADOS
Write-host "COPIANDO... " $TARGUETS[0] "PARA" "$unidadeBackup\PASTAS"  -BackgroundColor DarkRed
Copy-Item $TARGUETS[0] "$unidadeBackup\PASTAS" -Recurse -Force -ErrorAction SilentlyContinue

Write-host "COPIANDO... " $TARGUETS[1] "PARA" "$unidadeBackup\AddsoftSQL"  -BackgroundColor DarkRed
Copy-Item $TARGUETS[1] "$unidadeBackup\AddsoftSQL"  -Recurse -Force -ErrorAction SilentlyContinue

Write-host "COPIANDO... " $TARGUETS[2] "PARA" "$unidadeBackup\SistemasAddsoft"  -BackgroundColor DarkRed
Copy-Item $TARGUETS[2] "$unidadeBackup\SistemasAddsoft"  -Recurse -Force -ErrorAction SilentlyContinue

#INICIA SERVIÇOS DO SQL APÓS BACKAUP TER SIDO EXECUTADO
Get-Service -ComputerName SRVADD01 -Name "MSSQL`$ADDSOFT" | Start-Service -Verbose
Get-Service -ComputerName SRVADD01 -Name "MSSQL`$ADDSOFT" | Start-Service -Verbose
get-date -format F | add-content  U:\NUVEM\DIARIO\NUVEM_DIARIO.txt
add-content  U:\NUVEM\DIARIO\NUVEM_DIARIO.txt "ACIMA.: Fim "