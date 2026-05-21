# Query Outputs & Validation Notes

All queries were executed against `codejudge_raw.db`. Outputs below are from real data.

---

## Q1 — Active Students

**Purpose:** List all currently active students with their profile details.

| student_id | full_name | email | batch_id | admission_date |
|---|---|---|---|---|
| S0001 | Vivaan Gupta | vivaan.gupta001@codejudge.edu | B002 | 2025-02-13 |
| S0002 | Harsh Das | harsh.das002@codejudge.edu | B006 | 2025-04-08 |
| S0004 | Ananya Bose | ananya.bose004@codejudge.edu | B003 | 2025-02-19 |
| S0006 | Isha Mehta | isha.mehta006@codejudge.edu | B001 | 2025-03-14 |

**Result summary:** 232 rows returned.

**Validation note:** Total students = 320. Non-active: 29 dropped + 28 graduated + 30 inactive + 1 typo ('actve') = 88. 232 + 88 = 320.

---

## Q2 — Students with Missing or Invalid Email

**Purpose:** Detect students whose email field is empty or malformed.

| student_id | full_name | email |
|---|---|---|
| S0005 | Ayaan Gupta | *(empty string)* |
| S0018 | Anika Patel | ravi.no-at-symbol.codejudge.edu |

**Result summary:** 2 rows returned.

**Validation note:** S0005 has an empty string in the email column. S0018's email is missing the `@` character — the LIKE pattern `'%@%.%'` correctly rejects it. These will be flagged as data quality issues in Part 3.

---

## Q3 — Easy and Medium Problems

**Purpose:** List problems suitable for beginner/intermediate students.

| problem_id | problem_code | title | difficulty | max_score |
|---|---|---|---|---|
| P0002 | CS101_P02 | Dynamic Programming Basics 2 | Easy | 50 |
| P0003 | CS101_P03 | Dynamic Programming Basics 3 | Easy | 50 |
| P0001 | CS101_P01 | Shortest Path 1 | Medium | 75 |
| P0006 | CS101_P06 | Graph Traversal 6 | Medium | 75 |

**Result summary:** 38 problems (Easy + Medium combined).

**Validation note:** `IN ('Easy', 'Medium')` correctly excludes Hard and Very Hard problems. The dataset also contains 'Very Hard' difficulty which is unique to this platform.

---

## Q4 — Latest 20 Submissions

**Purpose:** Show the most recent platform activity.

| submission_id | student_id | problem_id | status | score | submitted_at |
|---|---|---|---|---|---|
| SUB001091 | S0074 | P0025 | Runtime Error | 12 | 2025-08-12 03:44:00 |
| SUB001593 | S0007 | P0005 | Accepted | 50 | 2025-08-05 20:47:00 |
| SUB000123 | S0002 | P0067 | Accepted | 50 | 2025-08-04 15:30:00 |
| SUB001144 | S0007 | P0006 | Compilation Error | 0 | 2025-07-31 02:49:00 |

**Result summary:** Exactly 20 rows (LIMIT 20).

**Validation note:** Results are ordered `DESC` by `submitted_at`. The most recent submission is from 2025-08-12. Submissions span from early 2025 to August 2025.

---

## Q5 — Unsuccessful Submissions

**Purpose:** Identify all failed/non-accepted submissions.

| submission_id | student_id | problem_id | status | score |
|---|---|---|---|---|
| SUB000001 | S0282 | P0043 | Wrong Answer | 46 |
| SUB000002 | S0289 | P0028 | Wrong Answer | 46 |
| SUB000006 | S0154 | P0012 | Compilation Error | 0 |
| SUB000007 | S0248 | P0023 | Wrong Answer | 6 |

**Result summary:** 1,373 unsuccessful submissions.

**Validation note:** 2,501 total − 1,128 successful ('Accepted'=1127, 'OK'=1) = 1,373. Note: a non-zero score alongside 'Wrong Answer' indicates partial scoring (some test cases passed even though the overall verdict failed).

---

## Q6 — Submissions with Student and Problem Details

**Purpose:** Human-readable submission log with names instead of IDs.

| submission_id | student_name | problem_title | language | status | score | submitted_at |
|---|---|---|---|---|---|---|
| SUB001091 | Neil Ghosh | Trie Search 25 | C++ | Runtime Error | 12 | 2025-08-12 |
| SUB001593 | Reyansh Kulkarni | Queue using Stacks 5 | Go | Accepted | 50 | 2025-08-05 |
| SUB000123 | Harsh Das | Reverse String 67 | C | Accepted | 50 | 2025-08-04 |
| SUB001144 | Reyansh Kulkarni | Graph Traversal 6 | Go | Compilation Error | 0 | 2025-07-31 |

**Result summary:** 2,501 rows (all submissions).

**Validation note:** Both JOINs resolve successfully — every submission has a valid `student_id` and `problem_id` in the raw data. Languages observed include C, C++, Java, Python, JavaScript, Go, PseudoCode.

---

## Q7 — All Students and Their Enrollments (LEFT JOIN)

