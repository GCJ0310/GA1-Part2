# SQL Reasoning & Explanations

---

## 1. When is LEFT JOIN more appropriate than INNER JOIN?

**Reference query:** Q7 — "Display all students and their enrolments"

```sql
SELECT st.student_id, st.full_name, e.enrollment_id, e.course_id
FROM students st
LEFT JOIN enrollments e ON st.student_id = e.student_id;
```

An `INNER JOIN` between `students` and `enrollments` would only return students who have **at least one enrollment**. Any student with zero enrollment records would be silently dropped from the result.

A `LEFT JOIN` keeps **all rows from the left table** (`students`) regardless of whether a matching row exists in `enrollments`. When there is no match, the right-side columns appear as `NULL`.

In Q7, the task is explicitly to "include students who are not enrolled in any course." Using `INNER JOIN` here would be semantically wrong — it would hide those students and give a false impression that every student is enrolled. Even though Q7_count showed 0 students have zero enrollments in this dataset, the `LEFT JOIN` is still the correct choice because:

- The schema does not enforce a constraint that every student must have at least one enrollment.
- Future data could include newly registered students who have not yet enrolled.
- The query's intent is to show the full student list with optional enrollment details.

Similarly, Q8 uses `LEFT JOIN` between `courses` and `enrollments` so that courses with zero enrollments still appear in the output with a count of 0.

---

## 2. When is HAVING required instead of WHERE?

**Reference query:** Q13 — "Find students with more than 10 submissions"

```sql
SELECT st.student_id, st.full_name, COUNT(s.submission_id) AS submission_count
FROM students st
JOIN submissions s ON st.student_id = s.student_id
GROUP BY st.student_id
HAVING submission_count > 10;
```

`WHERE` filters **individual rows before grouping** — it runs before `GROUP BY` and before any aggregate functions are evaluated. At the `WHERE` stage, `submission_count` does not yet exist as a value; the database has not yet counted anything.

`HAVING` filters **groups after aggregation** — it runs after `GROUP BY` and can reference aggregate results like `COUNT()`, `AVG()`, `SUM()`.

Trying to write `WHERE submission_count > 10` would cause a syntax/logic error because `submission_count` is an alias for a `COUNT()` result, which only exists after the group is formed.

The same logic applies to Q14 (`HAVING success_rate_pct < 40`) and Q16 (`HAVING avg_score > (...)`). In all these cases, the filter condition depends on the result of an aggregate function computed across a group of rows, so `HAVING` is mandatory.

---

## 3. When does a subquery help solve the problem better than a JOIN?

**Reference query:** Q20 — "Find the second-highest score for problem P0001"

```sql
SELECT MAX(CAST(score AS REAL)) AS second_highest_score
FROM submissions
WHERE problem_id = 'P0001'
  AND CAST(score AS REAL) < (
      SELECT MAX(CAST(score AS REAL))
      FROM submissions
      WHERE problem_id = 'P0001'
  );
```

This problem requires knowing the maximum score *before* filtering rows — a requirement that cannot be expressed in a single `WHERE` clause without a subquery, because a `WHERE` clause cannot reference aggregates from the same query level.

The subquery `(SELECT MAX(...) FROM submissions WHERE problem_id = 'P0001')` acts as a **scalar subquery** — it evaluates to a single value (75.0) that is then used as the comparison threshold in the outer query's `WHERE` clause.

Trying to solve this with a self-JOIN would produce a more complex, less readable result:
```sql
-- Equivalent with JOIN — harder to follow:
SELECT MAX(CAST(a.score AS REAL))
FROM submissions a
JOIN submissions b ON a.problem_id = b.problem_id
  AND CAST(a.score AS REAL) < CAST(b.score AS REAL)
WHERE a.problem_id = 'P0001';
```

The subquery approach is cleaner and directly expresses the intent: "find the highest score that is less than the overall maximum."

A second example is Q10 (`NOT EXISTS` correlated subquery), where checking per-student, per-course submission activity cannot be expressed as a simple JOIN without complex grouping.

---

## 4. When could a query output be misleading if duplicate records exist?

**Reference query:** Q7 — Student and enrolment display; Q8 — Enrolment counts

In Q7, student `S0001` appears three times in the result:

```
S0001 | Vivaan Gupta | E00001 | C006 | active
S0001 | Vivaan Gupta | E00001 | C006 | active   ← duplicate row
S0001 | Vivaan Gupta | E00002 | C001 | active
```

The raw `enrollments` table contains a duplicate row for (S0001, C006) — `enrollment_id` E00001 appears twice. Without knowing this, a reader could assume S0001 is genuinely enrolled in C006 twice, or count them as three enrolments instead of two.

In Q8, `COUNT(e.enrollment_id)` would count this duplicate and inflate C006's enrolment count by 1. This makes the output misleading — the count represents raw rows, not unique (student, course) pairs.

A safer version of Q8 that handles duplicates:

```sql
-- Counts unique students per course (not raw rows):
SELECT c.course_id, c.course_title,
       COUNT(DISTINCT e.student_id) AS enrolled_count
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_id;
```

This issue — duplicate enrolment records — is a data integrity violation that will be investigated and repaired in Part 3.

---

## 5. An edge case considered while writing a query

**Reference query:** Q16 — "Find students whose average score is greater than the overall average"

**Edge case: anomalous score values in TEXT columns**

Since the raw database stores all values as `TEXT`, the `score` column contains string values like `'46'`, `'0'`, `'75'`, and — critically — `'999'`.

Without `CAST(score AS REAL)`, SQLite performs lexicographic (alphabetical) string comparison for `AVG()` and `MAX()`. In string ordering, `'9'` > `'75'` > `'50'`, which produces completely wrong averages.

Applying `CAST(score AS REAL)` correctly converts strings to numbers. However, this revealed a second edge case: student `S0019` has a submission with `score = '999'` (submission SUB000103), which is almost certainly a data entry error — no problem in the dataset has a `max_score` above 100. This outlier inflates S0019's average to 197.83, making them appear as the top performer.

**How this was handled:** The query correctly computes the average using `CAST`, and the anomaly is documented in `query_outputs.md` and flagged for repair in Part 3. A production query might add a filter like `AND CAST(score AS REAL) <= 100` to defensively exclude out-of-range values, but for this assignment the raw data is queried as-is and the anomaly is reported rather than silently filtered.

This illustrates an important principle: always validate query outputs against domain knowledge (a score above the maximum possible is impossible), not just against SQL correctness.