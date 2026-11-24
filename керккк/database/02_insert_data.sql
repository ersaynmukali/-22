INSERT INTO course_categories (category_name, description, is_active) VALUES
('Python & Data Science', 'Программирование на Python, анализ данных и ML', TRUE),
('Web Development', 'Frontend, Backend и создание веб-приложений', TRUE),
('Databases & SQL', 'Проектирование реляционных БД, SQL и аналитика', TRUE),
('DevOps & Cloud', 'Docker, Linux, CI/CD и облачные сервисы', TRUE),
('Cybersecurity', 'Информационная безопасность и защита данных', TRUE),
('UI/UX Design', 'Проектирование интерфейсов и пользовательский опыт', TRUE),
('Mobile Development', 'Разработка мобильных приложений', TRUE),
('Product Management', 'Управление цифровыми продуктами и метриками', TRUE),
('QA & Test Automation', 'Ручное и автоматизированное тестирование ПО', TRUE),
('Artificial Intelligence', 'Нейросети, LLM и прикладной ИИ', TRUE),
('Computer Networks', 'Сетевые протоколы, маршрутизация и администрирование', TRUE),
('Soft Skills & Career', 'Техническое резюме, собеседования и коммуникации', TRUE);

-- 2. Преподаватели (15 записей)
INSERT INTO instructors (full_name, email, specialization, experience_years, revenue_share_pct, rating, hired_at)
SELECT
    'Instructor ' || g,
    'instructor' || g || '@edtech.kz',
    CASE (g % 5)
        WHEN 0 THEN 'SQL & Data Analytics'
        WHEN 1 THEN 'Python & Backend'
        WHEN 2 THEN 'Web & Fullstack'
        WHEN 3 THEN 'Cloud & DevOps'
        ELSE 'AI & Machine Learning'
    END,
    2 + (g % 10),
    45.00 + (g % 4) * 5.00,
    ROUND((3.8 + (g % 12) * 0.1)::numeric, 2),
    CURRENT_DATE - ((g * 35) % 700)
FROM generate_series(1, 15) AS g;

-- 3. Студенты (120 записей — укладывается в требование 100-300)
INSERT INTO students (full_name, email, phone, city, country, registered_at, is_active)
SELECT
    'Student ' || g,
    'student' || g || '@mail.kz',
    '+7701' || LPAD((1000000 + g * 7919)::text, 7, '0'),
    CASE (g % 6)
        WHEN 0 THEN 'Almaty'
        WHEN 1 THEN 'Astana'
        WHEN 2 THEN 'Shymkent'
        WHEN 3 THEN 'Karaganda'
        WHEN 4 THEN 'Aktobe'
        ELSE 'Oskemen'
    END,
    'Kazakhstan',
    CURRENT_TIMESTAMP - ((g * 3) || ' days')::interval,
    CASE WHEN g % 11 = 0 THEN FALSE ELSE TRUE END
FROM generate_series(1, 120) AS g;

-- 4. Курсы (24 записи)
INSERT INTO courses (instructor_id, category_id, title, difficulty_level, price, duration_hours, status, created_at)
SELECT
    1 + ((g - 1) % 15),
    1 + ((g - 1) % 12),
    'Course #' || g || ' - Practical Track',
    CASE (g % 3)
        WHEN 0 THEN 'Advanced'
        WHEN 1 THEN 'Beginner'
        ELSE 'Intermediate'
    END,
    (15000 + (g % 8) * 5000)::numeric(10,2),
    (10 + (g % 16) * 2.5)::numeric(6,2),
    CASE WHEN g = 24 THEN 'Draft' ELSE 'Published' END,
    CURRENT_TIMESTAMP - ((g * 12) || ' days')::interval
FROM generate_series(1, 24) AS g;

-- 5. Модули курсов (48 записей — по 2 модуля на курс)
INSERT INTO course_modules (course_id, title, module_order, description)
SELECT
    c.course_id,
    'Module ' || m || ' of Course ' || c.course_id,
    m,
    'Учебный блок #' || m || ' по курсу ' || c.title
FROM courses c
CROSS JOIN generate_series(1, 2) AS m;

