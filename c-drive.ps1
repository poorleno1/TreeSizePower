#$currentFolder="C:\Jarek\Apps\TreeSizePower"
#. "$PSScriptRoot\Logging_Functions.ps1"
$Missing_value='none'
$Folder = 'C:\Drivers\'
$OutputFolder = 'C:\Temp\slc\'
$OutputFile = 'c-drive3.csv'
$ExportCSV = $OutputFolder + $OutputFile

$ServerName = "LTF11000\MSSQLSERVER2014"
$DatabaseName = "ITInfra"
#Random generation of table name
$tableNAme = -join ((1..10) | %{(65..90) + (97..122) | Get-Random} | % {[char]$_})
$SQLFormatFile = $currentFolder + "\temp4.fmt"
$SMTP_server="relay.statoilfuelretail.com"
$mailRecipient="jarekole@circlekeurope.com"
$currentLogFile="Current_log.txt"
$logFile="Log.txt"
$exportCurrentLog= $OutputFolder + $currentLogFile
$exportLog= $OutputFolder + $logFile




function Execute-SQLStatement ($Query)
{
    $conn2=New-Object System.Data.SqlClient.SQLConnection
    $conn2.ConnectionString=$ConnectionString
    $conn2.Open()
    $cmd=New-Object system.Data.SqlClient.SqlCommand($Query,$conn2)
    $cmd.CommandTimeout=$QueryTimeout
    $ds=New-Object system.Data.DataSet
    try
    {
        
        #Write-Host "Executing statement." + $Query
        #Write-Host "------------------------------------------------------------"
        Write-Log -Message "Executing statement: $Query" -Path $exportCurrentLog -Level Info
        $da=New-Object system.Data.SqlClient.SqlDataAdapter($cmd)
        [void]$da.fill($ds)
        #$t = $da.fill($ds) | Out-String
        #Write-Log -Message "Executing statement: $t" -Path $exportCurrentLog -Level Info
    }
    catch [System.Data.SqlClient.SqlException]
    {
        Write-Log -Message "Something went wrong with statement: $_.Exception.Number" -Path $exportCurrentLog -Level Error
        #Write-Host "Something went wrong."
        #Write-Host $_.Exception.Number
        break
    }
    #finally
    #{
    #    Write-Host "cleaning up ..."
    #}

    
    $conn2.Close()
    $ds.Tables
}

function Test-SQLConnection
{    
    [OutputType([bool])]
    Param
    (
        [Parameter(Mandatory=$true,
                    ValueFromPipelineByPropertyName=$true,
                    Position=0)]
        $ConnectionString
    )
    try
    {
        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $ConnectionString;
        $sqlConnection.Open();
        $sqlConnection.Close();

        return $true;
    }
    catch
    {
        return $false;
    }
}


function SendMail ($body,$mailSubject)
{
    try
    {
        $oSmtp = new-object Net.Mail.SmtpClient($SMTP_server)
        $oSmtp.Send($mailRecipient, $mailRecipient, $mailSubject, $body)
        #Exit 0
    }
    Catch
    {
        Write-Host "Cannot send mail."
        #exit 1
    }

}


<# 
.Synopsis 
   Write-Log writes a message to a specified log file with the current time stamp. 
.DESCRIPTION 
   The Write-Log function is designed to add logging capability to other scripts. 
   In addition to writing output and/or verbose you can write to a log file for 
   later debugging. 
.NOTES 
   Created by: Jason Wasser @wasserja 
   Modified: 11/24/2015 09:30:19 AM   
 
   Changelog: 
    * Code simplification and clarification - thanks to @juneb_get_help 
    * Added documentation. 
    * Renamed LogPath parameter to Path to keep it standard - thanks to @JeffHicks 
    * Revised the Force switch to work as it should - thanks to @JeffHicks 
 
   To Do: 
    * Add error handling if trying to create a log file in a inaccessible location. 
    * Add ability to write $Message to $Verbose or $Error pipelines to eliminate 
      duplicates. 
.PARAMETER Message 
   Message is the content that you wish to add to the log file.  
.PARAMETER Path 
   The path to the log file to which you would like to write. By default the function will  
   create the path and file if it does not exist.  
