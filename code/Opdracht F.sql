create login FakeEmployeeLogin with password = '123'

create login ServiceAccLogin with password = '123'

create user FakeEmployee for login FakeEmployeeLogin

create user ServiceAcc for login ServiceAccLogin

grant execute on object::chk_trainer_course
to FakeEmployee

grant select on reg
to FakeEmployee

grant select on emp
to FakeEmployee

grant select on offr
to FakeEmployee

grant select on schema :: [dbo] to ServiceAcc


begin tran
setuser 'FakeEmployee'

--FakeEmployee isnt allowed to insert in emp
insert into emp values (2000, 'test', 'ADMIN', '1999-12-21', GETDATE(), 2, 2150, 'test', 12) 

--FakeEmployee is allowed to execute sp chck_trainer_course
exec chk_trainer_course 1001, 'J2EE', '2001-10-10', 4

--FakeEmployee isnt allowed to read the data in grd
select * from grd

setuser
rollback tran

begin tran
setuser 'ServiceAcc'

--ServiceAcc is allowed to read data from all the tables in this schema
select * from grd

select * from emp

select * from term

--ServiceAcc isnt allowed to insert, update or delete data
insert into term values (1000, GETDATE(), null) 

update offr
set trainer = 1000
where trainer = null

delete from emp
where empno = 1000


--ServiceAcc isnt allowed to execute any sp
exec usp_insert_term 1000, '2019-06-10', null

setuser
rollback tran