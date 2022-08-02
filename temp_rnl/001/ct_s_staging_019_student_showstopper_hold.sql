SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('acuity.s_staging_019_student_showstopper_hold') IS NOT NULL
    DROP  TABLE acuity.s_staging_019_student_showstopper_hold;

CREATE TABLE acuity.s_staging_019_student_showstopper_hold
(
    [student_id] NVARCHAR(4000) NOT NULL,
    [num_holds] [bigint]  NOT NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	HEAP
)