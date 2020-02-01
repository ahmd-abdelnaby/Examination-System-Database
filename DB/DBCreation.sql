use master
CREATE DATABASE ExaminationSystem 
ON

( 
	NAME = Df1, 
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL14.AHMDSQL\MSSQL\DATA\Df1.mdf',
	SIZE = 5MB
),
( 
	NAME = Df2, 
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL14.AHMDSQL\MSSQL\DATA\Df2.ndf',
	SIZE = 5MB
),
FILEGROUP SECONDARY_fg 
( 
	NAME = Df3,
	FILENAME ='C:\Program Files\Microsoft SQL Server\MSSQL14.AHMDSQL\MSSQL\DATA\Df3.ndf',
	SIZE = 1MB
),
( 
	NAME = Df4,
	FILENAME ='C:\Program Files\Microsoft SQL Server\MSSQL14.AHMDSQL\MSSQL\DATA\Df4.ndf',
	SIZE = 1MB
)
LOG ON 
( 
	NAME = Log1,
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL14.AHMDSQL\MSSQL\DATA\lg1.ldf', 
	SIZE = 1MB
);

use ExaminationSystem

create table Branch
(
  ID smallint IDENTITY ( 1 , 1 ) PRIMARY KEY,
  [Name] VARCHAR(30) NOT NULL,
  ManagerID smallint foreign key references Instructor(ID)

)ON SECONDARY_fg;

GO

create table Intake
(
  ID smallint IDENTITY ( 1 , 1 ) PRIMARY KEY,
  [Name] VARCHAR(30) NOT NULL,
) ON SECONDARY_fg;

GO

create table Track
(
  ID smallint IDENTITY ( 1 , 1 ) PRIMARY KEY,
  [Name] VARCHAR(30) NOT NULL,
)ON SECONDARY_fg;

GO

create table trainee
(   
  ID smallint IDENTITY ( 1 , 1 )PRIMARY KEY,  
  FirstName VARCHAR(20) NOT NULL,  
  LastName VARCHAR(30) NOT NULL,    
  Phone CHAR(11) NOT NULL,   
  Mobile VARCHAR(20) NOT NULL,   
  Email VARCHAR(70) NOT NULL,   
  Gender char(7) NOT NULL,
  BranchID smallint FOREIGN KEY REFERENCES Branch(ID),
  IntakeID smallint FOREIGN KEY REFERENCES Intake(ID),
  TrackID smallint FOREIGN KEY REFERENCES Track(ID),
)  ON SECONDARY_fg;
GO
create table [User] 
(
ID smallint primary key identity(1,1),
UserName varchar(25)NOT NULL,
[Password] varchar(25) NOT NULL 
);

GO
create table Instructor(
	ID smallint not null identity(1,1) primary key,
	InstructorName varchar(25) not null,
	ManagerID smallint foreign key references Instructor(ID),
)ON SECONDARY_fg;

GO
create table Course
(
ID smallint Primary Key Identity (1,1),
CouserName varchar(25) NOT NULL,
[Description] varchar(max) NOT NULL,
MaxDegree smallint NOT NULL,
MinDegree smallint NOT NULL,
TotalCouserHour smallint NOT NULL,
InstructorID smallint foreign key references Instructor(ID) ,
);

GO

create table Exam
(
ID smallint primary key identity(1,1),
[Type] varchar(20) check ([Type] in ('Exam','Corrective')) NOT NULL,
StartTime time NOT NULL ,
EndtTime time NOT NULL ,
TotalTime time NOT NULL,
ExamDate datetime not null,
InstructorID smallint foreign key references Instructor(ID) ,
CourseID smallint FOREIGN KEY REFERENCES Course(ID),
MCQDegree smallint,  
TrueAndFalseDegree smallint,
TextDegree smallint,
);

go

create table TraineeExam
(
ID smallint Primary Key Identity (1,1),
TraineeID smallint foreign key references trainee(ID),
ExamID smallint foreign key references Exam(ID),
TraineeDegree smallint not null ,
)
GO

create table ExamQuestions(
    ID smallint primary key identity(1,1),
	QuestionID smallint foreign key references QuestionPool(ID),
	ExamID smallint foreign key references Exam(ID),
)ON SECONDARY_fg;

GO

create table TraineeCourse(
    ID smallint primary key identity(1,1),
	TraineeID smallint foreign key references trainee(ID),
	CourseID smallint foreign key references Course(ID)
)ON SECONDARY_fg;

