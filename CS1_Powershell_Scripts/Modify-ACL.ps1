Function Modify-ACL {    
    [CmdletBinding(SupportsShouldProcess=$True)]
    Param(
        [parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({Test-Path $_ -PathType Container})]
        [String]$Folder,   # Folder
		[String]$User,     # add permissions for user
        [String]$Owner,    # set the owner
        [String[]]$Permissions, #list of permissions
        [Switch]$Recurse,  # apply recursively
        [Switch]$Inherit,  # inherit from parent folder
        [Switch]$Clean     # remove all permissions first if this is set
     )
     Begin {
        Try {
            [void][TokenAdjuster]
        } Catch {
            $AdjustTokenPrivileges = @"
            using System;
            using System.Runtime.InteropServices;

             public class TokenAdjuster
             {
              [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
              internal static extern bool AdjustTokenPrivileges(IntPtr htok, bool disall,
              ref TokPriv1Luid newst, int len, IntPtr prev, IntPtr relen);
              [DllImport("kernel32.dll", ExactSpelling = true)]
              internal static extern IntPtr GetCurrentProcess();
              [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
              internal static extern bool OpenProcessToken(IntPtr h, int acc, ref IntPtr
              phtok);
              [DllImport("advapi32.dll", SetLastError = true)]
              internal static extern bool LookupPrivilegeValue(string host, string name,
              ref long pluid);
              [StructLayout(LayoutKind.Sequential, Pack = 1)]
              internal struct TokPriv1Luid
              {
               public int Count;
               public long Luid;
               public int Attr;
              }
              internal const int SE_PRIVILEGE_DISABLED = 0x00000000;
              internal const int SE_PRIVILEGE_ENABLED = 0x00000002;
              internal const int TOKEN_QUERY = 0x00000008;
              internal const int TOKEN_ADJUST_PRIVILEGES = 0x00000020;
              public static bool AddPrivilege(string privilege)
              {
               try
               {
                bool retVal;
                TokPriv1Luid tp;
                IntPtr hproc = GetCurrentProcess();
                IntPtr htok = IntPtr.Zero;
                retVal = OpenProcessToken(hproc, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, ref htok);
                tp.Count = 1;
                tp.Luid = 0;
                tp.Attr = SE_PRIVILEGE_ENABLED;
                retVal = LookupPrivilegeValue(null, privilege, ref tp.Luid);
                retVal = AdjustTokenPrivileges(htok, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);
                return retVal;
               }
               catch (Exception ex)
               {
                throw ex;
               }
              }
              public static bool RemovePrivilege(string privilege)
              {
               try
               {
                bool retVal;
                TokPriv1Luid tp;
                IntPtr hproc = GetCurrentProcess();
                IntPtr htok = IntPtr.Zero;
                retVal = OpenProcessToken(hproc, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, ref htok);
                tp.Count = 1;
                tp.Luid = 0;
                tp.Attr = SE_PRIVILEGE_DISABLED;
                retVal = LookupPrivilegeValue(null, privilege, ref tp.Luid);
                retVal = AdjustTokenPrivileges(htok, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);
                return retVal;
               }
               catch (Exception ex)
               {
                throw ex;
               }
              }
             }
"@
            Add-Type $AdjustTokenPrivileges
        }
    }
    Process {
        
        foreach ($f in $Folder) {

            #Activate necessary admin privileges to make changes without NTFS perms
		    [void][TokenAdjuster]::AddPrivilege("SeRestorePrivilege") #Necessary to set Owner Permissions
		    [void][TokenAdjuster]::AddPrivilege("SeBackupPrivilege") #Necessary to bypass Traverse Checking
		    [void][TokenAdjuster]::AddPrivilege("SeTakeOwnershipPrivilege") #Necessary to override 

            if ($Recurse) {
				$FilesAndFolders = $(Get-ChildItem $f -Recurse ).FullName
			} else {
				$FilesAndFolders = $Folder
			}

            if ($FilesAndFolders -ne $null) {

                ForEach ( $file in $FilesAndFolders ) {

                    # Write-Verbose -message "Setting up $file"
                    Try {
                        # Get the item type
                        $Item = Get-Item -LiteralPath $file -Force -ErrorAction Stop

                        # Get the ACL for the file / folder
                        $acl = Get-Acl $file

                        # Set the owner 
                        if ( $Owner ) {
                            $acl.SetOwner([System.Security.Principal.NTAccount]$Owner)
                        } 

                        if ( $Clean ) {
					        # Remove inheritance
					        $acl.SetAccessRuleProtection($true,$false)
						
                            # Remove all existing ACL rules
                            $acl.Access | %{$acl.RemoveAccessRule($_)} | Out-Null
                        }

                        if (-Not $Recurse) {	
                            # Since this is the root folder, set FolderOwner permissions
                            $perms  = @("$User") + $permissions
                            $rule = New-Object System.Security.AccessControl.FileSystemAccessRule ( $perms )
                            $acl.AddAccessRule($rule)
                        } 

                        # Enable inheritance of permissions only if Inherit flag set 
                        if ($Inherit) {
                            $acl.SetAccessRuleProtection($false,$false)
                        }

                        # Set the final ACL
                        Set-Acl $file $acl 

                    } Catch {
                        $message = $_ | FL
                        Write-Warning $message
                    }
                }
            }
            else {
                Write-Verbose "Modify-ACL: No subfolders found for $f"
            }
        }
    }
    End {  
        #Remove priviledges that had been granted
        [void][TokenAdjuster]::RemovePrivilege("SeRestorePrivilege") 
        [void][TokenAdjuster]::RemovePrivilege("SeBackupPrivilege") 
        [void][TokenAdjuster]::RemovePrivilege("SeTakeOwnershipPrivilege")     
    }
}