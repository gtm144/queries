IF OBJECT_ID ( '[acuity].[sp_s_cpi_012_h_cpi]' ) IS NOT NULL   
    DROP PROCEDURE [acuity].[sp_s_cpi_012_h_cpi];  
GO  

CREATE PROC [acuity].[sp_s_cpi_012_h_cpi] AS BEGIN
    BEGIN TRANSACTION

        DECLARE @ErrorMessage NVARCHAR(4000);  
        DECLARE @ErrorSeverity INT;  
        DECLARE @ErrorState INT; 
        DECLARE @initial_time DATETIME;
        DECLARE @final_time DATETIME;
        DECLARE @time_diff_seconds FLOAT;
        DECLARE @table_name NVARCHAR(4000); 
        DECLARE @validate_query_result INT;

        BEGIN TRY  


            SET @initial_time  = CURRENT_TIMESTAMP;
		    SET @table_name = 's_cpi_012_h_cpi';

            
            DELETE FROM [acuity].[s_cpi_012_h_cpi]; 

            INSERT INTO [acuity].[s_cpi_012_h_cpi]
            SELECT CAST([s_ep_historical_spend].[id_customer] AS [nvarchar](250)) AS [id_customer]
            ,CAST([s_ep_historical_spend].[id_channel] AS [nvarchar](250)) AS [id_channel]
            ,[s_ep_historical_spend].[month] AS [month]
            ,[s_ep_historical_spend].[year] AS [year]
            ,CAST([s_ep_historical_spend].[sourceid] AS [nvarchar](250)) AS [sourceid]
            ,CAST([s_ep_historical_spend].[sourcecampaignid] AS [nvarchar](250)) AS [sourcecampaignid]
            ,[s_ep_historical_spend].[actual_spend] AS [actual_spend],
            CASE 
                WHEN s_cpi_005_h_scrubbed.[h_scrubbed] IS NOT NULL THEN FLOOR((CAST(s_ep_historical_spend.[actual_spend] AS FLOAT)/ CAST(s_cpi_005_h_scrubbed.[h_scrubbed] AS FLOAT))*100) / 100
            END AS [cpi]
            FROM [planning].[s_ep_historical_spend]
            INNER JOIN [acuity].[s_cpi_005_h_scrubbed]
                        ON
                            [s_cpi_005_h_scrubbed].[client_id] = CAST([s_ep_historical_spend].[id_customer] AS [nvarchar](250))
                                AND [s_cpi_005_h_scrubbed].[sourceid] = CAST([s_ep_historical_spend].[sourceid] AS [nvarchar](250))
                                AND [s_cpi_005_h_scrubbed].[source_campaign_id] = CAST([s_ep_historical_spend].[sourcecampaignid] AS [nvarchar](250))                    
                                AND [s_cpi_005_h_scrubbed].[month] = [s_ep_historical_spend].[month] 
                                AND [s_cpi_005_h_scrubbed].[year] = [s_ep_historical_spend].[year] ;

			
            SET @validate_query_result =  (SELECT count(*)FROM [acuity].[s_cpi_012_h_cpi]);

            SET @final_time  = CURRENT_TIMESTAMP;
            SET @time_diff_seconds = DATEDIFF(microsecond,@initial_time,@final_time) /1000000.0 ;


			IF @validate_query_result = 0
                BEGIN
                RAISERROR ('There are no rows in the source table', -- Message text.
                            16, -- Severity,
                            1 -- State,
                            );
                END ;

            INSERT INTO acuity.execution_history
                values(@table_name,@validate_query_result,'Table has been updated successfully',@time_diff_seconds , 'true', @final_time)


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
            
            INSERT INTO acuity.execution_history
            values(@table_name,@validate_query_result,@ErrorMessage,@time_diff_seconds , 'false', @final_time)

        END CATCH
END
GO