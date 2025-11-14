CREATE TABLE IF NOT EXISTS students (
    student_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    dob DATE,
    phone VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS courses (
    course_id SERIAL PRIMARY KEY,
    course_name VARCHAR(150) NOT NULL,
    duration_weeks INT,
    credits INT
);

CREATE TABLE IF NOT EXISTS enrollments (
    enroll_id SERIAL PRIMARY KEY,
    student_id INT NOT NULL REFERENCES students(student_id) ON DELETE CASCADE,
    course_id INT NOT NULL REFERENCES courses(course_id) ON DELETE CASCADE,
    enroll_date DATE DEFAULT CURRENT_DATE,
    UNIQUE(student_id, course_id)
);

INSERT INTO students (name, email, dob, phone)
SELECT * FROM (VALUES
  ('Asha Kumar', 'asha@example.com', '2001-05-12', '9876543210'),
  ('Ravi Reddy', 'ravi@example.com', '1999-11-01', '9123456780'),
  ('Maya Singh', 'maya@example.com', '2000-08-22', '9012345678')
) AS v(name,email,dob,phone)
WHERE NOT EXISTS (SELECT 1 FROM students WHERE email = v.email);

INSERT INTO courses (course_name, duration_weeks, credits)
SELECT * FROM (VALUES
  ('Python Programming', 8, 3),
  ('Database Systems', 10, 4),
  ('Web Development', 12, 3)
) AS v(course_name,duration_weeks,credits)
WHERE NOT EXISTS (SELECT 1 FROM courses WHERE course_name = v.course_name);

WITH s AS (SELECT student_id FROM students WHERE email='asha@example.com'),
     c1 AS (SELECT course_id FROM courses WHERE course_name='Python Programming'),
     c2 AS (SELECT course_id FROM courses WHERE course_name='Database Systems'),
     r AS (SELECT student_id FROM students WHERE email='ravi@example.com'),
     c3 AS (SELECT course_id FROM courses WHERE course_name='Web Development')
INSERT INTO enrollments (student_id, course_id)
SELECT s.student_id, c1.course_id FROM s, c1
WHERE NOT EXISTS (SELECT 1 FROM enrollments e WHERE e.student_id = s.student_id AND e.course_id = c1.course_id);

INSERT INTO enrollments (student_id, course_id)
SELECT s.student_id, c2.course_id FROM s, c2
WHERE NOT EXISTS (SELECT 1 FROM enrollments e WHERE e.student_id = s.student_id AND e.course_id = c2.course_id);

INSERT INTO enrollments (student_id, course_id)
SELECT r.student_id, c1.course_id FROM r, c1
WHERE NOT EXISTS (SELECT 1 FROM enrollments e WHERE e.student_id = r.student_id AND e.course_id = c1.course_id);

SELECT student_id, name, email, dob, phone FROM students ORDER BY student_id;

SELECT course_id, course_name, duration_weeks, credits FROM courses ORDER BY course_id;

SELECT e.enroll_id, s.student_id, s.name, c.course_id, c.course_name, e.enroll_date
FROM enrollments e
JOIN students s ON e.student_id = s.student_id
JOIN courses c ON e.course_id = c.course_id
ORDER BY e.enroll_date DESC, s.student_id;

SELECT s.student_id, s.name, s.email, e.enroll_date
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id
WHERE c.course_name = 'Python Programming'
ORDER BY s.name;

SELECT s.student_id, s.name, COUNT(e.course_id) AS total_courses
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id
GROUP BY s.student_id, s.name
ORDER BY total_courses DESC, s.name;

SELECT c.course_id, c.course_name, COUNT(e.student_id) AS total_students
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_name
ORDER BY total_students DESC, c.course_name;

SELECT s.student_id, s.name, s.email
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id
WHERE e.enroll_id IS NULL;

SELECT e.enroll_id, s.name, c.course_name, e.enroll_date
FROM enrollments e
JOIN students s ON e.student_id = s.student_id
JOIN courses c ON e.course_id = c.course_id
WHERE e.enroll_date >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY e.enroll_date DESC;

CREATE OR REPLACE VIEW student_summary AS
SELECT s.student_id, s.name, s.email,
       COUNT(e.course_id) AS courses_enrolled,
       STRING_AGG(c.course_name, ', ') AS course_list
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id
LEFT JOIN courses c ON e.course_id = c.course_id
GROUP BY s.student_id, s.name, s.email;
