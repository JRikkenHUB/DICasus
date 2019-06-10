Use COURSE

--Constraints
--1
ALTER TABLE [dbo].[emp]
ADD CONSTRAINT emp_chk_President CHECK (NOT (job='PRESIDENT' and msal<10000))

--2
Create trigger chk_manager
on [dbo].[emp]
after insert
as
begin
	declare @managerdepno int
	select @managerdepno = deptno from [dbo].[emp] where empno = (select max(empno) from dbo.emp) and job = 'PRESIDENT' or job = 'MANAGER'

	if(NOT Exists(select '' from [dbo].[emp] where job = 'ADMINISTRATOR' and deptno = @managerdepno))
		throw 1, 'No administrator was hired for this manager or president', 1
end

--3
ALTER TABLE [dbo].[emp] ADD CONSTRAINT emp_chk_age CHECK (DATEDIFF(yy, born, GETDATE()) >= 18);



--4
Create trigger chk_SalaryGdr
on [dbo].[grd]
after update
as
begin
		DECLARE @grade int
		DECLARE @llimit bit
        DECLARE @ulimit bit
        
        SET @grade = 0

		SET @grade  = (select grade from deleted)

		IF( @grade > 1 AND ( ( SELECT llimit FROM grd WHERE grade = @grade ) > (SELECT llimit FROM grd WHERE grade = @grade -1) ) )
            SET @llimit = 1
        IF( @grade = 1 )
            SET @llimit = 1


        IF( @grade > 1 AND ( ( SELECT ulimit FROM grd WHERE grade = @grade ) > (SELECT ulimit FROM grd WHERE grade = @grade - 1) ) )
            SET @ulimit = 1
        IF( @grade = 1 )
            SET @ulimit = 1

        
        IF(( @llimit = 0 AND @ulimit = 0) OR ( @llimit = 0 AND @ulimit = 1) OR ( @llimit = 1 AND @ulimit = 0))
                THROW 50000, 'The inserted values overlap the lower salary grade.', 1;
end

--5

alter table offr
drop constraint ofr_unq

create or alter trigger utrg_chk_start_trainer on offr
after insert, update

as

begin
	begin try 
		if exists (select starts, trainer from offr where trainer is not null group by starts, trainer having COUNT(*) > 1)
			begin
				raiserror('This trainer is already giving a course on that date', 11, 1)
			end
	end try
	begin catch
	 throw
	end catch
end
go
--6
Create proc chk_course
(
	@course VARCHAR(20),
	@starts DATE,
	@status VARCHAR(20),
	@maxcap int,
	@trainer int,
	@loc VARCHAR(50)
)
as
begin
	begin try
		if(not exists (select '' from offr where trainer = @trainer and starts = @starts))
			throw 50000, 'Trainer already has a course on that day', 1

		insert into offr values (@course, @starts, @status, @maxcap, @trainer, @loc)
	end try
	begin catch
		ROLLBACK TRAN
	end catch
end

/* 
Constraint 7 An active employee cannot be managed by a terminated employee. 
- Als er in memp een manager geinsert wordt die in term staat dan wordt de constraint geschonden.
- Als een manager die in memp staat geinsert wordt in term.
- Als een manager in memp geupdate wordt naar een employee die in term staat.
*/
go
create or alter proc usp_insert_mgr
@empno numeric(4),
@mgr numeric(4)
as
begin
	begin try
		if exists (select empno from term where empno = @mgr)
			begin
				declare @msg varchar(100)
				select @msg = 'Employee ' + cast(@mgr as varchar(100)) + ' cant be a manager because he doesnt work here anymore'
				raiserror(@msg, 11, 1)
			end
		else
			begin
				insert into memp values (@empno, @mgr)
			end
	end try
	begin catch
		throw
	end catch
end

go

create or alter proc usp_insert_term
@empno numeric(4),
@leftcomp date,
@comments varchar(60)
as
begin
	begin try
		if exists(select mgr from memp where mgr = @empno)
			begin
				declare @msg varchar(100)
				select @msg = 'Employee ' + CAST(@empno as varchar(10)) + ' is a managing employee and cant be terminated'
				raiserror (@msg, 11, 1)
			end
		else
			begin
				insert into term values (@empno, @leftcomp, @comments)
			end
	end try
	begin catch
		throw
	end catch
end

go

create or alter proc usp_update_mgr
@mgr numeric(4),
@empno numeric(4)
as

begin
	begin try
		if exists (select empno from term where empno = @mgr)
			begin
				declare @msg varchar(100)
				select @msg = 'Employee ' + CAST(@mgr as varchar(10)) + ' cant be a manager because he is terminated'
				raiserror(@msg, 11, 1)
			end
		else
			begin
				update memp
				set mgr = @mgr
				where empno = @empno
			end
	end try
	begin catch
		throw
	end catch
end
go
--8
Create proc chk_trainer_course
(
	@stud int,
	@course VARCHAR(50),
	@starts DATE,
	@eval int
)
as
begin
	begin try
		if(EXISTS(select '' from offr where course = @course and trainer = @stud))
			throw 50000, 'trainer cannot sign up for their own course',1

		insert into reg values (@stud, @course, @starts, @eval)
	end try
	begin catch
		rollback tran
	end catch
end