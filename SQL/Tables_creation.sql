--delete from slc.FileName

--delete from slc.FileExtensions
--delete from slc.FolderStructure
--delete from slc.Folder

--DBCC CHECKIDENT ('slc.FileName', RESEED, 0);
--DBCC CHECKIDENT ('slc.FileExtensions', RESEED, 0);
--DBCC CHECKIDENT ('slc.Folder', RESEED, 0);
--GO




USE [ITInfra]
GO

/****** Object:  Table [slc].[FileName]    Script Date: 11/17/2016 13:29:19 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[slc].[FileName]') AND type in (N'U'))
DROP TABLE [slc].[FileName]
GO


/****** Object:  Table [slc].[FileExtensions]    Script Date: 11/17/2016 13:30:42 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[slc].[FileExtensions]') AND type in (N'U'))
DROP TABLE [slc].[FileExtensions]
GO


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[slc].[FolderStructure]') AND type in (N'U'))
DROP TABLE [slc].[FolderStructure]
GO


/****** Object:  Table [slc].[Folder]    Script Date: 11/17/2016 13:33:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[slc].[Folder]') AND type in (N'U'))
DROP TABLE [slc].[Folder]
GO











CREATE TABLE [slc].[FileName](
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
/****** Object:  Index [idx_Name_ExtensionID_ServerID_FolderID]    Script Date: 11/17/2016 13:29:53 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[slc].[FileName]') AND name = N'idx_Name_ExtensionID_ServerID_FolderID')
DROP INDEX [idx_Name_ExtensionID_ServerID_FolderID] ON [slc].[FileName] WITH ( ONLINE = OFF )
GO

/****** Object:  Index [idx_Name_ExtensionID_ServerID_FolderID]    Script Date: 11/17/2016 13:29:55 ******/
CREATE NONCLUSTERED INDEX [idx_Name_ExtensionID_ServerID_FolderID] ON [slc].[FileName] 
(
	[Name] ASC,
	[ExtensionID] ASC,
	[ServerID] ASC,
	[FolderID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO








CREATE TABLE [slc].[FileExtensions](
	[ExtensionID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[ApplicationName] [nchar](10) NULL,
 CONSTRAINT [PK_FileExtensions] PRIMARY KEY CLUSTERED 
(
	[ExtensionID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Index [PK_FileExtensions]    Script Date: 11/17/2016 13:30:58 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[slc].[FileExtensions]') AND name = N'PK_FileExtensions')
ALTER TABLE [slc].[FileExtensions] DROP CONSTRAINT [PK_FileExtensions]
GO

/****** Object:  Index [PK_FileExtensions]    Script Date: 11/17/2016 13:31:00 ******/
ALTER TABLE [slc].[FileExtensions] ADD  CONSTRAINT [PK_FileExtensions] PRIMARY KEY CLUSTERED 
(
	[ExtensionID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[slc].[FK_FolderStructure_Folder]') AND parent_object_id = OBJECT_ID(N'[slc].[FolderStructure]'))
ALTER TABLE [slc].[FolderStructure] DROP CONSTRAINT [FK_FolderStructure_Folder]
GO








CREATE TABLE [slc].[Folder](
	[FolderID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[Owner] [nvarchar](255) NULL,
	[CreationTime] [datetime] NULL,
	[LastWriteTime] [datetime] NULL,
	[LastAccessTime] [datetime] NULL,
	[LastRowUpdateTime] [datetime] NULL,
	[IsNew] [bit] NULL,
	[ServerID] [int] NULL,
	[Length] [int] NULL,
	[hash] [varbinary](20) NULL,
	[ParentFolderID] [int] NULL,
 CONSTRAINT [PK_Folder] PRIMARY KEY CLUSTERED 
(
	[FolderID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


ALTER TABLE [slc].[Folder]  WITH CHECK ADD  CONSTRAINT [FK_Folder_Server] FOREIGN KEY([ServerID])
REFERENCES [slc].[Server] ([ServerID])
GO

ALTER TABLE [slc].[Folder] CHECK CONSTRAINT [FK_Folder_Server]
GO

--/****** Object:  Index [PK_Folder_1]    Script Date: 11/17/2016 13:33:49 ******/
--ALTER TABLE [slc].[Folder] ADD  CONSTRAINT [PK_Folder] PRIMARY KEY CLUSTERED 
--(
--	[FolderID] ASC
--)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
--GO



IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[slc].[Folder]') AND name = N'idx_hash')
DROP INDEX [idx_hash] ON [slc].[Folder] WITH ( ONLINE = OFF )
GO

/****** Object:  Index [idx_hash]    Script Date: 11/17/2016 13:36:43 ******/
CREATE NONCLUSTERED INDEX [idx_hash] ON [slc].[Folder] 
(
	[hash] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO





/****** Object:  Table [slc].[FolderStructure]    Script Date: 11/17/2016 13:33:09 ******/
CREATE TABLE [slc].[FolderStructure](
	[FolderID] [int] NOT NULL,
	[LevelID] [int] NOT NULL,
	[SubFolderName] [nvarchar](255) NULL
) ON [PRIMARY]

GO

ALTER TABLE [slc].[FolderStructure]  WITH CHECK ADD  CONSTRAINT [FK_FolderStructure_Folder] FOREIGN KEY([FolderID])
REFERENCES [slc].[Folder] ([FolderID])
GO

ALTER TABLE [slc].[FolderStructure] CHECK CONSTRAINT [FK_FolderStructure_Folder]
GO


IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[slc].[FK_Folder_Server]') AND parent_object_id = OBJECT_ID(N'[slc].[Folder]'))
ALTER TABLE [slc].[Folder] DROP CONSTRAINT [FK_Folder_Server]
GO


