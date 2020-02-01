

--------------------------------------------ahmed
alter proc makeExam(@mcqNo int,@tfNo int,@textNo int,@InsId smallint,@courseId smallint,@MCQDegree int,@T_FDegree int,@TEXTDegree int)
as
begin
	if(@InsId=(select InstructorID from Course where ID=@courseId)) 
	begin
	declare @MaxDegree smallint
	set @MaxDegree=(select MaxDegree from Course where ID=@courseId)
	if( @MaxDegree <(@MCQDegree*@mcqNo+@T_FDegree*@tfNo+@TEXTDegree*@textNo))
		begin
			Print 'Can not exceed course maxDegree'
		end
	else
		begin
		declare @ExID int
		declare @n int
		set @n = @mcqNo
		--set @MCQDegree=@MCQDegree*@mcqNo
		--set @T_FDegree=@T_FDegree*@tfNo
		--set @TEXTDegree=@TEXTDegree*@textNo
		insert into Exam values('Exam','08:00:00','09:00:00','01:00:00','2020-01-15',@InsId,@courseId,@MCQDegree,@T_FDegree,@TEXTDegree)
	
		set @ExID = @@IDENTITY
	
		insert into ExamQuestions(QuestionID,ExamID) 
		(select ID ,@ExID from QuestionPool where ID in
		(select top (@mcqNo) ID from QuestionPool where type='MCQ' ORDER BY NEWID()))

		insert into ExamQuestions(QuestionID,ExamID) 
		(select ID ,@ExID from QuestionPool where ID in
		( select top (@tfNo) ID from QuestionPool where type='TF' ORDER BY NEWID()))

		insert into ExamQuestions(QuestionID,ExamID) 
		(select ID ,@ExID from QuestionPool where ID in
		( select top (@textNo) ID from QuestionPool where type='TEXT' ORDER BY NEWID()))
	end
	end
	else
	begin
	declare @insName varchar(20)
	set @insName=(select InstructorName from Instructor where ID=@InsId)
		print 'The Instructor ' +@insName + ' can not add exam in this course' 
	end
end

exec makeExam 3,3,2,2,2,30,30,40
---------------------------------------

create function initializeTrainee(@TraineeNo smallint) 
returns @Trainee table
		(
		 TraineeID smallint primary key
		)
as
begin
	insert into @Trainee(TraineeID)(select ID from trainee where ID in(select top (@TraineeNo) ID from trainee))

return
end

select * from initializeTrainee(2)

create proc InsertTraineeExam(@ExID smallint,@TraineeNo smallint)
as
begin
	insert into [dbo].[TraineeExam](TraineeID,ExamID) (select TraineeID,@ExID from initializeTrainee(@TraineeNo))
end

select * from TraineeExam       --trainee and his exams
 
select * from trainee
select * from ExamQuestions     --exam with it's questions  
select * from QuestionPool

exec InsertTraineeExam 1,2

-------------------------------------------------

alter proc TraineeAnswerAQuestion(@TraineeID smallint,@ExID smallint,@QustionID smallint,@Answer varchar(MAX))
as
begin
	declare @CorrectAnswer varchar(max)
	declare @TraineeDegree smallint
	declare @FinalTraineeDegree smallint
	declare @AnswerID smallint
	declare @AnswerID2 smallint
	set @TraineeDegree=0
	insert into TraineeAnswer(TraineeID,ExamID,QuestionID) values(@TraineeID,@ExID,@QustionID)
	set @AnswerID=@@identity
	declare @QuestionType varchar(10)
	set @QuestionType=(select type from QuestionPool where ID=@QustionID)
	if(@QuestionType='MCQ')
		begin
			set @TraineeDegree=(select MCQDegree from Exam where ID=@ExID)
			set @CorrectAnswer=(select [Option] from MCQOption where QuestionID=@QustionID and IsTrue=1)
			if(@Answer=@CorrectAnswer)
			begin
			    set @FinalTraineeDegree=(select TraineeDegree from TraineeExam where TraineeID=@TraineeID and ExamID=@ExID)
				set @FinalTraineeDegree=@FinalTraineeDegree+@TraineeDegree
				insert into MCQAnswer(AnswerID,Answer,TraineeDegree,QuestionID) values(@AnswerID,@Answer,@TraineeDegree,@QustionID)
				set @AnswerID2=@@identity
				update TraineeExam set TraineeDegree=@FinalTraineeDegree where TraineeID=@TraineeID and ExamID=@ExID
			end
			else
			begin
				insert into MCQAnswer(AnswerID,Answer,TraineeDegree,QuestionID) values(@AnswerID,@Answer,0,@QustionID)
				set @AnswerID2=@@identity
			end
			update TraineeAnswer set AnswerID=@AnswerID2 where TraineeID=@TraineeID and ExamID=@ExID and QuestionID=@QustionID
		end
	else if(@QuestionType='TF')
		begin
		    set @TraineeDegree=(select TrueAndFalseDegree from Exam where ID=@ExID)
			set @CorrectAnswer=(select [Answer] from TrueAndFalse where QuestionID=@QustionID)
			if(@Answer=@CorrectAnswer)
			begin
			    set @FinalTraineeDegree=(select TraineeDegree from TraineeExam where TraineeID=@TraineeID and ExamID=@ExID)
				set @FinalTraineeDegree=@FinalTraineeDegree+@TraineeDegree
				insert into TrueAndFalseAnswer(AnswerID,Answer,TraineeDegree,QuestionID) values(@AnswerID,@Answer,@TraineeDegree,@QustionID)
				set @AnswerID2=@@identity
				update TraineeExam set TraineeDegree=@FinalTraineeDegree where TraineeID=@TraineeID and ExamID=@ExID
			end
			else
			begin
				insert into TrueAndFalseAnswer(AnswerID,Answer,TraineeDegree,QuestionID) values(@AnswerID,@Answer,0,@QustionID)
				set @AnswerID2=@@identity
			end
			update TraineeAnswer set AnswerID=@AnswerID2 where TraineeID=@TraineeID and ExamID=@ExID and QuestionID=@QustionID
		end
	else if(@QuestionType='TEXT')
		begin
		    set @TraineeDegree=(select TextDegree from Exam where ID=@ExID)
			set @CorrectAnswer=(select [Answer] from Text where QuestionID=@QustionID)
			if(@Answer=@CorrectAnswer)
			begin
			    set @FinalTraineeDegree=(select TraineeDegree from TraineeExam where TraineeID=@TraineeID and ExamID=@ExID)
				set @FinalTraineeDegree=@FinalTraineeDegree+@TraineeDegree
				insert into TextAnswer(AnswerID,Answer,TraineeDegree,QuestionID) values(@AnswerID,@Answer,@TraineeDegree,@QustionID)
				set @AnswerID2=@@identity
				update TraineeExam set TraineeDegree=@FinalTraineeDegree where TraineeID=@TraineeID and ExamID=@ExID
			end
			else
			begin
				insert into TextAnswer(AnswerID,Answer,TraineeDegree,QuestionID) values(@AnswerID,@Answer,0,@QustionID)
				set @AnswerID2=@@identity
			end
			update TraineeAnswer set AnswerID=@AnswerID2 where TraineeID=@TraineeID and ExamID=@ExID and QuestionID=@QustionID
		end
end


--------------------------------shimaa

create PROCEDURE InsertInstructor
    ( 
    @ManagerID smallint,
    @InstructorName VARCHAR(25)  
    )  
    AS 
    BEGIN
    if EXISTS(select dbo.Instructor.ManagerID from [dbo].[Instructor] where [ManagerID]=@ManagerID)
    BEGIN  
   insert into [dbo].[Instructor] (InstructorName,ManagerID) values(@InstructorName,@ManagerID)  
    END
    else
    BEGIN
    declare @Error varchar(50)
    set @Error='Plz enter correct manager id'
    print @Error
    End
    End
*************************
create proc UpdateInstructor
(
    @ID smallint, 
    @ManagerID smallint,
    @InstructorName VARCHAR(25)
)
    AS
    BEGIN
    if EXISTS(select dbo.Instructor.ManagerID from [dbo].[Instructor] where [ManagerID]=@ManagerID)
    BEGIN  
    UPDATE [dbo].[Instructor] SET  
    InstructorName = @InstructorName,[ManagerID]=@ManagerID
    WHERE  ID= @ID 
    END
    else
    BEGIN
    declare @Error varchar(50)
    set @Error='Plz enter correct manager id'
    print @Error
    End
    End
*********************************
create proc DeleteInstructor

