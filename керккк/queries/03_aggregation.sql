-- 1. Общие агрегаты по оплатам (COUNT, SUM, AVG, MIN, MAX)
SELECT
    COUNT(*) AS total_paid_payments,
    SUM(amount) AS total_revenue,
    ROUND(AVG(amount), 2) AS avg_payment,
    MIN(amount) AS min_payment,
    MAX(amount) AS max_payment
FROM payments
WHERE payment_status = 'Paid';

-- 2. GROUP BY по статусу записей на курсы
SELECT status, COUNT(*) AS enrollments_count, ROUND(AVG(progress_pct), 2) AS avg_progress
FROM enrollments
GROUP BY status
ORDER BY enrollments_count DESC;

-- 3. GROUP BY по способам оплаты с суммой и средним чеком
SELECT payment_method, COUNT(*) AS tx_count, SUM(amount) AS revenue, ROUND(AVG(amount), 2) AS avg_amount
FROM payments
WHERE payment_status = 'Paid'
GROUP BY payment_method
ORDER BY revenue DESC;

-- 4. WHERE + HAVING: категории курсов с >= 2 опубликованными курсами и средней ценой > 25000
SELECT category_id, COUNT(*) AS published_courses, ROUND(AVG(price), 2) AS avg_price
FROM courses
WHERE status = 'Published'
GROUP BY category_id
HAVING COUNT(*) >= 2 AND AVG(price) > 25000
ORDER BY avg_price DESC;

-- 5. WHERE + HAVING: студенты с >= 3 записями на курсы и средним прогрессом >= 45%
SELECT student_id, COUNT(*) AS courses_count, ROUND(AVG(progress_pct), 2) AS avg_progress
FROM enrollments
WHERE status <> 'Dropped'
GROUP BY student_id
HAVING COUNT(*) >= 3 AND AVG(progress_pct) >= 45
ORDER BY avg_progress DESC;

-- 6. HAVING по тестам: квизы с >= 8 попытками и средним баллом >= 70
SELECT quiz_id, COUNT(*) AS attempts_count, ROUND(AVG(score_pct), 2) AS avg_score
FROM quiz_attempts
GROUP BY quiz_id
HAVING COUNT(*) >= 8 AND AVG(score_pct) >= 70
ORDER BY avg_score DESC;