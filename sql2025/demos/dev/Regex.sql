/*
SQL 2025 Regex


REGEXP_LIKE 
REGEXP_REPLACE
REGEXP_SUBSTR
REGEXP_INSTR
REGEXP_COUNT
REGEXP_MATCHES
REGEXP_SPLIT_TO_TABLE
*/

/*
 REGEXP_LIKE
 Indica si el patrón de expresión regular coincide en una cadena.
*/
use AdventureWorks2022 
go

sp_helpindex 'Person.person'


-- Seleccione todos los registros de la tabla donde el nombre comienza por M y	 termina con Z


SELECT * FROM person.person 
WHERE REGEXP_LIKE (LastName, '^M.*Z$');

SELECT LastName FROM person.person 
WHERE REGEXP_LIKE (LastName, '^M.*Z$');

/*
REGEXP_REPLACE

Devuelve una cadena de origen modificada reemplazada por una cadena de 
reemplazo, donde se encontró la aparición del patrón de expresión regular. 
Si no se encuentra ninguna coincidencia, la función devuelve la cadena original.
*/

--  Reemplace todas las apariciones de a o e por X.

SELECT REGEXP_REPLACE(LastName, '[ae]', 'X', 1, 0, 'i') as c1, LastName
FROM person.Person;

-- Reemplace los últimos cuatro dígitos de los números de teléfono por asteriscos
SELECT 
PhoneNumber,
REGEXP_REPLACE(PhoneNumber, '\d{4}$', '****')
FROM [Person].[PersonPhone]


/*
 REGEXP_SUBSTR
	Devuelve una aparición de una subcadena de una cadena que coincide con el
	patrón de expresión regular. 
	Si no se encuentra ninguna coincidencia, devuelve NULL
*/
 -- Sacamos el Dominio de un mail
SELECT 
EmailAddress,
REGEXP_SUBSTR(EmailAddress, '@(.+)$', 1, 1, 'i', 1) AS DOMAIN
FROM person.EmailAddress;

/*
 REGEXP_INSTR 
	Devuelve la posición inicial o final de la subcadena coincidente, 
	según el valor del argumento return_option.
*/

-- Busque la posición de la tercera aparición de la letra a (sin distinción entre mayúsculas y minúsculas) en la columna NAME.
SELECT name,REGEXP_INSTR(name, 'a', 1, 3, 0, 'i')
FROM Production.Product;

/*
 REGEXP_COUNT 
	Cuenta el número de veces que un patrón de expresión 
	regular coincide en una cadena.
*/

-- Contar cuántas veces aparece la letra a en cada nombre de producto.
SELECT NAME,
       REGEXP_COUNT(NAME, 'a') AS A_COUNT
FROM Production.Product;

-- Contar cuántos productos tienen un nombre que contiene tres consonantes consecutivos, ignorando mayúsculas y minúsculas.

SELECT COUNT(*)
FROM Production.Product
WHERE REGEXP_COUNT(NAME, '[^aeiou]{3}', 1, 'i') > 0;

/*
 REGEXP_MATCHES 
	Devuelve una tabla de subcadenas capturadas que coinciden 
	con un patrón de expresión regular con una cadena. 
	Si no se encuentra ninguna coincidencia, la función 
	no devuelve ninguna filana.
*/

--Devuelve resultados tabulares de 'Learning #AzureSQL #AzureSQLDB' ese principio con un # carácter seguido de uno o varios caracteres alfanuméricos (A-Z, a-z, 0-9) o caracteres de subrayado (_).

SELECT *
FROM 
REGEXP_MATCHES('Learning #AzureSQL #AzureSQLDB', '#([A-Za-z0-9_]+)');

--Devuelve cadenas de ABC que coinciden con cadenas que comienzan con la letra A seguida de exactamente dos caracteres.

SELECT *
FROM REGEXP_MATCHES('ABC', '^(A)(..)$');


/*
 REGEXP_SPLIT_TO_TABLE 
	Devuelve una tabla de cadenas dividida, 
	delimitada por el patrón regex. 
	Si no hay ninguna coincidencia con el patrón, la función devuelve la cadena
*/

-- Devuelve una división de tabla para "Evento SQL 2025 Argentina".

SELECT *
FROM REGEXP_SPLIT_TO_TABLE('Evento SQL 2025 Argentina', '\s+');