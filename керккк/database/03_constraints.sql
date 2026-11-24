
-- =========================================================
-- Файл: database/03_constraints.sql
-- Дополнительные проверки и индексы для ускорения аналитики
-- =========================================================

-- Проверка: при прохождении теста на >= 70 баллов passed обычно TRUE (мягкая проверка через доп. столбец или индекс)
CREATE INDEX idx_courses_instructor ON courses(instructor_id);
CREATE INDEX idx_courses_category ON courses(category_id);
CREATE INDEX idx_enrollments_student ON enrollments(student_id);
CREATE INDEX idx_enrollments_course ON enrollments(course_id);
CREATE INDEX idx_enrollments_status ON enrollments(status);
CREATE INDEX idx_payments_enrollment ON payments(enrollment_id);
CREATE INDEX idx_payments_status_date ON payments(payment_status, paid_at);
CREATE INDEX idx_quiz_attempts_enrollment ON quiz_attempts(enrollment_id);
CREATE INDEX idx_lesson_progress_enrollment ON lesson_progress(enrollment_id);

-- Пример добавления логического ограничения через ALTER TABLE
ALTER TABLE students
    ADD CONSTRAINT chk_student_email_format CHECK (position('@' IN email) > 1);


	