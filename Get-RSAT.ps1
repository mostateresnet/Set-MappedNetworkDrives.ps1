<#
.SYNOPSIS   
A tool to automatically install the RSAT modules so they'll work with powershell - needed before using Set-MappedNetworkDrives.ps1
    
.DESCRIPTION 
This script will install the RSAT module for computers running Windows Server 2012. 
Has better success when run locally v. from a network drive.

.NOTES   
Name: Get-RSAT.ps1
Author: Clyde Miller 
Version: 1.2
DateCreated: 2015-07-24
DateModified: 2015-07-30

.LICENSE
MIT

.LINK
http://resnet.missouristate.edu
http://thatclyde.com
#>
#Changing the script to run as an elevated user.
param([switch]$Elevated)

function Test-Admin {
  $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if ((Test-Admin) -eq $false)  {
    if ($elevated) 
    {
        # tried to elevate, did not work, aborting
    } 
    else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
}

Write-Host "Cannot Elevate you to an Admin. This script may fail." -ForegroundColor Yellow
Write-Host "If it fails, run Get-RSAT.ps1 from your desktop." -ForegroundColor Yellow
Start-Sleep -Seconds 2 
}

#You're now running with full privileges

#Static Environmental Variable
$PSDefaultParameterValues = @{"*-AD*:Server"='SGF.EDUBEAR.NET'}

#Importing the Active Directory module so these commands will work
Write-Host "Installing Active Directory Tools" -ForegroundColor Yellow
#Install-windowsfeature -name AD-Domain-Services –IncludeManagementTools
Add-WindowsFeature RSAT-AD-PowerShell 

