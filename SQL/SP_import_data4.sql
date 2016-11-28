USE [ITInfra]
GO
/****** Object:  StoredProcedure [slc].[Import_data3]    Script Date: 11/28/2016 12:26:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jarek Olechno
-- Create date: 23.11.2016
-- Description:	Process data imported from file servers
-- =============================================
alter PROCEDURE [slc].[Import_data4]
	-- Add the parameters for the stored procedure here
	@serverID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


--declare @serverID int
declare @directory nvarchar(MAX)
declare @ParentDirectory nvarchar(4000)
declare @BaseName nvarchar(255)
declare @Extension nvarchar(255)
declare @LastWriteTime nvarchar(50)
declare @CreationTime nvarchar(50)
declare @LastAccessTime nvarchar(50)
declare @Length nvarchar(50)
declare @Owner nvarchar(255)
declare @hash varbinary(20)
declare @hashParent varbinary(20)
declare @indentity bigint
--declare @RowUpdateTime datetime
declare @RowUpdateTime_selected datetime
declare @folderID int
declare @folderID_selected int
declare @ParentfolderID int
declare @ExtensionID int
declare @isNew bit

--declare @serverID int
--set @serverID=1
declare @RowUpdateTime datetime
select @RowUpdateTime=GETDATE()
--select @RowUpdateTime=dateadd(day,-7,GETDATE())
declare @driveID int
--select @RowUpdateTime=dateadd(day,-7,GETDATE())

select top 1 @driveID=driveID from slc.drive where name in (select top 1 cast(replace(dbo.fn_Split6(directory,'\',1),':','') as CHAR(1)) from [slc].[e-drive])

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[slc].[Folder_2]') AND name = N'idx_Name_server')
DROP INDEX [idx_Name_server] ON [slc].[Folder_2] WITH ( ONLINE = OFF )


IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[slc].[Folder_2]') AND name = N'PK_Folder2')
ALTER TABLE [slc].[Folder_2] DROP CONSTRAINT [PK_Folder2]







  
  
  merge into [slc].[Folder_2] a
  using (SELECT distinct directory,@serverID as ServerID FROM [ITInfra].[slc].[e-drive]) b
  on a.hash = HASHBYTES('SHA1',(CONVERT(VARCHAR(4000), ltrim(RTRIM(b.[Directory]))))) and a.serverid=b.serverid
  when not matched then 
  INSERT
     ([Name],[DriveID],[Level],[LastRowUpdateTime],[IsNew],[ServerID],[Length],[hash],[ParentFolderID])
  VALUES
	(cast(Directory as nvarchar(4000)),@driveID,slc.CountOccurancesOfString(cast(Directory as nvarchar(4000)),'\'),@RowUpdateTime,1,@serverID, LEN(b.[Directory])
  ,HASHBYTES('SHA1',(CONVERT(VARCHAR(4000), ltrim(RTRIM(b.[Directory])))))
  ,-1);
  
  merge into slc.FileExtensions2 a
  using (select distinct Extension  FROM [ITInfra].[slc].[e-drive]) b
  on a.Name = b.Extension
  when not matched then
  insert
	([Name])
	Values
	(b.Extension);

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[slc].[FileName2]') AND name = N'idx_FolderID')
DROP INDEX [idx_FolderID] ON [slc].[FileName2] WITH ( ONLINE = OFF )
  
  merge into slc.FileName2 a
  using (select  b.folderID, a.BaseName ,a.Length ,a.Owner, a.CreationTime,a.LastWriteTime,a.LastAccessTime,@RowUpdateTime as LastRowUpdateTime, 1 as IsNew, @serverID as ServerID
  ,c.ExtensionID 
  from slc.[e-drive] a
  inner join [slc].[Folder_2] b
  on HASHBYTES('SHA1',(CONVERT(VARCHAR(4000), ltrim(RTRIM(a.Directory))))) = b.hash
  inner join slc.FileExtensions2 c
  on a.Extension = c.Name) d
  on a.Name=d.BaseName and a.serverID=d.ServerID
  when not matched then
  INSERT 
    ([FolderID],[Name],[SizeBytes],[Owner],[CreationTime],[LastWriteTime],[LastAccessTime],[LastRowUpdateTime],[IsNew],[ServerID],[ExtensionID])
  VALUES
    (d.FolderID,d.BaseName,d.Length,d.Owner,d.CreationTime,d.LastWriteTime,d.LastAccessTime,d.LastRowUpdateTime,d.IsNew,d.ServerID,d.ExtensionID);
    
 CREATE CLUSTERED INDEX [idx_FolderID] ON [slc].[FileName2] 
(
	[FolderID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]


 
 
 CREATE NONCLUSTERED INDEX [idx_Name_server] ON [slc].[Folder_2] 
(
	[Name] ASC,
	[ServerID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]

/****** Object:  Index [PK_Folder2]    Script Date: 11/28/2016 15:54:43 ******/
ALTER TABLE [slc].[Folder_2] ADD  CONSTRAINT [PK_Folder2] PRIMARY KEY CLUSTERED 
(
	[FolderID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
 
 
  

  declare @r int
	merge into [slc].[folder_2] a
    using (
		 select distinct HASHBYTES('SHA1',(CONVERT(VARCHAR(4000), ltrim(RTRIM(slc.GetParentDirectory(name)))))) as hash,slc.GetParentDirectory(name) as Name,serverid from [slc].[Folder_2] t1
			 where not exists
				(
					select name from [slc].[Folder_2] t2
					where t2.name=slc.GetParentDirectory(t1.name)
					and t1.serverID = t2.serverID
				)
    ) b
	  on a.hash = b.hash
	  and a.serverid=b.serverid
	  when not matched and b.name is not null then
	   INSERT 
	   ([Name],[DriveID],[Level],[LastRowUpdateTime],[IsNew],[ServerID],[Length],[hash],[ParentFolderID])
	   VALUES
	   (b.name,@driveID,slc.CountOccurancesOfString([Name],'\'),getdate(),1,b.serverid,len(b.name),HASHBYTES('SHA1',(CONVERT(VARCHAR(4000), ltrim(RTRIM(b.name))))),-1);
	    select @r=@@ROWCOUNT
  while @r >= 0
  begin
  --PRINT 'Inside WHILE LOOP on TechOnTheNet.com';
	print @r
	--set @r= @r-1;
	   merge into [slc].[folder_2] a
    using (
		 select distinct HASHBYTES('SHA1',(CONVERT(VARCHAR(4000), ltrim(RTRIM(slc.GetParentDirectory(name)))))) as hash,slc.GetParentDirectory(name) as Name,serverid from [slc].[Folder_2] t1
			 where not exists
				(
					select name from [slc].[Folder_2] t2
					where t2.name=slc.GetParentDirectory(t1.name)
					and t1.serverID = t2.serverID
				)
    ) b
	  on a.hash = b.hash
	  and a.serverid=b.serverid
	  when not matched and b.name is not null then
	   INSERT
	   ([Name],[DriveID],[Level],[LastRowUpdateTime],[IsNew],[ServerID],[Length],[hash],[ParentFolderID]) 
	   VALUES
	   (b.name,@driveID,slc.CountOccurancesOfString([Name],'\'),getdate(),1,b.serverid,len(b.name),HASHBYTES('SHA1',(CONVERT(VARCHAR(4000), ltrim(RTRIM(b.name))))),-1);
	    select @r=@@ROWCOUNT
		
		if (@r=0)
			break
		else
			Continue
  end


 
  merge into [slc].[Folder_2] a
  using (select * from [slc].[Folder_2] where hash in (select distinct HASHBYTES('SHA1',(CONVERT(VARCHAR(4000), ltrim(RTRIM(slc.GetParentDirectory(name)))))) from [slc].[Folder_2])) b
  on HASHBYTES('SHA1',(CONVERT(VARCHAR(4000), ltrim(RTRIM(slc.GetParentDirectory(a.name)))))) = b.hash
   when matched then
  update
	set a.ParentFolderID=b.FolderID;
  
  
--select  * from [slc].[Folder_2] where parentfolderid<>-1
--exec [slc].[Import_data4] 1

END