.PARAMETER Level 
   Specify the criticality of the log information being written to the log (i.e. Error, Warning, Informational) 
.PARAMETER NoClobber 
   Use NoClobber if you do not wish to overwrite an existing file. 
.EXAMPLE 
   Write-Log -Message 'Log message'  
   Writes the message to c:\Logs\PowerShellLog.log. 
.EXAMPLE 
   Write-Log -Message 'Restarting Server.' -Path c:\Logs\Scriptoutput.log 
   Writes the content to the specified log file and creates the path and file specified.  
.EXAMPLE 
   Write-Log -Message 'Folder does not exist.' -Path c:\Logs\Script.log -Level Error 
   Writes the message to the specified log file as an error message, and writes the message to the error pipeline. 
.LINK 
   https://gallery.technet.microsoft.com/scriptcenter/Write-Log-PowerShell-999c32d0 
#> 
function Write-Log 
{ 
    [CmdletBinding()] 
    Param 
    ( 
        [Parameter(Mandatory=$true, 
                   ValueFromPipelineByPropertyName=$true)] 
        [ValidateNotNullOrEmpty()] 
        [Alias("LogContent")] 
        [string]$Message, 
 
        [Parameter(Mandatory=$false)] 
        [Alias('LogPath')] 
        [string]$Path='C:\Logs\PowerShellLog.log', 
         
        [Parameter(Mandatory=$false)] 
        [ValidateSet("Error","Warn","Info")] 
        [string]$Level="Info", 
         
        [Parameter(Mandatory=$false)] 
        [switch]$NoClobber 
    ) 
 
    Begin 
    { 
        # Set VerbosePreference to Continue so that verbose messages are displayed. 
        $VerbosePreference = 'Continue' 
    } 
    Process 
    { 
         
        # If the file already exists and NoClobber was specified, do not write to the log. 
        if ((Test-Path $Path) -AND $NoClobber) { 
            Write-Error "Log file $Path already exists, and you specified NoClobber. Either delete the file or specify a different name." 
            Return 
            } 
 
        # If attempting to write to a log file in a folder/path that doesn't exist create the file including the path. 
        elseif (!(Test-Path $Path)) { 
            Write-Verbose "Creating $Path." 
            $NewLogFile = New-Item $Path -Force -ItemType File 
            } 
 
        else { 
            # Nothing to see here yet. 
            } 
 
        # Format Date for our Log File 
        $FormattedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss" 
 
        # Write message to error, warning, or verbose pipeline and specify $LevelText 
        switch ($Level) { 
            'Error' { 
                Write-Error $Message 
                $LevelText = 'ERROR:' 
                } 
            'Warn' { 
                Write-Warning $Message 
                $LevelText = 'WARNING:' 
                } 
            'Info' { 
                Write-Verbose $Message 
                $LevelText = 'INFO:' 
                } 
            } 
         
        # Write log entry to $Path 
        "$FormattedDate $LevelText $Message" | Out-File -FilePath $Path -Append 
    } 
    End 
    { 
    } 
}

#Log
#Write-Host "Checking if current log file exists."
Write-Log -Message "********************************Script started ********************************" -Path $exportCurrentLog -Level Info
Write-Log -Message "Checking if current log file exists." -Path $exportCurrentLog -Level Info
#if (!(Test-Path $exportCurrentLog))
#{
    #Write-Log -Message "File does not exist." -Path $exportCurrentLog -Level Info
    #Write-Log -Message "Creating Current log file." -Path $exportCurrentLog -Level Info
    #try
    #{
    #    New-Item -ItemType file -Path $OutputFolder -Name $currentLogFile -ea stop
    #}
    #catch
    #{
    #    Write-Log -Message "Something went wrong with creating file: $_.Exception.Number" -Path $exportCurrentLog -Level Error
    #    $subj = "Error in " + $env:computername
    #    SendMail "Cannot create log file." $subj
    #}
#}
#else
#{
 #   Write-Log -Message "File does exist. Continuing." -Path $exportCurrentLog -Level Info
#}




