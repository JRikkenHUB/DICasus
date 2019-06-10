select 1 from [dbo].[emp] where job = 'ADMINISTRATOR' and deptno = 10

create nonclustered index ix_deptno on emp
(job)

select 1 from offr where course = 'RGDEV' and trainer = 1018

create nonclustered index ix_trainer on offr
(trainer)