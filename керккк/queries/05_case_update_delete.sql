-- 1. CASE: сегментация студентов по среднему прогрессу
SELECT
    e.student_id,
    s.full_name,
    ROUND(AVG(e.progress_pct), 2) AS avg_progress,
    CASE
        WHEN AVG(e.progress_pct) >= 80 THEN 'High Performer'
        WHEN AVG(e.progress_pct) >= 40 THEN 'Steady Learner'
        ELSE 'At Risk / Needs Nudge'
    END AS learner_segment
FROM enrollments e
JOIN students s ON s.student_id = e.student_id
GROUP BY e.student_id, s.full_name;

-- 2. CASE: категоризация курсов по цене
SELECT
    course_id,
    title,
    price,
    CASE
        WHEN price < 25000 THEN 'Budget'
        WHEN price <= 40000 THEN 'Standard'
        ELSE 'Premium'
    END AS price_tier
FROM courses;

-- 3. CASE: статус сдачи теста в читаемом виде
SELECT
    attempt_id,
    enrollment_id,
    score_pct,
    CASE
        WHEN passed = TRUE AND score_pct >= 90 THEN 'Passed with Distinction'
        WHEN passed = TRUE THEN 'Passed'
        ELSE 'Failed - Retry Allowed'
    END AS result_label
FROM quiz_attempts
LIMIT 20;

-- 4. CASE: расчёт примерного бонуса преподавателю по рейтингу
SELECT
    instructor_id,
    full_name,
    rating,
    CASE
        WHEN rating >= 4.7 THEN 'Bonus +10%'
        WHEN rating >= 4.2 THEN 'Bonus +5%'
        ELSE 'Standard Share'
    END AS bonus_tier
FROM instructors;

-- DML: 2 UPDATE и 1 DELETE
UPDATE courses
SET price = ROUND((price * 1.05)::numeric, 2)
WHERE difficulty_level = 'Advanced' AND status = 'Published';

UPDATE enrollments
SET status = 'Completed', completed_at = CURRENT_TIMESTAMP
WHERE progress_pct = 100.00 AND status <> 'Completed';

DELETE FROM reviews
WHERE rating = 1 AND is_published = FALSE;

-- DDL: 2 ALTER TABLE и 1 DROP TABLE (на отдельной тестовой таблице)
ALTER TABLE courses
    ADD COLUMN IF NOT EXISTS language VARCHAR(30) NOT NULL DEFAULT 'Russian/Kazakh';

ALTER TABLE course_discounts
    ALTER COLUMN promo_code TYPE VARCHAR(60);

CREATE TABLE IF NOT EXISTS temp_test_logs (
    log_id SERIAL PRIMARY KEY,
    note TEXT
);
DROP TABLE IF EXISTS temp_test_logs;