if (Test-Path $exportCurrentLog)
{
    #Write-host "File does not exist."
    #Write-Host "Creating Current log file."
    Write-Log -Message "File does exist. Continuing." -Path $exportCurrentLog -Level Info
    Write-Log -Message "Recreating Current log file." -Path $exportCurrentLog -Level Info
    try
    {
        Remove-Item $exportCurrentLog
        New-Item -ItemType file -Path $OutputFolder -Name $currentLogFile -ea stop
    }
    catch
    {
        #Write-Host "Something went wrong."
        #Write-Host $_.Exception.Number
        Write-Log -Message "Something went wrong with creating file: $_.Exception.Number" -Path $exportCurrentLog -Level Error
        $subj = "Error in " + $env:computername
        SendMail "Cannot create log file." $subj
    }
}
else
{
    #Write-Host "Current log file exists."
    Write-Log -Message "File does not exist. Creating." -Path $exportCurrentLog -Level Info
    try
    {
        New-Item -ItemType file -Path $OutputFolder -Name $currentLogFile -ea stop
    }
    catch
    {
        Write-Log -Message "Something went wrong with creating file: $_.Exception.Number" -Path $exportCurrentLog -Level Error
        $subj = "Error in " + $env:computername
        SendMail "Cannot create log file." $subj
    }
}







#Write-Log -Message 'Starting logging.' -Path $exportCurrentLog -Level Info
#end of Log


#Log-Start -LogPath "C:\temp" -LogName "Last.log" -ScriptVersion "1.5"



if (!(Test-Path $Folder))
{

    #Write-host "ERROR: Folder $folder does not exists. Please verify path."
    Write-Log -Message "Folder $folder does not exists. Please verify path." -Path $exportCurrentLog -Level Error
    break
}


if (!(Test-Path $OutputFolder))
{
try
    {
    mkdir $OutputFolder
    }
catch [System.IO]
    {
    #Write-Host "ERROR: Something went wrong with creating folder $OutputFolder"
    Write-Log -Message "Something went wrong with creating folder $OutputFolder." -Path $exportCurrentLog -Level Error
    $subj = "Error in " + $env:computername
    SendMail "Cannot create outfile file. " $subj
    break
    }
}

Write-Log -Message "Starting processing files and folders." -Path $exportCurrentLog -Level Info

Get-ChildItem $Folder -recurse `
|where { ! $_.PSIsContainer } `
|Select-Object Directory, BaseName, Extension `
,@{Name="LastWriteTime";Expression= {"{0:yyyy}-{0:MM}-{0:dd} {0:hh}:{0:mm}:{0:ss}" -f ([DateTime]$_.LastWriteTime)}} `
,@{Name="CreationTime";Expression= {"{0:yyyy}-{0:MM}-{0:dd} {0:hh}:{0:mm}:{0:ss}" -f ([DateTime]$_.CreationTime)}} `
,@{Name="LastAccessTime";Expression= {"{0:yyyy}-{0:MM}-{0:dd} {0:hh}:{0:mm}:{0:ss}" -f ([DateTime]$_.LastAccessTime)}} `
,Length `
,@{Name="Owner";Expression={if (!(Get-Acl $_.FullName).Owner) {$Missing_value} else {(Get-Acl $_.FullName).Owner} }} `
|Export-Csv $ExportCSV -encoding "unicode"-notype -Delimiter ";"



