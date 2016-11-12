 param (
     [string]$folder
 )

$drv_out= $env:drive
$work_dir = $env:work_dir
$outfolder = $env:outfolder
$temp_folder = $env:temp_folder

#write-host "Processing folder: $folder" 
if (!$folder)
 {
   #write-host "Folder name is missing: $folder."
   Continue
 }
 else
 {
    if (Test-Path $folder)
    {
    $outfile = $folder.Replace("\","_").Replace(":","").Trim() + ".txt"
    #Write-Host "Outfile: $outfile"
    #Get-ChildItem $folder |where {$_.attributes -notMatch "Directory"}|Select-Object Directory, BaseName, Extension,@{Name="LastWriteTime";Expression= {"{0:yyyy}-{0:MM}-{0:dd} {0:hh}:{0:mm}:{0:ss}" -f ([DateTime]$_.LastWriteTime)}},@{Name="CreationTime";Expression= {"{0:yyyy}-{0:MM}-{0:dd} {0:hh}:{0:mm}:{0:ss}" -f ([DateTime]$_.CreationTime)}},@{Name="LastAccessTime";Expression= {"{0:yyyy}-{0:MM}-{0:dd} {0:hh}:{0:mm}:{0:ss}" -f ([DateTime]$_.LastAccessTime)}},Length, @{Name="Owner";Expression={(Get-Acl $_.FullName).Owner }} |Export-Csv $work_dir\$temp_folder\$outfile -encoding "unicode"-notype -Delimiter ";"
    Get-ChildItem $folder |where {$_.attributes -notMatch "Directory"}|Select-Object Directory, BaseName, Extension,@{Name="LastWriteTime";Expression= {"{0:yyyy}-{0:MM}-{0:dd} {0:hh}:{0:mm}:{0:ss}" -f ([DateTime]$_.LastWriteTime)}},@{Name="CreationTime";Expression= {"{0:yyyy}-{0:MM}-{0:dd} {0:hh}:{0:mm}:{0:ss}" -f ([DateTime]$_.CreationTime)}},@{Name="LastAccessTime";Expression= {"{0:yyyy}-{0:MM}-{0:dd} {0:hh}:{0:mm}:{0:ss}" -f ([DateTime]$_.LastAccessTime)}},Length, @{Name="Owner";Expression={(Get-Acl $_.FullName).Owner }} |Export-Csv $work_dir\$temp_folder\$outfile -encoding "unicode"-notype -Delimiter ";"
    If ((Get-Content "$work_dir\$temp_folder\$outfile") -eq $Null) 
    {
        Remove-Item $work_dir\$temp_folder\$outfile
    }
    }
    
 }