--- instalar librerias externas

/*
 INSTALAR LAS LIBRERIAS DE R

 "C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\R_SERVICES\bin\x64\Rgui.exe"
 lib.SQL <- "C:\\Program Files\\Microsoft SQL Server\\MSSQL14.MSSQLSERVER\\R_SERVICES\\library"  
 install.packages("igraph", lib = lib.SQL)  
 install.packages("jsonlite", lib = lib.SQL)
 install.packages("magrittr", lib = lib.SQL) 

 C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\R_SERVICES\library

*/

drop database if exists demo_r

create database demo_r
go

use demo_r
go

-----------------------
-- schema
-----------------------

-- This script creates a new database and creates the tables and stored procedures in it.

CREATE TABLE dbo.Node
( 
    Id int NOT NULL PRIMARY KEY, 
    Name varchar(50) NULL
)
GO

CREATE TABLE dbo.Edge
(
    FromNode int NOT NULL REFERENCES dbo.Node (Id), 
    ToNode int NOT NULL REFERENCES dbo.Node (Id), 
    [Weight] decimal (10, 3) NULL,
    PRIMARY KEY CLUSTERED (FromNode ASC, ToNode ASC)
)
GO


INSERT INTO DBO.NODE (ID,NAME)
VALUES (1,'A') ,(2,'B'), (3,'C'), (4,'D')

-- DISTANCIAS ENTRE ALGUNOS PUNTOS

INSERT INTO [dbo].[Edge] (FromNode,ToNode,Weight)
values (1,2,10),(2,1,10),
(1,4,50),(4,1,50),
(2,3,15),(3,2,15),
(4,3,5),(3,4,5)

/*
 INSTALAR LAS LIBRERIAS DE R

 "C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\R_SERVICES\bin\x64\Rgui.exe"
 lib.SQL <- "C:\\Program Files\\Microsoft SQL Server\\MSSQL14.MSSQLSERVER\\R_SERVICES\\library"  
 install.packages("igraph", lib = lib.SQL)  
 install.packages("jsonlite", lib = lib.SQL)
 install.packages("magrittr", lib = lib.SQL) 

 C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\R_SERVICES\library

*/

-- using R 
declare @SourceIdent nvarchar(255) = 'A'
declare @DestIdent nvarchar(255) = 'D'

declare @sourceId int = (select Id from Node where Name = @SourceIdent)
declare @destId int = (select Id from Node where Name = @DestIdent)

DECLARE @RScript nvarchar(max)
SET @RScript = CONCAT(N'
library(igraph)
library(jsonlite)

mynodes <- fromJSON(Nodes)
myedges <- fromJSON(Edges)

destNodeId <- ', @destId,'
destNodeName <- subset(mynodes, Id == destNodeId)

g <- graph.data.frame(myedges, vertices=mynodes, dir = FALSE)

(tmp2 = get.shortest.paths(g, from=''', @sourceId, ''', to=''',@destId , ''', output = "both", weights = E(g)$Weight))

TotalDistance <- sum(E(g)$Weight[tmp2$epath[[1]]])

PathIds <- paste(as.character(tmp2$vpath[[1]]$name), sep="''", collapse=",")
PathNames <- paste(as.character(tmp2$vpath[[1]]$Name), sep="''", collapse=",")

OutputDataSet <- data.frame(Id = destNodeId, Name = destNodeName$Name, Distance = TotalDistance, Path = PathIds, NamePath = PathNames)
')

DECLARE @NodesInput VARCHAR(MAX) = (SELECT * FROM dbo.Node FOR JSON AUTO);
DECLARE @EdgesInput VARCHAR(MAX) = (SELECT * FROM dbo.Edge FOR JSON AUTO);
declare @distOut float
DECLARE @PathIdsOut VARCHAR(MAX)
DECLARE @PathNamesOut VARCHAR(MAX)

EXECUTE sp_execute_external_script
@language = N'R',
@script = @RScript,
@input_data_1 = N'SELECT 1',
@params = N'@Nodes varchar(max), @Edges varchar(max), @TotalDistance float OUTPUT, @PathIds varchar(max) OUTPUT, @PathNames varchar(max) OUTPUT',
@Nodes = @NodesInput, @Edges = @EdgesInput, @TotalDistance = @distOut OUTPUT, @PathIds = @PathIdsOut OUTPUT, @PathNames = @PathNamesOut OUTPUT
WITH RESULT SETS (( Id int, Name varchar(500), Distance float, [Path] varchar(max) , NamePath varchar(max)))

-- here we format the result in different units of distance - miles and nautical miles
SELECT @distOut * 0.00062137 AS DistanceInMiles, @distOut * 0.00053996 AS DistanceInNauticalMiles

