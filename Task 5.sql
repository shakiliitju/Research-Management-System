-- =========================================================
-- Task 5: Database Views
-- Run after Task 3 (data loaded)
-- =========================================================

-- ---------- View 1 ----------
CREATE OR REPLACE VIEW vw_StudentResearchProfile AS
SELECT
    s.student_id,
    CONCAT(s.first_name, ' ', s.last_name)        AS student_name,
    s.email,
    p.program_name,
    p.degree_level,
    d.department_name,
    CONCAT(f.first_name, ' ', f.last_name)        AS supervisor_name,
    f.title                                       AS supervisor_title,
    COUNT(DISTINCT sp.project_id)                 AS num_projects,
    COALESCE(SUM(sp.contribution_percentage), 0)  AS total_contribution,
    GROUP_CONCAT(DISTINCT rp.project_title
                 ORDER BY rp.project_title
                 SEPARATOR '; ')                  AS project_titles
FROM Student s
JOIN Program p        ON s.program_id    = p.program_id
JOIN Department d     ON p.department_id = d.department_id
LEFT JOIN Faculty f   ON s.supervisor_id = f.faculty_id
LEFT JOIN StudentProject sp ON s.student_id = sp.student_id
LEFT JOIN ResearchProject rp ON sp.project_id = rp.project_id
GROUP BY s.student_id, s.first_name, s.last_name, s.email,
         p.program_name, p.degree_level, d.department_name,
         f.first_name, f.last_name, f.title;

-- ---------- View 2 ----------
CREATE OR REPLACE VIEW vw_FacultyResearchProfile AS
SELECT
    f.faculty_id,
    CONCAT(f.first_name, ' ', f.last_name)  AS faculty_name,
    f.title,
    f.email,
    d.department_name,
    (SELECT COUNT(*) FROM Student s
     WHERE s.supervisor_id = f.faculty_id)   AS num_supervised_students,
    (SELECT COUNT(*) FROM FacultyProject fp
     WHERE fp.faculty_id = f.faculty_id)     AS num_projects,
    (SELECT COUNT(*) FROM PublicationAuthor pa
     WHERE pa.faculty_id = f.faculty_id)     AS num_publications,
    (SELECT COUNT(*) FROM PublicationAuthor pa
     WHERE pa.faculty_id = f.faculty_id
       AND pa.is_corresponding = TRUE)       AS num_corresponding_pubs,
    (SELECT COALESCE(SUM(fu.funding_amount), 0)
     FROM Funding fu
     JOIN FacultyProject fp ON fu.project_id = fp.project_id
     WHERE fp.faculty_id = f.faculty_id)     AS total_funding_attributed,
    CONCAT(m.first_name, ' ', m.last_name)   AS mentor_name
FROM Faculty f
JOIN Department d   ON f.department_id = d.department_id
LEFT JOIN Faculty m ON f.mentor_id = m.faculty_id;

-- ---------- View 3 ----------
CREATE OR REPLACE VIEW vw_ProjectFundingSummary AS
SELECT
    rp.project_id,
    rp.project_title,
    rp.status,
    d.department_name,
    CONCAT(f.first_name, ' ', f.last_name)   AS lead_faculty,
    COUNT(DISTINCT fu.funding_id)             AS num_funding_records,
    COUNT(DISTINCT fu.source_id)              AS num_funding_sources,
    COALESCE(SUM(fu.funding_amount), 0)       AS total_funding,
    MIN(fu.funding_date)                      AS first_funding_date,
    MAX(fu.funding_date)                      AS last_funding_date
FROM ResearchProject rp
JOIN Department d          ON rp.department_id = d.department_id
LEFT JOIN Faculty f        ON rp.lead_faculty_id = f.faculty_id
LEFT JOIN Funding fu       ON rp.project_id = fu.project_id
GROUP BY rp.project_id, rp.project_title, rp.status,
         d.department_name, f.first_name, f.last_name;

-- ---------- View 4 ----------
CREATE OR REPLACE VIEW vw_PublicationAuthorSummary AS
SELECT
    p.publication_id,
    p.title,
    p.publication_type,
    p.publication_year,
    p.journal_name,
    GROUP_CONCAT(
        CONCAT(f.first_name, ' ', f.last_name,
               CASE WHEN pa.is_corresponding THEN ' (*)' ELSE '' END)
        ORDER BY pa.author_order
        SEPARATOR ', '
    )                                          AS author_list,
    MAX(CASE WHEN pa.is_corresponding
             THEN CONCAT(f.first_name,' ',f.last_name) END) AS corresponding_author,
    COUNT(pa.faculty_id)                       AS num_authors
