-- STUDENTS PERFORMANCE: DATABASE SETUP
-- Run from the project root folder so the relative path below works:
--   psql -U postgres -d students -f sql/01_setup.sql

-- Staging table: raw CSV loaded as-is
DROP TABLE IF EXISTS students_raw;
CREATE TABLE students_raw (
    gender                      text,
    race_ethnicity              text,
    parental_level_of_education text,
    lunch                       text,
    test_preparation_course     text,
    math_score                  int,
    reading_score               int,
    writing_score               int
);

\copy students_raw FROM 'data/StudentsPerformance.csv' CSV HEADER

-- Analysis table: lunch and test prep as booleans, plus total and average score
--   lunch = TRUE                    -> 'standard' lunch
--   lunch = FALSE                   -> 'free/reduced' lunch (proxy for low income)
--   test_preparation_course = TRUE  -> course 'completed'
DROP TABLE IF EXISTS studentspt;
CREATE TABLE studentspt AS
SELECT
    gender,
    race_ethnicity,
    parental_level_of_education,
    (lunch = 'standard')                       AS lunch,
    (test_preparation_course = 'completed')    AS test_preparation_course,
    math_score,
    reading_score,
    writing_score,
    math_score + reading_score + writing_score                        AS total_score,
    ROUND((math_score + reading_score + writing_score) / 3.0, 2)      AS average_score
FROM students_raw;

DROP TABLE students_raw;

-- Quick checks
SELECT count(*) AS total_students FROM studentspt;
SELECT * FROM studentspt LIMIT 5;
