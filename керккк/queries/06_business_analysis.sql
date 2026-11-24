-- 1. Completion Rate (процент полного прохождения) по каждому курсу
SELECT
    c.course_id,
    c.title,
    COUNT(e.enrollment_id) AS total_enrollments,
    COUNT(*) FILTER (WHERE e.status = 'Completed') AS completed_enrollments,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE e.status = 'Completed') / NULLIF(COUNT(e.enrollment_id), 0),
        2
    ) AS completion_rate_pct
FROM courses c
LEFT JOIN enrollments e ON e.course_id = c.course_id
GROUP BY c.course_id, c.title
ORDER BY completion_rate_pct DESC NULLS LAST;

-- 2. Средний балл за тесты и процент успешных попыток по курсам
SELECT
    c.course_id,
    c.title,
    COUNT(qa.attempt_id) AS total_attempts,
    ROUND(AVG(qa.score_pct), 2) AS avg_score_pct,
    ROUND(100.0 * AVG(CASE WHEN qa.passed THEN 1 ELSE 0 END), 2) AS pass_rate_pct
FROM courses c
JOIN quizzes q ON q.course_id = c.course_id
LEFT JOIN quiz_attempts qa ON qa.quiz_id = q.quiz_id
GROUP BY c.course_id, c.title
ORDER BY avg_score_pct DESC NULLS LAST;

-- 3. Самые прибыльные авторы-преподаватели (по оплаченным платежам и их доле)
SELECT
    i.instructor_id,
    i.full_name,
    i.specialization,
    COALESCE(SUM(p.amount) FILTER (WHERE p.payment_status = 'Paid'), 0) AS gross_revenue,
    ROUND(
        COALESCE(SUM(p.amount) FILTER (WHERE p.payment_status = 'Paid'), 0) * (i.revenue_share_pct / 100.0),
        2
    ) AS instructor_earnings
FROM instructors i
LEFT JOIN courses c ON c.instructor_id = i.instructor_id
LEFT JOIN enrollments e ON e.course_id = c.course_id
LEFT JOIN payments p ON p.enrollment_id = e.enrollment_id
GROUP BY i.instructor_id, i.full_name, i.specialization, i.revenue_share_pct
ORDER BY gross_revenue DESC;

-- 4. Динамика выручки и числа оплат по месяцам
SELECT
    DATE_TRUNC('month', paid_at)::date AS month_start,
    COUNT(*) AS paid_orders,
    SUM(amount) AS monthly_revenue
FROM payments
WHERE payment_status = 'Paid'
GROUP BY DATE_TRUNC('month', paid_at)
ORDER BY month_start;

-- 5. Эффективность промокодов / скидок
SELECT
    cd.promo_code,
    cd.discount_pct,
    COUNT(p.payment_id) AS payments_with_promo,
    COALESCE(SUM(p.amount) FILTER (WHERE p.payment_status = 'Paid'), 0) AS discounted_revenue
FROM course_discounts cd
LEFT JOIN payments p ON p.discount_id = cd.discount_id
GROUP BY cd.discount_id, cd.promo_code, cd.discount_pct
ORDER BY payments_with_promo DESC;