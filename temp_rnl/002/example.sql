IF OBJECT_ID ( '[acuity].[sp_<table>]' ) IS NOT NULL  --to be replaced
    DROP PROCEDURE [acuity].[sp_<table>];  --to be replaced
GO  

CREATE PROC [acuity].[sp_<table>] AS BEGIN --to be replaced
  BEGIN TRANSACTION
    DECLARE @validate_query_result INT;
    DECLARE @ErrorMessage NVARCHAR(4000);  
    DECLARE @ErrorSeverity INT;  
    DECLARE @ErrorState INT; 
    DECLARE @initial_time DATETIME;
    DECLARE @final_time DATETIME;
    DECLARE @time_diff_seconds FLOAT;
    DECLARE @table_name NVARCHAR(4000); 

    BEGIN TRY  
            
      SET @initial_time  = CURRENT_TIMESTAMP;
      SET @table_name = '<table>'; --to be replaced 

      DELETE FROM [acuity].[<table>]; --to be replaced

      <WITH CLAUSE> --to be replaced if applicable 
      INSERT INTO [acuity].[<table>] --to be replaced 
      <SELECT STATEMENT>;

      SET @validate_query_result =  (SELECT count(*) FROM [acuity].[<table>]); --to be replaced

      IF @validate_query_result = 0
          BEGIN
          RAISERROR (N'The query result is null.', -- Message text.
          16, -- Severity,
          1
          );
      END ;

      SET @final_time  = CURRENT_TIMESTAMP;
      SET @time_diff_seconds = DATEDIFF(microsecond,@initial_time,@final_time) /1000000.0 ;

      INSERT INTO [acuity].[execution_history]
        VALUES(@table_name,@validate_query_result,'Table has been updated successfully',@time_diff_seconds , 'true', @final_time)
      

      COMMIT; 
      PRINT 'Table has been updated successfully'
    END TRY  
    
    BEGIN CATCH  
      ROLLBACK;
            
      SELECT   
          @ErrorMessage = ERROR_MESSAGE(),  
          @ErrorSeverity = ERROR_SEVERITY(),  
          @ErrorState = ERROR_STATE();  
        
      RAISERROR (@ErrorMessage, 
              @ErrorSeverity, 
              @ErrorState 
              ); 

      SET @final_time  = CURRENT_TIMESTAMP;
      SET @time_diff_seconds = DATEDIFF(microsecond,@initial_time,@final_time) /1000000.0 ;
            
      INSERT INTO [acuity].[execution_history]
        VALUES(@table_name,@validate_query_result,@ErrorMessage,@time_diff_seconds , 'false', @final_time)
    END CATCH
END
GO