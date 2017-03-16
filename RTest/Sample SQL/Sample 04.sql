/*									---------- Using R Functions with SQL Server Data -----------------

	Many advanced statistical functions might be very complicated to implement using T-SQL, but can be run using a single line of R code. 
	With R Services, it's easy to embed R utility scripts in a stored procedure.
	
	In this sample, let us use some R mathematical and utility functions in SQL Server and embed the calls in a stored procedure.
*/

/* ------ Create a stored procedure to generate random numbers ------
	For simplicity, let us use the R stats package, which is installed and loaded by default with R Services. 
	The package contains hundreds of functions for common statistical tasks, among them the rnorm function, 
	which generates some number of random numbers in a normal distribution, given a standard deviation and mean.
	
	For example, this R code returns 100 numbers on a mean of 50, given a standard deviation of 3.
		as.data.frame(rnorm(100, mean = 50, sd = 3));
	
	To call this line of R from T-SQL, you just use sp_execute_external_script and put the function call in the R script parameter, like this:
*/

EXEC sp_execute_external_script    
	  @language = N'R'    
	, @script = N' OutputDataSet <- as.data.frame(rnorm(100, mean = 50, sd =3));'    
	, @input_data_1 = N'   ;'    
	  WITH RESULT SETS (([Density] float NOT NULL));    

/*	What if you'd like to make it easier to generate a different set of random numbers? 
	That's easy: define a stored procedure that gets the function arguments from the user, and passes those values into the R script as variables.

CREATE PROCEDURE MyRNorm (@param1 int, @param2 int, @param3 int)
AS
    EXEC sp_execute_external_script    
      @language = N'R'    
    , @script = N' OutputDataSet <- as.data.frame(rnorm(mynumbers, mymean, mysd));'    
    , @input_data_1 = N'   ;' 
    , @params = N' @mynumbers int, @mymean int, @mysd int'  
    , @mynumbers = @param1
    , @mymean = @param2
    , @mysd = @param3
    WITH RESULT SETS (([Density] float NOT NULL));

	=> The first line defines each of the SQL input parameters that are required when the stored procedure is executed.
	=> The line beginning with @params defines all variables used by the R code, and the corresponding SQL data types.
	=> The lines that immediately follow map the SQL parameter names to the corresponding R variable names.
	
	By wrapping the R function in a stored procedure, you can easily call any well-defined R function from SQL code and pass in different values, like this:
		EXEC MyRNorm @param1 = 100,@param2 = 50, @param3 = 3

*/