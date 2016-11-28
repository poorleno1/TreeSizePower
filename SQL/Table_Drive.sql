CREATE TABLE [slc].[drive](
	DriveID [int] IDENTITY(1,1) Not Null,
	Name[char](1) NULL
) ON [PRIMARY]

GO

;
with 
cte_tally as
(
select row_number() over (order by (select 1)) as n 
from sys.all_columns
)
insert into [slc].[drive]
select 
  char(n) as alpha
  
from 
  cte_tally
where
  (n > 64 and n < 91) 
go

