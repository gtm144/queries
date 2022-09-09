IF OBJECT_ID ( '[acuity].[sp_s_cpi_039_inquiry_cpi]', 'P' ) IS NOT NULL   
    DROP PROCEDURE [acuity].[sp_s_cpi_039_inquiry_cpi];  
GO  

CREATE PROC [acuity].[sp_s_cpi_039_inquiry_cpi] AS BEGIN
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
		    SET @table_name = 's_cpi_039_inquiry_cpi'; 

            DELETE FROM [acuity].[s_cpi_039_inquiry_cpi];
		
            INSERT INTO [acuity].[s_cpi_039_inquiry_cpi] 
            SELECT [s_cpi_024_inquiry_cpi].[leadid]
                ,ISNULL([s_cpi_024_inquiry_cpi].[inquiry_cost],0.00) + ISNULL([s_cpi_036_diff_sc].[additional_cpi],0.00) AS [inquiry_cost]
                ,[s_cpi_024_inquiry_cpi].[id_customer]
                ,[s_cpi_024_inquiry_cpi].[id_sourcecampaign]
                ,[s_cpi_024_inquiry_cpi].[id_vendor]
                ,[s_cpi_024_inquiry_cpi].[id_channel]
                ,[s_cpi_024_inquiry_cpi].[month]
                ,[s_cpi_024_inquiry_cpi].[year]
                ,[s_cpi_024_inquiry_cpi].[inquiry_cost] AS [prior_inquiry_cost]
            FROM [acuity].[s_cpi_024_inquiry_cpi]
            LEFT OUTER JOIN
            [acuity].[s_cpi_036_diff_sc] 
            ON TRIM([s_cpi_036_diff_sc].[client_id]) = TRIM([s_cpi_024_inquiry_cpi].[id_customer])
                AND TRIM([s_cpi_036_diff_sc].[source_campaign_id]) = TRIM([s_cpi_024_inquiry_cpi].[id_sourcecampaign])
                AND TRIM([s_cpi_036_diff_sc].[vendorid]) = TRIM([s_cpi_024_inquiry_cpi].[id_vendor])
                AND TRIM([s_cpi_036_diff_sc].[channel_id]) = TRIM([s_cpi_024_inquiry_cpi].[id_channel])
                AND [s_cpi_036_diff_sc].[month] = [s_cpi_024_inquiry_cpi].[month]
                AND [s_cpi_036_diff_sc].[year] = [s_cpi_024_inquiry_cpi].[year]
                AND [s_cpi_036_diff_sc].[additional_cpi] != 0.00;

			SET @validate_query_result =  (SELECT count(*)
			FROM [acuity].[s_cpi_039_inquiry_cpi]);
			
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