/*
SQL 2025 fuzzy string

EDIT_DISTANCE

	Calcula el número de inserciones, eliminaciones, 
	sustituciones y transposiciones necesarias 
	para transformar una cadena a otra.

EDIT_DISTANCE_SIMILARITY

	Calcula un valor de similitud comprendido 
	entre 0 (que indica ninguna coincidencia) 
	y 100 (lo que indica la coincidencia completa).

JARO_WINKLER_DISTANCE

	Calcula la distancia de edición entre 
	dos cadenas que dan preferencia a las cadenas 
	que coinciden desde el principio para una 
	longitud de prefijo establecida

JARO_WINKLER_SIMILARITY

	Calcula un valor de similitud comprendido 
	entre 0 (que indica ninguna coincidencia) a 1 
	(lo que indica la coincidencia completa).

*/

use tempdb 
go

drop table if exists WordPairs

-- Step 1: Create the table
CREATE TABLE WordPairs (
    WordID INT IDENTITY(1,1) PRIMARY KEY, -- Auto-incrementing ID
    WordUK NVARCHAR(50), -- UK English word
    WordUS NVARCHAR(50)  -- US English word
);

-- Step 2: Insert the data
INSERT INTO WordPairs (WordUK, WordUS) VALUES
('Colour', 'Color'),
('Flavour', 'Flavor'),
('Centre', 'Center'),
('Theatre', 'Theater'),
('Organise', 'Organize'),
('Analyse', 'Analyze'),
('Catalogue', 'Catalog'),
('Programme', 'Program'),
('Metre', 'Meter'),
('Honour', 'Honor'),
('Neighbour', 'Neighbor'),
('Travelling', 'Traveling'),
('Grey', 'Gray'),
('Defence', 'Defense'),
('Practise', 'Practice'), -- Verb form in UK
('Practice', 'Practice'), -- Noun form in both
('Aluminium', 'Aluminum'),
('Cheque', 'Check'); -- Bank cheque vs. check

--- EDIT_DISTANCE

SELECT WordUK, WordUS, EDIT_DISTANCE(WordUK, WordUS) AS Distance
FROM WordPairs
ORDER BY Distance ASC;

SELECT WordUK, WordUS, EDIT_DISTANCE(WordUK, WordUS) AS Distance
FROM WordPairs
WHERE EDIT_DISTANCE(WordUK, WordUS) <= 2
ORDER BY Distance ASC;

--- EDIT_DISTANCE_SIMILARITY

SELECT WordUK, WordUS, EDIT_DISTANCE_SIMILARITY(WordUK, WordUS) AS Similarity
FROM WordPairs
ORDER BY Similarity DESC;

SELECT WordUK, WordUS, EDIT_DISTANCE_SIMILARITY(WordUK, WordUS) AS Similarity
FROM WordPairs
WHERE EDIT_DISTANCE_SIMILARITY(WordUK, WordUS) >=75
ORDER BY Similarity DESC;

--- JARO_WINKLER_DISTANCE

SELECT WordUK, WordUS, JARO_WINKLER_DISTANCE(WordUK, WordUS) AS Distance
FROM WordPairs
ORDER BY Distance ASC;

SELECT WordUK, WordUS, JARO_WINKLER_DISTANCE(WordUK, WordUS) AS Distance
FROM WordPairs
WHERE JARO_WINKLER_DISTANCE(WordUK, WordUS) <= .05
ORDER BY Distance ASC;

--- JARO_WINKLER_SIMILARITY

SELECT WordUK, WordUS, JARO_WINKLER_SIMILARITY(WordUK, WordUS) AS Similarity
FROM WordPairs
ORDER BY  Similarity DESC;

SELECT WordUK, WordUS, JARO_WINKLER_SIMILARITY(WordUK, WordUS) AS Similarity
FROM WordPairs
WHERE JARO_WINKLER_SIMILARITY(WordUK, WordUS) > 0.9
ORDER BY  Similarity DESC;

-- Todas las funciones

SELECT	T.source_string,
		T.target_string,
		EDIT_DISTANCE(T.source_string, T.target_string) as ED_Distance,
		JARO_WINKLER_DISTANCE(T.source_string, T.target_string) as JW_Distance,
		EDIT_DISTANCE_SIMILARITY(T.source_string, T.target_string) as ED_Similarity,
		CAST(JARO_WINKLER_SIMILARITY(T.source_string, T.target_string)*100 as int) as JW_Similarity
FROM (VALUES('Black', 'Red'),
			('Colour', 'Yellow'),
			('Colour', 'Color'),
			('Microsoft', 'Msft'),
			('Regex', 'Regex')) 
as T(source_string, target_string);