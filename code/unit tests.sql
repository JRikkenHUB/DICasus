exec tSQLt.NewTestClass 'ConstraintsCasus';

use COURSE
--Constraint 1
create or alter proc [ConstraintsCasus].[Test insert president higher salary] 

as

begin

	exec tSQLt.FakeTable 'dbo', 'emp'
	exec tSQLt.ApplyConstraint 'emp', 'emp_chk_President'

	insert into emp values (null, null, 'president', null, null, null, 11000, null, null)
end

exec tSQLt.Run 'ConstraintsCasus.Test insert president higher salary'

create or alter proc [ConstraintsCasus].[Test insert president lower salary] 

as

begin

	exec tSQLt.FakeTable 'dbo', 'emp'
	exec tSQLt.ApplyConstraint 'emp', 'emp_chk_President'

	insert into emp values (null, null, 'president', null, null, null, 9000, null, null)
end

exec tSQLt.Run 'ConstraintsCasus.Test insert president lower salary'

create or alter proc [ConstraintsCasus].[Test insert employee higher salary] 

as

begin

	exec tSQLt.FakeTable 'dbo', 'emp'
	exec tSQLt.ApplyConstraint 'emp', 'emp_chk_President'

	insert into emp values (null, null, 'administrator', null, null, null, 11000, null, null)
end

exec tSQLt.Run 'ConstraintsCasus.Test insert employee higher salary'

create or alter proc [ConstraintsCasus].[Test insert employee lower salary] 

as

begin

	exec tSQLt.FakeTable 'dbo', 'emp'
	exec tSQLt.ApplyConstraint 'emp', 'emp_chk_President'

	insert into emp values (null, null, 'administrator', null, null, null, 9000, null, null)
end

exec tSQLt.Run 'ConstraintsCasus.Test insert employee lower salary'

--Constraint 2
create or alter proc [ConstraintsCasus].[Test insert check administrator for manager] 

as

begin

	exec tSQLt.FakeTable 'dbo', 'emp'
	exec tSQLt.ApplyTrigger 'emp', 'emp_chk_President'
	insert into emp values (null, null, 'administrator', null, null, null, null, null, null)

	insert into emp values (null, null, 'manager', null, null, null, null, null, null)
end

exec tSQLt.Run 'ConstraintsCasus.Test insert check administrator for manager'

create or alter proc [ConstraintsCasus].[Test insert check no administrator for manager] 

as

begin

	exec tSQLt.FakeTable 'dbo', 'emp'
	exec tSQLt.ApplyTrigger 'emp', 'emp_chk_President'

	exec tSQLt.ExpectException @ExpectedMessage = 'No administrator was hired for this manager or president'

	insert into emp values (null, null, 'manager', null, null, null, null, null, null)
end

exec tSQLt.Run 'ConstraintsCasus.Test insert check administrator for manager'

create or alter proc [ConstraintsCasus].[Test update check administrator for manager] 

as

begin

	exec tSQLt.FakeTable 'dbo', 'emp'
	exec tSQLt.ApplyTrigger 'emp', 'emp_chk_President'
	insert into emp values (null, null, 'administrator', null, null, null, null, null, null)
	insert into emp values (null, null, 'manager', null, null, null, null, null, null)

	update emp set job = 'president' where job = 'manager'
end

exec tSQLt.Run 'ConstraintsCasus.Test update check administrator for manager'

create or alter proc [ConstraintsCasus].[Test insert check no administrator for manager] 

as

begin

	exec tSQLt.FakeTable 'dbo', 'emp'

	exec tSQLt.ExpectException @ExpectedMessage = 'No administrator was hired for this manager or president'

	insert into emp values (null, null, 'manager', null, null, null, null, null, null)

	--was placed lower so the first insert wouldn't be affacted by the constraint
	exec tSQLt.ApplyTrigger 'emp', 'emp_chk_President'

	update emp set job = 'president' where job = 'manager'
end

exec tSQLt.Run 'ConstraintsCasus.Test insert check administrator for manager'

--Constraint 3
create or alter proc [ConstraintsCasus].[Test insert adult employee] 

as

begin

	exec tSQLt.FakeTable 'dbo', 'emp'
	exec tSQLt.ApplyConstraint 'emp', 'emp_chk_age'

	insert into emp values (null, null, null, '1957-12-22', null, null, null, null, null)
