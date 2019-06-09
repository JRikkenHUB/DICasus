exec tSQLt.NewTestClass 'ConstraintsCasus';

use COURSE

--Constraint 6
go

create or alter proc [ConstraintsCasus].[Test insert course without trainer] 

as

begin
	exec tSQLt.FakeTable 'dbo', 'offr'
	exec tSQLt.ApplyTrigger 'offr', 'utrg_chk_start_trainer'
	
	exec tSQLt.ExpectNoException

	insert into offr values (null, '2019-07-06', null, null, null, null)
	insert into offr values (null, '2019-07-06', null, null, null, null)
end

exec tSQLt.Run 'ConstraintsCasus.Test insert course without trainer'

go

create or alter proc [ConstraintsCasus].[Test insert course without unique combination] 

as

begin
	exec tSQLt.FakeTable 'dbo', 'offr'
	exec tSQLt.ApplyTrigger 'offr', 'utrg_chk_start_trainer'

	exec tSQLt.ExpectException @ExpectedMessage = 'This trainer is already giving a course on that date'

	insert into offr values (null, '2019-07-06', null, null, 1, null)
	insert into offr values (null, '2019-07-06', null, null, 1, null)

end

exec tSQLt.Run 'ConstraintsCasus.Test insert course without unique combination'

go

create or alter proc [ConstraintsCasus].[Test insert course with unique combination] 

as

begin 
	exec tSQLt.FakeTable 'dbo', 'offr'
	exec tSQLt.ApplyTrigger 'offr', 'utrg_chk_start_trainer'

	exec tSQLt.ExpectNoException

	insert into offr values (null, '2019-07-06', null, null, 1, null)
	insert into offr values (null, '2019-07-06', null, null, 2, null)
end

exec tSQLt.Run 'ConstraintsCasus.Test insert course with unique combination'

go

create or alter proc [ConstraintsCasus].[Test update course without trainer] 

as

begin
	exec tSQLt.FakeTable 'dbo', 'offr'
	exec tSQLt.ApplyTrigger 'offr', 'utrg_chk_start_trainer'
	
	exec tSQLt.ExpectNoException

	insert into offr values (null, '2019-07-06', null, null, 1, null)
	insert into offr values (null, '2019-07-06', null, null, null, null)

	update offr
	set trainer = null
	where trainer = 1
end

exec tSQLt.Run 'ConstraintsCasus.Test update course without trainer'

go

create or alter proc [ConstraintsCasus].[Test update course without unique combination] 

as

begin
	exec tSQLt.FakeTable 'dbo', 'offr'
	exec tSQLt.ApplyTrigger 'offr', 'utrg_chk_start_trainer'

	exec tSQLt.ExpectException @ExpectedMessage = 'This trainer is already giving a course on that date'

	insert into offr values (null, '2019-07-06', null, null, 1, null)
	insert into offr values (null, '2019-07-06', null, null, null, null)

	update offr
	set trainer = 1
	where trainer is null
end

exec tSQLt.Run 'ConstraintsCasus.Test update course without unique combination'

go

create or alter proc [ConstraintsCasus].[Test update course with unique combination] 

as

begin 
	exec tSQLt.FakeTable 'dbo', 'offr'
	exec tSQLt.ApplyTrigger 'offr', 'utrg_chk_start_trainer'

	exec tSQLt.ExpectNoException

	insert into offr values (null, '2019-07-06', null, null, 1, null)
	insert into offr values (null, '2019-07-06', null, null, null, null)

	update offr
	set trainer = 2
	where trainer is null
end

exec tSQLt.Run 'ConstraintsCasus.Test update course with unique combination'

--Constraint 7
go

create proc [ConstraintsCasus].[Test insert terminated employee as manager] 

as

