-- =============================================================
-- SECTION A: Basic Retrieval and Filtering
-- =============================================================

-- Q1: List all active students with student ID, name, email, batch, and admission date.
SELECT
    student_id,
    full_name,
    email,
    batch_id,
    admission_date
FROM students
WHERE enrollment_status = 'active'
ORDER BY student_id;

-- Q2: Find students whose email is missing or appears invalid.
SELECT
    student_id,
    full_name,
    email
FROM students
WHERE
    email IS NULL
    OR email = ''
    OR email NOT LIKE '%@%.%'
ORDER BY student_id;

-- Q3: List all problems with difficulty level Easy or Medium.
SELECT
    problem_id,
    problem_code,
    title,
    difficulty,
    max_score
FROM problems
WHERE difficulty IN ('Easy', 'Medium')
ORDER BY difficulty, problem_id;

-- Q4: Display the latest 20 submissions based on submission timestamp.
SELECT
    submission_id,
    student_id,
    problem_id,
    contest_id,
    status,
    score,
    submitted_at
FROM submissions
ORDER BY submitted_at DESC
LIMIT 20;

-- Q5: Find submissions where the status is not successful.

SELECT
    submission_id,
    student_id,
    problem_id,
    status,
    score
FROM submissions
WHERE status NOT IN ('Accepted', 'OK')
ORDER BY submitted_at DESC;

-- =============================================================
-- SECTION B: Joins
-- =============================================================

-- Q6: Display each submission with student name, problem title, language, status, score, and submitted time.
SELECT
    s.submission_id,
    st.full_name        AS student_name,
    p.title             AS problem_title,
    s.language,
    s.status,
    CAST(s.score AS REAL) AS score,
    s.submitted_at
FROM submissions s
JOIN students  st ON s.student_id  = st.student_id
JOIN problems  p  ON s.problem_id  = p.problem_id
ORDER BY s.submitted_at DESC
LIMIT 20;

-- Q7: Display all students and their enrollments, including students who are not enrolled in any course.
SELECT
    st.student_id,
    st.full_name,
    e.enrollment_id,
    e.course_id,
    e.enrollment_status
FROM students st
LEFT JOIN enrollments e ON st.student_id = e.student_id
ORDER BY st.student_id;

-- Q8: Display all courses with the number of enrolled students.
SELECT
    c.course_id,
    c.course_code,
    c.course_title,
    COUNT(e.enrollment_id) AS enrolled_count
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_id
ORDER BY enrolled_count DESC;

-- Q9: Display test-case results for each submission, including problem title and student name.
SELECT
    tr.result_id,
    s.submission_id,
    st.full_name      AS student_name,
    p.title           AS problem_title,
    tc.case_no,
    tr.result_status,
    tr.awarded_points
FROM test_results tr
JOIN submissions s  ON tr.submission_id  = s.submission_id
JOIN students    st ON s.student_id      = st.student_id
JOIN problems    p  ON s.problem_id      = p.problem_id
JOIN test_cases  tc ON tr.test_case_id   = tc.test_case_id
ORDER BY tr.result_id
LIMIT 20;

-- Q10: Find students enrolled in a course but who have not submitted any solution for that course.
SELECT DISTINCT
    st.student_id,
    st.full_name,
    e.course_id,
    c.course_title
FROM students    st
JOIN enrollments e ON st.student_id  = e.student_id
JOIN courses     c ON e.course_id    = c.course_id
WHERE NOT EXISTS (
    SELECT 1
    FROM submissions sub
    JOIN problems    pr ON sub.problem_id = pr.problem_id
    WHERE sub.student_id = st.student_id
      AND pr.course_id   = e.course_id
)
ORDER BY st.student_id;

-- =============================================================
-- SECTION C: Aggregation and HAVING
-- =============================================================

-- Q11: Count submissions by status.
SELECT
    status,
    COUNT(*) AS submission_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM submissions), 2) AS percentage
FROM submissions
GROUP BY status
ORDER BY submission_count DESC;

