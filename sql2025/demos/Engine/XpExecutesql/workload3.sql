EXECUTE sp_executesql
    N'SELECT * FROM AdventureWorks2022.HumanResources.Employee
    WHERE BusinessEntityID = @level',
    N'@level TINYINT',
    @level = 3;
GO

