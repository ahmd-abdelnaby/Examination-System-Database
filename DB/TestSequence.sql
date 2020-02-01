exec makeExam 5,5,5,1,7,5,5,10   --create Exam  MCQ NO.,TF No.,TEXT No.,INS ID,Course ID,MCQ point degree,TF point degree,TEXT point degree


exec showExamQuestions 107   -- procedure show specified exam Qusestions  Exam ID


exec TraineeDoExam 7,107,1   --proc that assign a trainee to a exam  TraineeID,ExID,INSID
exec TraineeDoExam 4,107,1

exec TraineeAnswerAQuestion 7,107,69,'COUNT(*)'  --procs to answer question and calculate results
exec TraineeAnswerAQuestion 7,107,70,'MAX'
exec TraineeAnswerAQuestion 7,107,71,'DELETE'
exec TraineeAnswerAQuestion 7,107,72,'DELETE'
exec TraineeAnswerAQuestion 7,107,74,'ROLLBACK and SAVEPOINT'
exec TraineeAnswerAQuestion 7,107,81,'DELETE'
exec TraineeAnswerAQuestion 7,107,82,'TRUNCATE'
exec TraineeAnswerAQuestion 7,107,83,'UPDATE'
exec TraineeAnswerAQuestion 7,107,85,'DDL'
exec TraineeAnswerAQuestion 7,107,88,'The AS SQL clause is used to change'
exec TraineeAnswerAQuestion 7,107,92,'true'
exec TraineeAnswerAQuestion 7,107,94,'false'
exec TraineeAnswerAQuestion 7,107,95,'false'
exec TraineeAnswerAQuestion 7,107,96,'true'
exec TraineeAnswerAQuestion 7,107,98,'false'

exec TraineeAnswerAQuestion 4,107,69,'COUNT(*)'  --procs to answer question and calculate results
exec TraineeAnswerAQuestion 4,107,70,'MAX'
exec TraineeAnswerAQuestion 4,107,71,'DELETE'
exec TraineeAnswerAQuestion 4,107,72,'DELETE'
exec TraineeAnswerAQuestion 4,107,74,'ROLLBACK and SAVEPOINT'
exec TraineeAnswerAQuestion 4,107,81,'DELETE'
exec TraineeAnswerAQuestion 4,107,82,'TRUNCATE'
exec TraineeAnswerAQuestion 4,107,83,'UPDATE'
exec TraineeAnswerAQuestion 4,107,85,'DDL'
exec TraineeAnswerAQuestion 4,107,88,'The AS SQL clause is used to change'
exec TraineeAnswerAQuestion 4,107,92,'true'
exec TraineeAnswerAQuestion 4,107,94,'false'
exec TraineeAnswerAQuestion 4,107,95,'false'
exec TraineeAnswerAQuestion 4,107,96,'true'
exec TraineeAnswerAQuestion 4,107,98,'false'

select * from ExamDetails order by TraineeID  --view display Exam results for each trainee

select * from [dbo].[vTraineeFinalMark]      -- view show trainees final result Pass or not pass


exec summary   --EXmaination system summary all trainees with all exams

