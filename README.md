# Set-MappedNetworkDrives.ps1
Determines AD permissions on a list of network shares (even nested permissions), and if access has been granted, maps the drive.

It does require the RSAT tools. There are scripts to install the tools if they aren't already installed, but they are not particularly elegant. Installing it on your image prior to deploying would be the easiest way to resolve this.

