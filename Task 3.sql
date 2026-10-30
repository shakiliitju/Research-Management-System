-- =========================================================
-- Research Management System - Sample Data
-- Run AFTER the DDL script from Task 1
-- =========================================================
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE AuditLog;
TRUNCATE TABLE EquipmentUsage;
TRUNCATE TABLE Equipment;
TRUNCATE TABLE Revision;
TRUNCATE TABLE Review;
TRUNCATE TABLE Submission;
TRUNCATE TABLE Conference;
TRUNCATE TABLE PublicationAuthor;
TRUNCATE TABLE Publication;
TRUNCATE TABLE Funding;
TRUNCATE TABLE FundingSource;
TRUNCATE TABLE StudentProject;
TRUNCATE TABLE FacultyProject;
TRUNCATE TABLE ResearchProject;
TRUNCATE TABLE Student;
TRUNCATE TABLE Faculty;
TRUNCATE TABLE Program;
TRUNCATE TABLE Department;
SET FOREIGN_KEY_CHECKS = 1;

-- =========================================================
-- 1. DEPARTMENTS (5)
-- head_faculty_id set later after Faculty insert
-- =========================================================
INSERT INTO Department (department_id, department_name, building, phone) VALUES
(1, 'Computer Science',        'Building A', '011-2001'),
(2, 'Electrical Engineering',  'Building B', '011-2002'),
(3, 'Mechanical Engineering',  'Building C', '011-2003'),
(4, 'Mathematics',             'Building D', '011-2004'),
(5, 'Physics',                 'Building E', '011-2005');

-- =========================================================
-- 2. PROGRAMS (8)
-- =========================================================
INSERT INTO Program (program_id, program_name, degree_level, department_id) VALUES
(1, 'BSc Computer Science',        'Bachelor', 1),
(2, 'MSc Computer Science',        'Master',   1),
(3, 'PhD Computer Science',        'PhD',      1),
(4, 'BSc Electrical Engineering',  'Bachelor', 2),
(5, 'MSc Electrical Engineering',  'Master',   2),
(6, 'BSc Mechanical Engineering',  'Bachelor', 3),
(7, 'MSc Mathematics',             'Master',   4),
(8, 'PhD Physics',                 'PhD',      5);

-- =========================================================
-- 3. FACULTY (15)
-- mentor_id references earlier faculty rows (recursive)
-- =========================================================
INSERT INTO Faculty
(faculty_id, first_name, last_name, email, phone, hire_date, title, salary, department_id, mentor_id) VALUES
(1,  'Ahmed',   'Al-Farsi',    'ahmed.alfarsi@uni.edu',    '050-1001', '2010-09-01', 'Professor',           22000.00, 1, NULL),
(2,  'Sara',    'Hassan',      'sara.hassan@uni.edu',      '050-1002', '2013-01-15', 'Associate Professor', 18000.00, 1, 1),
(3,  'Omar',    'Khalid',      'omar.khalid@uni.edu',      '050-1003', '2015-08-20', 'Assistant Professor', 14000.00, 1, 2),
(4,  'Lina',    'Nasser',      'lina.nasser@uni.edu',      '050-1004', '2016-03-10', 'Assistant Professor', 14000.00, 1, 1),
(5,  'Yousef',  'Saleh',       'yousef.saleh@uni.edu',     '050-1005', '2012-05-01', 'Professor',           21000.00, 2, NULL),
(6,  'Mona',    'Rahman',      'mona.rahman@uni.edu',      '050-1006', '2017-09-01', 'Lecturer',            11000.00, 2, 5),
(7,  'Khaled',  'Othman',      'khaled.othman@uni.edu',    '050-1007', '2014-11-11', 'Associate Professor', 17500.00, 3, NULL),
(8,  'Huda',    'Mansour',     'huda.mansour@uni.edu',     '050-1008', '2018-02-01', 'Assistant Professor', 13500.00, 3, 7),
(9,  'Faisal',  'Ali',         'faisal.ali@uni.edu',       '050-1009', '2011-07-07', 'Professor',           23000.00, 4, NULL),
(10, 'Noura',   'Ibrahim',     'noura.ibrahim@uni.edu',    '050-1010', '2019-10-01', 'Lecturer',            10500.00, 4, 9),
(11, 'Tariq',   'Mahmoud',     'tariq.mahmoud@uni.edu',    '050-1011', '2016-06-15', 'Assistant Professor', 13800.00, 5, NULL),
(12, 'Reem',    'Yahya',       'reem.yahya@uni.edu',       '050-1012', '2020-01-10', 'Lecturer',            10800.00, 5, 11),
(13, 'Sami',    'Zaid',        'sami.zaid@uni.edu',        '050-1013', '2013-04-04', 'Associate Professor', 17200.00, 1, 1),
(14, 'Dina',    'Bakr',        'dina.bakr@uni.edu',        '050-1014', '2017-12-12', 'Assistant Professor', 14200.00, 2, 5),
(15, 'Hassan',  'Farouk',      'hassan.farouk@uni.edu',    '050-1015', '2019-03-03', 'Lecturer',            10900.00, 3, 7);

