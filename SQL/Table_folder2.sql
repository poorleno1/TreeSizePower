USE [ITInfra]
GO

/****** Object:  Table [slc].[Folder_2]    Script Date: 11/23/2016 13:45:39 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[slc].[Folder_2]') AND type in (N'U'))
DROP TABLE [slc].[Folder_2]
GO

USE [ITInfra]
GO

/****** Object:  Table [slc].[Folder_2]    Script Date: 11/23/2016 13:45:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [slc].[Folder_2](
	[FolderID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](4000) NULL,
	[DriveID] tinyint NOT NULL,
	[Level] tinyint NOT NULL, 
	--[Owner] [nvarchar](255) NULL,
	--[CreationTime] [datetime] NULL,
	--[LastWriteTime] [datetime] NULL,
	--[LastAccessTime] [datetime] NULL,
	[LastRowUpdateTime] [datetime] NULL,
	[IsNew] [bit] NULL,
	[ServerID] [int] NULL,
	[Length] [int] NULL,
	[hash] [varbinary](20) NULL,
	[ParentFolderID] [int] NULL,
 CONSTRAINT [PK_Folder2] PRIMARY KEY CLUSTERED 
(
	[FolderID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO



/****** Object:  Index [PK_Folder2]    Script Date: 11/28/2016 15:56:04 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[slc].[Folder_2]') AND name = N'PK_Folder2')
ALTER TABLE [slc].[Folder_2] DROP CONSTRAINT [PK_Folder2]
GO

/****** Object:  Index [PK_Folder2]    Script Date: 11/28/2016 15:56:06 ******/
ALTER TABLE [slc].[Folder_2] ADD  CONSTRAINT [PK_Folder2] PRIMARY KEY CLUSTERED 
(
	[FolderID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO



/****** Object:  Index [idx_Name_server]    Script Date: 11/25/2016 14:29:41 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[slc].[Folder_2]') AND name = N'idx_Name_server')
DROP INDEX [idx_Name_server] ON [slc].[Folder_2] WITH ( ONLINE = OFF )
GO

USE [ITInfra]
GO

/****** Object:  Index [idx_Name_server]    Script Date: 11/25/2016 14:29:42 ******/
CREATE NONCLUSTERED INDEX [idx_Name_server] ON [slc].[Folder_2] 
(
	[Name] ASC,
	[ServerID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO


