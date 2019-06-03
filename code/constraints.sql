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

--7

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