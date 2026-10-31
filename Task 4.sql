
SELECT s.student_id,
       CONCAT(s.first_name,' ',s.last_name) AS student_name,
       p.program_name,
       p.degree_level,
       d.department_name
FROM Student s
JOIN Program p    ON s.program_id = p.program_id
JOIN Department d ON p.department_id = d.department_id
ORDER BY d.department_name, p.program_name, s.last_name;



SELECT s.student_id,
       CONCAT(s.first_name,' ',s.last_name) AS student_name,
       CONCAT(f.first_name,' ',f.last_name) AS supervisor_name,
       f.title,
       f.email
FROM Student s
LEFT JOIN Faculty f ON s.supervisor_id = f.faculty_id
ORDER BY supervisor_name, student_name;



SELECT f.faculty_id,
       CONCAT(f.first_name,' ',f.last_name) AS faculty_name,
       COUNT(s.student_id) AS num_students
FROM Faculty f
JOIN Student s ON s.supervisor_id = f.faculty_id
GROUP BY f.faculty_id, f.first_name, f.last_name
HAVING COUNT(s.student_id) > 5
ORDER BY num_students DESC;



SELECT rp.project_id,
       rp.project_title,
       COUNT(sp.student_id) AS num_students
FROM ResearchProject rp
JOIN StudentProject sp ON rp.project_id = sp.project_id
GROUP BY rp.project_id, rp.project_title
HAVING COUNT(sp.student_id) > 3
ORDER BY num_students DESC;



SELECT rp.project_id,
       rp.project_title,
       SUM(f.funding_amount) AS total_funding
FROM ResearchProject rp
JOIN Funding f ON rp.project_id = f.project_id
GROUP BY rp.project_id, rp.project_title
HAVING SUM(f.funding_amount) > 500000
ORDER BY total_funding DESC;



SELECT s.student_id,
       CONCAT(s.first_name,' ',s.last_name) AS student_name,
       COUNT(sp.project_id) AS num_projects
FROM Student s
JOIN StudentProject sp ON s.student_id = sp.student_id
GROUP BY s.student_id, s.first_name, s.last_name
HAVING COUNT(sp.project_id) > 1
ORDER BY num_projects DESC;



SELECT DISTINCT f.faculty_id,
       CONCAT(f.first_name,' ',f.last_name) AS faculty_name
FROM Faculty f
JOIN PublicationAuthor pa ON f.faculty_id = pa.faculty_id
ORDER BY faculty_name;



SELECT p.publication_id,
       p.title,
       COUNT(pa.faculty_id) AS num_authors
FROM Publication p
JOIN PublicationAuthor pa ON p.publication_id = pa.publication_id
GROUP BY p.publication_id, p.title
HAVING COUNT(pa.faculty_id) > 3
ORDER BY num_authors DESC;



-- Example: faculty_id = 1
SELECT p.publication_id,
       p.title,
       p.publication_year,
       CONCAT(f.first_name,' ',f.last_name) AS corresponding_author
FROM Publication p
JOIN PublicationAuthor pa ON p.publication_id = pa.publication_id
JOIN Faculty f            ON pa.faculty_id = f.faculty_id
WHERE pa.is_corresponding = TRUE
  AND f.faculty_id = 1
ORDER BY p.publication_year DESC;



SELECT c.conference_id,
       c.conference_name,
       COUNT(s.submission_id) AS num_submissions
FROM Conference c
JOIN Submission s ON c.conference_id = s.conference_id
GROUP BY c.conference_id, c.conference_name
HAVING COUNT(s.submission_id) > 5
ORDER BY num_submissions DESC;



-- Example: decision = 'Accepted'
SELECT s.submission_id,
       p.title,
       c.conference_name,
       s.decision,
       s.decision_date
FROM Submission s
JOIN Publication p ON s.publication_id = p.publication_id
JOIN Conference c  ON s.conference_id  = c.conference_id
WHERE s.decision = 'Accepted'
ORDER BY s.decision_date DESC;



