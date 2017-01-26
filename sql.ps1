$ServerName = "LTF11000\MSSQLSERVER2014"
$DatabaseName = "ITInfra"
#Random generation of table name
$ExportCSV = 'c:\temp\slc\c-drive3.csv'
$SQLFormatFile = 'c:\temp\temp4.fmt'

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

$query_bulLoad=" `
BULK INSERT [slc].["+$tableNAme+"] `
FROM '"+$ExportCSV+"' `
WITH ( `
FORMATFILE = '"+$SQLFormatFile+"', FIRSTROW = 2 ,DATAFILETYPE = 'widechar')"



$query_drop=" `
select top 2  * from [slc].["+$tableNAme+"] `
drop table [slc].["+$tableNAme+"]"



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

if ((Test-SQLConnection $ConnectionString) -eq $true)
{
Write-Host "Creating table: $tableNAme"
Execute-SQLStatement ($query)

Write-Host "Inserting data into table: $tableNAme"
Execute-SQLStatement ($query_bulLoad)

Write-Host "Dropping table: $tableNAme"
Execute-SQLStatement ($query_drop)

}
else
{
Write-Host "ERROR: No Connection to $serverName" 
}

function Execute-SQLStatement ($Query)
{
    $conn2=New-Object System.Data.SqlClient.SQLConnection
    $conn2.ConnectionString=$ConnectionString
    $conn2.Open()
    $cmd=New-Object system.Data.SqlClient.SqlCommand($Query,$conn2)
    $cmd.CommandTimeout=$QueryTimeout
    $ds=New-Object system.Data.DataSet
    $da=New-Object system.Data.SqlClient.SqlDataAdapter($cmd)
    [void]$da.fill($ds)
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


