-- 1. Базовая выборка опубликованных курсов с сортировкой по цене (ORDER BY + LIMIT)
SELECT course_id, title, difficulty_level, price, duration_hours
FROM courses
WHERE status = 'Published'
ORDER BY price DESC
LIMIT 10;

-- 2. Уникальные города активных студентов (DISTINCT)
SELECT DISTINCT city
FROM students
WHERE is_active = TRUE AND city IS NOT NULL
ORDER BY city;