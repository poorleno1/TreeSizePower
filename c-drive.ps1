$currentFolder=$PSScriptRoot
#. "$PSScriptRoot\Logging_Functions.ps1"
$Missing_value='none'
$Folder = 'C:\temp\aws\'
$OutputFolder = 'C:\Temp\slc\'
#$OutputFile = 'c-drive3.csv'

$random = -join ((1..10) | %{(65..90) + (97..122) | Get-Random} | % {[char]$_})
$OutputFile = $env:computername +"_"+ $random
#$tableNAme = -join ((1..10) | %{(65..90) + (97..122) | Get-Random} | % {[char]$_})
$tableNAme = $OutputFile
$ExportCSV = $OutputFolder + $OutputFile

$ServerName = "SFRFIDCSQLA035P,5097"
#$ServerName = "LTF11000\MSSQLSERVER2014"
$DatabaseName = "ITInfra"
#Random generation of table name

$SQLFormatFile = $currentFolder + "\temp4.fmt"
$SMTP_server="relay.statoilfuelretail.com"
$mailRecipient="jarekole@circlekeurope.com"
$currentLogFile="Current_log.txt"
$logFile="Log.txt"
$exportCurrentLog= $OutputFolder + $currentLogFile
$exportLog= $OutputFolder + $logFile
$destinationPath= "\\sfrfidcsqla035p\slc"
$DataLoadTimeout = 60*10
$DataLoadIterations = 250


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

#$Query_createView=" `
#    create view slc.vw_drive `
#    as `
#    SELECT * FROM [ITInfra].[slc].["+$tableNAme+"] `
#    GO"

$Query_createView=" `
    create view [slc].[vw_drive] `
    as `
    SELECT `
	  case `
		when left([Directory],1)='`"' then replace([Directory],'`"','') `
		else [Directory] `
	 end  as [Directory] `
	  ,case `
		when left([BaseName],1)='`"' then replace([BaseName],'`"','') `
		else [BaseName] `
	   end  as [BaseName] `
	   ,case `
		when left([Extension],1)='`"' then replace([Extension],'`"','') `
		else [Extension] `
	   end  as [Extension] `
	   ,case `
		when left([LastWriteTime],1)='`"' then replace([LastWriteTime],'`"','') `
		else [LastWriteTime] `
	   end  as [LastWriteTime] `
	   ,case `
		when left([CreationTime],1)='`"' then replace([CreationTime],'`"','') `
		else [CreationTime] `
	   end  as [CreationTime] `
	   ,case `
		when left([LastAccessTime],1)='`"' then replace([LastAccessTime],'`"','') `
		else [LastAccessTime] `
	   end  as [LastAccessTime] `
	   ,case `
		when left([Length],1)='`"' then replace([Length],'`"','') `
		else [Length] `
	   end  as [Length] `
	    ,case `
		when left([Owner],1)='`"' then replace([Owner],'`"','') `
		else [Owner] `
	   end  as [Owner] `
    FROM [ITInfra].[slc].["+$tableNAme+"]"
 #   where ISNUMERIC(case when left([Length],1)='`"' then replace([Length],'`"','')  else [Length] end)=1"

#$query_bulLoad=" `
#    BULK INSERT [slc].["+$tableNAme+"] `
#    FROM '"+$ExportCSV+"' `
#    WITH ( `
#    FORMATFILE = '"+$SQLFormatFile+"', FIRSTROW = 2 ,DATAFILETYPE = 'widechar')"