$Query=" `
    CREATE TABLE [slc].["+$tableNAme+"]( `
	    [Directory] [nvarchar](255) NULL, `
	    [BaseName] [nvarchar](255) NULL, `
	    [Extension] [nvarchar](255) NULL, `
	    [LastWriteTime] [nvarchar](50) NULL, `
	    [CreationTime] [nvarchar](50) NULL, `
	    [LastAccessTime] [nvarchar](50) NULL, `
	    [Length] [nvarchar](50) NULL, `
	    [Owner] [nvarchar](255) NULL) `
"

$Query_createView=" `
    create view slc.vw_drive `
    as `
    SELECT * FROM [ITInfra].[slc].["+$tableNAme+"] `
    GO"

$query_bulLoad=" `
    BULK INSERT [slc].["+$tableNAme+"] `
    FROM '"+$ExportCSV+"' `
    WITH ( `
    FORMATFILE = '"+$SQLFormatFile+"', FIRSTROW = 2 ,DATAFILETYPE = 'widechar')"


$query_ProcessData=" `
    exec [slc].[Import_data6] "

$query_dropTable=" `
    --select top 2  * from [slc].["+$tableNAme+"] `
    drop table [slc].["+$tableNAme+"] `
    "

$query_dropView=" `
    if exists(select 1 from sys.views where name='vw_drive' and type='v') drop view slc.vw_drive"
#$query_GetServerID=" `
#    SELECT [ServerID] FROM [ITInfra].[slc].[Server] where name='SFRFIDCFIDF007P'"
$query_GetServerID=" `
    SELECT [ServerID] FROM [ITInfra].[slc].[Server] where name='"+$env:computername+"'"


#$Query = "Select top 1 * from [slc].[e-drive] `
#Go `
#select getdate()"

#Timeout parameters
$QueryTimeout = 120
$ConnectionTimeout = 30

#Action of connecting to the Database and executing the query and returning results if there were any.
$conn=New-Object System.Data.SqlClient.SQLConnection
$ConnectionString = "Server={0};Database={1};Integrated Security=True;Connect Timeout={2}" -f $ServerName,$DatabaseName,$ConnectionTimeout
$conn.ConnectionString=$ConnectionString

Write-Log -Message "Testing SQL connection to server." -Path $exportCurrentLog -Level Info

if ((Test-SQLConnection $ConnectionString) -eq $true)
{
    Write-Log -Message "Connection to SQL established. Continuing." -Path $exportCurrentLog -Level Info
    #Write-Host "Getting ServerID from server based on hostname."
    Write-Log -Message "Getting ServerID from server based on hostname." -Path $exportCurrentLog -Level Info

    $conn.Open()
    $Command = New-Object System.Data.SQLClient.SQLCommand
    $Command.Connection=$conn
    $Command.CommandText=$query_GetServerID
    $ServerID = $Command.ExecuteScalar()
    $conn.Close()
    if (!($ServerID))
    {
        Write-Host "Your computer is not on authorized list."
        Write-Log -Message "Your computer is not on authorized list." -Path $exportCurrentLog -Level Error
        break
    }

    #Write-Host "My hostname is:"+ $env:computername
    #Write-Host $reader


    #Write-Host "Dropping View."
    Write-Log -Message "Dropping View." -Path $exportCurrentLog -Level Info
    Execute-SQLStatement ($query_dropView)

    #Write-Host "Creating table: $tableNAme"
    Write-Log -Message "Creating table: $tableNAme" -Path $exportCurrentLog -Level Info
    Execute-SQLStatement ($query)

    #Write-Host "Creating view."
    Write-Log -Message "Creating view." -Path $exportCurrentLog -Level Info
    Execute-SQLStatement ($Query_createView)

    #Write-Host "Inserting data into table: $tableNAme"
    Write-Log -Message "Inserting data into table: $tableNAme" -Path $exportCurrentLog -Level Info
    Execute-SQLStatement ($query_bulLoad)

    #Write-Host "Processing data."
    Write-Log -Message "Processing data." -Path $exportCurrentLog -Level Info
    Execute-SQLStatement ($query_ProcessData +$ServerID)

    #Write-Host "Dropping table: $tableNAme"
    Write-Log -Message "Dropping table: $tableNAme" -Path $exportCurrentLog -Level Info
    Execute-SQLStatement ($query_dropTable)

    #Write-Host "Dropping View."
    Write-Log -Message "Dropping View." -Path $exportCurrentLog -Level Info
    Execute-SQLStatement ($query_dropView)

    $subj = "Successful processing on: " + $env:computername
    $body = Get-Content $exportCurrentLog | Out-String
    SendMail $body $subj
}
else
{
    #Write-Host "ERROR: No Connection to $serverName" 
    Write-Log -Message "No Connection to $serverName." -Path $exportCurrentLog -Level Error
}

Get-Content $exportCurrentLog  >>  $exportLog
#Remove-Item $exportCurrentLog 
