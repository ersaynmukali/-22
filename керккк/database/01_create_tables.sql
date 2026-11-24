-- 1. Категории курсов
CREATE TABLE course_categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 2. Преподаватели / авторы курсов
CREATE TABLE instructors (
    instructor_id SERIAL PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    specialization VARCHAR(120) NOT NULL,
    experience_years INT NOT NULL DEFAULT 1 CHECK (experience_years >= 0),
    revenue_share_pct NUMERIC(5,2) NOT NULL DEFAULT 50.00 CHECK (revenue_share_pct BETWEEN 0 AND 100),
    rating NUMERIC(3,2) DEFAULT 0.00 CHECK (rating BETWEEN 0 AND 5),
    hired_at DATE NOT NULL DEFAULT CURRENT_DATE
);

-- 3. Студенты
CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(30),
    city VARCHAR(80),
    country VARCHAR(80) NOT NULL DEFAULT 'Kazakhstan',
    registered_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

-- 4. Курсы
CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    instructor_id INT NOT NULL REFERENCES instructors(instructor_id) ON DELETE RESTRICT,
    category_id INT NOT NULL REFERENCES course_categories(category_id) ON DELETE RESTRICT,
    title VARCHAR(200) NOT NULL,
    difficulty_level VARCHAR(20) NOT NULL DEFAULT 'Beginner'
        CHECK (difficulty_level IN ('Beginner', 'Intermediate', 'Advanced')),
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    duration_hours NUMERIC(6,2) NOT NULL CHECK (duration_hours > 0),
    status VARCHAR(20) NOT NULL DEFAULT 'Published'
        CHECK (status IN ('Draft', 'Published', 'Archived')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_course_title_instructor UNIQUE (title, instructor_id)
);