(
   @ID smallint, 
   @ManagerID smallint
)
    AS
    BEGIN
    if EXISTS(select dbo.Instructor.ManagerID from [dbo].[Instructor] where [ManagerID]=@ManagerID)
    BEGIN  
    DELETE FROM [dbo].[Instructor] WHERE [ID]=@ID
    End
    else
    BEGIN
    declare @Error varchar(50)
    set @Error='Plz enter correct manager id'
    print @Error
    End
    End
**************************************

create proc ManagerAddCourse
(
   @ManagerID smallint,
   @CouserName varchar(25),
   @description varchar(MAX),
   @MaxDegree smallint,
   @MinDegree smallint,
   @TotalCourseHour smallint,
   @InstructorID smallint
)
  AS
  BEGIN
  if EXISTS(select dbo.Instructor.ManagerID from [dbo].[Instructor] where [ManagerID]=@ManagerID)
  BEGIN
  insert into [dbo].[Course]
  values(@CouserName,@description,@MaxDegree,@MinDegree,@TotalCourseHour,
  (select dbo.Instructor.ID from [dbo].[Instructor] where @InstructorID=[ID]))
  End
  else
  BEGIN
  declare @Error varchar(50)
  set @Error='Plz enter correct manager id'
  print @Error
  End
  End

  -------------------------roshdy
  create proc AddBranch
(
@BranchName varchar(30),
@ManagerID smallint
)
as
begin
if EXISTS(select dbo.Instructor.ManagerID from [dbo].[Instructor] where [ManagerID]=@ManagerID)
begin
insert into dbo.Branch
values(@BranchName,(select dbo.Instructor.ManagerID from [dbo].[Instructor] where [ManagerID]=@ManagerID))
end
else
begin
declare @Error varchar(50)
set @Error='Plz enter correct manager id'
print @Error
End
end



create proc UpdateBranch
(
@BranchName varchar(30),
@ManagerID smallint
)
as
begin
if EXISTS(select dbo.Instructor.ManagerID from [dbo].[Instructor] where [ManagerID]=@ManagerID)
begin
Update dbo.Branch
set [Name]=@BranchName,[ManagerID]=@ManagerID
end
else
begin
declare @Error varchar(50)
set @Error='Plz enter correct manager id'
print @Error
End
End


------------------------------------------------------------------

create proc AddIntake
(
@IntakeName varchar(30),
@ManagerID smallint
)
as
begin
if EXISTS(select dbo.Instructor.ManagerID from [dbo].[Instructor] where [ManagerID]=@ManagerID)
begin
insert into dbo.Intake
values(@IntakeName,(select dbo.Instructor.ManagerID from [dbo].[Instructor] where [ManagerID]=@ManagerID))
end
else
begin
declare @Error varchar(50)
set @Error='Plz enter correct manager id'
print @Error
End
end


---------------------
create proc UpdateIntake
(
@IntakeName varchar(30),
@ManagerID smallint
)
as
begin
if EXISTS(select dbo.Instructor.ManagerID from [dbo].[Instructor] where [ManagerID]=@ManagerID)
begin
Update dbo.Intake
set [Name]=@IntakeName,[ManagerID]=@ManagerID
end
else
begin
declare @Error varchar(50)
set @Error='Plz enter correct manager id'
print @Error
End
End


------------------------------------------------------
alter table [dbo].[Track]
add [ManagerID] smallint foreign key references [dbo].[Instructor]([ID])
create proc AddTrack
(
@TrackName varchar(30),
@ManagerID smallint
)
as
begin
if EXISTS(select dbo.Instructor.ManagerID from [dbo].[Instructor] where [ManagerID]=@ManagerID)
begin
insert into dbo.Track
values(@TrackName,(select dbo.Instructor.ManagerID from [dbo].[Instructor] where [ManagerID]=@ManagerID))
end
else
begin
declare @Error varchar(50)
set @Error='Plz enter correct manager id'
print @Error
End
end


-------------------------
create proc UpdateTrack
(
@TrackName varchar(30),
@ManagerID smallint
)
as
begin
if EXISTS(select dbo.Instructor.ManagerID from [dbo].[Instructor] where [ManagerID]=@ManagerID)
begin
Update dbo.Track
set [Name]=@TrackName,[ManagerID]=@ManagerID
end
else
begin
declare @Error varchar(50)
set @Error='Plz enter correct manager id'
print @Error
End
End

-----------------------------------------------------------------
create proc UpdateCourse
(
@CourseName varchar(30),
@Description varchar(max),
@MaxDegree smallint,
@MinDegree smallint,
@TotalCourseHour smallint,
@ManagerID smallint,
@InstructorID smallint
)
as
begin
if EXISTS(select dbo.Instructor.ManagerID from [dbo].[Instructor] where [ManagerID]=@ManagerID)
begin
if EXIsTS(select dbo.Instructor.ID from dbo.Instructor where dbo.Instructor.ID=@InstructorID)
begin
Update dbo.Course
set [CouserName]=@CourseName , [Description]=@Description,
[MaxDegree]=@MaxDegree,[MinDegree]=@MinDegree,
[TotalCouserHour]=@TotalCourseHour,[InstructorID]=@InstructorID
end
else
begin
declare @Error1 varchar(50)
set @Error1='Plz enter correct instructor id'
print @Error1
end
end
else
begin
declare @Error varchar(50)
set @Error='Plz enter correct manager id'
print @Error
End
End

------------------------
create proc DeleteCourse
(
@CourseName varchar(30),
@ManagerID smallint
)
as
begin
if EXISTS(select dbo.Instructor.ManagerID from [dbo].[Instructor] where [ManagerID]=@ManagerID)
begin
delete from [dbo].[Course] where [CouserName]=@CourseName and [InstructorID]=@ManagerID
end
else
begin
declare @Error varchar(50)
set @Error='Plz enter correct manager id'
print @Error
End
End

-----------------------------------sally
-- manager add trainee
create proc AddTrainee
(
@FirstName varchar(20),
@LastName varchar(30),
@Phone char(11),
@Mobile varchar(20),
@Email varchar(70),
@Gender char(7),
@BranchID smallint,
@IntakeID smallint,
@TrackID smallint,
@ManagerID smallint
)
as
begin
if EXISTS(select dbo.Branch.ID from [dbo].[Branch] where [ID]=@BranchID )
begin
if EXISTS(select dbo.Track.ID from [dbo].[Track] where [ID]=@TrackID)
begin
if EXISTS(select dbo.Intake.ID from [dbo].[Intake] where [ID]=@TrackID)
begin
if EXISTS(select dbo.Branch.ManagerID from [dbo].[Branch] where [ManagerID]=@ManagerID)
begin
insert into dbo.trainee
values(@FirstName ,@LastName,@Phone ,@Mobile, @Email,@Gender ,@BranchID ,@IntakeID ,@TrackID)

end
else
begin
declare @Error varchar(50)
set @Error='Plz enter correct manager id'
print @Error
End
end
else
begin
declare @Error1 varchar(50)
set @Error1='Plz enter correct intake id'
print @Error1
End
end
else
begin
declare @Error2 varchar(50)
set @Error2='Plz enter correct track id'
print @Error2
End
end
else
begin
declare @Error3 varchar(50)
set @Error3='Plz enter correct branch id'
print @Error3
End
end


exec AddTrainee 'sally','sayed','0862340101','01065816867','sallysayed780@gmail.com','female',4,2,2,1
select * from dbo.trainee

--select trainees that take the exam

alter proc TraineeDoExam
(
@TraineeID smallint,
@ExamID smallint,
@InstructorID smallint
)
as
begin
if EXISTS(select dbo.trainee.ID from [dbo].[trainee] where [ID]=@TraineeID )
begin
if EXISTS(select dbo.Instructor.ID from [dbo].[Instructor] where [ID]=@InstructorID)
begin
if EXISTS(select dbo.Exam.ID from [dbo].[Exam] where [ID]=@ExamID)
begin
insert into dbo.TraineeExam
values(@TraineeID,@ExamID,0)
end
else
begin
declare @Error1 varchar(50)
set @Error1='Plz enter correct exam id'
print @Error1
End
end
else
begin
declare @Error varchar(50)
set @Error='Plz enter correct instructor id'
print @Error
End
end
else
begin
declare @Error3 varchar(50)
set @Error3='Plz enter correct trainee id'
print @Error3
End
end


exec TraineeDoExam 2,7,2
select * from dbo.TraineeExam

alter table [dbo].[TraineeExam]
drop column [TraineeDegree]

alter table [dbo].[TraineeExam]
add [TraineeDegree] smallint