-- Assign department heads
UPDATE Department SET head_faculty_id = 1 WHERE department_id = 1;
UPDATE Department SET head_faculty_id = 5 WHERE department_id = 2;
UPDATE Department SET head_faculty_id = 7 WHERE department_id = 3;
UPDATE Department SET head_faculty_id = 9 WHERE department_id = 4;
UPDATE Department SET head_faculty_id = 11 WHERE department_id = 5;

-- =========================================================
-- 4. STUDENTS (30)
-- =========================================================
INSERT INTO Student
(student_id, first_name, last_name, email, phone, date_of_birth, enrollment_date, academic_status, program_id, supervisor_id) VALUES
(1,  'Ali',     'Ahmad',      'ali.ahmad@student.edu',     '055-2001', '2000-02-11', '2019-09-01', 'Active',    1, 1),
(2,  'Fatima',  'Saleh',      'fatima.saleh@student.edu',  '055-2002', '2001-03-22', '2020-09-01', 'Active',    1, 2),
(3,  'Mohammed','Hussain',    'mohammed.h@student.edu',    '055-2003', '1999-07-15', '2018-09-01', 'Graduated', 1, 1),
(4,  'Aisha',   'Omar',       'aisha.omar@student.edu',    '055-2004', '2002-01-09', '2021-09-01', 'Active',    1, 3),
(5,  'Saud',    'Nasser',     'saud.nasser@student.edu',   '055-2005', '2000-11-30', '2019-09-01', 'Active',    2, 2),
(6,  'Maryam',  'Khalid',     'maryam.khalid@student.edu', '055-2006', '1998-05-19', '2018-09-01', 'Active',    2, 1),
(7,  'Abdullah','Rahman',     'abdullah.r@student.edu',    '055-2007', '1997-08-25', '2017-09-01', 'Active',    3, 1),
(8,  'Layla',   'Faisal',     'layla.faisal@student.edu',  '055-2008', '2001-12-14', '2020-09-01', 'Active',    3, 13),
(9,  'Nawaf',   'Sultan',     'nawaf.sultan@student.edu',  '055-2009', '2000-04-08', '2019-09-01', 'Suspended', 1, 4),
(10, 'Hind',    'Majed',      'hind.majed@student.edu',    '055-2010', '2002-06-17', '2021-09-01', 'Active',    1, 2),
(11, 'Sultan',  'Turki',      'sultan.turki@student.edu',  '055-2011', '1999-09-09', '2018-09-01', 'Graduated', 4, 5),
(12, 'Amal',    'Saad',       'amal.saad@student.edu',     '055-2012', '2001-10-21', '2020-09-01', 'Active',    4, 6),
(13, 'Fahad',   'Nayef',      'fahad.nayef@student.edu',   '055-2013', '2000-03-03', '2019-09-01', 'Active',    4, 5),
(14, 'Razan',   'Waleed',     'razan.waleed@student.edu',  '055-2014', '2002-08-12', '2021-09-01', 'Active',    5, 14),
(15, 'Bader',   'Hamad',      'bader.hamad@student.edu',   '055-2015', '1998-12-01', '2017-09-01', 'Active',    5, 5),
(16, 'Jawaher', 'Salem',      'jawaher.salem@student.edu', '055-2016', '2001-05-27', '2020-09-01', 'Active',    6, 7),
(17, 'Mansour', 'Ibrahim',    'mansour.i@student.edu',     '055-2017', '2000-07-04', '2019-09-01', 'Active',    6, 8),
(18, 'Ghada',   'Yousef',     'ghada.yousef@student.edu',  '055-2018', '2002-11-16', '2021-09-01', 'Active',    6, 7),
(19, 'Rakan',   'Fahad',      'rakan.fahad@student.edu',   '055-2019', '1999-01-23', '2018-09-01', 'Withdrawn', 6, 15),
(20, 'Shahad',  'Nawaf',      'shahad.nawaf@student.edu',  '055-2020', '2001-09-05', '2020-09-01', 'Active',    7, 9),
(21, 'Talal',   'Hamza',      'talal.hamza@student.edu',   '055-2021', '2000-06-30', '2019-09-01', 'Active',    7, 10),
(22, 'Wafa',    'Adel',       'wafa.adel@student.edu',     '055-2022', '1998-02-18', '2018-09-01', 'Active',    7, 9),
(23, 'Ziyad',   'Mazen',      'ziyad.mazen@student.edu',   '055-2023', '2001-04-11', '2020-09-01', 'Active',    8, 11),
(24, 'Asma',    'Rashed',     'asma.rashed@student.edu',   '055-2024', '1997-10-07', '2017-09-01', 'Active',    8, 12),
(25, 'Saeed',   'Nabil',      'saeed.nabil@student.edu',   '055-2025', '2000-12-25', '2019-09-01', 'Active',    8, 11),
(26, 'Lama',    'Fouad',      'lama.fouad@student.edu',    '055-2026', '2002-03-14', '2021-09-01', 'Active',    1, 4),
(27, 'Yara',    'Tariq',      'yara.tariq@student.edu',    '055-2027', '2001-08-08', '2020-09-01', 'Active',    2, 3),
(28, 'Othman',  'Jamil',      'othman.jamil@student.edu',  '055-2028', '1999-11-19', '2018-09-01', 'Active',    3, 13),
(29, 'Dalal',   'Khaled',     'dalal.khaled@student.edu',  '055-2029', '2002-01-02', '2021-09-01', 'Active',    4, 6),
(30, 'Nasser',  'Ayman',      'nasser.ayman@student.edu',  '055-2030', '2000-05-20', '2019-09-01', 'Active',    5, 14);

