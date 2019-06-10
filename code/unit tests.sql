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

--Constraint 10
go
create or alter proc [ConstraintsCasus].[Test insert more than 6 regs]

as

begin
	exec tSQLt.FakeTable 'dbo', 'reg'
	exec tSQLt.FakeTable 'dbo', 'offr'

	exec tSQLt.ApplyTrigger 'dbo.reg', 'utrg_chk_reg'

	insert into offr values ('test', '2019-06-07', 'SCHD', null, null, null)

	insert into reg values (1, 'test', '2019-06-07', null),
	(2, 'test', '2019-06-07', null),
	(3, 'test', '2019-06-07', null),
	(4, 'test', '2019-06-07', null),
	(5, 'test', '2019-06-07', null)

	
	exec tSQLt.ExpectException @ExpectedMessage = 'The course must be confirmed'

	insert into reg values (6, 'test', '2019-06-07', null)
end
exec tSQLt.Run 'ConstraintsCasus.Test insert more than 6 regs'

go

create or alter proc [ConstraintsCasus].[Test insert less than 6 reg]

as

begin
	exec tSQLt.FakeTable 'dbo', 'reg'
	exec tSQLt.FakeTable 'dbo', 'offr'

	exec tSQLt.ApplyTrigger 'dbo.reg', 'utrg_chk_reg'

	insert into offr values ('test', '2019-06-07', 'SCHD', null, null, null)

	insert into reg values (1, 'test', '2019-06-07', null),
	(2, 'test', '2019-06-07', null),
	(3, 'test', '2019-06-07', null),
	(4, 'test', '2019-06-07', null)

	
	exec tSQLt.ExpectNoException

	insert into reg values (6, 'test', '2019-06-07', null)
end

exec tSQLt.Run 'ConstraintsCasus.Test insert less than 6 reg'