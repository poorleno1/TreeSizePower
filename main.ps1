$env:drive = "C:"
$env:work_dir = "C:\Temp\slc\file7"
$env:outfolder = "out"
$env:temp_folder = "temp"

$drive= $env:drive
$work_dir = $env:work_dir
$outfolder = $env:outfolder
$temp_folder = $env:temp_folder

function StripQuotes ($filename)
{
    $a=$filename
    get-content $a | foreach-object { $_ -replace "`"" ,""} | set-content $a".txt" -Force -Encoding Unicode
    Remove-Item -Path $a
}


function MyFunction ($param1, $param2)
{
    
}

function ConcatenateFiles (
    $outout_file = "finale3.txt", 
    $filter = "FullName")
{
    $file_count = 0
    #$filter = "FullName"
    if (test-path "$work_dir\$temp_folder\$outout_file")
    {
        remove-item $work_dir\$temp_folder\$outout_file
    }
   
    if (!(test-path "$work_dir\$outfolder\$outout_file"))
    {
        New-Item -Path $work_dir\$outfolder\$outout_file -ItemType File
    }
    else
    {
        Remove-Item -Path $work_dir\$outfolder\$outout_file
        New-Item -Path $work_dir\$outfolder\$outout_file -ItemType File
    }


    Get-ChildItem -Path $work_dir\$temp_folder | ForEach-Object {
    #Write-Host "Processing file: $_"
    $a=$_
    #Get-Content $work_dir\$temp_folder\$a | Select-String -Pattern $filter -NotMatch | add-Content $work_dir\$outfolder\filtered.txt
    
    get-content $work_dir\$temp_folder\$a | foreach-object { $_ -replace $filter ,"".Trim()} | add-content $work_dir\$outfolder\$outout_file -Force -Encoding Unicode 
    Remove-Item $work_dir\$temp_folder\$a 
    $file_count = $file_count + 1
    }
    #Move-Item $work_dir\$outfolder\$outout_file $work_dir\$temp_folder\$outout_file

    Get-Content $work_dir\$outfolder\$outout_file | Foreach {$_.TrimEnd()} | where {$_ -ne ""} | Set-Content $work_dir\$outfolder\$outout_file.txt
    if (test-path $work_dir\$outfolder\$outout_file)
    {
    Remove-Item $work_dir\$outfolder\$outout_file
    }

    Move-Item $work_dir\$outfolder\$outout_file.txt $work_dir\$outfolder\$outout_file


    return $file_count
}


 if (!(Test-Path $work_dir\$outfolder))
    {
        New-Item $work_dir\$outfolder -type directory
    }

if (!(Test-Path $work_dir\$temp_folder))
    {
        New-Item $work_dir\$temp_folder -type directory
    }

<#
 Creating arguments - list of directories to process up to 3rd level
#>


Get-ChildItem "$drive\*" | ?{ $_.PSIsContainer } | Select-Object FullName | Export-Csv $work_dir\$temp_folder\arg1 -encoding "unicode"-notype
Get-ChildItem "$drive\*\*" | ?{ $_.PSIsContainer } | Select-Object FullName | Export-Csv $work_dir\$temp_folder\arg1a -encoding "unicode"-notype
get-content $work_dir\$temp_folder\arg1a | add-content $work_dir\$temp_folder\arg1 -Force -Encoding Unicode 
remove-item $work_dir\$temp_folder\arg1a
StripQuotes $work_dir\$temp_folder\arg1
Get-ChildItem "$drive\*\*\*" | ?{ $_.PSIsContainer } | Select-Object FullName | Export-Csv $work_dir\$temp_folder\arg2 -encoding "unicode"-notype
StripQuotes $work_dir\$temp_folder\arg2



<#
 # For each folder process create a new thread that will create a list of subfolders
#>

Write-Host "Processing directories on 3rd and deeper level."
.\Multithread2.ps1 -Command $work_dir\folder.ps1 -ObjectList (gc $work_dir\$temp_folder\arg2.txt)


Write-Host "Concatenating all files into a single one.."
$no = $(ConcatenateFiles "finale.txt" "FullName" )
Write-Host "Finished contacatenating files. $no processed."

if (test-path "$work_dir\$temp_folder\arg1")
{
Remove-Item $work_dir\$temp_folder\arg1
}
if (test-path "$work_dir\$temp_folder\arg2")
{
Remove-Item $work_dir\$temp_folder\arg2
}


<#
 # For each subfolder run file discovery
#>
Write-Host "Processing each directory on drive $drive. Looking for files."
if (test-path "$work_dir\$outfolder\finale.txt")
{
    
  Invoke-Expression -Command "$work_dir\Multithread2.ps1 -Command $work_dir\drive.ps1 -ObjectList (gc $work_dir\$outfolder\finale.txt)"
  
}
else
{
    Write-Host "Input file is missing. ($work_dir\$outfolder\finale.txt)"
}

<#
 # Process detailed file data - concatenate into single file
#>



$no = $(ConcatenateFiles "data.txt" "`"Directory`";`"BaseName`";`"Extension`";`"LastWriteTime`";`"CreationTime`";`"LastAccessTime`";`"Length`";`"Owner`"" )

Write-Host "Number of file: $no"


#Get-ChildItem -Path $work_dir\$temp_folder | ForEach-Object {Write-Host $_}

#Get-ChildItem -Path $work_dir\$temp_folder | ForEach-Object {



#Write-Host "Processing file: $_"
#.\Multithread2.ps1 -Command $work_dir\drive.ps1 -ObjectList (gc $work_dir\$temp_folder\$_)
#.\Multithread2.ps1 -Command $work_dir\test1.ps1


#Invoke-Command -ScriptBlock { .\test1.ps1 }
#}
