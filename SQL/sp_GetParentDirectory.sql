USE [ITInfra]
GO

/****** Object:  UserDefinedFunction [slc].[GetParentDirectory]    Script Date: 11/28/2016 16:14:53 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[slc].[GetParentDirectory]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [slc].[GetParentDirectory]
GO

USE [ITInfra]
GO

/****** Object:  UserDefinedFunction [slc].[GetParentDirectory]    Script Date: 11/28/2016 16:14:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [slc].[GetParentDirectory]
(
	-- Add the parameters for the function here
	@directory nvarchar(MAX)
)
RETURNS nvarchar(4000) 
AS
BEGIN
	-- Declare the return variable here
	DECLARE @resultvar nvarchar(4000)
	declare @charidx int
	
	set @directory = ltrim(RTRIM(@directory))
	
	if (SUBSTRING(reverse(@directory),1,1)='\')
	begin
		set @directory = SUBSTRING(@directory,1,len(@directory)-1)
	end
	
	set @resultvar = NULL
	if (charindex('\',@directory) !=0)
	begin
		set @charidx =CHARINDEX('\',(REVERSE(@directory)))
		set @resultvar= convert(nvarchar(4000),SUBSTRING(@directory,1,len(@directory)-@charidx))
	end
	-- Return the result of the function
	RETURN @resultvar

END


GO


