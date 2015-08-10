<#
.SYNOPSIS   
A tool to automatically map network drives.
    
.DESCRIPTION 
This script reads through the permissions of network drives, and if it sees the name of the currently logged-in user 
within the folder's explicitly permitted groups/users it maps that network drive for them (with an intelligent drive letter)	

.NOTES   
Name: Set-MappedNetworkDrives.ps1
Author: Clyde Miller 
Version: 1.2
DateCreated: 2015-07-24
DateModified: 2015-07-31

.LICENSE
MIT

.LINK
http://resnet.missouristate.edu
http://thatclyde.com
#>
#determining OS, in case we need to install the AD module
$OS = (Get-WmiObject Win32_OperatingSystem).name

if(Get-Module -ListAvailable | Where-Object Name -match ActiveDirectory) 
{ 
Import-Module -Name ActiveDirectory 
}  
elseif($OS -like "*Server 2012 R2*")
{
Write-Host "You need to install the RSAT tool. This script will try to do that and then resume in 90 seconds." -ForegroundColor Yellow
Invoke-Expression .\Get-RSAT.ps1
Start-Sleep -s 90
Import-Module -Name ActiveDirectory
}
elseif($OS -like "*Windows 8.1*")
{
Write-Host "You need to install the RSAT tool. This script will try to do that and then resume in 90 seconds." -ForegroundColor Yellow
Invoke-Expression .\Get-RSAT-Windows8.1.ps1
Start-Sleep -s 180
Import-Module -Name ActiveDirectory
}

else 
{ 
Write-Host "The Active Directory Module is not installed, so this will not be successful. Please download and install the appropriate RSAT package, then re-run this script." -ForegroundColor Yellow
Write-Host "Press enter to exit" -NoNewline
Read-Host " "
exit
}



#set the folders to be searched as a comma delimited list
$folders = "\\share\GDrive","\\share\HDrive"
#Find the id of the current user
$User = (Get-ADUser([Environment])::UserName | Select-Object name)


#turn off errors, because they will happen when it encounters old or non AD entries
$ErrorActionPreference = 'silentlycontinue'

#labelling the loop so that we can break out of it once the User is found - speeding up the script
:outer

Foreach ($folder in $folders)
{

#find the permissions for the specific folder, then for each group within that folder
Get-Acl $folder | Select-Object  -ExpandProperty Access | ForEach-Object {

$FolderSid = $_.IdentityReference.Translate([System.Security.Principal.SecurityIdentifier]).Value
$SIDs = Get-ADGroupMember $FolderSid -Recursive 

    #looking through each of the SIDs that have permission to view the share
    foreach ($SID in $SIDs)       
        {
        #translating the SID into the friendly name for comparison
        $SID = $SID | Select-Object name
        #comparing the names
        if ($SID -match $User)
            {
            #Reporting if a match was found
            Write-Host "Found a match in $folder - mapping it!" -ForegroundColor Green
                #these if statements strip out the appropriate letter out of the folder name so the various drives will be unique. 
                #then they create the mapped drive using that drive letter.
                if ($folder -eq "\\rlsmuseum\MUSEUM")
                    {
                    #Setting the folder letter, based off the first name of folder being shared - your environment will probably be different
                    $DriveName = "$($folder.Substring(8,1)):"
                    Net Use $DriveName $folder /Persistent:Yes
                    #New-PSDrive -Name $DriveName -PSProvider FileSystem -Root $folder -Persist
                    }
                    #If a drive has been mapped, this kicks the script out of the loop so it'll move on to the next folder
                    continue outer
          
            }
        else {}
        
        }
    }
}

#changing the Error action so they'll show up again for this computer
$ErrorActionPreference = 'continue' 
Write-Host "Press enter to exit" -ForegroundColor Yellow -NoNewline
Read-Host " "
exit
