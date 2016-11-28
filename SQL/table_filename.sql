USE [ITInfra]
GO

/****** Object:  Table [slc].[FileName2]    Script Date: 11/23/2016 14:33:33 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[slc].[FileName2]') AND type in (N'U'))
DROP TABLE [slc].[FileName2]
GO

USE [ITInfra]
GO

/****** Object:  Table [slc].[FileName2]    Script Date: 11/23/2016 14:33:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [slc].[FileName2](
	[FileID] [int] IDENTITY(1,1) NOT NULL,
	[FolderID] [int] NOT NULL,
	[Name] [nvarchar](255) NULL,
	[SizeBytes] [bigint] NULL,
	[Owner] [nvarchar](255) NULL,
	[CreationTime] [datetime] NULL,
	[LastWriteTime] [datetime] NULL,
	[LastAccessTime] [datetime] NULL,
	[LastRowUpdateTime] [datetime] NULL,
	[IsNew] [bit] NULL,
	[ServerID] [int] NULL,
	[ExtensionID] [int] NULL
) ON [PRIMARY]

GO


