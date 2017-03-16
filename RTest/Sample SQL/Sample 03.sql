/* ---------- R and SQL Data Types and Data Objects ----------

	In this step, you'll learn about some common issues that arise when moving data between R and SQL Server.
		-> Data types sometimes do not match
		-> Implicit conversions are performed
		-> Cast and convert operations are sometimes required
		-> R and SQL use different data objects
*/

EXECUTE sp_execute_external_script	@language = N'R'
									,@script = N' mytextvariable <- c("hello", " ", "world");  
	   OutputDataSet <- as.data.frame(mytextvariable);'
									,@input_data_1 = N' ';

EXECUTE sp_execute_external_script	@language = N'R'
									,@script = N' OutputDataSet<- data.frame(c("hello"), " ", c("world"));'
									,@input_data_1 = N'  ';

/*
	If you look at the results of the above two scripts, though the scripts doesn't seem to be different, the results speak otherwise.
	
	Why are the results so different?
	The answer can usually be found by using the R str() command. Add the function str(object_name) anywhere in your R script to have the data schema of the specified R object returned as an informational message. To view messages, see in the Messages pane of Visual Studio Code, or the Messages tab in SSMS.
To figure out why Example 1 and Example 2 have such different results, insert the line str(OutputDataSet) at the end of the @script variable definition in each statement, like this:
*/


-- Call the external script execution – note, must be enabled already

EXECUTE sp_execute_external_script
-- Set the language to R
	@language = N'R'
	-- Set a variable for the R code, in this case simply making output equal to input
	,@script = N' OutputDataSet <- InputDataSet;'
	-- Set a variable for the T-SQL statement that will obtain the data
	,@input_data_1 = N' SELECT * FROM MyTable;'
-- Return the data – in this case, a set of integers with