------------------------------------------Aya
--Instructor Insert 
create proc InstructorInsertQuestion  
    (  
	@instID smallint,
    @body varchar(max), 
    @type varchar(10),
	@courseID smallint
    )  
    AS 
    BEGIN
    if EXISTS(select [InstructorID] from [dbo].[Course] where [InstructorID]=@instID )
    --select ID from [dbo].[Course] where ID=@courseID
	BEGIN
    insert into [dbo].[QuestionPool] (Body,Type,[CourseID]) values(@body,@type,@courseID)  
    END
	else
    BEGIN
    declare @Error varchar(50)
    set @Error='Unable to insert...'
    print @Error
    End
    End
	-------------------------------------
	exec InstructorInsertQuestion 1, 'km,njkmlml?','TF',1
	--------------------------------------
-----------------------------------------------------------------------------------


--Instructor update
create proc InstructorUpdateQuestion
(
	@instID smallint,
	@QuestionID smallint,
    @body varchar(max), 
    @type varchar(10)
	--, @courseID smallint
)
    AS
    BEGIN
    if EXISTS(select [InstructorID] from [dbo].[Course] where [InstructorID]=@instID )
    BEGIN  
    UPDATE [dbo].[QuestionPool] SET  
    [Body] = @body,
	[Type]=@type
    WHERE  ID= @QuestionID 
    END
    else
    BEGIN
    declare @Error varchar(50)
    set @Error='Unable to update...'
    print @Error
    End
    End

	----------------------------------------------
	exec InstructorUpdateQuestion 1 , 5 , 'km ml?','TF'
	-----------------------------------------------
------------------------------------------------------------------
--instructor delete
	
create proc InstructorDeleteQuestion
(
   @instID smallint, 
   @QuestionID smallint
)
    AS
    BEGIN
    if EXISTS(select [InstructorID] from [dbo].[Course] where [InstructorID]=@instID )
    BEGIN  
    DELETE FROM [dbo].[QuestionPool] WHERE [ID]=@QuestionID
	--DELETE FROM [dbo].[MCQOption] WHERE [QuestionID]=@QuestionID
    End
    else
    BEGIN
    declare @Error varchar(50)
    set @Error='Invalid Operation...Not Exists'
    print @Error
    End
    End
	-------------------------------------------------------
	exec InstructorDeleteQuestion 1 , 9 
	exec InstructorDeleteQuestion 1 , 10
	--------------------------------------------------------
---------------------------------------------------------------------------------
--Add Options for questions
create type OptionType as table
(
		Ques_ID smallint not null
		,Optn varchar(25)
		,isTrue bit
)
go

                        -------------------------

create procedure InstructorInsertOption
		(@totalOptions OptionType READONLY)
as
begin 
		insert into [dbo].[MCQOption]
		select * from @totalOptions
end
			----------------------------

declare @opts OptionType
insert into @opts values (1,'agree',1)
insert into @opts values (1,'dis agree',0)

execute InstructorInsertOption @opts 
------------------------------------------------------------------
--------------------------------------------------------------------
--insert answers in TEXTor TF
alter proc [dbo].[InstructorInsertAnswerTFandTEXT]
(
	@questionID smallint,
	@answer varchar(max),
	@type varchar(10)
	--, @courseID smallint
)
    AS
    BEGIN  
	if(@type='TF')
	BEGIN
	insert into [dbo].[TrueAndFalse] values (@questionID,@answer)
	End
	else if(@type='TEXT')
	BEGIN
    insert into [dbo].[Text] values (@questionID,@answer)
	End
    else
    BEGIN
    declare @Error varchar(50)
    set @Error='Not Valid Type'
    print @Error
    End
	End
  --------------------------------------
  exec InstructorInsertAnswerTFandMCQ 5,'TRUE','TF'
  ----------------------------------------------------
----------------------------------------------------------------------------------------

select * from Exam

alter proc PrintExam(@ExID smallint)
as
begin
	declare @startDate datetime
	declare @EndDate datetime
	set @startDate=(select StartTime from Exam where ID=@ExID)
	set @EndDate=(select EndtTime from Exam where ID=@ExID)
	declare @dateNow int
	set @dateNow=DATEDIFF(HOUR,@startDate,GETDATE());
	select @dateNow
	if(@dateNow=0)
	begin
		select distinct EXQ.QuestionID from Exam EX,ExamQuestions EXQ
		where EXQ.ExamID=@ExID
	end
	else
	begin
		print 'Not Allowed Now'
	end
end

exec PrintExam 103

create proc showExamQuestions(@EXID smallint)
as
begin
select * from ExamQuestions where ExamID=@EXID order by QuestionID
end

