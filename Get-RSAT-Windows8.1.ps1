<#
.SYNOPSIS   
A tool to automatically install the required pre-requisites for Set-Mapped-NetworkDrives-NetUse.ps1 to work.

.DESCRIPTION 


.NOTES   
Name: Get-RSAT-Windows8.1.ps1
Author: Clyde Miller 
Version: 1.0
DateCreated: 2015-07-31

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
        # tried to elevate, did not work
    } 
    else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
}
Write-Host "This script will attempt to install the utility. Please click OK to install the Windows Update." -ForegroundColor Yellow
Start-Sleep -s 2
}

#You're now running with full privileges - presumably

.\ADUtilities\Windows8.1-KB2693643-x64.msu
