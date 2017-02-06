$_SCRIPT_PATH = split-path -parent $MyInvocation.MyCommand.Definition;
$_DATABASE = 'ImdbMovies';
$_PROVIDER_NAME = 'System.Data.SqlClient';
$_CS = "Server=(localdb)\MSSQLLocalDB;Database=$_DATABASE;Trusted_Connection=True;";
[System.Reflection.Assembly]::LoadWithPartialName('System.Data.Common') | Out-Null;
[System.Reflection.Assembly]::LoadWithPartialName($_PROVIDER_NAME) | Out-Null;
$_PROVIDER = [System.Data.Common.DbProviderFactories]::GetFactory($_PROVIDER_NAME);

function use {
    [CmdletBinding()]
    param($obj, [scriptblock]$sb)

    try {
        &$sb;
    } finally {
        if ($obj -is [IDisposable]) { 
            $obj.Dispose();
        }
    }
}

Write-Host "creating [$_DATABASE] database";
# create DB
use ($c = $_PROVIDER.CreateConnection()) {
    $c.ConnectionString = "Server=(localdb)\MSSQLLocalDB;Database=master;Trusted_Connection=True;";
    $c.Open();
    use ($cmd = $c.CreateCommand()) {
        $cmd.CommandText = @"
CREATE DATABASE $_DATABASE  
ON   
( NAME = ImdbMovies,  
    FILENAME = '$_SCRIPT_PATH\..\$_DATABASE.mdf',  
    SIZE = 76MB,  
    MAXSIZE = 1024MB,  
    FILEGROWTH = 10MB )  
LOG ON  
( NAME = ImdbMovies_log,  
    FILENAME = '$_SCRIPT_PATH\..\$($_DATABASE)_log.ldf',  
    SIZE = 100MB,  
    MAXSIZE = 1024MB,  
    FILEGROWTH = 10% );
"@;
        $cmd.ExecuteNonQuery() | Out-Null;
    }
}
Write-Host 'done';

# setup && config 
use ($c = $_PROVIDER.CreateConnection()) {
    $c.ConnectionString = $_CS;
    $c.Open();

    # create table
    Write-Host 'creating [movie] table';
    use ($cmd = $c.CreateCommand()) {
        $cmd.CommandText = @'
CREATE TABLE dbo.movies (
  title nvarchar(512) NOT NULL,
  year int NOT NULL
);
'@;  
        $cmd.ExecuteNonQuery() | Out-Null;
    }
    Write-Host 'done';

    # enable CLR
    Write-Host 'enabling database CLR'
    use ($cmd = $c.CreateCommand()) {
        $cmd.CommandType = [System.Data.CommandType]::StoredProcedure;
        $cmd.CommandText = 'sp_configure';
        $cmd.Parameters.Add($cmd.CreateParameter()) | Out-Null;
        $cmd.Parameters[0].ParameterName = '@configname';
        $cmd.Parameters[0].Value = 'clr enabled';
        $cmd.Parameters.Add($cmd.CreateParameter()) | Out-Null;
        $cmd.Parameters[1].ParameterName = '@configvalue';
        $cmd.Parameters[1].Value = 1;
        $cmd.ExecuteNonQuery() | Out-Null;;
    }
    Write-Host 'done';

    # import data
    Write-Host 'importing IMDB movie title data';
    use ($cmd = $c.CreateCommand()) {
        $cmd.CommandText = @"
BULK INSERT movies
FROM '$_SCRIPT_PATH\movies.txt'
WITH (
    FIELDTERMINATOR = '\t',
    ROWTERMINATOR = '\n'
);
"@;
        $cmd.ExecuteNonQuery() | Out-Null;
    }
    Write-Host 'done';

    # create assembly
    Write-Host 'creating CLR assembly';
    use ($cmd = $c.CreateCommand()) {
        $cmd.CommandText = @"
DECLARE @dll_path varchar(8000);
SET @dll_path='$_SCRIPT_PATH\..\bin\Release\kuujinbo.SqlClr.dll';
EXEC('CREATE ASSEMBLY ClrUDF FROM '
  + '''' + @dll_path + ''''
  + ' WITH PERMISSION_SET=SAFE'
)
"@;
        $cmd.ExecuteNonQuery() | Out-Null;
    }

    # UDF => RegexMatch
    Write-Host 'creating RegexMatch UDF';
    use ($cmd = $c.CreateCommand()) {
        $cmd.CommandText = @'
CREATE FUNCTION RegexMatch(
-- ========================================
-- set regex options using inline syntax:
-- http://msdn.microsoft.com/en-us/library/yd1hzczs.aspx
-- ========================================
  @input NVARCHAR(4000),
  @pattern NVARCHAR(1024)
)
RETURNS BIT
-- return NULL if any input parameter(s) are NULL
WITH RETURNS NULL ON NULL INPUT
AS
EXTERNAL NAME ClrUDF.[kuujinbo.SqlClr.UDF].RegexMatch
'@;
        $cmd.ExecuteNonQuery() | Out-Null;
    }
    Write-Host 'done';

    # UDF => RegexReplace
    Write-Host 'creating RegexReplace UDF';
    use ($cmd = $c.CreateCommand()) {
        $cmd.CommandText = @'
CREATE FUNCTION RegexReplace(
-- ========================================
-- set regex options using inline syntax:
-- http://msdn.microsoft.com/en-us/library/yd1hzczs.aspx
-- ========================================
  @input NVARCHAR(4000),
  @pattern NVARCHAR(1024), 
  @replacement NVARCHAR(1024)
)
RETURNS NVARCHAR(4000)
-- return NULL if any input parameter(s) are NULL
WITH RETURNS NULL ON NULL INPUT
AS
EXTERNAL NAME ClrUDF.[kuujinbo.SqlClr.UDF].RegexReplace
'@;
        $cmd.ExecuteNonQuery() | Out-Null;
    }
    Write-Host 'done';
}