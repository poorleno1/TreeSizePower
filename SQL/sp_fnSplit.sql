USE [ITInfra]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_Split6]    Script Date: 11/28/2016 16:15:22 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_Split6]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[fn_Split6]
GO

USE [ITInfra]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_Split6]    Script Date: 11/28/2016 16:15:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create function [dbo].[fn_Split6](
 @String nvarchar (4000),
 @Delimiter nvarchar (10),
 @id int
 )
returns nvarchar(4000) as
begin
 declare @NextString nvarchar(4000)
 declare @Pos int
 declare @NextPos int
 declare @CommaCheck nvarchar(1)
 declare @no int
 declare @ret nvarchar(1000)
 
 --Initialize
 set @NextString = ''
 set @CommaCheck = right(@String,1) 
 
 --Check for trailing Comma, if not exists, INSERT
 --if (@CommaCheck <> @Delimiter )
 set @String = @String + @Delimiter
 
 --Get position of first Comma
 set @Pos = charindex(@Delimiter,@String)
 set @NextPos = 1
 
 
 set @no=1
 while (@pos <>  0)  
 begin
  set @NextString = substring(@String,1,@Pos - 1)
 
 if @no=@id
 set  @ret=cast(@nextString as nvarchar(4000))
  --insert into @ValueTable ([id],[Value]) Values (@no,@NextString)
  
  set @String = substring(@String,@pos +1,len(@String))
  
  set @NextPos = @Pos
  set @pos  = charindex(@Delimiter,@String)
  set @no=@no+1
 end
 
 
 return @ret
end

GO


