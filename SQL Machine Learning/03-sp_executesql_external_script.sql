-----
----- como usar sp_executesql_external_script 
-----

-- Call the external script execution – 
-- note, must be enabled already execute 
-- sp_execute_external_script     
-- Set the language to R @language = N'R'   
-- Set a variable for the R code, 
-- in this case simply making output equal to input
-- , @script = N' OutputDataSet <- InputDataSet;'     
-- Set a variable for the T-SQL statement that will 
-- obtain the data     , 
-- @input_data_1 = N' SELECT * FROM MyTable;'     
-- Return the data – in this case, a set of integers 
-- with a column name     
-- WITH RESULT SETS (([NewCollumnName] int NOT NULL)); 

EXEC sp_execute_external_script
  @language = N'R',
  @script = N'print(''Hello World'')'
GO

-- usando una tabla como entrada

execute sp_execute_external_script   
@language = N'R' -- lenguaje (r o Python) 
, @script = N' OutputDataSet <- InputDataSet;' -- salida en un dataset   
, @input_data_1 = N' SELECT name FROM sys.databases;'  -- input
WITH RESULT SETS (([BASE] nvarchar(max) NOT NULL)); -- resultset

--- con python
EXEC sp_execute_external_script  @language =N'Python',
@script=N'OutputDataSet=InputDataSet',
@input_data_1 = N'SELECT name FROM sys.databases'


-- usando iris dataset 
-- library(help="datasets")

EXECUTE sp_execute_external_script
   @language = N'R',
   @script = N'OutputDataSet <- head(iris)',
   @input_data_1 = N''
WITH RESULT SETS (([Sepal.Length] float, [Sepal.Width] float,
                   [Petal.Length] float, [Petal.Width] float,
                   [Species] varchar(25)));

---- creando un modelo predictivo
use tempdb
go

CREATE TABLE CarSpeed ([speed] int not null, 
                       [distance] int not null);

INSERT INTO CarSpeed
EXEC sp_execute_external_script
        @language = N'R'
        , @script = N'car_speed <- cars;'
        , @input_data_1 = N''
        , @output_data_1_name = N'car_speed'

select * from CarSpeed

-- crear un modelo de regresion lineal 
DROP PROCEDURE IF EXISTS generate_linear_model;
GO
CREATE PROCEDURE generate_linear_model
AS
BEGIN
    EXEC sp_execute_external_script
    @language = N'R'
   ,@script = N'lrmodel <- rxLinMod(formula = distance ~ speed, data = CarsData);
    trained_model <- data.frame(payload = as.raw(serialize(lrmodel, connection=NULL)));'
    , @input_data_1 = N'SELECT [speed], [distance] FROM CarSpeed'
    , @input_data_1_name = N'CarsData'
    , @output_data_1_name = N'trained_model'
    WITH RESULT SETS ((model varbinary(max)));
END;
GO

-- guardar el modelo

CREATE TABLE stopping_distance_models (
    model_name varchar(30) not null default('default model') primary key,
    model varbinary(max) not null);

INSERT INTO stopping_distance_models (model)
EXEC generate_linear_model;

select * from stopping_distance_models

--- predecir distancia de frenado
-- con el modelo anterior vamos a predecir la distancia de frenado para nuevas
-- velocidades ya que las del modelo son de autos de 1920

CREATE TABLE [dbo].[NewCarSpeed]([speed] [int] NOT NULL,
    [distance] [int]  NULL) ON [PRIMARY]
GO
INSERT [dbo].[NewCarSpeed] (speed)
VALUES (40),  (50),  (60), (70), (80), (90), (100)

-- predecimos con el modelo guardado anteriormente en la tabla
DECLARE @speedmodel varbinary(max) = 
(SELECT model FROM [dbo].[stopping_distance_models]);

EXEC sp_execute_external_script
@language = N'R'
, @script = N'
             current_model <- unserialize(as.raw(speedmodel));
             new <- data.frame(NewCarData);
             predicted.distance <- rxPredict(current_model, new);
             str(predicted.distance);
             OutputDataSet <- cbind(new, ceiling(predicted.distance));
            '
 , @input_data_1 = N' SELECT speed FROM [dbo].[NewCarSpeed] '
 , @input_data_1_name = N'NewCarData'
 , @params = N'@speedmodel varbinary(max)'
 , @speedmodel = @speedmodel
 WITH RESULT SETS (([new_speed] INT, [predicted_distance] INT))

 -- paralelizando el procesamiento 
 DECLARE @speedmodel varbinary(max) = (select model from [dbo].[stopping_distance_models] where model_name = 'default model');
EXEC sp_execute_external_script
    @language = N'R'
    , @script = N'
            current_model <- unserialize(as.raw(speedmodel));
            new <- data.frame(NewCarData);
            predicted.distance <- rxPredict(current_model, new);
            OutputDataSet <- cbind(new, ceiling(predicted.distance));
            '
    , @input_data_1 = N' SELECT [speed] FROM [dbo].[NewCarSpeed] '
    , @input_data_1_name = N'NewCarData'
    , @parallel = 1 -- usamos el procesamiento en paralelo
    , @params = N'@speedmodel varbinary(max)'
    , @speedmodel = @speedmodel
WITH RESULT SETS (([new_speed] INT, [predicted_distance] INT))

----------------------------------
---- haciendo un plot de salida (grafico)

EXECUTE sp_execute_external_script
 @language = N'R'
 , @script = N'
     imageDir <- ''c:\\tmp\\plot'';
     image_filename = tempfile(pattern = "plot_", tmpdir = imageDir, fileext = ".jpg")
     print(image_filename);
     jpeg(filename=image_filename,  width=600, height = 800);
     print(plot(distance~speed, data=InputDataSet, xlab="Speed", ylab="Stopping distance", main = "1920 Car Safety"));
     abline(lm(distance~speed, data = InputDataSet));
     dev.off();
     OutputDataSet <- data.frame(data=readBin(file(image_filename, "rb"), what=raw(), n=1e6));
     '
  , @input_data_1 = N'SELECT speed, distance from [dbo].[CarSpeed]'
  WITH RESULT SETS ((plot varbinary(max)));