GO
create table TraineeAnswer(
	ID smallint primary key identity(1,1),
	TraineeID smallint foreign key references trainee(ID),
	ExamID smallint foreign key references Exam(ID),
    QuestionID smallint foreign key references QuestionPool(ID),
	AnswerID smallint 
)ON SECONDARY_fg;

go
create table MCQOption
	(
    ID smallint primary key identity(1,1),
	QuestionID smallint foreign key references QuestionPool(ID),
	[Option] varchar (25) not null,
	IsTrue bit not null,
	);
	
go
create table MCQAnswer
	(
	ID smallint primary key identity(1,1),
	AnswerID smallint foreign key references TraineeAnswer(ID),
	Answer varchar(100),
	TraineeDegree smallint
	);
	
go
create table TrueAndFalse
	(
	ID smallint primary key identity(1,1),
	QuestionID smallint foreign key references QuestionPool(ID),
	Answer varchar(7) default ('False')
	);
go
create table TrueAndFalseAnswer
	(
	ID smallint primary key identity(1,1),
	AnswerID smallint foreign key references TraineeAnswer(ID),
	Answer char(4) not null,
	TraineeDegree smallint
	);
go
create table [Text]
	(
	ID smallint primary key identity(1,1),
	QuestionID smallint foreign key references QuestionPool(ID),
	Answer varchar(max) not null
	);

go
create table TextAnswer
	(
	ID smallint primary key identity(1,1),
	AnswerID smallint foreign key references TraineeAnswer(ID),
	Answer varchar(max) not null,
	TraineeDegree smallint
	);

go
create table QuestionPool(
	ID smallint primary key not null identity(1,1),
	Body varchar(max) not null,
	[Type] varchar(10) not null
    );
go


create table TraineeExam
(
	TraineeID smallint foreign key references trainee(ID),
	ExamID smallint foreign key references Exam(ID),
	FinalDegree smallint not null
);
go

alter table [dbo].[TraineeExam]
alter column TraineeDegree smallint



alter table MCQAnswer
add  QuestionID smallint foreign key references QuestionPool(ID) on delete cascade 

alter table [dbo].[TrueAndFalseAnswer]
add  QuestionID smallint foreign key references QuestionPool(ID) on delete cascade 

alter table [dbo].[TextAnswer]
add  QuestionID smallint foreign key references QuestionPool(ID) on delete cascade 

alter table [dbo].[QuestionPool]
add CourseID smallint foreign key references [dbo].[Course](ID)
----------------------------------- roshdy
alter table [dbo].[Track]
add [ManagerID] smallint foreign key references [dbo].[Instructor]([ID])

alter table [dbo].[Intake]
add [ManagerID] smallint foreign key references [dbo].[Instructor]([ID])


alter table [dbo].[TraineeCourse]
drop [FK_TraineeCoCours_2FCF1A8A]

ALTER TABLE [dbo].[TraineeCourse]
ADD CONSTRAINT FK_CONSTRAINTNAME
    FOREIGN KEY ([CourseID])
    REFERENCES [dbo].[Course](ID)
    ON DELETE CASCADE ON UPDATE cascade

alter table [dbo].[Exam]
drop [FK_ExamCourseID_4CA06362]


alter table [dbo].[Exam]
ADD CONSTRAINT FK_CONSTRAINTNAME2
    FOREIGN KEY ([CourseID])
    REFERENCES [dbo].[Course](ID)
    ON DELETE CASCADE ON UPDATE cascade


------------------------------------Aya

alter table [dbo].[trainee]
add isDeleted  bit default 0 not null

  --done
-------------------------
create TRIGGER trgSoftDeleteOnTrainee
ON trainee
INSTEAD OF DELETE
AS
		
		UPDATE [dbo].[trainee]
		SET  isDeleted=1
		where [ID] in (select [ID] from deleted)
--------------------------------
------------------------------------------------------------
alter table [dbo].[Course]
add isDeleted bit default 0 not null

go
-------------------------
create TRIGGER trgSoftDeleteOnCourse
ON Course
INSTEAD OF DELETE
AS
		
		UPDATE [dbo].[Course]
		SET  isDeleted=1
		where [ID] in (select [ID] from deleted)
--------------------------------
---------------------------------------------------------
alter table [dbo].[Instructor]
add isDeleted bit default 0 not null

go
-------------------------
create TRIGGER trgSoftDeleteOnInstructor
ON [dbo].[Instructor]
INSTEAD OF DELETE
AS
		
		UPDATE [dbo].[Instructor]
		SET  isDeleted=1
		where [ID] in (select [ID] from deleted)