-- 6. Уроки (144 записи — по 3 урока на модуль)
INSERT INTO lessons (module_id, title, lesson_type, duration_minutes, lesson_order, is_free_preview)
SELECT
    cm.module_id,
    'Lesson ' || l || ' (' || cm.title || ')',
    CASE (l % 3)
        WHEN 1 THEN 'Video'
        WHEN 2 THEN 'Practice'
        ELSE 'Article'
    END,
    12 + (l * 7) + (cm.module_id % 10),
    l,
    CASE WHEN cm.module_order = 1 AND l = 1 THEN TRUE ELSE FALSE END
FROM course_modules cm
CROSS JOIN generate_series(1, 3) AS l;

-- 7. Скидки / промокоды (15 записей)
INSERT INTO course_discounts (course_id, promo_code, discount_pct, valid_from, valid_to, is_active)
SELECT
    1 + ((g - 1) % 23),
    'PROMO' || g || 'EDU',
    (10 + (g % 5) * 5)::numeric(5,2),
    CURRENT_DATE - 60,
    CURRENT_DATE + 60,
    TRUE
FROM generate_series(1, 15) AS g;

-- 8. Записи студентов на курсы (320 записей — в диапазоне 300-1000)
INSERT INTO enrollments (student_id, course_id, enrolled_at, completed_at, status, progress_pct)
SELECT
    s_id,
    c_id,
    enr_ts,
    CASE
        WHEN ((s_id + c_id) % 4 = 0) THEN enr_ts + INTERVAL '14 days'
        ELSE NULL
    END,
    CASE
        WHEN ((s_id + c_id) % 4 = 0) THEN 'Completed'
        WHEN ((s_id + c_id) % 9 = 0) THEN 'Dropped'
        WHEN ((s_id + c_id) % 7 = 0) THEN 'Paused'
        ELSE 'Active'
    END,
    CASE
        WHEN ((s_id + c_id) % 4 = 0) THEN 100.00
        ELSE ROUND((((s_id * 13 + c_id * 7) % 85) + 10)::numeric, 2)
    END
FROM (
    SELECT
        1 + ((g - 1) % 120) AS s_id,
        1 + (((g - 1) * 7 + (g - 1) / 120) % 23) AS c_id,
        CURRENT_TIMESTAMP - ((g % 150) || ' days')::interval AS enr_ts
    FROM generate_series(1, 320) AS g
) sub;

-- 9. Прогресс по урокам (640 записей — по 2 урока на каждую из 320 записей)
INSERT INTO lesson_progress (enrollment_id, lesson_id, is_completed, watched_minutes, last_accessed_at, completed_at)
SELECT
    e.enrollment_id,
    l.lesson_id,
    CASE WHEN e.status = 'Completed' OR (e.enrollment_id + l.lesson_id) % 2 = 0 THEN TRUE ELSE FALSE END,
    CASE WHEN e.status = 'Completed' OR (e.enrollment_id + l.lesson_id) % 2 = 0 THEN l.duration_minutes ELSE l.duration_minutes / 2 END,
    e.enrolled_at + INTERVAL '2 days',
    CASE WHEN e.status = 'Completed' OR (e.enrollment_id + l.lesson_id) % 2 = 0 THEN e.enrolled_at + INTERVAL '2 days' ELSE NULL END
FROM enrollments e
JOIN course_modules cm ON cm.course_id = e.course_id
JOIN LATERAL (
    SELECT lesson_id, duration_minutes
    FROM lessons l2
    WHERE l2.module_id = cm.module_id
    ORDER BY l2.lesson_order
    LIMIT 1
) l ON TRUE;

-- 10. Тесты (24 теста — по 1 на курс)
INSERT INTO quizzes (course_id, module_id, title, passing_score, time_limit_minutes, max_attempts)
SELECT
    c.course_id,
    (SELECT cm.module_id FROM course_modules cm WHERE cm.course_id = c.course_id ORDER BY cm.module_order DESC LIMIT 1),
    'Final Quiz - ' || c.title,
    70.00,
    30,
    3
FROM courses c;

-- 11. Вопросы тестов (72 вопроса — по 3 на тест)
INSERT INTO quiz_questions (quiz_id, question_text, question_type, points, question_order)
SELECT
    q.quiz_id,
    'Question ' || qq || ' for ' || q.title,
    CASE qq
        WHEN 1 THEN 'SingleChoice'
        WHEN 2 THEN 'MultipleChoice'
        ELSE 'TrueFalse'
    END,
    10.00,
    qq
