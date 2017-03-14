-- Using R Code in Transact-SQL (SQL Server R Services)
-- Am using Visual Studio with R Tools plugin
-- You must have access to an instance of SQL Server where R Services is already installed, for all the samples in this project.

-- Create a sqlquery file. Connect to the database server and setup the database as you would do in SSMS.
-- Execute the below query. 
-- If all went through fine, then you have executed your first R code by calling it using sp_execute_external_script and wrapping
-- your R code within it.

EXEC sp_execute_external_script  
  @language =N'R',    
  @script=N'OutputDataSet<-InputDataSet',      
  @input_data_1 =N'SELECT 1 AS hello'    
  WITH RESULT SETS (([hello] int not null));    
GO    