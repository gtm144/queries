SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('acuity.s_staging_009_enroll_accounts') IS NOT NULL
    DROP  TABLE acuity.s_staging_009_enroll_accounts;

CREATE TABLE acuity.s_staging_009_enroll_accounts
(
    [accountid] NVARCHAR(4000) NOT NULL,
    [customerid] [bigint]  NOT NULL,
    [client_id] [bigint]  NOT NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	HEAP
)