# Part 2 — SQL Query Implementation & Verification

**CodeJudge Platform Database Assignment**

## Overview

This repository contains the Part 2 submission for the DBMS assignment based on the CodeJudge platform dataset. The goal is to write 20 SQL queries covering basic retrieval, joins, aggregation, and subqueries — and to verify each query's output against the real dataset.

## Repository Files

| File | Contents |
|---|---|
| `README.md` | This file — overview, setup instructions, query index |
| `queries.sql` | All 20 SQL queries with inline comments, purpose, sample output, and validation notes |
| `query_outputs.md` | Detailed output tables and validation notes for every query |
| `sql_reasoning.md` | Answers to 5 explanation questions on LEFT JOIN, HAVING, subqueries, duplicates, and edge cases |

---

## Database

All queries run against `codejudge_raw.db` — a SQLite database loaded from the CodeJudge platform CSV exports.

Key statistics:
- **2,501** submissions across **320** students and **67** problems
- **9,673** test-case results
- **719** enrolments across **10** courses
- All columns stored as `TEXT` in the raw DB (type casting applied where needed)

---

## How to Run the Queries

### Option 1 — Python (no extensions needed)

```bash
python run_queries.py
```

This executes all 20 queries and prints the results to the terminal.

### Option 2 — VS Code with SQLite Extension

1. Install the **SQLite** extension: `Ctrl+Shift+X` → search `alexcvzz.vscode-sqlite` → Install
2. Open `queries.sql`
3. Right-click → **Run Query** → select `codejudge_raw.db`

### Option 3 — DB Browser for SQLite

1. Open DB Browser for SQLite → open `codejudge_raw.db`
2. Go to **Execute SQL** tab
3. Paste any query from `queries.sql` and click **Run**

---

## Query Index

### Basic Retrieval and Filtering

| # | Query | Key Clause |
|---|---|---|
| Q1 | List all active students | `WHERE enrollment_status = 'active'` |
| Q2 | Students with missing or invalid email | `email NOT LIKE '%@%.%'` |
| Q3 | Problems with difficulty Easy or Medium | `WHERE difficulty IN ('Easy', 'Medium')` |
| Q4 | Latest 20 submissions by timestamp | `ORDER BY submitted_at DESC LIMIT 20` |
| Q5 | Submissions where status is not successful | `WHERE status NOT IN ('Accepted', 'OK')` |

### Joins

| # | Query | Key Clause |
|---|---|---|
| Q6 | Submissions with student name and problem title | `JOIN students JOIN problems` |
| Q7 | All students and enrolments (including unenrolled) | `LEFT JOIN enrollments` |
| Q8 | Courses with enrolment counts | `LEFT JOIN enrollments GROUP BY course_id` |
| Q9 | Test-case results with student and problem details | 4-table `JOIN` |
| Q10 | Enrolled students with no submissions in that course | `NOT EXISTS` correlated subquery |

### Aggregation and HAVING

| # | Query | Key Clause |
|---|---|---|
| Q11 | Submission count by status | `GROUP BY status` |
| Q12 | Average score per problem | `AVG(CAST(score AS REAL))` |
| Q13 | Students with more than 10 submissions | `HAVING COUNT > 10` |
| Q14 | Problems with success rate below 40% | `HAVING success_rate < 40` |
| Q15 | Top 10 most attempted problems | `ORDER BY COUNT DESC LIMIT 10` |

### Subqueries / Set Logic

| # | Query | Key Clause |
|---|---|---|
| Q16 | Students above overall average score | `HAVING avg > (SELECT AVG(...))` |
| Q17 | Problems never attempted | `WHERE problem_id NOT IN (SELECT ...)` |
| Q18 | Enrolled students who never submitted | `WHERE student_id NOT IN (SELECT ...)` |
| Q19 | Students who submitted in both Python and Java | Two `IN` subqueries (set intersection) |
| Q20 | Second-highest score for problem P0001 | Nested `MAX` subquery |

---

## Notable Findings

- **Q2:** 2 students have invalid emails (empty string and missing `@`)
- **Q7:** Student S0001 has a duplicate enrolment for course C006 — a data integrity issue
- **Q11:** 1 submission has status `'OK'` instead of `'Accepted'` — non-standard value
- **Q16:** Student S0019 has an anomalous score of `999` (submission SUB000103), inflating their average to 197.83
- **Q17:** Only 1 problem (P0036 — Trie Search 36) has never been attempted
- **Q18:** Every enrolled student has submitted at least once (0 completely inactive students)
- **Q19:** 181 out of 320 students (~56.6%) have submitted in both Python and Java

All anomalies noted above are documented and will be formally addressed in Part 3 (Data Integrity Audit).

---

## Design Notes

- `CAST(score AS REAL)` is applied wherever numeric operations are performed, since the raw database stores all columns as `TEXT`
- `'OK'` is treated as equivalent to `'Accepted'` in success-rate calculations (Q5, Q14) — this is a known raw data inconsistency
- `NOT EXISTS` is used in Q10 (instead of LEFT JOIN / IS NULL) to correctly handle students enrolled in multiple courses
- The second-highest score query (Q20) uses a nested scalar subquery to avoid window functions, ensuring compatibility with SQLite
