[CmdletBinding(SupportsShouldProcess=$true)]
param(  [string]$importcsvfile )

$students = Import-Csv $importcsvfile

$class_path = "C:\Share\classes\2017\jan\CS301-1\"
$web_path = "C:\Share\classes\2017\jan\CS301"

if ( -not (Test-path "$web_path" -PathType Any) ) {
    mkdir $web_path
}

ForEach ($student in $students) {
	# Construct student user name from CSV entry
    $newstudent = $student.UNAME
    $newpublic_html = $class_path + $newstudent + "\public_html"
    if ( -not (Test-path "$newpublic_html" -PathType Any) ) {
        mkdir $newpublic_html | Out-Null
    }

    $AccessRule = New-Object system.security.accesscontrol.filesystemaccessrule("IIS_IUSRS","ReadAndExecute","ContainerInherit, ObjectInherit","none","Allow")
    $ACL = Get-Acl $newpublic_html
    $ACL.SetAccessRule($AccessRule)
    Set-Acl $newpublic_html -AclObject $ACL
    $AccessRule = New-Object system.security.accesscontrol.filesystemaccessrule("IUSR","ReadAndExecute","ContainerInherit, ObjectInherit","none","Allow")
    $ACL = Get-Acl $newpublic_html
    $ACL.SetAccessRule($AccessRule)
    Set-Acl $newpublic_html -AclObject $ACL

    $mklinkcmd = "mklink /d " + "$web_path" + "\" + $newstudent + " " + "$newpublic_html"
    Write-Verbose $mklinkcmd
	$result = cmd /c $mklinkcmd 

    $web_link = "$web_path" + "\" + $newstudent

    $AccessRule = New-Object system.security.accesscontrol.filesystemaccessrule("IIS_IUSRS","ReadAndExecute","ContainerInherit, ObjectInherit","none","Allow")
    $ACL = Get-Acl $web_link
    $ACL.SetAccessRule($AccessRule)
    Set-Acl $web_link -AclObject $ACL
    $AccessRule = New-Object system.security.accesscontrol.filesystemaccessrule("IUSR","ReadAndExecute","ContainerInherit, ObjectInherit","none","Allow")
    $ACL = Get-Acl $web_link
    $ACL.SetAccessRule($AccessRule)
    Set-Acl $web_link -AclObject $ACL

}