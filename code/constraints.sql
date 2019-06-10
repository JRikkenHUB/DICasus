Use COURSE

--Constraints
--1
ALTER TABLE [dbo].[emp]
ADD CONSTRAINT emp_chk_President CHECK (NOT (job='PRESIDENT' and msal<10000))

--2
Create trigger chk_administrator_for_manager
on [dbo].[emp]
after insert, update
as
begin
	declare @managerdepno int

	begin try
		select @managerdepno = deptno from inserted where empno = empno and job = 'PRESIDENT' or job = 'MANAGER'

		if(NOT Exists(select '' from [dbo].[emp] where job = 'ADMINISTRATOR' and deptno = @managerdepno))
			throw 1, 'No administrator was hired for this manager or president', 1
	end try
	begin catch
		throw
	end catch
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
Create trigger chk_register_self
on [dbo].[reg]
after insert, update
as
begin
	declare @course varchar(6)
	declare @starts date
	begin try
		set @course = (select course from inserted)
		set @starts = (select starts from inserted)

		if((select trainer from offr where course = @course and starts = @starts) = (select stud from inserted))
			throw 1, 'A trainer cannot teach himself', 1
	end try
	begin catch
		throw
	end catch
end

--9
create or alter proc insert_trainer_offerings(
@course varchar(6),
@starts date,
@status varchar(4),
@maxcap numeric(2),
@trainer numeric(4),
@loc varchar(14)
)
as
begin
	declare @home_location varchar(14);
	declare @home_course_duration int;
	declare @total_duration int;
	declare @new_time int;
	begin try
		
		set @home_location = (select loc from emp e
								left join dept d on e.deptno = d.deptno
								where empno = @trainer);

		set @home_course_duration = isnull((select sum(dur) from offr o
								left join crs c on o.course = c.code
								where loc = @home_location and trainer = @trainer), 0)
		set @total_duration = isnull((select sum(dur) from offr o
								left join crs c on o.course = c.code
								where trainer = @trainer), 0)

		set @new_time = (select dur from crs where code = @course)


		if(@loc <> @home_location)
			set @total_duration = (@total_duration + @new_time)
		else
			set @home_course_duration = (@home_course_duration + @new_time)


		if(100 * @home_course_duration / @total_duration < 50)
			RAISERROR('Trainer is spending to much time teaching at a different location', 16, 1)
		else
			insert into offr values (@course, @starts, @status, @maxcap, @trainer, @loc);

	end try
	begin catch
		throw
	end catch

end

exec insert_trainer_offerings 'RGDEB', '2019-02-01', 'CONF', 20, 1017, 'hawaii'

Create or alter proc update_trainer_offerings(
@oldCourse varchar(6),
@oldStarts date,
@course varchar(6),
@starts date,
@status varchar(4),
@maxcap numeric(2),
@trainer numeric(4),
@loc varchar(14)
)
as
begin
	declare @home_location varchar(14);
	declare @home_course_duration int;
	declare @total_duration int;
	declare @new_time int;
	begin try
		
		set @home_location = (select loc from emp e
								left join dept d on e.deptno = d.deptno
								where empno = @trainer);

		set @home_course_duration = isnull((select sum(dur) from offr o
								left join crs c on o.course = c.code
								where loc = @home_location and trainer = @trainer), 0)

		set @total_duration = isnull((select sum(dur) from offr o
								left join crs c on o.course = c.code
								where trainer = @trainer), 0)
	
		

		if(@oldCourse <> @course)
			set @new_time = (select dur from crs where code = @course)
		else 
			set @new_time = (select dur from crs where code = @oldCourse)

		if (@loc <> (select loc from offr where course = @oldCourse and starts = @oldStarts))
			begin
				set @home_course_duration = (@home_course_duration - @new_time)	
				set @total_duration = (@total_duration + @new_time)	
			end
		else
			begin
				set @total_duration = (@total_duration - @new_time)	
				set @home_course_duration = (@home_course_duration + @new_time)	
			end


		if(100 * @home_course_duration / @total_duration < 50)
			RAISERROR('Trainer is spending to much time teaching at a different location', 16, 1)
		else
			update offr set course = @course, starts = @starts, status = @status, maxcap = @maxcap, trainer = @trainer, loc = @loc where course = @oldCourse and starts = @oldStarts;

	end try
	begin catch
		throw
	end catch

end

exec update_trainer_offerings 'RGDEB', '2019-02-02', 'RGDEB', '2019-02-01', 'CONF', 20, 1017, 'hawaii'

Create or alter proc delete_trainer_offerings(
@course varchar(6),
@starts date,
@trainer numeric(4),
@loc varchar(14)
)
as
begin
	declare @home_location varchar(14);
	declare @home_course_duration int;
	declare @total_duration int;
	declare @new_time int;
	begin try

		set @home_location = (select loc from emp e
								left join dept d on e.deptno = d.deptno
								where empno = @trainer);

		set @home_course_duration = isnull((select sum(dur) from offr o
								left join crs c on o.course = c.code
								where loc = @home_location and trainer = @trainer), 0)

		set @total_duration = isnull((select sum(dur) from offr o
								left join crs c on o.course = c.code
								where trainer = @trainer), 0)

		set @new_time = (select dur from crs where code = @course)

		if(@loc <> @home_location)
			set @total_duration = (@total_duration - @new_time)
		else
			set @home_course_duration = (@home_course_duration - @new_time)		


		if(100 * @home_course_duration / @total_duration < 50)
			RAISERROR('Trainer is spending to much time teaching at a different location', 16, 1)
		else
			delete from offr where course = @course and starts = @starts;

	end try
	begin catch
		throw
	end catch

end

exec delete_trainer_offerings 'RGDEB', '2019-02-02', 1017, 'hawaii'

go
--Constraint 10	Offerings with 6 or more registrations must have status confirmed
create or alter trigger utrg_chk_reg on reg
after insert

as

begin
	begin try
		if exists (select 1 from offr o where exists (
		select COUNT(*)
		from reg r
		where r.starts = o.starts and r.course = o.course
		having COUNT(*) > 5
		) and o.status not in('CONF'))
			begin
				raiserror('The course must be confirmed', 11, 1)
			end
	end try
	begin catch
		throw
	end catch
end
								
go

-- Constraint 11 You are allowed to teach a course only if:
-- your job type is trainer and
---		-you have been employed for at least one year 
---		-or you have attended the course yourself (as participant) 

create or alter proc usp_insert_new_offr
@course varchar(6),
@starts date,
@status varchar(4),
@maxcap numeric(2),
@trainer numeric(4),
@loc varchar(14)

as

begin
	begin try
		declare @hired date = (select hired from emp where empno = @trainer)
		declare @dateDif int = (select DATEDIFF(MONTH, @hired, @starts))
		if (select job from emp where empno = @trainer) not in ('TRAINER')
			begin
				raiserror('Only a trainer can teach courses', 11, 1)
			end
		else if @dateDif < 12
			begin
				if not exists (select stud from reg where stud = @trainer and course = @course)
					raiserror('The employee has to follow the course or work here for a year before he can teach.', 11, 1)
			end
		insert into offr values(@course, @starts, @status, @maxcap, @trainer, @loc)
	end try
	begin catch
	 throw
	end catch
end