FROM quizzes q
CROSS JOIN generate_series(1, 3) AS qq;

-- 12. Попытки тестов (240 записей)
INSERT INTO quiz_attempts (enrollment_id, quiz_id, attempt_number, score_pct, passed, started_at, submitted_at)
SELECT
    e.enrollment_id,
    q.quiz_id,
    1,
    score_val,
    score_val >= q.passing_score,
    e.enrolled_at + INTERVAL '5 days',
    e.enrolled_at + INTERVAL '5 days 20 minutes'
FROM (
    SELECT
        e2.enrollment_id,
        e2.course_id,
        e2.enrolled_at,
        (45 + ((e2.enrollment_id * 17) % 56))::numeric(5,2) AS score_val
    FROM enrollments e2
    ORDER BY e2.enrollment_id
    LIMIT 240
) e
JOIN quizzes q ON q.course_id = e.course_id;

-- 13. Сертификаты (80 записей — для завершённых курсов)
INSERT INTO certificates (enrollment_id, certificate_code, final_score, issued_at, is_valid)
SELECT
    e.enrollment_id,
    'CERT-2026-' || LPAD(e.enrollment_id::text, 5, '0'),
    (72 + (e.enrollment_id % 28))::numeric(5,2),
    COALESCE(e.completed_at, e.enrolled_at + INTERVAL '15 days'),
    TRUE
FROM enrollments e
WHERE e.status = 'Completed'
LIMIT 80;

-- 14. Платежи (280 записей — в диапазоне 200-700)
INSERT INTO payments (enrollment_id, discount_id, amount, payment_method, payment_status, paid_at)
SELECT
    e.enrollment_id,
    CASE WHEN e.enrollment_id % 3 = 0 THEN ((e.enrollment_id % 15) + 1) ELSE NULL END,
    CASE
        WHEN e.enrollment_id % 3 = 0 THEN ROUND((c.price * 0.85)::numeric, 2)
        ELSE c.price
    END,
    CASE (e.enrollment_id % 4)
        WHEN 0 THEN 'Kaspi'
        WHEN 1 THEN 'Card'
        WHEN 2 THEN 'BankTransfer'
        ELSE 'PayPal'
    END,
    CASE
        WHEN e.enrollment_id % 12 = 0 THEN 'Refunded'
        WHEN e.enrollment_id % 17 = 0 THEN 'Pending'
        ELSE 'Paid'
    END,
    e.enrolled_at + INTERVAL '10 minutes'
FROM enrollments e
JOIN courses c ON c.course_id = e.course_id
ORDER BY e.enrollment_id
LIMIT 280;

-- 15. Отзывы (110 записей — в диапазоне 30-200)
INSERT INTO reviews (enrollment_id, rating, comment, created_at, is_published)
SELECT
    e.enrollment_id,
    1 + ((e.enrollment_id * 3) % 5),
    CASE ((e.enrollment_id * 3) % 5)
        WHEN 4 THEN 'Отличный курс, много практики и понятный разбор.'
        WHEN 3 THEN 'Хорошая структура модулей, полезный материал.'
        WHEN 2 THEN 'Нормально, но хотелось бы больше задач.'
        WHEN 1 THEN 'Средне, часть тем показалась быстрой.'
        ELSE 'Мало практики, ожидал большего.'
    END,
    e.enrolled_at + INTERVAL '7 days',
    TRUE
FROM enrollments e
ORDER BY e.enrollment_id
LIMIT 110;

COMMIT;


-- проверка --
SELECT 'students' AS tbl, COUNT(*) FROM students
UNION ALL SELECT 'instructors', COUNT(*) FROM instructors
UNION ALL SELECT 'course_categories', COUNT(*) FROM course_categories
UNION ALL SELECT 'courses', COUNT(*) FROM courses
UNION ALL SELECT 'enrollments', COUNT(*) FROM enrollments
UNION ALL SELECT 'payments', COUNT(*) FROM payments
UNION ALL SELECT 'quiz_attempts', COUNT(*) FROM quiz_attempts
UNION ALL SELECT 'certificates', COUNT(*) FROM certificates
UNION ALL SELECT 'reviews', COUNT(*) FROM reviews;