end

exec tSQLt.Run 'ConstraintsCasus.Test insert adult employee'

create or alter proc [ConstraintsCasus].[Test insert child employee] 

as

begin

	exec tSQLt.FakeTable 'dbo', 'emp'
	exec tSQLt.ApplyConstraint 'emp', 'emp_chk_age'

	insert into emp values (null, null, null, getdate(), null, null, null, null, null)
end

exec tSQLt.Run 'ConstraintsCasus.Test insert adult employee'

--Constraint 4
create or alter proc [ConstraintsCasus].[Test update sal grade] 

as

begin

	exec tSQLt.FakeTable 'dbo', 'grd'
	exec tSQLt.ApplyTrigger 'emp', 'chk_salaryGrd'

	insert into grd values (1,	500.00,	1500.00, 250.00), (2, 1000.00, 2500.00,	500.00)

	update grd set llimit = 400 where grade = 1
end

exec tSQLt.Run 'ConstraintsCasus.Test update sal grade'

create or alter proc [ConstraintsCasus].[Test update lower sal grade] 

as

begin

	exec tSQLt.FakeTable 'dbo', 'grd'
	exec tSQLt.ApplyTrigger 'emp', 'chk_salaryGrd'

	insert into grd values (1,	500.00,	1500.00, 250.00), (2, 1000.00, 2500.00,	500.00)

	exec tSQLt.ExpectException @ExpectedMessage = 'The inserted values overlap the lower salary grade'

	update grd set llimit = 1600 where grade = 2
end

exec tSQLt.Run 'ConstraintsCasus.Test insert adult employee'

--Constraint 5
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

--Constraint 6
create or alter proc [ConstraintsCasus].[Test trainer course plannen] 

as

begin 
	exec tSQLt.FakeTable 'dbo', 'offr'

	exec tSQLt.ExpectNoException

	exec chk_course '1', '2019-02-02', null, null, 1017, null
end

exec tSQLt.Run 'ConstraintsCasus.Test trainer course plannen'

create or alter proc [ConstraintsCasus].[Test trainer two courses plannen] 

as

begin 
	exec tSQLt.FakeTable 'dbo', 'offr'

	exec tSQLt.ExpectException @ExpectedMessage = 'Trainer already has a course on that day'

	exec chk_course '1', '2019-02-02', null, null, 1017, null
end

exec tSQLt.Run 'ConstraintsCasus.Test trainer two courses plannen'

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
--Constraint 8
create proc [ConstraintsCasus].[Test insert student signing up] 

as

begin

	exec tSQLt.FakeTable 'dbo', 'offr'
	exec tSQLt.FakeTable 'dbo', 'reg'
	exec tSQLt.ApplyTrigger 'reg', 'chk_register_self'
	insert into offr values (null, null, null, null, 2, null)

	insert into reg values (1, null, null, null)

end

exec tSQLt.Run 'ConstraintsCasus.Test insert student signing up'

create proc [ConstraintsCasus].[Test insert trainer signing up] 

as

begin

	exec tSQLt.FakeTable 'dbo', 'offr'
	exec tSQLt.FakeTable 'dbo', 'reg'
	exec tSQLt.ApplyTrigger 'reg', 'chk_register_self'
	insert into offr values (null, null, null, null, 2, null)

	insert into reg values (2, null, null, null)

end

exec tSQLt.Run 'ConstraintsCasus.Test insert trainer signing up'

create proc [ConstraintsCasus].[Test update student signing up] 

as

begin

	exec tSQLt.FakeTable 'dbo', 'offr'
	exec tSQLt.FakeTable 'dbo', 'reg'
	exec tSQLt.ApplyTrigger 'reg', 'chk_register_self'
	insert into offr values (null, null, null, null, 2, null)

	insert into reg values (1, null, null, null)
	update reg set stud = 3 where stud = 1

end

exec tSQLt.Run 'ConstraintsCasus.Test update student signing up'

create proc [ConstraintsCasus].[Test update trainer signing up] 

as

begin

	exec tSQLt.FakeTable 'dbo', 'offr'
	exec tSQLt.FakeTable 'dbo', 'reg'
	
	insert into offr values (null, null, null, null, 2, null)

	insert into reg values (1, null, null, null)
	exec tSQLt.ApplyTrigger 'reg', 'chk_register_self'

	update reg set stud = 2 where stud = 1

