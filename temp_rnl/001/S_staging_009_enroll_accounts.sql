SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [acuity].[sp_s_staging_009_enroll_accounts] AS
BEGIN
BEGIN TRANSACTION

	BEGIN TRY

		DECLARE @validate_query_result INT;

		SET @validate_query_result =  (SELECT count(*)
		FROM [enable].[hlx_campusbase] AS cb
		INNER JOIN [enable].[accountbase] AS ab ON cb.[hlx_institutionid] = ab.[Accountid]
		INNER JOIN [porter].[customer] AS c ON cb.[hlx_CampusCode] = c.[Customer Number]) ;


		IF @validate_query_result = 0
			BEGIN
			
			RAISERROR (N'The query result is null.', -- Message text.  
			10, -- Severity,  
			1, -- State,  
			N'number', -- First argument.  
			5); 

			END ; 

		DELETE FROM [acuity].[s_staging_009_enroll_accounts];

		INSERT INTO [acuity].[s_staging_009_enroll_accounts]
		SELECT 
		cb.[hlx_campusId] AS [accountid],
		c.[CustomerID] AS [customerid],
		c.[ClientID] AS [client_id]
		FROM [enable].[hlx_campusbase] AS cb
		INNER JOIN [enable].[accountbase] AS ab ON cb.[hlx_institutionid] = ab.[Accountid]
		INNER JOIN [porter].[customer] AS c ON cb.[hlx_CampusCode] = c.[Customer Number];

		COMMIT;

	END TRY
	
	BEGIN CATCH

	ROLLBACK;

	print('entro al error')

	DECLARE @ErrorMessage NVARCHAR(4000);  
        DECLARE @ErrorSeverity INT;  
        DECLARE @ErrorState INT; 
            
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