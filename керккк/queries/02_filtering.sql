-- 3. Многоусловие с AND и OR: курсы средней/высокой сложности или дороже 35000
SELECT course_id, title, difficulty_level, price
FROM courses
WHERE (difficulty_level IN ('Intermediate', 'Advanced') OR price > 35000)
  AND status = 'Published';

-- 4. Диапазон цен через BETWEEN и исключение через NOT
SELECT course_id, title, price
FROM courses
WHERE price BETWEEN 20000 AND 40000
  AND NOT (difficulty_level = 'Beginner');

-- 5. Поиск по шаблону LIKE: промокоды с 'PROMO1'
SELECT discount_id, course_id, promo_code, discount_pct
FROM course_discounts
WHERE promo_code LIKE 'PROMO1%';

-- 6. Фильтрация оплат по списку статусов (IN) и дате
SELECT payment_id, enrollment_id, amount, payment_method, payment_status
FROM payments
WHERE payment_status IN ('Paid', 'Refunded')
  AND amount >= 15000
ORDER BY paid_at DESC;

-- 7. Неактивные студенты из конкретных городов с проверкой NULL
SELECT student_id, full_name, email, city
FROM students
WHERE is_active = FALSE
  AND city IN ('Almaty', 'Astana')
  AND phone IS NOT NULL;

-- 8. Уроки длительностью более 25 минут, не являющиеся бесплатным превью
SELECT lesson_id, module_id, title, lesson_type, duration_minutes
FROM lessons
WHERE duration_minutes > 25
  AND is_free_preview = FALSE
ORDER BY duration_minutes DESC;