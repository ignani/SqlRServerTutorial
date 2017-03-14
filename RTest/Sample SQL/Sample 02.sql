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
-- run the following statement. It gets the data from the table, makes a round-trip through the R runtime, and returns the values with the column name, NewColName.