SELECT s.student_id,
       CONCAT(s.first_name,' ',s.last_name) AS student_name,
       p.program_name
FROM Student s
JOIN Program p ON s.program_id = p.program_id
WHERE NOT EXISTS (
    SELECT 1
    FROM StudentProject sp
    WHERE sp.student_id = s.student_id
)
ORDER BY s.student_id;



SELECT f.faculty_id,
       CONCAT(f.first_name,' ',f.last_name) AS faculty_name,
       f.title
FROM Faculty f
WHERE NOT EXISTS (
    SELECT 1
    FROM Student s
    WHERE s.supervisor_id = f.faculty_id
)
ORDER BY f.faculty_id;



-- Example: equipment_id = 1 (GPU Server)
SELECT DISTINCT rp.project_id,
       rp.project_title,
       e.equipment_name
FROM ResearchProject rp
JOIN EquipmentUsage eu ON rp.project_id = eu.project_id
JOIN Equipment e       ON eu.equipment_id = e.equipment_id
WHERE e.equipment_id = 1
ORDER BY rp.project_id;



SELECT DISTINCT
       m.faculty_id   AS mentor_id,
       CONCAT(m.first_name,' ',m.last_name) AS mentor_name,
       CONCAT(mt.first_name,' ',mt.last_name) AS mentee_name
FROM Faculty m
JOIN Faculty mt ON mt.mentor_id = m.faculty_id
ORDER BY mentor_name, mentee_name;



SELECT f.faculty_id,
       CONCAT(f.first_name,' ',f.last_name) AS faculty_name,
       f.title
FROM Faculty f
WHERE f.mentor_id IS NULL
ORDER BY f.faculty_id;



-- Method A: correlated subquery
SELECT rp.project_id,
       rp.project_title,
       (SELECT SUM(f.funding_amount)
        FROM Funding f
        WHERE f.project_id = rp.project_id) AS total_funding
FROM ResearchProject rp
WHERE (SELECT SUM(f.funding_amount)
       FROM Funding f
       WHERE f.project_id = rp.project_id) = (
           SELECT MAX(proj_total)
           FROM (SELECT SUM(funding_amount) AS proj_total
                 FROM Funding
                 GROUP BY project_id) AS totals
       );

-- Method B: ORDER BY + LIMIT (simpler, MySQL)
SELECT rp.project_id,
       rp.project_title,
       SUM(f.funding_amount) AS total_funding
FROM ResearchProject rp
JOIN Funding f ON rp.project_id = f.project_id
GROUP BY rp.project_id, rp.project_title
ORDER BY total_funding DESC
LIMIT 1;



SELECT f.faculty_id,
       CONCAT(f.first_name,' ',f.last_name) AS author_name,
       COUNT(pa.publication_id) AS num_publications
FROM Faculty f
JOIN PublicationAuthor pa ON f.faculty_id = pa.faculty_id
GROUP BY f.faculty_id, f.first_name, f.last_name
HAVING COUNT(pa.publication_id) = (
    SELECT MAX(pub_count)
    FROM (SELECT COUNT(publication_id) AS pub_count
          FROM PublicationAuthor
          GROUP BY faculty_id) AS counts
)
ORDER BY author_name;



SELECT d.department_id,
       d.department_name,
       COUNT(rp.project_id) AS num_projects
FROM Department d
JOIN ResearchProject rp ON d.department_id = rp.department_id
GROUP BY d.department_id, d.department_name
HAVING COUNT(rp.project_id) = (
    SELECT MAX(proj_count)
    FROM (SELECT COUNT(project_id) AS proj_count
          FROM ResearchProject
          GROUP BY department_id) AS counts
);



SELECT rp.project_id,
       rp.project_title,
       COUNT(sp.student_id) AS num_students,
       ROUND(AVG(sp.contribution_percentage), 2) AS avg_contribution
FROM ResearchProject rp
JOIN StudentProject sp ON rp.project_id = sp.project_id
GROUP BY rp.project_id, rp.project_title
ORDER BY avg_contribution DESC;

