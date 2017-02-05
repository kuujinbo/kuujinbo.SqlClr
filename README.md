# kuujinbo.SqlClr
Simple starter code to enable per-database SQL Server CLR Integration with two user-defined functions (UDF) that support SQL Server's missing [regular expression](https://en.wikipedia.org/wiki/Regular_expression) functionality, which is included with every other major [RDBMS](https://en.wikipedia.org/wiki/Relational_database_management_system):

1. RegexMatch
2. RegexReplace

## Simple Setup
1. Unzip `movies.zip`
2. Build the solution in `Release` configuration.
3. Run `setup.ps1` Powershell script to create and setup database and objects. Default DB and log files are located in top-level project directory; SQL Server LocalDB (Visual Studio) is used for the backend.
4. See `usage.sql` for examples.
5. For more info see [SQL Server CLR Integration](https://en.wikipedia.org/wiki/SQL_CLR).