-- =========================================================
-- 5. RESEARCH PROJECTS (15)
-- =========================================================
INSERT INTO ResearchProject
(project_id, project_title, start_date, end_date, status, department_id, lead_faculty_id) VALUES
(1,  'AI for Healthcare Diagnostics',          '2022-01-15', '2025-01-14', 'Active',    1, 1),
(2,  'Cybersecurity in IoT Networks',           '2021-06-01', '2024-05-31', 'Active',    1, 2),
(3,  'Natural Language Processing for Arabic',  '2023-02-01', NULL,         'Active',    1, 3),
(4,  'Renewable Energy Storage Systems',        '2021-09-01', '2024-08-31', 'Completed', 2, 5),
(5,  '5G Network Optimization',                 '2022-03-15', '2025-03-14', 'Active',    2, 6),
(6,  'Robotic Assembly Line Automation',        '2020-11-01', '2023-10-31', 'Completed', 3, 7),
(7,  'Advanced Materials for Aerospace',        '2022-07-01', '2025-06-30', 'Active',    3, 8),
(8,  'Computational Number Theory',             '2021-01-10', '2024-01-09', 'Active',    4, 9),
(9,  'Statistical Models for Climate Data',     '2023-03-01', NULL,         'Active',    4, 10),
(10, 'Quantum Computing Algorithms',            '2022-05-20', '2025-05-19', 'Active',    5, 11),
(11, 'Particle Physics Simulation',             '2021-08-15', '2024-08-14', 'Active',    5, 12),
(12, 'Machine Learning for Finance',            '2023-01-01', NULL,         'Proposed',  1, 13),
(13, 'Smart Grid Cybersecurity',                '2022-10-01', '2025-09-30', 'Active',    2, 14),
(14, 'Autonomous Vehicle Navigation',           '2021-04-01', '2024-03-31', 'Active',    3, 15),
(15, 'Astrophysics Data Mining',                '2023-06-01', NULL,         'Proposed',  5, 11);

-- =========================================================
-- 6. FACULTY–PROJECT SUPERVISION (M:N with attributes)
-- =========================================================
INSERT INTO FacultyProject (faculty_id, project_id, supervision_role, start_date) VALUES
(1,  1,  'Principal Investigator', '2022-01-15'),
(2,  1,  'Co-Investigator',        '2022-01-15'),
(3,  1,  'Supervisor',             '2022-02-01'),
(2,  2,  'Principal Investigator', '2021-06-01'),
(4,  2,  'Co-Investigator',        '2021-06-01'),
(3,  3,  'Principal Investigator', '2023-02-01'),
(13, 3,  'Advisor',                '2023-02-01'),
(5,  4,  'Principal Investigator', '2021-09-01'),
(6,  4,  'Co-Investigator',        '2021-09-01'),
(6,  5,  'Principal Investigator', '2022-03-15'),
(14, 5,  'Co-Investigator',        '2022-03-15'),
(7,  6,  'Principal Investigator', '2020-11-01'),
(8,  6,  'Supervisor',             '2020-11-01'),
(8,  7,  'Principal Investigator', '2022-07-01'),
(15, 7,  'Co-Investigator',        '2022-07-01'),
(9,  8,  'Principal Investigator', '2021-01-10'),
(10, 8,  'Co-Investigator',        '2021-01-10'),
(10, 9,  'Principal Investigator', '2023-03-01'),
(9,  9,  'Advisor',                '2023-03-01'),
(11, 10, 'Principal Investigator', '2022-05-20'),
(12, 10, 'Co-Investigator',        '2022-05-20'),
(12, 11, 'Principal Investigator', '2021-08-15'),
(11, 11, 'Co-Investigator',        '2021-08-15'),
(13, 12, 'Principal Investigator', '2023-01-01'),
(14, 13, 'Principal Investigator', '2022-10-01'),
(6,  13, 'Co-Investigator',        '2022-10-01'),
(15, 14, 'Principal Investigator', '2021-04-01'),
(7,  14, 'Co-Investigator',        '2021-04-01'),
(11, 15, 'Principal Investigator', '2023-06-01');

