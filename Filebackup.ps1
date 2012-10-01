add-pssnapin Microsoft.DataProtectionManager.PowerShell
$producttype = read-host "Type the Product Type. Like 'MD' 'PLESK' 'Host-in' 'China' without quotes"
$type = read-host "Input the type of backup. Like 'Web' 'db'"
$server= Read-host "Type the server NetBIOS name"
$path=read-host "Type the path or file to recover"
$sitename=read-host "Type the Site name"
$drive=$path.split("\")[0]
$item = $path.substring($path.lastIndexOf('\')+1)
$location = $path.substring(0,$path.lastIndexOf('\'))
$PG=Get-ProtectionGroup -DPMServerName $env:Computername | where {$_.friendlyname -like "$producttype"}
$ds = Get-Datasource $pg |  where {($_ -like "*$server*") -and ($_.type -like "*FileSystem*") -and ($_.name -like "*$drive*")}
$ds
$drive 
$item
$location
$from = Get-Date -f "23-MMMM-yyyy 00:01:00"
$to = Get-Date -f "dd-MMMM-yyyy HH:mm:ss"
$from
$to
$so=New-SearchOption -FromRecoveryPoint "$from" -ToRecoveryPoint "$to" -SearchDetail filesfolders -SearchType contains -Location $location -SearchString  "$item"
$ri=Get-RecoverableItem -Datasource $ds -SearchOption $so
$ri
#$ro = New-RecoveryOption  -TargetServer "dpm-dallas" -RecoveryLocation CopyToFolder -DestinationPath "C:\Users\administrator\Desktop"  -OverwriteType overwrite -RecoveryType Recover
$ro = New-RecoveryOption -TargetServer "dpm-dallas.public.directi.com" -RecoveryLocation copytofolder -FileSystem -AlternateLocation "C:\Users\administrator\Desktop" -OverwriteType overwrite -RestoreSecurity -RecoveryType Restore
$ro
$recoveryJob = Recover-RecoverableItem -RecoverableItem $ri -RecoveryOption $ro
#4.3 Wait till the recovery job completes

while (! $recoveryJob.hasCompleted )
{
   # Show a progress bar
   Write-Host "." -NoNewLine
   Start-Sleep 1
}

if($recoveryJob.Status -ne "Succeeded")
{
   Write-Host "Recovery failed"
}

else
{
   Write-Host "Recovery successful" 
}
