exec tSQLt.NewTestClass 'ConstraintsCasus';

use COURSE

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