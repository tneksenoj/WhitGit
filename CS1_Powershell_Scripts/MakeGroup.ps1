Function MakeGroup {  
[CmdletBinding(SupportsShouldProcess=$true)]
param( [string]$group_name, [string]$group_description, [switch]$reset )

    $Computer = $env:COMPUTERNAME
    $cn = [ADSI]”WinNT://$Computer”
    $remove_group_check = $True

    #$group = $cn.Children.Find($group_name, 'group') 2>&1 | Out-Null
    try { $cn.Children.Find($group_name, 'group') } catch { $remove_group_check = $False }
    if ( ! $remove_group_check -or $reset) {

        if ($remove_group_check) {
            $cn.Children.Remove($group) | Out-Null
        }

        $group = $cn.Create(“Group”,$group_name)

        $group.SetInfo()

        $group.Description  = "$group_description"

        $group.SetInfo() 
    }

}