/* --------- Working with Inputs and Outputs -------------

When you want to run R code in SQL Server, you must wrap the R script in a system stored procedure, sp_execute_external_script. 
This stored procedure is used to start the R runtime in the context of SQL Server, which passes data to R, 
manages R user sessions securely, and returns any results to the client.

*/

-- Create a test database
-- Create a small table of test data by running the following T-SQL statement

CREATE TABLE RTestData ([col1] int not null) ON [PRIMARY]    
INSERT INTO RTestData   VALUES (1);    
INSERT INTO RTestData   VALUES (10);    
INSERT INTO RTestData   VALUES (100) ;    
GO

-- Now that the table has been created and data inserted, let us access the data using R script
-- run the following statement. It gets the data from the table, makes a round-trip through the R runtime, 
-- and returns the values with the column name, NewColName.

EXECUTE sp_execute_external_script    
	  @language = N'R'    
	, @script = N' OutputDataSet <- InputDataSet;'    
	, @input_data_1 = N' SELECT *  FROM RTestData;'    
	WITH RESULT SETS (([NewColName] int NOT NULL));

/*
----------- Some points about the above script ----------------
	-> The @language parameter defines the language extension to call, in this case, R.
	-> In the @script parameter, you define the commands to pass to the R runtime. 
		Your entire R script must be enclosed in this argument, as Unicode text. 
		You could also add the text to a variable of type nvarchar and then call the variable.
	-> InputDataSet and OutputDataSet are the default variable names for input & output variables.
		To define the input data associated with InputDatSet, you use the @input_data_1 variable.
	-> The data returned by the query is passed to the R runtime, which returns the data to SQL Server as a data frame.
	-> The WITH RESULT SETS clause defines the schema of the returned data table for SQL Server.
		In the above script, a column name as NewColName is returned, which is of type int.
*/

-- In this example, the names of the output and input variables for the stored procedure have been changed to SQL_Out and SQL_In.
EXECUTE sp_execute_external_script    
  @language = N'R'      
  , @script = N' SQL_out <- SQL_in;'    
  , @input_data_1 = N' SELECT 12 as Col;'    
  , @input_data_1_name  = N'SQL_In'    
  , @output_data_1_name =  N'SQL_Out'    
  WITH RESULT SETS (([NewColName] int NOT NULL));

/*
	If you execute the above code, you will get the error: 	"Error in eval(expr, envir, enclos) : object 'SQL_in' not found".
	If you are a developer, you might have guessed it by now. R is case sensitive. 
	In the example, the R script uses the variables SQL_in and SQL_out, 
		but the parameters to the stored procedure use the variables SQL_In and SQL_Out.

	Let us try correcting the SQL_in variable and execute the script again.
*/

EXECUTE sp_execute_external_script    
  @language = N'R'      
  , @script = N' SQL_out <- SQL_In;'    
  , @input_data_1 = N' SELECT 12 as Col;'    
  , @input_data_1_name  = N'SQL_In'    
  , @output_data_1_name =  N'SQL_Out'    
  WITH RESULT SETS (([NewColName] int NOT NULL));

/*
	Now we have a different error as below:
	"EXECUTE statement failed because its WITH RESULT SETS clause specified 1 result set(s), but the statement only sent 0 result set(s) at run time."

	This is a generic error that you'll see often while testing your R code. 
	It means that the R script ran successfully, but SQL Server got back no data, or got back wrong or unexpected data. 
	In this case, the output schema (the line beginning with WITH) specifies that one column of integer data should be returned, 
	but since R put the data in a different variable, nothing came back to SQL Server; hence, the error.

	------ Some points to remember -----
	-> Variable names must follow the rules for valid SQL identifiers.
	-> The order of the parameters is important. 
		You must specify the required parameters @input_data_1 and @output_data_1 first, 
		in order to use the optional parameters @input_data_1_name and @output_data_1_name.
	-> Only one input dataset can be passed as a parameter, and you can return only one dataset. 
		However, you can call other datasets from inside your R code and you can return outputs of other types in addition to the dataset. 
		You can also add the OUTPUT keyword to any parameter to have it returned with the results. 
	-> The WITH RESULT SETS statement defines the schema for the data, for the benefit of SQL Server. 
		You need to provide SQL compatible data types for each column you return from R. 
		You can use the schema definition to provide new column names too; you need not use the column names from the R data.frame. 
		In some cases this clause is optional; try omitting it and see what happens.
	-> In Management Studio, tabular results are returned in the Values pane. 
		Messages returned by the R runtime are provided in the Messages pane.
*/

------- Now let us try by generating results without input/output variables -----
EXECUTE sp_execute_external_script    
	@language = N'R'    
   , @script = N' mytextvariable <- c("hello", " ", "world");  
	   OutputDataSet <- as.data.frame(mytextvariable);'    
   , @input_data_1 = N' SELECT 1 as Temp1'    
   WITH RESULT SETS (([Col1] char(20) NOT NULL));    

/*
	In the above example, you can see that values are generated using just the R script.
	Either you can leave the input query string in @input_data_1 blank, Or use a valid SQL SELECT statement as a placeholder, 
	and not use the SQL results in the R script.
*/