$query_bulLoad=" `
    BULK INSERT [slc].["+$tableNAme+"] `
    FROM 'K:\jarek\slc\"+$OutputFile+"' `
    WITH ( `
    FORMATFILE = 'K:\jarek\slc\temp5.fmt', FIRSTROW = 2 ,DATAFILETYPE = 'widechar')"



$query_ProcessData=" `
    exec [slc].[Import_data7] "

$query_FurtherProcessData=" `
    exec [slc].[CalculateSize3rdLevel2] `
    GO `
    exec [slc].[UpdateOwners] `
    Go"

$query_dropTable=" `
    --select top 2  * from [slc].["+$tableNAme+"] `
    drop table [slc].["+$tableNAme+"] `
    "

$query_dropView=" `
    if exists(select 1 from sys.views where name='vw_drive' and type='v') drop view slc.vw_drive"



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
    catch #[System.Data.SqlClient.SqlException]
    {
        Write-Log -Message "Something went wrong with statement: $($_.Exception.Number)" -Path $exportCurrentLog -Level Error
        Write-Log -Message "cleaning up ..." -Path $exportCurrentLog -Level Info
        Write-Log -Message "Dropping View." -Path $exportCurrentLog -Level Info
        Execute-SQLStatement ($query_dropView)
        SendMail "Error in processing SQL statement."
        #Write-Host "Something went wrong."
        #Write-Host $_.Exception.Number
        break
    }
    #finally
    #{
    #    Write-Log -Message "cleaning up ..." -Path $exportCurrentLog -Level Info
    #    Write-Log -Message "Dropping View." -Path $exportCurrentLog -Level Info
    #    Execute-SQLStatement ($query_dropView)
    #    SendMail "Error in processing SQL statement."
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


function SendMail ($mailSubject)
{
    try
    {
        $body = Get-Content $exportCurrentLog | Out-String
        $oSmtp = new-object Net.Mail.SmtpClient($SMTP_server)
        $mailSubject=$env:computername + ": " +$mailSubject
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

function VerifyIfAuthorized ($Hostname)
{
    #$query_GetServerID=" `
    #    SELECT [ServerID] FROM [ITInfra].[slc].[Server] where name='SFRFIDCFIDF007P'"
    $query_GetServerID=" `
    SELECT [ServerID] FROM [ITInfra].[slc].[Server] where name='"+$Hostname+"'"

    $conn=New-Object System.Data.SqlClient.SQLConnection
    $ConnectionString = "Server={0};Database={1};Integrated Security=True;Connect Timeout={2}" -f $ServerName,$DatabaseName,$ConnectionTimeout
    $conn.ConnectionString=$ConnectionString
    $conn.Open()
    $Command = New-Object System.Data.SQLClient.SQLCommand
    $Command.Connection=$conn
    $Command.CommandText=$query_GetServerID
    $ServerID = $Command.ExecuteScalar()
    $conn.Close()
    if (!($ServerID))
    {
        return 0
    }
    else
    {
        return $ServerID
    }
}

function VerifyIfDBIsReady
{
    $query_RetVal=" `
    select 1 as RetVal from sys.views where name='vw_drive' and type='v'"

    $conn=New-Object System.Data.SqlClient.SQLConnection
    $ConnectionString = "Server={0};Database={1};Integrated Security=True;Connect Timeout={2}" -f $ServerName,$DatabaseName,$ConnectionTimeout
    $conn.ConnectionString=$ConnectionString
    $conn.Open()
    $Command = New-Object System.Data.SQLClient.SQLCommand
    $Command.Connection=$conn
    $Command.CommandText=$query_RetVal
    $RetVal = $Command.ExecuteScalar()
    $conn.Close()
    if (!($RetVal))
    {
        return 0
    }
    else
    {
        return 1
    }
}


#Write-Log -Message "Testing SQL connection to server." -Path $exportCurrentLog -Level Info



if (Test-Path $exportCurrentLog) {
    Write-Host "Log File Exits. Removing"
    Remove-Item $exportCurrentLog
}

Write-Log -Message "********************************Script started ********************************" -Path $exportCurrentLog -Level Info

if (!(Test-Path $Folder))
{
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
    Write-Log -Message "Something went wrong with creating folder $OutputFolder." -Path $exportCurrentLog -Level Error
    $subj = "Error in " + $env:computername
    SendMail "Cannot create outfile file. "
    break
    }
}





#Timeout parameters
$QueryTimeout = 24000
$ConnectionTimeout = 30

#Action of connecting to the Database and executing the query and returning results if there were any.
$conn=New-Object System.Data.SqlClient.SQLConnection
$ConnectionString = "Server={0};Database={1};Integrated Security=True;Connect Timeout={2}" -f $ServerName,$DatabaseName,$ConnectionTimeout
$conn.ConnectionString=$ConnectionString

Write-Log -Message "Testing SQL connection to server." -Path $exportCurrentLog -Level Info
$conntest= (Test-SQLConnection $ConnectionString)

if ($conntest -eq $true){
    Write-Log -Message "Connection to SQL is OK." -Path $exportCurrentLog -Level Info

    Write-Log -Message "Testing if server is authorized to send data." -Path $exportCurrentLog -Level Info
    $auth = (VerifyIfAuthorized $env:computername)

    if ($auth -ge 1){
        Write-Log -Message "Server is authorized to send data." -Path $exportCurrentLog -Level Info
    }
    else
    {
        Write-Log -Message "Server is not authorized to send data. Add it to table slc.servers." -Path $exportCurrentLog -Level Info
    }

}
else
{
    Write-Log -Message "No connection to server." -Path $exportCurrentLog -Level Error
}


if ($conntest -eq $true -and (VerifyIfAuthorized $env:computername) -ge 1)
{
    Write-Log -Message "All SQL prerequisites met. Continuing." -Path $exportCurrentLog -Level Info
    Write-Log -Message "Getting ServerID from server based on hostname." -Path $exportCurrentLog -Level Info
    Write-Log -Message "Starting processing files and folders in $Folder" -Path $exportCurrentLog -Level Info
    Get-ChildItem $Folder -recurse `
    |where { ! $_.PSIsContainer } `
    |Select-Object `
     @{Name="Directory";Expression={if ($_.Directory -match "[;]") {$_.Directory -replace ";","" } else {$_.Directory}}} `
    ,@{Name="BaseName";Expression={if ($_.BaseName -match "[;]") {$_.BaseName -replace ";","" } else {$_.BaseName}}} `
    ,@{Name="Extension";Expression={if ($_.Extension -match "[;]") {$_.Extension -replace ";","" } else {$_.Extension}}} `
    ,@{Name="LastWriteTime";Expression= {"{0:yyyy}-{0:MM}-{0:dd} {0:hh}:{0:mm}:{0:ss}" -f ([DateTime]$_.LastWriteTime)}} `
    ,@{Name="CreationTime";Expression= {"{0:yyyy}-{0:MM}-{0:dd} {0:hh}:{0:mm}:{0:ss}" -f ([DateTime]$_.CreationTime)}} `
    ,@{Name="LastAccessTime";Expression= {"{0:yyyy}-{0:MM}-{0:dd} {0:hh}:{0:mm}:{0:ss}" -f ([DateTime]$_.LastAccessTime)}} `
    ,Length `
    ,@{Name="Owner1";Expression={(Get-Acl $_.FullName).Owner}} `
    |Export-Csv $ExportCSV -encoding "unicode"-notype -Delimiter ";"


    #|Select-Object Directory, BaseName, Extension `
    #,@{Name="LastWriteTime";Expression= {"{0:yyyy}-{0:MM}-{0:dd} {0:hh}:{0:mm}:{0:ss}" -f ([DateTime]$_.LastWriteTime)}} `
    #,@{Name="CreationTime";Expression= {"{0:yyyy}-{0:MM}-{0:dd} {0:hh}:{0:mm}:{0:ss}" -f ([DateTime]$_.CreationTime)}} `
    #,@{Name="LastAccessTime";Expression= {"{0:yyyy}-{0:MM}-{0:dd} {0:hh}:{0:mm}:{0:ss}" -f ([DateTime]$_.LastAccessTime)}} `
    #,Length `
    #,@{Name="Owner";Expression={if ($_.BaseName -match "[[]" -or $_.BaseName -match "[]]" -or $_.BaseName -match "[~]") {$Missing_value}else {if (!(Get-Acl $_.FullName).Owner) {$Missing_value} else {(Get-Acl $_.FullName).Owner}}}} `
    #|Export-Csv $ExportCSV -encoding "unicode"-notype -Delimiter ";"

    Write-log -Message "Copying over Network data file" -Path $exportCurrentLog -level Info
    try
    {
        $err=0
        Move-Item $ExportCSV -Destination $destinationPath -Force -ErrorAction Stop
    }
    catch
    {
        Write-Host "Other exception"
        Write-log -Message "Cannot copy files to destination: $destinationPath, $($_.exception.message)" -Path $exportCurrentLog -level Error
        $err = 1
    }

    if ($err -ne 1)
    {
        Write-log -Message "Data is prepared to load." -Path $exportCurrentLog -level Info

        Write-Log -Message "Creating table: $tableNAme" -Path $exportCurrentLog -Level Info
        Execute-SQLStatement ($query)

        Write-Log -Message "Inserting data into table: $tableNAme" -Path $exportCurrentLog -Level Info
        Execute-SQLStatement ($query_bulLoad)

        Write-Log -Message "Verifying if View is created."
        
        if (VerifyIfDBIsReady -eq 1)
        {
            $n = 0
            while ($n -lt $DataLoadIterations) {
                Write-Log -Message "Other process is loading data. Waiting $DataLoadTimeout seconds" -Path $exportCurrentLog -Level Info
                if (VerifyIfDBIsReady -eq 1) { Start-Sleep -Seconds $DataLoadTimeout } 
                else {
                Write-Log -Message "Resouces released. Moving forward with creating view." -Path $exportCurrentLog -Level Info
                $n = $DataLoadIterations}
                $n += 1
            }

            if (VerifyIfDBIsReady -eq 1 -and $n -eq $DataLoadIterations) {
            Write-Log -Message "Process timed out while waiting for view to be released." -Path $exportCurrentLog -Level Info
            SendMail "File servers report."
            break}
        }
        
        

        Write-Log -Message "Creating view." -Path $exportCurrentLog -Level Info
        Execute-SQLStatement ($Query_createView)

        Write-Log -Message "Processing data." -Path $exportCurrentLog -Level Info
        Execute-SQLStatement ($query_ProcessData +$auth)

        Write-Log -Message "Dropping table: $tableNAme" -Path $exportCurrentLog -Level Info
        Execute-SQLStatement ($query_dropTable)

        Write-Log -Message "Dropping View." -Path $exportCurrentLog -Level Info
        Execute-SQLStatement ($query_dropView)

        Write-Log -Message "Cleaning network drive." -Path $exportCurrentLog -Level Info
        try
        {
            $file=$destinationPath+"\"+$OutputFile
            Remove-Item $file
        }
        catch [System.Net.WebException],[System.Exception]
        {
            Write-log -Message "Cannot remove file $file" -Path $exportCurrentLog -level Error
        }
    }
}
else
{
    Write-Log -Message "Something went wrong with prerequisites. Check if you have connection or if is authorized." -Path $exportCurrentLog -Level Error
}
SendMail "File servers report."
Get-Content $exportCurrentLog  >>  $exportLog