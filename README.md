# kuujinbo.SqlClr
Simple starter code to enable per-database SQL Server CLR Integration, with two user-defined functions (UDF) to support a curiously missing feature in SQL Server that pretty much every other RDBMS supports:

1. RegexMatch
2. RegexReplace

## Simple Setup
1. Unzip `movies.zip`
2. Run `setup.ps1` Powershell script to create and setup database and objects. Default DB and log files are located in top-level project directory
3. See `usage.sql` for example usage.
4. For more info see [SQL Server CLR Integration](https://en.wikipedia.org/wiki/SQL_CLR).