end

exec tSQLt.Run 'ConstraintsCasus.Test insert trainer signing up'
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

	exec tSQLt.ExpectException @ExpectedMessage = 'Trainer is spending to much time teaching at a different location'

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
	
	exec tSQLt.ExpectException @ExpectedMessage = 'Trainer is spending to much time teaching at a different location'

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

	exec tSQLt.ExpectException @ExpectedMessage = 'Trainer is spending to much time teaching at a different location'

	exec delete_trainer_offerings('2', '2019-02-02', 1017, 'hawaii')

end

exec tSQLt.Run 'Test delete for trainer with not enough hours at home'

go

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

go

--Constraint 11
create or alter proc [ConstraintsCasus].[Test insert employee who isnt a trainer] 

as

begin
	exec tSQLt.FakeTable 'dbo', 'offr'
	exec tSQLt.FakeTable 'dbo', 'emp'
	exec tSQLt.FakeTable 'dbo', 'reg'

	insert into emp values (1, null, 'ADMIN', null, null, null, null, null, null);
	insert into reg values (1, 'test', null, null)

	exec tSQLt.ExpectException @ExpectedMessage = 'Only a trainer can teach courses'

	exec usp_insert_new_offr 'test', null, null, null, 1, null
end

exec tSQLt.Run 'ConstraintsCasus.Test insert employee who isnt a trainer'

go

create or alter proc [ConstraintsCasus].[Test insert employee who is a trainer] 

as

begin
	exec tSQLt.FakeTable 'dbo', 'offr'
	exec tSQLt.FakeTable 'dbo', 'emp'
	exec tSQLt.FakeTable 'dbo', 'reg'

	insert into emp values (1, null, 'TRAINER', null, null, null, null, null, null)
	insert into reg values (1, 'test', null, null)

	exec tSQLt.ExpectNoException

	exec usp_insert_new_offr 'test', null, null, null, 1, null
end

exec tSQLt.Run 'ConstraintsCasus.Test insert employee who is a trainer'

go

create or alter proc [ConstraintsCasus].[Test insert employee who is a trainer, who didnt work for a year and hasnt followed the course] 

as

begin
	exec tSQLt.FakeTable 'dbo', 'offr'
	exec tSQLt.FakeTable 'dbo', 'emp'
	exec tSQLt.FakeTable 'dbo', 'reg'

	insert into emp values (1, null, 'TRAINER', null, '2018-06-10', null, null, null, null)

	exec tSQLt.ExpectException 'The employee has to follow the course or work here for a year before he can teach.'

	exec usp_insert_new_offr 'test', '2019-05-10', null, null, 1, null
end

exec tSQLt.Run 'ConstraintsCasus.Test insert employee who is a trainer, who didnt work for a year and hasnt followed the course'

go

create or alter proc [ConstraintsCasus].[Test insert employee who is a trainer, who did work for a year and hasnt followed the course] 

as

begin
	exec tSQLt.FakeTable 'dbo', 'offr'
	exec tSQLt.FakeTable 'dbo', 'emp'
	exec tSQLt.FakeTable 'dbo', 'reg'

	insert into emp values (1, null, 'TRAINER', null, '2017-06-10', null, null, null, null)

	exec tSQLt.ExpectNoException

	exec usp_insert_new_offr 'test', '2019-05-10', null, null, 1, null
end

exec tSQLt.Run 'ConstraintsCasus.Test insert employee who is a trainer, who did work for a year and hasnt followed the course'

go

create or alter proc [ConstraintsCasus].[Test insert employee who is a trainer, who didnt work for a year and has followed the course] 

as

begin
	exec tSQLt.FakeTable 'dbo', 'offr'
	exec tSQLt.FakeTable 'dbo', 'emp'
	exec tSQLt.FakeTable 'dbo', 'reg'

	insert into emp values (1, null, 'TRAINER', null, '2018-06-10', null, null, null, null)

	insert into reg values (1, 'test', null, null)

	exec tSQLt.ExpectNoException

	exec usp_insert_new_offr 'test', '2019-05-10', null, null, 1, null
end

exec tSQLt.Run 'ConstraintsCasus.Test insert employee who is a trainer, who didnt work for a year and has followed the course'