begin
	--IF OBJECT_ID('[ConstraintsCasus].[verwacht]','Table') IS NOT NULL
	--DROP TABLE [ConstraintsCasus].[verwacht]

	--SELECT TOP 0 * 
	--INTO [ConstraintsCasus].[verwacht]
	--FROM dbo.memp;
	
	--insert into [ConstraintsCasus].[verwacht] values


	exec tSQLt.FakeTable 'dbo', 'memp'
	exec tSQLt.FakeTable 'dbo', 'term'

	insert into term values (1, GETDATE(), null)

	exec tSQLt.ExpectException @ExpectedMessage = 'Employee 1 cant be a manager because he doesnt work here anymore'

	exec usp_insert_mgr @empno = 2, @mgr = 1

end

exec tSQLt.Run 'ConstraintsCasus.Test insert terminated employee as manager'
--Constraint 7

--constraint 9

go

create proc [ConstraintsCasus].[Test insert for trainer with enough hours at home] 

as

begin
	--IF OBJECT_ID('[ConstraintsCasus].[verwacht]','Table') IS NOT NULL
	--DROP TABLE [ConstraintsCasus].[verwacht]

	--SELECT TOP 0 * 
	--INTO [ConstraintsCasus].[verwacht]
	--FROM dbo.memp;
	
	--insert into [ConstraintsCasus].[verwacht] values


	exec tSQLt.FakeTable 'dbo', 'emp'
	exec tSQLt.FakeTable 'dbo', 'dept'
	exec tSQLt.FakeTable 'dbo', 'offr'
	exec tSQLt.FakeTable 'dbo', 'crs'

	insert into emp values (1, null, null, null, null, null, null, null, 1)
	insert into dept values (1, null, null, 'hawaii')
	insert into crs values (1, null, null, 10)
	insert into crs values ('2', null, null, 20)
	insert into offr values ('1', '2019-02-01', 'CONF', 1, 1017, 'USA')

	exec insert_trainer_offerings('2', '2019-02-01', 'CONF', 20, 1017, 'hawaii')

end

exec tSQLt.Run 'Test insert for trainer with enough hours at home'

create proc [ConstraintsCasus].[Test insert for trainer with not enough hours at home] 

as

begin
	--IF OBJECT_ID('[ConstraintsCasus].[verwacht]','Table') IS NOT NULL
	--DROP TABLE [ConstraintsCasus].[verwacht]

	--SELECT TOP 0 * 
	--INTO [ConstraintsCasus].[verwacht]
	--FROM dbo.memp;
	
	--insert into [ConstraintsCasus].[verwacht] values


	exec tSQLt.FakeTable 'dbo', 'emp'
	exec tSQLt.FakeTable 'dbo', 'dept'
	exec tSQLt.FakeTable 'dbo', 'offr'
	exec tSQLt.FakeTable 'dbo', 'crs'

	insert into emp values (1, null, null, null, null, null, null, null, 1)
	insert into dept values (1, null, null, null)
	insert into crs values (1, null, null, 10)
	insert into crs values ('2', null, null, 20)
	insert into offr values ('1', '2019-02-02', null, null, 20, 'america')

	exec insert_trainer_offerings('2', '2019-02-01', 'CONF', 1, 1017, 'hawaii')

end

exec tSQLt.Run 'Test insert for trainer with not enough hours at home'

create proc [ConstraintsCasus].[Test update for trainer with enough hours at home] 

as

begin
	--IF OBJECT_ID('[ConstraintsCasus].[verwacht]','Table') IS NOT NULL
	--DROP TABLE [ConstraintsCasus].[verwacht]

	--SELECT TOP 0 * 
	--INTO [ConstraintsCasus].[verwacht]
	--FROM dbo.memp;
	
	--insert into [ConstraintsCasus].[verwacht] values


	exec tSQLt.FakeTable 'dbo', 'emp'
	exec tSQLt.FakeTable 'dbo', 'dept'
	exec tSQLt.FakeTable 'dbo', 'offr'
	exec tSQLt.FakeTable 'dbo', 'crs'

	insert into emp values (1, null, null, null, null, null, null, null, 1)
	insert into dept values (1, null, null, null)
	insert into crs values (1, null, null, 10)
	insert into crs values ('2', null, null, 20)
	insert into offr values ('1', '2019-02-02', null, null, 20, 'america')
	insert into offr values ('2', '2019-02-02', null, null, 20, 'hawaii')

	exec update_trainer_offerings('2', '2019-02-01', '2', '2019-02-01', 'CONF', 21, 1017, 'hawaii')

