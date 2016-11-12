 param (
    [string]$folder
 )

#$work_dir = "C:\Jarek\Apps\TreeSizePower"
#$outfolder = "out"
#$temp_folder = "temp"

$drv_out= $env:drive
$work_dir = $env:work_dir
$outfolder = $env:outfolder
$temp_folder = $env:temp_folder



 if (!$folder)
 {
   write-host "Parameter is null"  
 }
 else
 {
    if (Test-Path $folder)
    {
    #write-host "Processing folder: $folder" 
    #| Out-File -FilePath c:\temp\log.txt -Append -NoClobber
    $outfile = $folder.Replace("\","_").Replace(":","").Trim()
    #Write-Host "Outfile: $outfile"
    #Get-ChildItem $folder
    #Get-ChildItem C:\Temp  -Recurse | ?{ $_.PSIsContainer } |Select-Object BaseName | Out-File -FilePath $work_dir\$temp_folder\$outfile -Encoding unicode
    Get-ChildItem $folder  -Recurse | ?{ $_.PSIsContainer } |Select-Object FullName |    Export-Csv $work_dir\$temp_folder\$outfile -encoding "unicode"-notype #-Delimiter ";"
    $a=$work_dir+"\"+$temp_folder+"\"+$outfile
    get-content $a | foreach-object { $_ -replace "`"" ,""} | set-content $a".txt" -Force -Encoding Unicode
    Remove-Item -Path $a
    }
    
 }

#Get-ChildItem $folder |where {$_.attributes -notMatch "Directory"}|Select-Object Directory, BaseName, Extension,@{Name="LastWriteTime";Expression= {"{0:yyyy}-{0:MM}-{0:dd} {0:hh}:{0:mm}:{0:ss}" -f ([DateTime]$_.LastWriteTime)}},@{Name="CreationTime";Expression= {"{0:yyyy}-{0:MM}-{0:dd} {0:hh}:{0:mm}:{0:ss}" -f ([DateTime]$_.CreationTime)}},@{Name="LastAccessTime";Expression= {"{0:yyyy}-{0:MM}-{0:dd} {0:hh}:{0:mm}:{0:ss}" -f ([DateTime]$_.LastAccessTime)}},Length, @{Name="Owner";Expression={(Get-Acl $_.FullName).Owner }} |Export-Csv $outfolder\$outfile -encoding "unicode"-notype -Delimiter ";"
# Get-ChildItem "\*" | ?{ $_.PSIsContainer } | Select-Object FullName | Out-File -FilePath $work_dir\$temp_folder\arg1.txt -Encoding unicode