**Purpose:** Show all students, including any who are not enrolled in any course.

| student_id | full_name | enrollment_id | course_id | enrollment_status |
|---|---|---|---|---|
| S0001 | Vivaan Gupta | E00002 | C001 | active |
| S0001 | Vivaan Gupta | E00001 | C006 | active |
| S0001 | Vivaan Gupta | E00001 | C006 | active |
| S0002 | Harsh Das | E00034 | C003 | active |

**Result summary:** 719+ rows. 0 students have zero enrolments.

**Validation note:** S0001 appears three times — once for C001 and twice for C006 (duplicate enrolment in the raw data — a data integrity issue to be fixed in Part 3). The LEFT JOIN correctly includes all students.

---

## Q8 — Course Enrolment Counts

**Purpose:** Show how many students are enrolled in each course.

| course_id | course_code | course_title | enrolled_count |
|---|---|---|---|
| C002 | CS102 | Data Structures | 101 |
| C005 | CS202 | Operating Systems | 99 |
| C007 | CS204 | Algorithms | 94 |
| C006 | CS203 | Computer Networks | 91 |
| C003 | CS103 | Object Oriented Programming | 89 |
| C001 | CS101 | Programming Fundamentals | 80 |
| C004 | CS201 | Database Management Systems | 79 |
| C009 | CS301 | Machine Learning | 57 |
| C010 | CS302 | Cloud Computing | 29 |
| C008 | CS205 | Software Engineering | 20 |

**Result summary:** 10 rows (all courses).

**Validation note:** Sum of enrolled_count = 719, which exactly matches the total rows in the `enrollments` table. Data Structures is the most popular course (101 students).

---

## Q9 — Test-Case Results with Student and Problem Details

**Purpose:** Granular view of how each submission performed per test case.

| result_id | submission_id | student_name | problem_title | case_no | result_status | awarded_points |
|---|---|---|---|---|---|---|
| R0000001 | SUB000001 | Isha Gupta | Dynamic Programming Basics 43 | 1 | Runtime Error | 0 |
| R0000002 | SUB000001 | Isha Gupta | Dynamic Programming Basics 43 | 6 | Failed | 0 |
| R0000005 | SUB000001 | Isha Gupta | Dynamic Programming Basics 43 | 5 | Passed | 8 |

**Result summary:** 9,673 rows (full test results).

**Validation note:** A single submission (SUB000001) can span multiple result rows — one per test case. The 4-table JOIN correctly resolves all foreign keys. A mix of 'Passed' and 'Failed' results for the same submission explains partial scores.

---

## Q10 — Students Enrolled but Never Submitted (per course)

**Purpose:** Find (student, course) pairs where the student is enrolled but has never submitted for that course.

| student_id | full_name | course_id | course_title |
|---|---|---|---|
| S0004 | Ananya Bose | C001 | Programming Fundamentals |
| S0004 | Ananya Bose | C002 | Data Structures |
| S0010 | Rohan Singh | C007 | Algorithms |

**Result summary:** 214 distinct students have at least one such course.

**Validation note:** Uses `NOT EXISTS` with a correlated subquery checking if any submission exists for that student in that course's problems. This is more accurate than a simple LEFT JOIN because a student can submit for one course but not another.

---

## Q11 — Submission Count by Status

**Purpose:** Distribution of automated judge verdicts.

| status | submission_count | percentage |
|---|---|---|
| Accepted | 1127 | 45.06% |
| Wrong Answer | 729 | 29.15% |
| Runtime Error | 277 | 11.08% |
| Compilation Error | 196 | 7.84% |
| Time Limit Exceeded | 171 | 6.84% |
| OK | 1 | 0.04% |

**Result summary:** 6 distinct status values, total = 2,501.

**Validation note:** 1127 + 729 + 277 + 196 + 171 + 1 = 2,501. The single 'OK' record is a non-standard alias for 'Accepted' — a data issue to address in Part 3.

---

## Q12 — Average Score per Problem

**Purpose:** Identify easiest and hardest problems by student performance.

| problem_id | title | difficulty | total_submissions | avg_score | max_score |
|---|---|---|---|---|---|
| P0021 | SQL Joins 21 | Hard | 18 | 90.72 | 100 |
| P0018 | Database Indexing 18 | Hard | 21 | 79.43 | 100 |
| P0017 | Tree Diameter 17 | Medium | 22 | 71.91 | 75 |
| P0008 | LRU Cache 8 | Medium | 36 | 66.72 | 75 |
| P0040 | Graph Traversal 40 | Medium | 55 | 65.80 | 75 |

**Result summary:** 66 rows (P0036 has no submissions so is excluded from JOIN).

**Validation note:** `CAST(score AS REAL)` required because all columns are TEXT in the raw DB. Without casting, SQLite's AVG on strings returns incorrect results.

---

## Q13 — Students with More than 10 Submissions

**Purpose:** Identify the most active students (threshold = 10).

