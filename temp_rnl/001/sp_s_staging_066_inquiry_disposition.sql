SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('acuity.sp_s_staging_066_inquiry_disposition') IS NOT NULL
DROP PROCEDURE [acuity].[sp_s_staging_066_inquiry_disposition] 
GO

CREATE PROC [acuity].[sp_s_staging_066_inquiry_disposition] AS
BEGIN
BEGIN TRANSACTION
	DECLARE @ErrorMessage NVARCHAR(4000);  
    DECLARE @ErrorSeverity INT;  
    DECLARE @ErrorState INT; 

	BEGIN TRY

		DECLARE @validate_query_result INT;

		SET @validate_query_result =  (SELECT 
                                       COUNT(*)
                                       FROM acuity.[s_staging_063_inquiry_disposition] AS s63 
                                       WHERE s63.rank = 1) ;


		IF @validate_query_result = 0
			BEGIN
				SET  @ErrorMessage = 'There are no rows in the source table';
				SET @ErrorSeverity = 10 ;
                SET @ErrorState = 3; -- to locate where the error comes from easily

				RAISERROR (@ErrorMessage,
							@ErrorSeverity,  
							@ErrorState  
							); 

			END ; 

		DELETE FROM acuity.[s_staging_066_inquiry_disposition];

		INSERT INTO acuity.[s_staging_066_inquiry_disposition]
        SELECT
        s63.leadid,
        s63.status_name,
        s63.received_date
        FROM acuity.[s_staging_063_inquiry_disposition] AS s63 
        WHERE s63.rank = 1;


		COMMIT;

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

	END CATCH

END;
GO