CLS
Start-Transcript -Path U:\NUVEM\LOGS\NUVEM_VMS_6_MESES.TXT
get-date -format F | add-content U:\NUVEM\VMS_6_MESES\VMS_6_MESES.txt
add-content  U:\NUVEM\VMS_6_MESES\VMS_6_MESES.txt "ACIMA.: INICIO"
#LOCAL DE ARMAZENAMENTO DIARIO COM INTERVALOS DE 7 DIAS
$TargetFolderClean = "U:\NUVEM\VMS_6_MESES"
#
#
#ENDEREÇOS A SEREM BACKPEADOS
$TARGUETS = "D:\VMS\SRVAD01", "D:\VMS\SRVADD01", "D:\VMS\SRVFL01"
#
#
#Pega a data do sistema e da um formato a ela 'permitido por ter o -uformat antes.
$data = Get-Date -uformat " - (%d-%m-%Y)"
#PEGA HORA DO BKP
$horario = Get-Date
$horas = $horario.Hour
$seraBkpeado = Get-Item -Path $TARGUETS
$unidadeBackup = "U:\NUVEM\VMS_6_MESES\" + "BACKUP AGENDADO" + $data + " " + $horas + " HORAS"

Function DeleteByDate{
#----Definindo os paramentros----#
#----Obtendo a data atual----#
$Now = Get-Date
$Days = "7" #----Intervalos em dias----#
$LastWrite = $Now.AddDays(-$Days)
#----Obtem os arquivos baseado na ultima modificação sofrida. #LastWriteTime# filtro e pasta especifica.
$Files = Get-ChildItem $TargetFolderClean -Recurse | where {$_.CreationTime -le "$LastWrite" }
foreach($File in $Files)
{
if($File -ne $null)
{
Write-host "Deletando... File $File" -BackgroundColor DarkRed
Remove-Item -Path $File -Force | Write-host "Deletando... File $File" -BackgroundColor DarkRed
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
#DeleteByDate
#DeleteEmptyFolders

Write-host "COPIANDO... $TARGUETS[0]" -BackgroundColor DarkRed
Copy-Item $TARGUETS[0] "$unidadeBackup\SRVAD01" -Recurse -Force -ErrorAction SilentlyContinue

Write-host "COPINADO...  $TARGUETS[1]" -BackgroundColor DarkRed
Copy-Item $TARGUETS[1] "$unidadeBackup\SRVADD01"  -Recurse -Force -ErrorAction SilentlyContinue

Write-host "COPIANDO... $TARGUETS[2]" -BackgroundColor DarkRed
Copy-Item $TARGUETS[2] "$unidadeBackup\SRVFL01"  -Recurse -Force -ErrorAction SilentlyContinue

#INICIA SERVIÇOS DO SQL APÓS BACKAUP TER SIDO EXECUTADO
<#Get-Service -ComputerName SRVADD01 -Name "MSSQL`$ADDSOFT" | Start-Service -Verbose
Get-Service -ComputerName SRVADD01 -Name "MSSQL`$ADDSOFT" | Start-Service -Verbose#>
get-date -format F | add-content U:\NUVEM\VMS_6_MESES\VMS_6_MESES.txt
add-content  U:\NUVEM\VMS_6_MESES\VMS_6_MESES.txt "ACIMA.: Fim "