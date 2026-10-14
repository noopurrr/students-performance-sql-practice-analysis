-- STUDENTS PERFORMANCE: ANALYSIS QUERIES
-- Table: studentspt (built in 01_setup.sql)
-- Grades by total score (max 300): A >= 200, B 100-199, C < 100


-- 1. COUNT OF STUDENTS BY DEMOGRAPHIC GROUP

SELECT gender, count(*) AS count
FROM studentspt
GROUP BY gender;

SELECT race_ethnicity, count(*) AS count
FROM studentspt
GROUP BY race_ethnicity
ORDER BY count DESC;

SELECT parental_level_of_education, count(*) AS count
FROM studentspt
GROUP BY parental_level_of_education
ORDER BY count DESC;

SELECT lunch, count(*) AS count
FROM studentspt
GROUP BY lunch
ORDER BY count DESC;

SELECT test_preparation_course, count(*) AS count
FROM studentspt
GROUP BY test_preparation_course
ORDER BY count DESC;


-- 2. SCORE DISTRIBUTION

-- Lowest math score by gender
SELECT gender, min(math_score) AS min_math
FROM studentspt
GROUP BY gender;

-- Highest reading score by race/ethnicity
SELECT race_ethnicity, max(reading_score) AS max_reading
FROM studentspt
GROUP BY race_ethnicity
ORDER BY race_ethnicity;

-- Average writing score by parental education
SELECT parental_level_of_education, round(avg(writing_score), 1) AS avg_writing
FROM studentspt
GROUP BY parental_level_of_education
ORDER BY avg_writing DESC;

-- Spread of total score by lunch type
SELECT lunch, round(stddev(total_score), 1) AS std_dev
FROM studentspt
GROUP BY lunch
ORDER BY std_dev DESC;


-- 3. TEST PREP COMPARISON

SELECT test_preparation_course,
       round(avg(math_score), 1)    AS avg_math,
       round(avg(reading_score), 1) AS avg_reading,
       round(avg(writing_score), 1) AS avg_writing,
       round(avg(average_score), 1) AS avg_overall
FROM studentspt
GROUP BY test_preparation_course
ORDER BY test_preparation_course;


-- 4. CROSS-TAB QUERIES

-- Average score by lunch type and test prep
-- (Does test prep close the gap for students with free/reduced lunch?)
SELECT lunch, test_preparation_course,
       round(avg(average_score), 1) AS avg_score,
       count(*) AS students
FROM studentspt
GROUP BY lunch, test_preparation_course
ORDER BY lunch, test_preparation_course;

-- Average score by gender and race/ethnicity
SELECT gender, race_ethnicity, round(avg(average_score), 1) AS avg_score
FROM studentspt
GROUP BY gender, race_ethnicity
ORDER BY gender, race_ethnicity;

-- Average score by race/ethnicity after splitting by lunch type
SELECT lunch, race_ethnicity, round(avg(average_score), 1) AS avg_score
FROM studentspt
GROUP BY lunch, race_ethnicity
ORDER BY lunch, race_ethnicity;


-- 5. PERFORMANCE TIERS (CASE)

-- Students in each grade
SELECT CASE WHEN total_score < 100 THEN 'grade C'
            WHEN total_score < 200 THEN 'grade B'
            ELSE 'grade A'
       END AS grade,
       count(*) AS num_students
FROM studentspt
GROUP BY grade
ORDER BY grade;

-- Grades by lunch type (do free/reduced lunch students fall more in grade C?)
SELECT lunch,
       CASE WHEN total_score < 100 THEN 'grade C'
            WHEN total_score < 200 THEN 'grade B'
            ELSE 'grade A'
       END AS grade,
       count(*) AS count
FROM studentspt
GROUP BY lunch, grade
ORDER BY lunch, grade;

-- Grades by test prep (does test prep reduce grade C students?)
SELECT test_preparation_course,
       CASE WHEN total_score < 100 THEN 'grade C'
            WHEN total_score < 200 THEN 'grade B'
            ELSE 'grade A'
       END AS grade,
       count(*) AS count
FROM studentspt
GROUP BY test_preparation_course, grade
ORDER BY test_preparation_course, grade;

-- Grades by lunch type + test prep
SELECT lunch, test_preparation_course,
       CASE WHEN total_score < 100 THEN 'grade C'
            WHEN total_score < 200 THEN 'grade B'
            ELSE 'grade A'
       END AS grade,
       count(*) AS count
FROM studentspt
GROUP BY lunch, test_preparation_course, grade
ORDER BY lunch, test_preparation_course, grade;

-- Which subject has the highest / lowest average?
SELECT round(avg(math_score), 1)    AS avg_math,
       round(avg(reading_score), 1) AS avg_reading,
       round(avg(writing_score), 1) AS avg_writing
FROM studentspt;


-- 6. STRENGTHS AND WEAK AREAS

-- Weak in math, strong in reading and writing
SELECT * FROM studentspt
WHERE math_score < 60 AND reading_score >= 80 AND writing_score >= 80;

-- Strong in math, weak in reading or writing
-- (edit the cut-offs if this returns 0 rows)
SELECT * FROM studentspt
WHERE math_score >= 70 AND (reading_score < 60 OR writing_score < 60);

-- Students scoring below 40 in any subject, by demographic group
SELECT gender, race_ethnicity, parental_level_of_education, lunch,
       test_preparation_course, count(*) AS students
FROM studentspt
WHERE math_score < 40 OR reading_score < 40 OR writing_score < 40
GROUP BY gender, race_ethnicity, parental_level_of_education, lunch, test_preparation_course
ORDER BY students DESC;


-- 7. RANKING (WINDOW FUNCTION)

-- Rank race/ethnicity groups by average math score
-- (swap math_score for reading_score or writing_score to rank other subjects)
SELECT race_ethnicity,
       round(avg(math_score), 1) AS avg_math,
       RANK() OVER (ORDER BY avg(math_score) DESC) AS rank_math
FROM studentspt
GROUP BY race_ethnicity;

-- Which mix of factors gives the highest average score?
SELECT race_ethnicity, lunch, test_preparation_course,
       round(avg(average_score), 1) AS avg_score
FROM studentspt
GROUP BY race_ethnicity, lunch, test_preparation_course
ORDER BY avg_score DESC;
