/*									---------- Create a Predictive Model ----------
	In this sample, let us learn how to train a model using R, and then save the model to a table in SQL Server. 
	The model is a simple regression model that predicts the stopping distance of a car based on speed. 
	You'll use the cars dataset already included with R, because it is small and easy to understand.
*/
------------- Create the source data
--First, create a table to save the training data.
CREATE TABLE CarSpeed (
	[speed] INT NOT NULL
	,[distance] INT NOT NULL
)
INSERT INTO CarSpeed
EXEC sp_execute_external_script	
	@language = N'R'
	,@script = N'car_speed <- cars;'
	,@input_data_1 = N''
	,@output_data_1_name = N'car_speed'

/* 
	If you want to use temporary tables, be aware that some R clients will disconnect sessions between batches.
	Many datasets, small and large, are included with the R runtime. 
	To get a list of datasets installed with R, type library(help="datasets") from an R command prompt.