USE [ITInfra]
GO

/****** Object:  Table [slc].[FileExtensions2]    Script Date: 11/23/2016 13:55:08 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[slc].[FileExtensions2]') AND type in (N'U'))
DROP TABLE [slc].[FileExtensions2]
GO

USE [ITInfra]
GO

/****** Object:  Table [slc].[FileExtensions2]    Script Date: 11/23/2016 13:55:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [slc].[FileExtensions2](
	[ExtensionID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[ApplicationName] [nchar](10) NULL,
 CONSTRAINT [PK_FileExtensions2] PRIMARY KEY CLUSTERED 
(
	[ExtensionID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