FROM Publication p
JOIN PublicationAuthor pa ON p.publication_id = pa.publication_id
JOIN Faculty f            ON pa.faculty_id = f.faculty_id
GROUP BY p.publication_id, p.title, p.publication_type,
         p.publication_year, p.journal_name;

-- ---------- View 5 ----------
CREATE OR REPLACE VIEW vw_StudentOwnProfile AS
SELECT
    s.student_id,
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    s.email,
    s.enrollment_date,
    s.academic_status,
    p.program_name,
    p.degree_level,
    d.department_name,
    CONCAT(f.first_name, ' ', f.last_name) AS supervisor_name
FROM Student s
JOIN Program p      ON s.program_id = p.program_id
JOIN Department d   ON p.department_id = d.department_id
LEFT JOIN Faculty f ON s.supervisor_id = f.faculty_id
WHERE s.student_id = CAST(
        SUBSTRING_INDEX(CURRENT_USER(), 'stu_', -1) AS UNSIGNED
      );

-- ---------- View 6 ----------
CREATE OR REPLACE VIEW vw_FacultyOwnProfile AS
SELECT
    f.faculty_id,
    CONCAT(f.first_name, ' ', f.last_name) AS faculty_name,
    f.title,
    f.email,
    d.department_name,
    (SELECT COUNT(*) FROM FacultyProject fp
     WHERE fp.faculty_id = f.faculty_id)    AS num_projects,
    (SELECT COUNT(*) FROM PublicationAuthor pa
     WHERE pa.faculty_id = f.faculty_id)    AS num_publications,
    (SELECT COUNT(*) FROM Student s
     WHERE s.supervisor_id = f.faculty_id)  AS num_supervised_students,
    CONCAT(m.first_name, ' ', m.last_name)  AS mentor_name
FROM Faculty f
JOIN Department d   ON f.department_id = d.department_id
LEFT JOIN Faculty m ON f.mentor_id = m.faculty_id
WHERE f.faculty_id = CAST(
        SUBSTRING_INDEX(CURRENT_USER(), 'fac_', -1) AS UNSIGNED
      );

-- ---------- View 7 ----------
CREATE OR REPLACE VIEW vw_ConferenceSubmissionStatus AS
SELECT
    c.conference_id,
    c.conference_name,
    c.location,
    c.conference_date,
    COUNT(s.submission_id)                                        AS total_submissions,
    SUM(CASE WHEN s.decision = 'Accepted' THEN 1 ELSE 0 END)      AS accepted,
    SUM(CASE WHEN s.decision = 'Rejected' THEN 1 ELSE 0 END)      AS rejected,
    SUM(CASE WHEN s.decision = 'Revision' THEN 1 ELSE 0 END)      AS under_revision,
    SUM(CASE WHEN s.decision = 'Pending'  THEN 1 ELSE 0 END)      AS pending,
    ROUND(
        100.0 * SUM(CASE WHEN s.decision = 'Accepted' THEN 1 ELSE 0 END)
        / NULLIF(COUNT(s.submission_id), 0), 2
    )                                                             AS acceptance_rate_pct
FROM Conference c
LEFT JOIN Submission s ON c.conference_id = s.conference_id
GROUP BY c.conference_id, c.conference_name, c.location, c.conference_date;

-- ---------- Verification ----------
SELECT 'Views created' AS status;
SHOW FULL TABLES WHERE Table_type = 'VIEW';

-- Sample outputs
SELECT * FROM vw_ProjectFundingSummary ORDER BY total_funding DESC LIMIT 5;
SELECT * FROM vw_ConferenceSubmissionStatus ORDER BY total_submissions DESC;
SELECT * FROM vw_PublicationAuthorSummary ORDER BY num_authors DESC LIMIT 5;
SELECT * FROM vw_FacultyResearchProfile ORDER BY num_publications DESC LIMIT 5;
SELECT * FROM vw_StudentResearchProfile ORDER BY num_projects DESC LIMIT 5;