end

exec tSQLt.Run 'Test update for trainer with enough hours at home'

create proc [ConstraintsCasus].[Test update for trainer with not enough hours at home] 

as

begin
	--IF OBJECT_ID('[ConstraintsCasus].[verwacht]','Table') IS NOT NULL
	--DROP TABLE [ConstraintsCasus].[verwacht]

	--SELECT TOP 0 * 
	--INTO [ConstraintsCasus].[verwacht]
	--FROM dbo.memp;
	
	--insert into [ConstraintsCasus].[verwacht] values


	exec tSQLt.FakeTable 'dbo', 'emp'
	exec tSQLt.FakeTable 'dbo', 'dept'
	exec tSQLt.FakeTable 'dbo', 'offr'
	exec tSQLt.FakeTable 'dbo', 'crs'

	insert into emp values (1, null, null, null, null, null, null, null, 1)
	insert into dept values (1, null, null, null)
	insert into crs values (1, null, null, 10)
	insert into crs values ('2', null, null, 20)
	insert into offr values ('1', '2019-02-02', null, null, 20, 'america')
	insert into offr values ('2', '2019-02-02', null, null, 20, 'hawaii')

	exec update_trainer_offerings('2', '2019-02-01', '1', '2019-02-01', 'CONF', 1, 1017, 'hawaii')

end

exec tSQLt.Run 'Test update for trainer with not enough hours at home'

create proc [ConstraintsCasus].[Test delete for trainer with enough hours at home] 

as

begin
	--IF OBJECT_ID('[ConstraintsCasus].[verwacht]','Table') IS NOT NULL
	--DROP TABLE [ConstraintsCasus].[verwacht]

	--SELECT TOP 0 * 
	--INTO [ConstraintsCasus].[verwacht]
	--FROM dbo.memp;
	
	--insert into [ConstraintsCasus].[verwacht] values


	exec tSQLt.FakeTable 'dbo', 'emp'
	exec tSQLt.FakeTable 'dbo', 'dept'
	exec tSQLt.FakeTable 'dbo', 'offr'
	exec tSQLt.FakeTable 'dbo', 'crs'

	insert into emp values (1, null, null, null, null, null, null, null, 1)
	insert into dept values (1, null, null, null)
	insert into crs values (1, null, null, 10)
	insert into crs values ('2', null, null, 20)
	insert into offr values ('1', '2019-02-02', null, null, 20, 'america')
	insert into offr values ('2', '2019-02-02', null, null, 20, 'hawaii')

	exec delete_trainer_offerings('1', '2019-02-02', 1017, 'america')

end

exec tSQLt.Run 'Test delete for trainer with enough hours at home'

create proc [ConstraintsCasus].[Test delete for trainer with not enough hours at home] 

as

begin
	--IF OBJECT_ID('[ConstraintsCasus].[verwacht]','Table') IS NOT NULL
	--DROP TABLE [ConstraintsCasus].[verwacht]

	--SELECT TOP 0 * 
	--INTO [ConstraintsCasus].[verwacht]
	--FROM dbo.memp;
	
	--insert into [ConstraintsCasus].[verwacht] values


	exec tSQLt.FakeTable 'dbo', 'emp'
	exec tSQLt.FakeTable 'dbo', 'dept'
	exec tSQLt.FakeTable 'dbo', 'offr'
	exec tSQLt.FakeTable 'dbo', 'crs'

	insert into emp values (1, null, null, null, null, null, null, null, 1)
	insert into dept values (1, null, null, null)
	insert into crs values (1, null, null, 10)
	insert into crs values ('2', null, null, 20)
	insert into offr values ('1', '2019-02-02', null, null, 20, 'america')
	insert into offr values ('2', '2019-02-02', null, null, 20, 'hawaii')

	exec delete_trainer_offerings('2', '2019-02-02', 1017, 'hawaii')

end

exec tSQLt.Run 'Test delete for trainer with not enough hours at home'