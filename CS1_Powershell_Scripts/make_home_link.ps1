[CmdletBinding(SupportsShouldProcess=$true)]
param(  [string]$link, [string]$target, [string]$newstudent, [switch]$only_update_links )

function Test-ReparsePoint([string]$path) {
  $file = Get-Item $path -Force -ea 0
  return [bool]($file.Attributes -band [IO.FileAttributes]::ReparsePoint)
}

if ( -not (Get-Module -ListAvailable -Name activedirectory) ) {
    Import-Module activedirectory
}

. .\Modify-ACL.ps1

# check if the username is in the system or not
$UserObject = Get-ADUser -Filter {sAMAccountName -eq $newstudent }

if ( -not $only_update_links ) {

    # Set permissions for the student's share folder
    Modify-ACL -Folder $target -Clean -User "ADMIN\CSAdministrators"  -Owner "ADMIN\CSAdministrators"`
                -Permissions "FullControl","ContainerInherit, ObjectInherit","None", "Allow" 
    Modify-ACL -Folder $target -User "ADMIN\Domain Admins" `
                -Permissions "FullControl","ContainerInherit, ObjectInherit","None", "Allow"

    if ($UserObject) {
        Modify-ACL  -Folder $target -User "ADMIN\$newstudent" `
                    -Owner "ADMIN\CSAdministrators" `
                    -Permissions "Write, ReadAndExecute, Synchronize","None","None", "Allow"
        Modify-ACL -Folder $target -User "ADMIN\$newstudent" `
                    -Owner "ADMIN\CSAdministrators" `
                    -Permissions "Modify, Synchronize","ContainerInherit, ObjectInherit","InheritOnly", "Allow"
    } else {
        Write-Warning "$newstudent is not a user, set permissions to administrators only"
    }
}

# Add students to the home share folder
if ( Test-ReparsePoint -path  $link ) {
    $rmlinkcmd2 = "rmdir $link"  
    cmd /c $rmlinkcmd2
}
$mklinkcmd2 = "mklink /d $link $target" 
Write-Verbose $mklinkcmd2
$result = cmd /c $mklinkcmd2

# Set the ACL of the link to the same ACL as the file
$acl = Get-Acl $target
Set-Acl $link $acl


Write-Verbose "Processed $fullname"

