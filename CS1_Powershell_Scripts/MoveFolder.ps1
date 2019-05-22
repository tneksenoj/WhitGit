Function MoveFolder {  
[CmdletBinding(SupportsShouldProcess=$true)]
param( [string]$old_loc, [string]$newstudent, [string]$path )

	# Construct the name for the student's home folder and classes folder
	$istudent = $newstudent -match '.*([0-9][0-9])$'
    if ( $istudent ) {
         $newgrad_yearfolder = "$path\students\20" + $matches[1]
         $newgrad_yearshare  = "students\20" + $matches[1]
    } else {
         $newgrad_yearfolder = "$path\students\other"
         $newgrad_yearshare = "students\other"
    }  	
 
    # Set paths for student user 
	$newhomefolder = "$newgrad_yearfolder\$newstudent"
    $newstudentshare_unc = "\\" + "$share\$newgrad_yearshare\$newstudent"

    ###########################################################
    # Construct new home folder for student user if not existing 
    ##########################################################

	if ( Test-path "$old_loc\$newstudent" -PathType Any ) {
        if ( -not (Test-path $newgrad_yearfolder -PathType Any )  ) {
            New-Item $newgrad_yearfolder -type Directory  
        }
        Write-Verbose "Set permissions and move old folder for $newstudent"
        #Modify-ACL -Recurse -Inherit -Folder "$old_loc\$newstudent" 

        $robocmd = "robocopy $old_loc\$newstudent $newhomefolder /MT:8 /COPYALL /DCOPY:T /E /MOVE"
        Write-Verbose $robocmd
	    $result = cmd /c $robocmd
 <#
        if ( -not (Test-path $newhomefolder -PathType Any )  ) {
            Move-Item "$old_loc\$newstudent" "$newhomefolder"
        } else {
            Move-Item -Force "$old_loc\$newstudent\*" "$newhomefolder"
            $directoryInfo = Get-ChildItem "$old_loc\$newstudent" | Measure-Object
            if ( $directoryInfo.count -eq 0 ) { #Returns the count of all of the files in the directory
                # If the old folder is empty, remove it!
                Remove-Item "$old_loc\$newstudent"
            }
        }
#>
    }
} 