-- Q12: Calculate average score per problem.
SELECT
    p.problem_id,
    p.title,
    p.difficulty,
    COUNT(s.submission_id)                              AS total_submissions,
    ROUND(AVG(CAST(s.score AS REAL)), 2)                AS avg_score,
    p.max_score
FROM problems p
JOIN submissions s ON p.problem_id = s.problem_id
GROUP BY p.problem_id
ORDER BY avg_score DESC;

-- Q13: Find students with more than a chosen number of submissions. (Chosen threshold: 10)
SELECT
    st.student_id,
    st.full_name,
    COUNT(s.submission_id) AS submission_count
FROM students    st
JOIN submissions s ON st.student_id = s.student_id
GROUP BY st.student_id
HAVING submission_count > 10
ORDER BY submission_count DESC;

-- Q14: Find problems where the success rate is below 40%.
SELECT
    p.problem_id,
    p.title,
    p.difficulty,
    COUNT(s.submission_id)  AS total_attempts,
    SUM(CASE WHEN s.status IN ('Accepted', 'OK') THEN 1 ELSE 0 END) AS accepted_count,
    ROUND(
        100.0 * SUM(CASE WHEN s.status IN ('Accepted', 'OK') THEN 1 ELSE 0 END)
              / COUNT(s.submission_id),
        2
    )                       AS success_rate_pct
FROM problems p
JOIN submissions s ON p.problem_id = s.problem_id
GROUP BY p.problem_id
HAVING success_rate_pct < 40
ORDER BY success_rate_pct ASC;

-- Q15: Find the top 10 most attempted problems.
SELECT
    p.problem_id,
    p.title,
    p.difficulty,
    COUNT(s.submission_id) AS attempt_count
FROM problems p
JOIN submissions s ON p.problem_id = s.problem_id
GROUP BY p.problem_id
ORDER BY attempt_count DESC
LIMIT 10;

-- =============================================================
-- SECTION D: Subqueries / Set Logic
-- =============================================================

-- Q16: Find students whose average score is greater than the overall average score across all submissions.
SELECT
    st.student_id,
    st.full_name,
    COUNT(s.submission_id)               AS total_submissions,
    ROUND(AVG(CAST(s.score AS REAL)), 2) AS avg_score
FROM students    st
JOIN submissions s ON st.student_id = s.student_id
GROUP BY st.student_id
HAVING avg_score > (
    SELECT AVG(CAST(score AS REAL)) FROM submissions
)
ORDER BY avg_score DESC;

-- Q17: Find problems that have never been attempted.
SELECT
    p.problem_id,
    p.problem_code,
    p.title,
    p.difficulty,
    p.course_id
FROM problems p
WHERE p.problem_id NOT IN (
    SELECT DISTINCT problem_id FROM submissions
)
ORDER BY p.problem_id;

-- Q18: Find students who have enrolled but never submitted any solution.
SELECT
    st.student_id,
    st.full_name,
    st.enrollment_status
FROM students st
JOIN enrollments e ON st.student_id = e.student_id
WHERE st.student_id NOT IN (
    SELECT DISTINCT student_id FROM submissions
)
ORDER BY st.student_id;

-- Q19: Find students who have submitted solutions in both Python and Java.
SELECT
    st.student_id,
    st.full_name
FROM students st
WHERE st.student_id IN (
    SELECT student_id FROM submissions WHERE language = 'Python'
)
AND st.student_id IN (
    SELECT student_id FROM submissions WHERE language = 'Java'
)
ORDER BY st.student_id;

-- Q20: Find the second-highest score for a selected problem.
--      (Selected problem: P0001 — 'Shortest Path 1')
SELECT
    MAX(CAST(score AS REAL)) AS second_highest_score
FROM submissions
WHERE problem_id = 'P0001'
  AND CAST(score AS REAL) < (
      SELECT MAX(CAST(score AS REAL))
      FROM submissions
      WHERE problem_id = 'P0001'
  );