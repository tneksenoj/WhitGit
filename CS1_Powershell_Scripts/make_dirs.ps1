[CmdletBinding(SupportsShouldProcess=$true)]
param(  [string]$importcsvfile, [string]$path="C:\Share", [string]$share="cs1", [switch]$only_update_links, [switch]$reset_home_folder_permissions )

# Example: .\make_dirs.ps1 -importcsvfile .\2017JanStudents.csv
# NOTE: at the start of new semester, be sure to delete the \\cs1\classes share since it will have symbolic links to classes for the semester.
#
# Sample entry in CSV file  follows. It is important to have the fields 
# 'Student ID'	'First Name'	'Last Name'	'Term'	'Section Name'	'Section Title'	'Whitworth Email'
# 9999999	Ciera	Aguilara	17/FA	CS-171-1	Computer Science I	ciera-agulara21@my.whitworth.edu



function Test-ReparsePoint([string]$path) {
  $file = Get-Item $path -Force -ea 0
  return [bool]($file.Attributes -band [IO.FileAttributes]::ReparsePoint)
}

Function NEW-SHARE( $Foldername, $Sharename ) {

    # Test for existence of folder, if not there then create it 
    # 
    IF (!(TEST-PATH $Foldername)) { 
        NEW-ITEM $Foldername -type Directory 
    }
    # check to make sure it isn’t already there 
    # if there, remove it if the argument DontRemoveOld is false
    $check_smb_output = ( Get-SMBShare -Name $Sharename 2>&1  )
    $check = (select-string -pattern "No MSFT_SMBShare objects found" -InputOBject $check_smb_output) 
    If ($check.count -eq 0) { 
        Remove-SmbShare -Force -Name $Sharename 
    }
    New-SmbShare -Name $Sharename -Path $Foldername -FolderEnumerationMode AccessBased
}

# Get active directory module
Import-Module activedirectory

# Load the Share setting ACL scripts
. .\Modify-CSShare-ACL.ps1  # Script for the root folder of the share
. .\Modify-ACL.ps1          # Script for student root folder and subfolders/files
. .\MakeGroup.ps1           # Script for creating grader group (still need to add grader's manually to these groups!)
. .\MoveFolder.ps1          # Script to move old folders from CS_DATA


Write-Verbose "IF THIS IS A NEW SEMESTER, NAVIGATE TO Server Manager\File and Storage Services\Shares and remove the classes share (NOT THE FOLDER!)"

$VerbosePreference = "Continue"

# Make the main SHARE root folder and set it's permissions
if ( -not (Test-path $path -PathType Any )  ) {
    $result = mkdir $path 
}

if ( -not (Test-path $path -PathType Any )  ) {
    mkdir $path
    Write-Verbose "Modifying the ACL for Root Folder"
    Modify-CSShare-ACL -Folder $path 
}

$csstudents_home_folder = "$path\home"
$csstudents_share_folder = "$path\students"
$newhomeshare = "home"
$newstudentshare ="students"

$students = Import-Csv $importcsvfile

