-- 1. INNER JOIN (3 таблицы): курсы, имя преподавателя и категория
SELECT c.course_id, c.title AS course_title, i.full_name AS instructor_name, cc.category_name, c.price
FROM courses c
INNER JOIN instructors i ON i.instructor_id = c.instructor_id
INNER JOIN course_categories cc ON cc.category_id = c.category_id;

-- 2. INNER JOIN (4 таблицы): студенты, курсы, статусы и суммы оплат
SELECT s.full_name AS student_name, c.title AS course_title, e.status AS enrollment_status, p.amount, p.payment_status
FROM enrollments e
INNER JOIN students s ON s.student_id = e.student_id
INNER JOIN courses c ON c.course_id = e.course_id
INNER JOIN payments p ON p.enrollment_id = e.enrollment_id;

-- 3. LEFT JOIN: все курсы и количество записей (включая курсы без записей)
SELECT c.course_id, c.title, COUNT(e.enrollment_id) AS enrollments_count
FROM courses c
LEFT JOIN enrollments e ON e.course_id = c.course_id
GROUP BY c.course_id, c.title
ORDER BY enrollments_count DESC;

-- 4. LEFT JOIN: студенты и их выданные сертификаты (показать даже тех, у кого сертификата нет)
SELECT s.student_id, s.full_name, cert.certificate_code, cert.issued_at
FROM students s
LEFT JOIN enrollments e ON e.student_id = s.student_id
LEFT JOIN certificates cert ON cert.enrollment_id = e.enrollment_id
ORDER BY s.student_id;

-- 5. RIGHT JOIN: все попытки тестов и названия курсов
SELECT qa.attempt_id, qa.score_pct, qa.passed, q.title AS quiz_title, c.title AS course_title
FROM courses c
RIGHT JOIN quizzes q ON q.course_id = c.course_id
RIGHT JOIN quiz_attempts qa ON qa.quiz_id = q.quiz_id
ORDER BY qa.attempt_id
LIMIT 20;

-- 6. FULL OUTER JOIN (через UNION для надёжности/наглядности): категории и курсы
SELECT cc.category_name, c.title AS course_title
FROM course_categories cc
LEFT JOIN courses c ON c.category_id = cc.category_id
UNION
SELECT cc.category_name, c.title AS course_title
FROM course_categories cc
RIGHT JOIN courses c ON c.category_id = cc.category_id;

-- 7. JOIN с отзывами и оценками: средний рейтинг по преподавателям
SELECT i.instructor_id, i.full_name, ROUND(AVG(r.rating), 2) AS avg_review_rating, COUNT(r.review_id) AS reviews_count
FROM instructors i
LEFT JOIN courses c ON c.instructor_id = i.instructor_id
LEFT JOIN enrollments e ON e.course_id = c.course_id
LEFT JOIN reviews r ON r.enrollment_id = e.enrollment_id
GROUP BY i.instructor_id, i.full_name
ORDER BY avg_review_rating DESC NULLS LAST;

-- 8. JOIN по модулям и урокам: суммарная длительность уроков каждого курса
SELECT c.course_id, c.title, COALESCE(SUM(l.duration_minutes), 0) AS total_lesson_minutes
FROM courses c
LEFT JOIN course_modules cm ON cm.course_id = c.course_id
LEFT JOIN lessons l ON l.module_id = cm.module_id
GROUP BY c.course_id, c.title
ORDER BY total_lesson_minutes DESC;

-- 9. UNION по 3 таблицам: объединяем списки участников платформы (студенты и преподаватели) с привязкой к курсам/обучению
SELECT
    s.student_id AS person_id,
    s.full_name,
    'Student' AS role_type,
    c.title AS course_title
FROM students s
JOIN enrollments e ON e.student_id = s.student_id
JOIN courses c ON c.course_id = e.course_id

UNION

SELECT
    i.instructor_id AS person_id,
    i.full_name,
    'Instructor' AS role_type,
    c.title AS course_title
FROM instructors i
JOIN courses c ON c.instructor_id = i.instructor_id;