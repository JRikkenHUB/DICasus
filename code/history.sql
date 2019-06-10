create or alter proc tgr_change_history_trigger (
@table_name varchar(40)
)
as
begin
   
	select 'Create trigger tgr_history
			on '+ @table_name +'
			after insert, update, delete
			as
			begin	
				if((select count(*) from inserted) >= 1)
					insert into HIST_'+ @table_name +' values (CURRENT_TIMESTAMP, (select * from inserted))
				
				if(((select count(*) from deleted) >= 1))
					insert into HIST_'+ @table_name +' values (CURRENT_TIMESTAMP, (select * from deleted))
			end'

end

create or alter proc tgr_generate_tables
as
begin
	declare @NAME varchar(100)

	DECLARE CUR CURSOR FOR SELECT * FROM [INFORMATION_SCHEMA].[TABLES] where TABLE_NAME not like 'HIST_%';

	OPEN CUR

	FETCH NEXT FROM CUR INTO @NAME

	WHILE @@FETCH_STATUS = 0
	  BEGIN
		  exec tgr_change_history_trigger @NAME

		  FETCH NEXT FROM CUR INTO @NAME
	  END

	CLOSE CUR
	DEALLOCATE CUR 
end

exec tgr_generate_tables
