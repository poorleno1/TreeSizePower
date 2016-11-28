/****** Script for SelectTopNRows command from SSMS  ******/

alter  PROCEDURE slc.GetFolderHierarchy(@folderID int,@sort char(4)='asc')
AS
BEGIN

if (@sort = 'asc')
begin
;with cte ([FolderID],[ParentFolderID],[ServerID],[SizeBytes],[Level],[Name],[DriveID],Level1) as
  (
	SELECT [FolderID],[ParentFolderID],[ServerID],[SizeBytes],[Level],[Name],[DriveID],0 as Level
	  FROM [ITInfra].[slc].[vw_folder_by_size2] where folderid=@folderID
	  union all
	  SELECT  t1.[FolderID],t1.[ParentFolderID],t1.[ServerID],t1.[SizeBytes],t1.[Level],t1.[Name],t1.[DriveID],t2.Level + 1 as Level
	  FROM [ITInfra].[slc].[vw_folder_by_size2] t1
	  inner join cte t2
	  on t1.ParentFolderID=t2.FolderID
  )
  select * from cte
end
else
begin
;with cte ([FolderID],[ParentFolderID],[ServerID],[SizeBytes],[Level],[Name],[DriveID],Level1) as
  (
	SELECT [FolderID],[ParentFolderID],[ServerID],[SizeBytes],[Level],[Name],[DriveID],0 as Level
	  FROM [ITInfra].[slc].[vw_folder_by_size2] where folderid=@folderID
	  union all
	  SELECT  t1.[FolderID],t1.[ParentFolderID],t1.[ServerID],t1.[SizeBytes],t1.[Level],t1.[Name],t1.[DriveID],t2.Level + 1 as Level
	  FROM [ITInfra].[slc].[vw_folder_by_size2] t1
	  inner join cte t2
	  on t1.FolderID=t2.ParentFolderID
  )
  select * from cte

end

--exec slc.GetFolderHierarchy 65527,'desc'

end
go
  
