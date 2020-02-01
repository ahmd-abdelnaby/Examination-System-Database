

------------------------------------------------------

create proc summary
as
begin
select distinct tr.TraineeID, ExQ.ExamID,ExQ.QuestionID,Q.Body,M.[Option] as 'Correct Answer',MA.Answer as 'Trainee Answer',MA.TraineeDegree 
from ExamQuestions ExQ,TraineeExam tr,MCQAnswer MA,MCQOption M,QuestionPool Q
where ExQ.ExamID=tr.ExamID and m.IsTrue=1 and M.QuestionID=ExQ.QuestionID and MA.QuestionID=ExQ.QuestionID and Q.ID=ExQ.QuestionID and ExQ.QuestionID in
(select ID from QuestionPool )

union all
select distinct tr.TraineeID, ExQ.ExamID,ExQ.QuestionID,Q.Body,TF.Answer as 'Corect Answer',TFA.Answer as 'Trainee Answer',TFA.TraineeDegree 
from ExamQuestions ExQ,TraineeExam tr,TrueAndFalse TF,TrueAndFalseAnswer TFA,QuestionPool Q
where ExQ.ExamID=tr.ExamID and TF.QuestionID=ExQ.QuestionID and TFA.QuestionID=ExQ.QuestionID and Q.ID=ExQ.QuestionID  and ExQ.QuestionID in
(select ID from QuestionPool )


union all
select distinct tr.TraineeID, ExQ.ExamID,ExQ.QuestionID,Q.Body,TXT.Answer as 'correct',TXTA.Answer as'trainee answer',TXTA.TraineeDegree 
from ExamQuestions ExQ,TraineeExam tr,[Text] TXT,TextAnswer TXTA,QuestionPool Q
where ExQ.ExamID=tr.ExamID and TXT.QuestionID=ExQ.QuestionID and TXTA.QuestionID=ExQ.QuestionID and Q.ID=ExQ.QuestionID and ExQ.QuestionID in
(select ID from QuestionPool )
order by tr.TraineeID
end 


exec summary


create function computeSucces(@traineeDegree smallint)
returns varchar(10)
with schemabinding
	begin
		declare @res varchar(10)
		if(@traineeDegree>60)
			begin
			set @res='PASS'
			end
		else
			begin
			set @res='NOT PASS'
		    end
		return @res
	end

alter table [dbo].[TraineeExam]
add Result as dbo.computeSucces(TraineeDegree) 

----------------------
alter view [vTraineeFinalMark]
as  
select [TraineeID],[ExamID],[TraineeDegree],[Result]
from [dbo].[TraineeExam]
----------------
select * from vResults
-------------------

select * from [dbo].[ExamsDetails]order by TraineeID

select * from TraineeAnswer
select * from MCQAnswer

select * from TrueAndFalse
select * from TrueAndFalseAnswer
select * from Exam
select * from Course

alter view ExamDetails
as
select tr.TraineeID,tr.ExamID,C.CouserName,tr.QuestionID,Q.Body,M.[Option] as 'Correct Answer',MA.Answer as 'Trainee Answer',MA.TraineeDegree 
from TraineeAnswer tr,QuestionPool Q,MCQOption M,MCQAnswer MA,Course C,Exam X
where tr.QuestionID=Q.ID and tr.ExamID=X.ID and X.CourseID=C.ID 
and Q.Type='MCQ'and M.QuestionID=tr.QuestionID and M.IsTrue=1 and tr.AnswerID=MA.ID

union all
select tr.TraineeID,tr.ExamID,C.CouserName,tr.QuestionID,Q.Body,TF.Answer,TFA.Answer,TFA.TraineeDegree
from TraineeAnswer tr,QuestionPool Q,TrueAndFalse TF,TrueAndFalseAnswer TFA,Course C,Exam X
where tr.QuestionID=Q.ID and tr.ExamID=X.ID and X.CourseID=C.ID 
and Q.Type='TF'and TF.QuestionID=tr.QuestionID  and tr.AnswerID=TFA.ID

union all
select tr.TraineeID,tr.ExamID,C.CouserName,tr.QuestionID,Q.Body,T.Answer,TA.Answer,TA.TraineeDegree 
from TraineeAnswer tr,QuestionPool Q,Text T,TextAnswer TA,Course C,Exam X
where tr.QuestionID=Q.ID and tr.ExamID=X.ID and X.CourseID=C.ID 
and Q.Type='TEXT'and T.QuestionID=tr.QuestionID  and tr.AnswerID=TA.ID
-----------------------------------------------

select * from [dbo].[ExamDetails] order by TraineeID
select * from [dbo].[vResults]
select * from TraineeExam

create view MCQ
as
SELECT        dbo.MCQOption.ID, dbo.MCQOption.[Option], dbo.QuestionPool.Body AS [MCQ Body]
FROM            dbo.MCQOption INNER JOIN
                         dbo.QuestionPool ON dbo.MCQOption.QuestionID = dbo.QuestionPool.ID
WHERE        (dbo.MCQOption.IsTrue = 1)

select * from MCQ


alter view TrueAndFalseView
as

SELECT        dbo.TrueAndFalse.QuestionID, dbo.QuestionPool.Body AS [Question Body], dbo.TrueAndFalse.Answer
FROM            dbo.QuestionPool INNER JOIN
                         dbo.TrueAndFalse ON dbo.QuestionPool.ID = dbo.TrueAndFalse.QuestionID
WHERE        (dbo.QuestionPool.Type = 'TF')



create view TextQuestionsAndAnswers
as
SELECT        dbo.QuestionPool.Body, dbo.Text.QuestionID, dbo.Text.Answer
FROM            dbo.QuestionPool INNER JOIN
                         dbo.Text ON dbo.QuestionPool.ID = dbo.Text.QuestionID
WHERE        (dbo.QuestionPool.Type = 'TEXT')

select * from TextQuestionsAndAnswers

select * from [dbo].[vTraineeFinalMark]