-- =========================================================
-- 7. STUDENT–PROJECT PARTICIPATION (M:N with attributes)
-- contribution_percentage per project kept <= 100 via trigger (Task 7)
-- =========================================================
INSERT INTO StudentProject
(student_id, project_id, project_role, contribution_percentage, join_date) VALUES
(1,  1,  'Lead Student', 40.00, '2022-01-20'),
(2,  1,  'Researcher',   30.00, '2022-02-01'),
(4,  1,  'Assistant',    20.00, '2022-03-01'),
(5,  2,  'Lead Student', 50.00, '2021-06-10'),
(6,  2,  'Researcher',   30.00, '2021-07-01'),
(7,  3,  'Lead Student', 60.00, '2023-02-10'),
(8,  3,  'Researcher',   40.00, '2023-03-01'),
(11, 4,  'Lead Student', 45.00, '2021-09-15'),
(12, 4,  'Researcher',   35.00, '2021-10-01'),
(14, 5,  'Lead Student', 55.00, '2022-03-20'),
(15, 5,  'Researcher',   45.00, '2022-04-01'),
(16, 6,  'Lead Student', 50.00, '2020-11-15'),
(17, 6,  'Researcher',   30.00, '2020-12-01'),
(18, 7,  'Lead Student', 60.00, '2022-07-10'),
(20, 8,  'Lead Student', 50.00, '2021-01-20'),
(21, 8,  'Researcher',   50.00, '2021-02-01'),
(22, 9,  'Lead Student', 60.00, '2023-03-10'),
(23, 10, 'Lead Student', 50.00, '2022-05-25'),
(24, 10, 'Researcher',   30.00, '2022-06-01'),
(25, 11, 'Lead Student', 55.00, '2021-08-20'),
(26, 12, 'Researcher',   100.00,'2023-01-15'),
(27, 13, 'Lead Student', 60.00, '2022-10-10'),
(28, 14, 'Lead Student', 50.00, '2021-04-10'),
(29, 14, 'Researcher',   50.00, '2021-05-01'),
(30, 15, 'Lead Student', 100.00,'2023-06-10'),
-- Students in multiple projects (required for query #6)
(1,  2,  'Researcher',   10.00, '2021-08-01'),
(5,  1,  'Researcher',   10.00, '2022-06-01'),
(7,  1,  'Assistant',    10.00, '2022-07-01'),
(11, 5,  'Researcher',   10.00, '2022-09-01'),
(16, 7,  'Researcher',   20.00, '2022-09-01');

-- =========================================================
-- 8. FUNDING SOURCES (8)
-- =========================================================
INSERT INTO FundingSource (source_id, source_name, source_type, contact_email, country) VALUES
(1, 'Ministry of Higher Education',  'Government',    'grants@mhe.gov',         'Saudi Arabia'),
(2, 'National Science Foundation',   'Government',    'info@nsf.gov',           'USA'),
(3, 'TechCorp Industries',           'Industry',      'funding@techcorp.com',   'Saudi Arabia'),
(4, 'King Abdulaziz University Fund','University',    'fund@kau.edu.sa',        'Saudi Arabia'),
(5, 'Gates Foundation',              'Non-Profit',    'grants@gates.org',       'USA'),
(6, 'EU Horizon Program',            'International', 'horizon@eu.int',         'Belgium'),
(7, 'Saudi Aramco Research',         'Industry',      'research@aramco.com',    'Saudi Arabia'),
(8, 'UNESCO Research Fund',          'International', 'research@unesco.org',    'France');

-- =========================================================
-- 9. FUNDING (project funding records)
-- =========================================================
INSERT INTO Funding (funding_id, project_id, source_id, funding_amount, funding_date) VALUES
(1,  1,  1, 500000.00, '2022-01-10'),
(2,  1,  3, 250000.00, '2022-03-15'),
(3,  2,  2, 400000.00, '2021-05-20'),
(4,  2,  7, 150000.00, '2021-08-01'),
(5,  3,  1, 300000.00, '2023-01-20'),
(6,  4,  6, 600000.00, '2021-08-15'),
(7,  5,  3, 350000.00, '2022-03-01'),
(8,  6,  7, 450000.00, '2020-10-15'),
(9,  7,  2, 380000.00, '2022-06-20'),
(10, 8,  4, 200000.00, '2021-01-05'),
(11, 9,  5, 180000.00, '2023-02-15'),
(12, 10, 6, 700000.00, '2022-05-10'),
(13, 11, 8, 320000.00, '2021-08-01'),
(14, 13, 3, 280000.00, '2022-09-15'),
(15, 14, 7, 410000.00, '2021-03-20'),
(16, 12, 1, 100000.00, '2023-01-05'),
(17, 15, 2,  75000.00, '2023-05-25');

-- =========================================================
-- 10. PUBLICATIONS (25)
-- =========================================================
INSERT INTO Publication (publication_id, title, publication_type, publication_year, doi, journal_name) VALUES
(1,  'Deep Learning for Medical Image Analysis',        'Journal',      2023, '10.1000/pub001', 'IEEE Transactions on Medical Imaging'),
(2,  'IoT Security Challenges and Solutions',           'Journal',      2022, '10.1000/pub002', 'Journal of Cybersecurity'),
(3,  'Arabic NLP: A Survey',                            'Journal',      2023, '10.1000/pub003', 'ACM Computing Surveys'),
(4,  'Battery Storage for Renewable Energy',            'Journal',      2022, '10.1000/pub004', 'Renewable Energy Journal'),
(5,  '5G Network Slicing Optimization',                 'Conference',   2023, '10.1000/pub005', NULL),
(6,  'Robotic Automation in Manufacturing',             'Journal',      2021, '10.1000/pub006', 'Robotics and Automation Letters'),
(7,  'Advanced Alloys for Aerospace',                   'Journal',      2023, '10.1000/pub007', 'Materials Science Journal'),
(8,  'Prime Distribution Algorithms',                   'Journal',      2022, '10.1000/pub008', 'Journal of Number Theory'),
(9,  'Climate Data Statistical Analysis',               'Journal',      2023, '10.1000/pub009', 'Climate Statistics'),
(10, 'Quantum Algorithm Design',                        'Journal',      2023, '10.1000/pub010', 'Quantum Information Processing'),
(11, 'Particle Simulation Techniques',                  'Conference',   2022, '10.1000/pub011', NULL),
(12, 'ML for Stock Prediction',                         'Journal',      2023, '10.1000/pub012', 'Financial ML Journal'),
(13, 'Smart Grid Intrusion Detection',                  'Conference',   2023, '10.1000/pub013', NULL),
(14, 'Autonomous Navigation Systems',                   'Journal',      2022, '10.1000/pub014', 'IEEE Robotics'),
(15, 'Astrophysics Data Mining Techniques',             'Journal',      2023, '10.1000/pub015', 'Astroinformatics'),
(16, 'Federated Learning for Healthcare',               'Conference',   2023, '10.1000/pub016', NULL),
(17, 'Blockchain for Supply Chain',                     'Journal',      2022, '10.1000/pub017', 'Blockchain Journal'),
(18, 'Edge Computing for IoT',                          'Journal',      2023, '10.1000/pub018', 'Edge Computing Review'),
(19, 'Sentiment Analysis in Arabic Tweets',             'Conference',   2022, '10.1000/pub019', NULL),
(20, 'Solar Panel Efficiency Optimization',             'Journal',      2021, '10.1000/pub020', 'Solar Energy'),
(21, 'Deep Reinforcement Learning for Games',           'Journal',      2023, '10.1000/pub021', 'AI Journal'),
(22, 'Privacy-Preserving Data Mining',                  'Conference',   2023, '10.1000/pub022', NULL),
(23, 'Wireless Sensor Network Protocols',               'Journal',      2022, '10.1000/pub023', 'Sensor Networks'),
(24, 'Graph Neural Networks for Chemistry',             'Journal',      2023, '10.1000/pub024', 'Chemical Informatics'),
(25, 'Fault-Tolerant Distributed Systems',              'Conference',   2022, '10.1000/pub025', NULL);

-- =========================================================
-- 11. PUBLICATION AUTHORS (author_order + is_corresponding)
-- =========================================================
INSERT INTO PublicationAuthor (publication_id, faculty_id, author_order, is_corresponding) VALUES
(1,  1, 1, TRUE),  (1, 2, 2, FALSE), (1, 3, 3, FALSE),
(2,  2, 1, TRUE),  (2, 4, 2, FALSE),
(3,  3, 1, TRUE),  (3, 13, 2, FALSE),
(4,  5, 1, TRUE),  (4, 6, 2, FALSE),
(5,  6, 1, TRUE),  (5, 14, 2, FALSE),
(6,  7, 1, TRUE),  (6, 8, 2, FALSE),
(7,  8, 1, TRUE),  (7, 15, 2, FALSE),
(8,  9, 1, TRUE),  (8, 10, 2, FALSE),
(9,  10, 1, TRUE), (9, 9, 2, FALSE),
(10, 11, 1, TRUE), (10, 12, 2, FALSE),
(11, 12, 1, TRUE), (11, 11, 2, FALSE),
(12, 13, 1, TRUE), (12, 1, 2, FALSE),
(13, 14, 1, TRUE), (13, 6, 2, FALSE),
(14, 15, 1, TRUE), (14, 7, 2, FALSE),
(15, 11, 1, TRUE), (15, 12, 2, FALSE),
(16, 1, 1, TRUE),  (16, 2, 2, FALSE), (16, 4, 3, FALSE), (16, 13, 4, FALSE),
(17, 13, 1, TRUE), (17, 3, 2, FALSE),
(18, 4, 1, TRUE),  (18, 2, 2, FALSE), (18, 6, 3, FALSE), (18, 14, 4, FALSE),
(19, 3, 1, TRUE),  (19, 13, 2, FALSE),
(20, 5, 1, TRUE),  (20, 6, 2, FALSE),
(21, 1, 1, TRUE),  (21, 3, 2, FALSE), (21, 13, 3, FALSE), (21, 4, 4, FALSE),
(22, 2, 1, TRUE),  (22, 14, 2, FALSE),
(23, 6, 1, TRUE),  (23, 14, 2, FALSE), (23, 5, 3, FALSE), (23, 4, 4, FALSE),
(24, 8, 1, TRUE),  (24, 7, 2, FALSE),
(25, 12, 1, TRUE), (25, 11, 2, FALSE), (25, 10, 3, FALSE);

-- =========================================================
-- 12. CONFERENCES (8)
-- =========================================================
INSERT INTO Conference (conference_id, conference_name, location, conference_date, submission_deadline) VALUES
(1, 'IEEE International Conference on AI',        'Riyadh, Saudi Arabia', '2023-12-15', '2023-09-01'),
(2, 'ACM SIGCOMM',                                'New York, USA',        '2023-08-20', '2023-04-15'),
(3, 'International Conference on NLP',            'Dubai, UAE',           '2023-11-10', '2023-07-01'),
(4, 'IEEE Power Engineering Conference',          'Berlin, Germany',      '2023-06-05', '2023-02-01'),
(5, 'ACM Conference on Robotics',                 'Tokyo, Japan',         '2023-10-25', '2023-06-15'),
(6, 'International Cybersecurity Symposium',      'London, UK',           '2023-09-12', '2023-05-01'),
(7, 'World Quantum Computing Summit',             'Geneva, Switzerland',  '2023-07-18', '2023-03-15'),
(8, 'International Data Mining Conference',       'Paris, France',        '2023-05-22', '2023-01-20');

-- =========================================================
-- 13. SUBMISSIONS (20)
-- =========================================================
INSERT INTO Submission (submission_id, publication_id, conference_id, submission_date, decision, decision_date) VALUES
(1,  5,  2, '2023-04-10', 'Accepted', '2023-06-15'),
(2,  11, 7, '2023-03-10', 'Accepted', '2023-05-20'),
(3,  13, 6, '2023-05-05', 'Accepted', '2023-07-01'),
(4,  16, 1, '2023-08-25', 'Accepted', '2023-10-20'),
(5,  19, 3, '2023-06-20', 'Revision', '2023-08-15'),
(6,  22, 8, '2023-01-10', 'Accepted', '2023-03-25'),
(7,  25, 2, '2023-04-05', 'Accepted', '2023-06-10'),
(8,  17, 6, '2023-05-15', 'Rejected', '2023-07-05'),
(9,  18, 2, '2023-04-20', 'Accepted', '2023-06-20'),
(10, 21, 1, '2023-08-30', 'Accepted', '2023-10-25'),
(11, 24, 5, '2023-06-10', 'Revision', '2023-08-01'),
(12, 14, 5, '2023-06-12', 'Accepted', '2023-08-05'),
(13, 20, 4, '2023-01-25', 'Accepted', '2023-03-30'),
(14, 15, 8, '2023-01-15', 'Pending',  NULL),
(15, 23, 6, '2023-05-10', 'Accepted', '2023-07-15'),
(16, 12, 1, '2023-08-28', 'Revision', '2023-10-15'),
(17, 1,  8, '2023-01-18', 'Accepted', '2023-03-20'),
(18, 9,  8, '2023-01-22', 'Accepted', '2023-03-28'),
(19, 10, 7, '2023-03-20', 'Accepted', '2023-05-25'),
(20, 3,  3, '2023-06-25', 'Accepted', '2023-08-20');

-- =========================================================
-- 14. REVIEWS (30) - mix of internal faculty and external reviewers
-- =========================================================
INSERT INTO Review (review_id, submission_id, reviewer_faculty_id, reviewer_name, review_score, review_comments, review_date) VALUES
(1,  1,  1,    NULL,              8.5, 'Strong contribution, well written.',           '2023-05-01'),
(2,  1,  3,    NULL,              7.5, 'Good but needs more experiments.',             '2023-05-02'),
(3,  1,  NULL, 'Dr. External A',  8.0, 'Solid work.',                                  '2023-05-03'),
(4,  2,  11,   NULL,              9.0, 'Excellent paper.',                             '2023-04-01'),
(5,  2,  12,   NULL,              8.5, 'Minor revisions recommended.',                 '2023-04-02'),
(6,  3,  14,   NULL,              7.0, 'Needs clearer motivation.',                    '2023-06-01'),
(7,  3,  NULL, 'Dr. External B',  8.0, 'Good contribution.',                           '2023-06-02'),
(8,  4,  1,    NULL,              8.5, 'Well structured.',                             '2023-09-15'),
(9,  4,  2,    NULL,              9.0, 'Excellent.',                                   '2023-09-16'),
(10, 4,  4,    NULL,              8.0, 'Accept with minor changes.',                   '2023-09-17'),
(11, 5,  3,    NULL,              6.5, 'Needs more data.',                             '2023-07-10'),
(12, 5,  13,   NULL,              7.0, 'Moderate contribution.',                       '2023-07-11'),
(13, 6,  2,    NULL,              8.0, 'Interesting approach.',                        '2023-02-05'),
(14, 6,  14,   NULL,              7.5, 'Good.',                                        '2023-02-06'),
(15, 7,  12,   NULL,              8.5, 'Solid systems work.',                          '2023-05-01'),
(16, 7,  11,   NULL,              8.0, 'Well evaluated.',                              '2023-05-02'),
(17, 8,  13,   NULL,              5.0, 'Limited novelty.',                             '2023-06-01'),
(18, 8,  NULL, 'Dr. External C',  5.5, 'Reject.',                                      '2023-06-02'),
(19, 9,  4,    NULL,              8.5, 'Good contribution.',                           '2023-05-05'),
(20, 9,  6,    NULL,              8.0, 'Accept.',                                      '2023-05-06'),
(21, 10, 1,    NULL,              9.0, 'Excellent.',                                   '2023-09-20'),
(22, 10, 3,    NULL,              8.5, 'Strong.',                                      '2023-09-21'),
(23, 11, 8,    NULL,              7.0, 'Minor revision.',                              '2023-07-01'),
(24, 11, 7,    NULL,              7.5, 'Good.',                                        '2023-07-02'),
(25, 12, 15,   NULL,              8.0, 'Accept.',                                      '2023-07-05'),
(26, 13, 5,    NULL,              8.5, 'Good paper.',                                  '2023-02-20'),
(27, 14, 11,   NULL,              7.0, 'Pending decision.',                            '2023-03-01'),
(28, 15, 6,    NULL,              8.5, 'Accept.',                                      '2023-06-01'),
(29, 16, 13,   NULL,              6.0, 'Needs revision.',                              '2023-09-10'),
(30, 17, 9,    NULL,              9.0, 'Excellent.',                                   '2023-02-15');

-- =========================================================
-- 15. REVISIONS (20)
-- =========================================================
INSERT INTO Revision (revision_id, submission_id, revision_number, revision_date, revision_notes) VALUES
(1,  5,  1, '2023-07-15', 'Added more experimental results.'),
(2,  5,  2, '2023-08-10', 'Improved clarity and fixed typos.'),
(3,  11, 1, '2023-07-05', 'Expanded related work section.'),
(4,  11, 2, '2023-07-28', 'Added comparison with baseline.'),
(5,  16, 1, '2023-09-20', 'Improved methodology description.'),
(6,  16, 2, '2023-10-05', 'Added more datasets.'),
(7,  1,  1, '2023-05-20', 'Addressed reviewer 2 comments.'),
(8,  2,  1, '2023-04-15', 'Minor formatting fixes.'),
(9,  3,  1, '2023-06-15', 'Clarified motivation.'),
(10, 4,  1, '2023-09-25', 'Added ablation study.'),
(11, 6,  1, '2023-02-15', 'Improved figures.'),
(12, 7,  1, '2023-05-10', 'Added more baselines.'),
(13, 9,  1, '2023-05-15', 'Fixed references.'),
(14, 10, 1, '2023-09-30', 'Minor edits.'),
(15, 12, 1, '2023-07-15', 'Added results table.'),
(16, 13, 1, '2023-03-01', 'Improved abstract.'),
(17, 15, 1, '2023-06-10', 'Added discussion.'),
(18, 17, 1, '2023-02-25', 'Fixed typos.'),
(19, 18, 1, '2023-02-28', 'Improved conclusion.'),
(20, 20, 1, '2023-07-01', 'Added limitations section.');

-- =========================================================
-- 16. EQUIPMENT (10)
-- =========================================================
INSERT INTO Equipment (equipment_id, equipment_name, serial_number, purchase_date, condition_status, department_id) VALUES
(1,  'GPU Server NVIDIA A100',      'SN-GPU-001', '2022-01-10', 'Good',           1),
(2,  'High-Performance Cluster',    'SN-HPC-002', '2021-06-15', 'Good',           1),
(3,  'Network Analyzer',            'SN-NET-003', '2020-03-20', 'Fair',           2),
(4,  'Oscilloscope 500MHz',         'SN-OSC-004', '2019-08-01', 'Good',           2),
(5,  '3D Printer Industrial',       'SN-3DP-005', '2021-11-11', 'Good',           3),
(6,  'CNC Milling Machine',         'SN-CNC-006', '2018-05-05', 'Fair',           3),
(7,  'MATLAB Workstation',          'SN-MAT-007', '2022-02-28', 'Good',           4),
(8,  'Statistical Computing Server','SN-STA-008', '2021-09-09', 'Good',           4),
(9,  'Particle Detector',           'SN-PAR-009', '2020-12-12', 'Poor',           5),
(10, 'Spectrometer',                'SN-SPE-010', '2022-07-07', 'Good',           5);

-- =========================================================
-- 17. EQUIPMENT USAGE (M:N with usage attributes)
-- =========================================================
INSERT INTO EquipmentUsage (equipment_id, project_id, usage_date, usage_purpose) VALUES
(1,  1,  '2022-02-01', 'Training deep learning models'),
(1,  1,  '2022-05-10', 'Model evaluation'),
(1,  3,  '2023-03-01', 'NLP model training'),
(2,  2,  '2021-07-01', 'Security simulations'),
(2,  10, '2022-06-01', 'Quantum simulations'),
(3,  2,  '2021-08-15', 'Network traffic analysis'),
(4,  5,  '2022-04-01', '5G signal measurement'),
(5,  6,  '2021-01-10', 'Prototype printing'),
(5,  7,  '2022-08-01', 'Material sample printing'),
(6,  6,  '2021-03-01', 'Component machining'),
(7,  8,  '2021-02-01', 'Number theory computations'),
(7,  9,  '2023-04-01', 'Climate data analysis'),
(8,  9,  '2023-05-01', 'Statistical modeling'),
(9,  11, '2021-09-01', 'Particle detection experiments'),
(10, 11, '2021-10-01', 'Spectral analysis'),
(10, 15, '2023-07-01', 'Astrophysics measurements'),
(1,  12, '2023-02-01', 'Financial ML training'),
(2,  13, '2022-11-01', 'Smart grid simulation'),
(5,  14, '2021-05-01', 'Autonomous vehicle parts'),
(7,  5,  '2022-06-01', 'Network optimization modeling');

-- =========================================================
-- VERIFICATION QUERIES
-- =========================================================
SELECT 'Departments'        AS table_name, COUNT(*) AS row_count FROM Department
UNION ALL SELECT 'Programs',          COUNT(*) FROM Program
UNION ALL SELECT 'Students',          COUNT(*) FROM Student
UNION ALL SELECT 'Faculty',           COUNT(*) FROM Faculty
UNION ALL SELECT 'Research Projects', COUNT(*) FROM ResearchProject
UNION ALL SELECT 'Funding Sources',   COUNT(*) FROM FundingSource
UNION ALL SELECT 'Funding Records',   COUNT(*) FROM Funding
UNION ALL SELECT 'Publications',      COUNT(*) FROM Publication
UNION ALL SELECT 'Publication Authors', COUNT(*) FROM PublicationAuthor
UNION ALL SELECT 'Conferences',       COUNT(*) FROM Conference
UNION ALL SELECT 'Submissions',       COUNT(*) FROM Submission
UNION ALL SELECT 'Reviews',           COUNT(*) FROM Review
UNION ALL SELECT 'Revisions',         COUNT(*) FROM Revision
UNION ALL SELECT 'Equipment',         COUNT(*) FROM Equipment
UNION ALL SELECT 'Equipment Usage',   COUNT(*) FROM EquipmentUsage
UNION ALL SELECT 'Faculty-Project',   COUNT(*) FROM FacultyProject
UNION ALL SELECT 'Student-Project',   COUNT(*) FROM StudentProject;