-- 5. Модули курса
CREATE TABLE course_modules (
    module_id SERIAL PRIMARY KEY,
    course_id INT NOT NULL REFERENCES courses(course_id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    module_order INT NOT NULL CHECK (module_order > 0),
    description TEXT,
    CONSTRAINT uq_module_order_per_course UNIQUE (course_id, module_order)
);

-- 6. Уроки внутри модуля
CREATE TABLE lessons (
    lesson_id SERIAL PRIMARY KEY,
    module_id INT NOT NULL REFERENCES course_modules(module_id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    lesson_type VARCHAR(20) NOT NULL DEFAULT 'Video'
        CHECK (lesson_type IN ('Video', 'Article', 'Practice', 'Quiz')),
    duration_minutes INT NOT NULL CHECK (duration_minutes > 0),
    lesson_order INT NOT NULL CHECK (lesson_order > 0),
    is_free_preview BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT uq_lesson_order_per_module UNIQUE (module_id, lesson_order)
);

-- 7. Записи студентов на курсы
CREATE TABLE enrollments (
    enrollment_id SERIAL PRIMARY KEY,
    student_id INT NOT NULL REFERENCES students(student_id) ON DELETE CASCADE,
    course_id INT NOT NULL REFERENCES courses(course_id) ON DELETE RESTRICT,
    enrolled_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'Active'
        CHECK (status IN ('Active', 'Completed', 'Dropped', 'Paused')),
    progress_pct NUMERIC(5,2) NOT NULL DEFAULT 0.00 CHECK (progress_pct BETWEEN 0 AND 100),
    CONSTRAINT uq_student_course UNIQUE (student_id, course_id),
    CONSTRAINT chk_enrollment_dates CHECK (completed_at IS NULL OR completed_at >= enrolled_at)
);

-- 8. Прогресс по урокам
CREATE TABLE lesson_progress (
    progress_id SERIAL PRIMARY KEY,
    enrollment_id INT NOT NULL REFERENCES enrollments(enrollment_id) ON DELETE CASCADE,
    lesson_id INT NOT NULL REFERENCES lessons(lesson_id) ON DELETE CASCADE,
    is_completed BOOLEAN NOT NULL DEFAULT FALSE,
    watched_minutes INT NOT NULL DEFAULT 0 CHECK (watched_minutes >= 0),
    last_accessed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    CONSTRAINT uq_enrollment_lesson UNIQUE (enrollment_id, lesson_id)
);

-- 9. Тесты / квизы
CREATE TABLE quizzes (
    quiz_id SERIAL PRIMARY KEY,
    course_id INT NOT NULL REFERENCES courses(course_id) ON DELETE CASCADE,
    module_id INT REFERENCES course_modules(module_id) ON DELETE SET NULL,
    title VARCHAR(200) NOT NULL,
    passing_score NUMERIC(5,2) NOT NULL DEFAULT 70.00 CHECK (passing_score BETWEEN 0 AND 100),
    time_limit_minutes INT NOT NULL DEFAULT 30 CHECK (time_limit_minutes > 0),
    max_attempts INT NOT NULL DEFAULT 3 CHECK (max_attempts > 0)
);

-- 10. Вопросы тестов
CREATE TABLE quiz_questions (
    question_id SERIAL PRIMARY KEY,
    quiz_id INT NOT NULL REFERENCES quizzes(quiz_id) ON DELETE CASCADE,
    question_text TEXT NOT NULL,
    question_type VARCHAR(20) NOT NULL DEFAULT 'SingleChoice'
        CHECK (question_type IN ('SingleChoice', 'MultipleChoice', 'TrueFalse', 'Code')),
    points NUMERIC(5,2) NOT NULL DEFAULT 10.00 CHECK (points > 0),
    question_order INT NOT NULL CHECK (question_order > 0),
    CONSTRAINT uq_question_order_per_quiz UNIQUE (quiz_id, question_order)
);

-- 11. Попытки прохождения тестов
CREATE TABLE quiz_attempts (
    attempt_id SERIAL PRIMARY KEY,
    enrollment_id INT NOT NULL REFERENCES enrollments(enrollment_id) ON DELETE CASCADE,
    quiz_id INT NOT NULL REFERENCES quizzes(quiz_id) ON DELETE CASCADE,
    attempt_number INT NOT NULL DEFAULT 1 CHECK (attempt_number > 0),
    score_pct NUMERIC(5,2) NOT NULL CHECK (score_pct BETWEEN 0 AND 100),
    passed BOOLEAN NOT NULL DEFAULT FALSE,
    started_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    submitted_at TIMESTAMP,
    CONSTRAINT chk_attempt_dates CHECK (submitted_at IS NULL OR submitted_at >= started_at)
);

-- 12. Сертификаты
CREATE TABLE certificates (
    certificate_id SERIAL PRIMARY KEY,
    enrollment_id INT NOT NULL UNIQUE REFERENCES enrollments(enrollment_id) ON DELETE CASCADE,
    certificate_code VARCHAR(60) NOT NULL UNIQUE,
    final_score NUMERIC(5,2) CHECK (final_score BETWEEN 0 AND 100),
    issued_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_valid BOOLEAN NOT NULL DEFAULT TRUE
);

-- 13. Скидки на курсы
CREATE TABLE course_discounts (
    discount_id SERIAL PRIMARY KEY,
    course_id INT NOT NULL REFERENCES courses(course_id) ON DELETE CASCADE,
    promo_code VARCHAR(40) NOT NULL UNIQUE,
    discount_pct NUMERIC(5,2) NOT NULL CHECK (discount_pct > 0 AND discount_pct <= 90),
    valid_from DATE NOT NULL,
    valid_to DATE NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT chk_discount_dates CHECK (valid_to >= valid_from)
);

-- 14. Платежи
CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    enrollment_id INT NOT NULL REFERENCES enrollments(enrollment_id) ON DELETE RESTRICT,
    discount_id INT REFERENCES course_discounts(discount_id) ON DELETE SET NULL,
    amount NUMERIC(10,2) NOT NULL CHECK (amount >= 0),
    payment_method VARCHAR(30) NOT NULL
        CHECK (payment_method IN ('Card', 'Kaspi', 'BankTransfer', 'PayPal', 'PromoFree')),
    payment_status VARCHAR(20) NOT NULL DEFAULT 'Paid'
        CHECK (payment_status IN ('Pending', 'Paid', 'Failed', 'Refunded')),
    paid_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 15. Отзывы студентов
CREATE TABLE reviews (
    review_id SERIAL PRIMARY KEY,
    enrollment_id INT NOT NULL UNIQUE REFERENCES enrollments(enrollment_id) ON DELETE CASCADE,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_published BOOLEAN NOT NULL DEFAULT TRUE
);