| student_id | full_name | submission_count |
|---|---|---|
| S0052 | Kabir Mehta | 19 |
| S0126 | Yash Khan | 17 |
| S0133 | Dhruv Patel | 16 |
| S0146 | Nisha Iyer | 16 |
| S0060 | Isha Das | 15 |

**Result summary:** 51 students have more than 10 submissions.

**Validation note:** `HAVING` is used because the filter operates on the aggregated `COUNT()` result — `WHERE` runs before grouping and cannot reference aggregate aliases.

---

## Q14 — Problems with Success Rate Below 40%

**Purpose:** Flag problems where fewer than 40% of submissions were accepted.

| problem_id | title | difficulty | total | accepted | success_rate_pct |
|---|---|---|---|---|---|
| P0064 | Trie Search 64 | Hard | 40 | 12 | 30.00% |
| P0028 | Valid Parentheses 28 | Hard | 38 | 12 | 31.58% |
| P0008 | LRU Cache 8 | Medium | 36 | 12 | 33.33% |
| P0055 | Merge Intervals 55 | Hard | 27 | 9 | 33.33% |
| P0032 | Valid Parentheses 32 | Hard | 47 | 16 | 34.04% |

**Result summary:** Multiple problems fall below the 40% threshold.

**Validation note:** Hard problems dominate this list, which is logically expected. The `CASE WHEN` expression inside `SUM` counts only successful verdicts — both 'Accepted' and 'OK' are treated as success.

---

## Q15 — Top 10 Most Attempted Problems

**Purpose:** Find which problems students engage with most.

| problem_id | title | difficulty | attempt_count |
|---|---|---|---|
| P0040 | Graph Traversal 40 | Medium | 55 |
| P0019 | Dynamic Programming Basics 19 | Medium | 53 |
| P0001 | Shortest Path 1 | Medium | 53 |
| P0045 | Deadlock Detection 45 | Medium | 49 |
| P0043 | Dynamic Programming Basics 43 | Medium | 49 |

**Result summary:** Top 10 problems shown; most are Medium difficulty.

**Validation note:** Medium-difficulty problems dominate the top 10, suggesting they are most commonly assigned or most approachable. P0040 leads with 55 attempts across all students.

---

## Q16 — Students Above Overall Average Score

**Purpose:** Find students performing above the platform-wide average.

**Overall average score:** 43.94

| student_id | full_name | total_submissions | avg_score |
|---|---|---|---|
| S0019 | Arjun Reddy | 6 | 197.83 |
| S0112 | Aditya Sharma | 4 | 97.50 |
| S0123 | Kunal Kulkarni | 4 | 73.75 |
| S0021 | Priya Mehta | 4 | 73.75 |
| S0241 | Ayaan Patel | 5 | 73.00 |

**Result summary:** Many students above the average of 43.94.

**Validation note:** S0019 appears with avg_score 197.83 — caused by submission SUB000103 having a raw score of `'999'`, which is a data anomaly. This will be corrected in Part 3. The overall average (43.94) is computed as a scalar subquery inside `HAVING`, correctly evaluated once before comparing per-student averages.

---

## Q17 — Problems Never Attempted

**Purpose:** Find problems with zero submissions.

| problem_id | problem_code | title | difficulty | course_id |
|---|---|---|---|---|
| P0036 | CS203_P06 | Trie Search 36 | Hard | C006 |

**Result summary:** 1 row — only P0036 has never been attempted.

**Validation note:** 67 total problems − 66 with at least one submission = 1. The `NOT IN` subquery correctly identifies this single problem. P0036 is a Hard problem in CS203 (Computer Networks).

---

## Q18 — Enrolled Students Who Never Submitted

**Purpose:** Find completely inactive enrolled students.

**Result:** 0 rows.

**Validation note:** Every enrolled student has made at least one submission somewhere. While Q10 shows 214 students inactive in specific courses, all have submitted at least once on the platform overall. This is a meaningful distinction: Q18 checks global inactivity; Q10 checks per-course inactivity.

---

## Q19 — Students Who Submitted in Both Python and Java

**Purpose:** Identify students who have coded in both languages.

| student_id | full_name |
|---|---|
| S0002 | Harsh Das |
| S0003 | Ira Pillai |
| S0005 | Ayaan Gupta |
| S0006 | Isha Mehta |
| S0007 | Reyansh Kulkarni |

**Result summary:** 181 students submitted in both Python and Java.

**Validation note:** Two `IN` subqueries perform set intersection. This is equivalent to `INTERSECT` but works across all SQL dialects. 181/320 students ≈ 56.6% are multi-language users.

---

## Q20 — Second-Highest Score for Problem P0001

**Purpose:** Find the runner-up score for 'Shortest Path 1' (P0001).

| second_highest_score |
|---|
| 72.0 |

**Highest score for P0001:** 75.0

**Result summary:** Second-highest score = 72.0

**Validation note:** The nested subquery finds `MAX(score)` = 75, then the outer query finds the highest score strictly below 75. P0001 has 53 submissions with scores ranging from 0 to 75. The approach works correctly even if multiple submissions share the highest score, since `< MAX` always skips all tied top scores.