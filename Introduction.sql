-- Unit-I Introduction: Review of database design methods: ER modeling and normalization.

-- ===========================================================================
-- DATABASE APPLICATIONS: COMPLETE ALL-IN-ONE STUDENT-COURSE ENROLLMENT SYSTEM
-- ===========================================================================
-- Covers:
--  - ER Modeling (Entities + Relationships)
--  - Normalization (1NF, 2NF, 3NF)
--  - Table creation with keys, constraints, checks, defaults
--  - Sample data insertion for realistic testing
--  - Multiple advanced queries to verify and analyze data
-- ===========================================================================

-- ===============================
-- STEP 1: ENTITY CREATION (ER MODEL)
-- ===============================

-- STUDENT ENTITY
CREATE TABLE Student (
    StudentID INT PRIMARY KEY,               -- Unique Student ID
    Name VARCHAR(100) NOT NULL,              -- Student full name
    Email VARCHAR(100) UNIQUE NOT NULL,      -- Student email, unique
    Phone VARCHAR(15),                       -- Atomic phone number (1NF)
    DateOfBirth DATE NOT NULL                -- Student DOB
);

-- COURSE ENTITY
CREATE TABLE Course (
    CourseID INT PRIMARY KEY,                -- Unique Course ID
    CourseName VARCHAR(100) NOT NULL,       -- Course title
    Credits INT CHECK (Credits > 0)          -- Positive integer credits
);

-- ENROLLMENT RELATIONSHIP (Many-to-Many)
CREATE TABLE Enrollment (
    StudentID INT NOT NULL,
    CourseID INT NOT NULL,
    EnrollmentDate DATE NOT NULL DEFAULT CURRENT_DATE, -- Enrollment date, defaults to today
    Grade CHAR(2),                            -- Optional Grade (A, B+, etc.)

    PRIMARY KEY (StudentID, CourseID),      -- Composite key (2NF)
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Course(CourseID)
);

-- ===============================
-- STEP 2: NORMALIZATION NOTES (Documentation)
-- ===============================
-- 1NF: All columns atomic, no repeating groups (e.g., Phone stores only one number).
-- 2NF: Enrollment composite key prevents partial dependencies.
-- 3NF: Non-key attributes depend only on the key (no transitive dependencies).

-- ===============================
-- STEP 3: SAMPLE DATA INSERTION
-- ===============================

INSERT INTO Student (StudentID, Name, Email, Phone, DateOfBirth) VALUES
(1, 'Alice Johnson', 'alice@example.com', '1234567890', '2000-04-15'),
(2, 'Bob Smith', 'bob@example.com', '0987654321', '1999-09-23'),
(3, 'Carol Davis', 'carol@example.com', '5551234567', '2001-01-05'),
(4, 'David Lee', 'david@example.com', '4445556666', '2000-12-12'),
(5, 'Eve Turner', 'eve@example.com', '2223334444', '2002-06-30');

INSERT INTO Course (CourseID, CourseName, Credits) VALUES
(101, 'Database Systems', 4),
(102, 'Operating Systems', 3),
(103, 'Computer Networks', 3),
(104, 'Software Engineering', 4),
(105, 'Artificial Intelligence', 3);

INSERT INTO Enrollment (StudentID, CourseID, EnrollmentDate, Grade) VALUES
(1, 101, '2025-05-01', 'A'),
(1, 102, '2025-05-02', 'B+'),
(2, 102, '2025-05-03', 'A-'),
(3, 103, '2025-05-04', 'B'),
(3, 101, '2025-05-05', 'A'),
(4, 104, '2025-05-06', 'B-'),
(4, 101, '2025-05-07', NULL),
(5, 105, '2025-05-08', 'A'),
(5, 103, '2025-05-09', 'B+'),
(5, 101, '2025-05-10', 'A-');

-- ===============================
-- STEP 4: VERIFICATION AND ANALYSIS QUERIES
-- ===============================

-- 1) List all students with their enrolled courses and grades
SELECT 
    s.StudentID, s.Name, s.Email, s.Phone, s.DateOfBirth,
    c.CourseID, c.CourseName, c.Credits,
    e.EnrollmentDate, e.Grade
FROM Student s
JOIN Enrollment e ON s.StudentID = e.StudentID
JOIN Course c ON e.CourseID = c.CourseID
ORDER BY s.StudentID, c.CourseID;

-- 2) Number of students enrolled per course
SELECT
    c.CourseID, c.CourseName, c.Credits,
    COUNT(e.StudentID) AS EnrolledStudents
FROM Course c
LEFT JOIN Enrollment e ON c.CourseID = e.CourseID
GROUP BY c.CourseID, c.CourseName, c.Credits
ORDER BY EnrolledStudents DESC;

-- 3) Students enrolled in more than two courses
SELECT
    s.StudentID, s.Name, COUNT(e.CourseID) AS CoursesEnrolled
FROM Student s
JOIN Enrollment e ON s.StudentID = e.StudentID
GROUP BY s.StudentID, s.Name
HAVING COUNT(e.CourseID) > 2
ORDER BY CoursesEnrolled DESC;

-- 4) Average GPA per course (letter grades converted to GPA points)
SELECT
    c.CourseID, c.CourseName,
    ROUND(AVG(CASE 
        WHEN e.Grade = 'A' THEN 4.0
        WHEN e.Grade = 'A-' THEN 3.7
        WHEN e.Grade = 'B+' THEN 3.3
        WHEN e.Grade = 'B' THEN 3.0
        WHEN e.Grade = 'B-' THEN 2.7
        WHEN e.Grade = 'C+' THEN 2.3
        WHEN e.Grade = 'C' THEN 2.0
        WHEN e.Grade = 'C-' THEN 1.7
        WHEN e.Grade = 'D+' THEN 1.3
        WHEN e.Grade = 'D' THEN 1.0
        WHEN e.Grade = 'F' THEN 0.0
        ELSE NULL
    END), 2) AS AvgGPA
FROM Course c
JOIN Enrollment e ON c.CourseID = e.CourseID
GROUP BY c.CourseID, c.CourseName
ORDER BY AvgGPA DESC;

-- 5) List students with no enrollments (if any)
SELECT
    s.StudentID, s.Name
FROM Student s
LEFT JOIN Enrollment e ON s.StudentID = e.StudentID
WHERE e.StudentID IS NULL;

-- 6) List courses with no students enrolled (if any)
SELECT
    c.CourseID, c.CourseName
FROM Course c
LEFT JOIN Enrollment e ON c.CourseID = e.CourseID
WHERE e.CourseID IS NULL;

-- 7) Students ordered by Date of Birth (youngest first)
SELECT StudentID, Name, DateOfBirth
FROM Student
ORDER BY DateOfBirth DESC;

-- 8) Total credits each student is enrolled in
SELECT
    s.StudentID, s.Name,
    SUM(c.Credits) AS TotalCredits
FROM Student s
JOIN Enrollment e ON s.StudentID = e.StudentID
JOIN Course c ON e.CourseID = c.CourseID
GROUP BY s.StudentID, s.Name
ORDER BY TotalCredits DESC;

-- ===========================================================================
-- END OF SCRIPT
-- ===========================================================================