ForEach ($student in $students) {

	# Construct student user name from CSV email entry
    #old csv format: $newstudent = $student.UNAME
    $newstudent = $student.'Whitworth Email'.Split("@")[0]

    # Add the student to the CS_Students Active Directory User Group
    Add-ADGroupMember "CS_Students" $newstudent
	
    # Construct the Class Name from the CSV entry
    if ( $student.'Section Name' ) {
	    #old csv format: $newclass = $student.DEPT+$student.CLASS+"-"+$student.SECTION
        $newclass = $student.'Section Name'
    } 

    # Extract the year and semester of registration from the student's information
    if ( $student.'Term' ) {
        $year,$semester = $student.'Term'.Split("/")
        $year = "20" + $year
        switch($semester) 
        {
            "FA" { $semester = "fall" }
            "JA" { $semester = "jan" }
            "SP" { $semester = "spring" }
        }
    }

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

    if ( -not $only_update_links -and (Test-path "$newhomefolder\$newclass" -PathType Any) ) {
        Write-Verbose "Class $newclass already configured for $newstudent. Skipping..."
        continue
    }

    ###########################################################
    # Construct home folder for student user if not existing 
    ###########################################################

    # check if the username is in the system or not
    $UserObject = Get-ADUser -Filter {sAMAccountName -eq $newstudent }

	if ( $reset_home_folder_permissions -or (-not (Test-path $newhomefolder -PathType Any ))  ) {

        if (-not (Test-path $newhomefolder -PathType Any )) {
		    mkdir $newhomefolder | Out-Null
        }

        # Set permissions for the student's home folder
        Modify-ACL -Clean -Folder $newhomefolder -User "ADMIN\CSAdministrators"  -Owner "ADMIN\CSAdministrators"`
                    -Permissions "FullControl","ContainerInherit, ObjectInherit","None", "Allow" 
        Modify-ACL -Folder $newhomefolder -User "ADMIN\Domain Admins" `
                    -Permissions "FullControl","ContainerInherit, ObjectInherit","None", "Allow"

        if ($UserObject) {
            Modify-ACL  -Folder $newhomefolder -User "ADMIN\$newstudent" `
                        -Owner "ADMIN\CSAdministrators" `
                        -Permissions "Write, ReadAndExecute, Synchronize","None","None", "Allow"
            Modify-ACL -Folder $newhomefolder -User "ADMIN\$newstudent" `
                        -Owner "ADMIN\CSAdministrators" `
                        -Permissions "Modify, Synchronize","ContainerInherit, ObjectInherit","InheritOnly", "Allow"
        } else {
            Write-Warning "$newstudent is not a user, set permissions to administrators only"
        }
    }
  
    # Make sure the share folder exists
	if ( -not (Test-path $csstudents_home_folder)  ) {
            
        Write-Verbose "Configuring home folder for $newstudent."
	    mkdir $csstudents_home_folder | Out-Null
    
        # Make the SHARE for home folders
        NEW-SHARE $csstudents_home_folder $newhomeshare

        # Set the permissions for the share
        Grant-SmbShareAccess -Name $newhomeshare -AccountName "ADMIN\CS_Students"  –AccessRight Full -Force;
        Grant-SmbShareAccess -Name $newhomeshare -AccountName "ADMIN\CSAdministrators"  –AccessRight Full -Force;

        # Make the SHARE for student folders
        NEW-SHARE $csstudents_share_folder $newstudentshare

        # Set the permissions for the share
        Grant-SmbShareAccess -Name $newstudentshare -AccountName "ADMIN\CS_Students"  –AccessRight Full -Force;
        Grant-SmbShareAccess -Name $newstudentshare -AccountName "ADMIN\CSAdministrators"  –AccessRight Full -Force;
	}

    # Make the student's home folder
    $student_home_target = "$newhomefolder"
    $student_home_share_target = "\\$share\home\$newstudent"
    if ( -not (Test-path "$student_home_target" -PathType Any )  ) {
        mkdir "$student_home_target" | Out-Null
    }

    # Make link from main homes folder to students home folder
    if ( $only_update_links -or (-not ( Test-ReparsePoint -path  $student_home_share_target ) ) ) {
        if ( $only_update_links ) {
            .\make_home_link.ps1 -target $newstudentshare_unc  -link $student_home_share_target -newstudent $newstudent -only_update_links -Verbose
        } else {
            .\make_home_link.ps1 -target $newstudentshare_unc  -link $student_home_share_target -newstudent $newstudent -Verbose
        }
    }

               				
	# Set variables needed for class and grading group
    $semester_path = "$path\classes\$year\$semester"

    ###########################################################
    # Construct share for classes
    ##########################################################
    # If the class share for this year does not exist yet
    if ( -not (Test-path "$semester_path" -PathType Any )  ) {
        mkdir "$semester_path" | Out-Null

    }

            
    # Make a share for all classes for easy access by students and controlled access by graders
    NEW-SHARE  "$semester_path"  "classes" 

    # Set the permissions for the share
    Grant-SmbShareAccess -Name "classes" -AccountName "ADMIN\CS_Students"  –AccessRight Full -Force;
    Grant-SmbShareAccess -Name "classes" -AccountName "ADMIN\CSAdministrators"  –AccessRight Full -Force;


    ###########################################################
    # Construct class folder 
    ##########################################################
    $newclassfolder = "$semester_path\$newclass"
    $group_name = "$newclass-Graders"

    # Construct folder for class if not existing and group for the class grader
	if ( -not (Test-path $newclassfolder -PathType Any )  ) {
		mkdir $newclassfolder | Out-Null
	}

    # Create the group for the class grader (if it doesnt exist already)
    $description = "Graders for $newclass"
    MakeGroup -group_name $group_name -group_description $description

	# Construct a student folder for this class if not already existing
    $student_class_folder = "$newhomefolder\$newclass"
	if ( -not (Test-path $student_class_folder -PathType Any )  ) {
		mkdir $student_class_folder | Out-Null
    }
    # Set the permissions for the student class folder
    Modify-ACL -Clean -Folder $student_class_folder -User "ADMIN\$newstudent" `
                -Owner "ADMIN\CSAdministrators" `
                -Permissions "Write, ReadAndExecute, Synchronize","None","None", "Allow"
    Modify-ACL -Folder $student_class_folder -User "ADMIN\$newstudent" `
                -Owner "ADMIN\CSAdministrators" `
                -Permissions "Modify, Synchronize","ContainerInherit, ObjectInherit","InheritOnly", "Allow"
    Modify-ACL -Folder $student_class_folder -User "ADMIN\CSAdministrators" `
                -Permissions "FullControl","ContainerInherit, ObjectInherit","None", "Allow"
    Modify-ACL -Folder $student_class_folder -User "ADMIN\Domain Admins" `
                -Permissions "FullControl","ContainerInherit, ObjectInherit","None", "Allow"
    Modify-ACL -Folder $student_class_folder -User "$share\$group_name" `
                -Permissions "Write, ReadAndExecute, Synchronize","ContainerInherit, ObjectInherit","None", "Allow"
    
	
    # In the class folder update the symbolic link to the students class folder
    if ( Test-ReparsePoint -path "\\$share\classes\$newclass\$newstudent")   {
        $rmlinkcmd = "rmdir \\$share\classes\$newclass\$newstudent"  
        cmd /c $rmlinkcmd
    }
    $mklinkcmd = "mklink /d " + "\\" + "$share\classes\$newclass\$newstudent " + "\\" + "$share\home\$newstudent\$newclass"
    Write-Verbose $mklinkcmd
	$result = cmd /c $mklinkcmd 

    # Set permissions for the symbolic link
    $student_folder_link = "\\" + "$share\classes\$newclass\$newstudent"
    Modify-ACL -Clean -Folder $student_folder_link -User "ADMIN\$newstudent" `
                -Owner "ADMIN\CSAdministrators" `
                -Permissions "Write, ReadAndExecute, Synchronize","None","None", "Allow"
    Modify-ACL -Folder $student_folder_link -User "ADMIN\$newstudent" `
                -Owner "ADMIN\CSAdministrators" `
                -Permissions "Modify, Synchronize","ContainerInherit, ObjectInherit","InheritOnly", "Allow"
    Modify-ACL -Folder $student_folder_link -User "ADMIN\CSAdministrators" `
                -Permissions "FullControl","ContainerInherit, ObjectInherit","None", "Allow"
    Modify-ACL -Folder $student_folder_link -User "ADMIN\Domain Admins" `
                -Permissions "FullControl","ContainerInherit, ObjectInherit","None", "Allow"
    Modify-ACL -Folder $student_folder_link -User "$share\$group_name" `
                -Permissions "Write, ReadAndExecute, Synchronize","ContainerInherit, ObjectInherit","None", "Allow"


	Write-Verbose "Setup $newclass for $newstudent"
}