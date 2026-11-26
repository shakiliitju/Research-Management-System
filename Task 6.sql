
DELIMITER $$
CREATE PROCEDURE sp_AddResearchProject (
    IN  p_project_id       INT,
    IN  p_project_title    VARCHAR(200),
    IN  p_start_date       DATE,
    IN  p_end_date         DATE,
    IN  p_status           VARCHAR(20),
    IN  p_department_id    INT,
    IN  p_lead_faculty_id  INT,
    OUT p_result_message   VARCHAR(255)
)
proc_body: BEGIN
    DECLARE v_dept_exists     INT DEFAULT 0;
    DECLARE v_faculty_exists  INT DEFAULT 0;
    DECLARE v_faculty_dept    INT DEFAULT NULL;

    IF p_project_id IS NULL OR p_project_id <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'project_id must be a positive integer.';
    END IF;

    IF p_project_title IS NULL OR TRIM(p_project_title) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'project_title cannot be empty.';
    END IF;

    IF p_start_date IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'start_date is required.';
    END IF;

    IF p_end_date IS NOT NULL AND p_end_date < p_start_date THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'end_date cannot be earlier than start_date.';
    END IF;

    IF p_status NOT IN ('Proposed','Active','Completed','Cancelled') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'status must be Proposed, Active, Completed, or Cancelled.';
    END IF;

    SELECT COUNT(*) INTO v_dept_exists
    FROM Department WHERE department_id = p_department_id;

    IF v_dept_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Department does not exist.';
    END IF;

    IF p_lead_faculty_id IS NOT NULL THEN
        SELECT COUNT(*), MAX(department_id)
          INTO v_faculty_exists, v_faculty_dept
        FROM Faculty WHERE faculty_id = p_lead_faculty_id;

        IF v_faculty_exists = 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Lead faculty does not exist.';
        END IF;

        IF v_faculty_dept <> p_department_id THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Lead faculty must belong to the project department.';
        END IF;
    END IF;

    IF EXISTS (SELECT 1 FROM ResearchProject WHERE project_id = p_project_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A project with this project_id already exists.';
    END IF;

    INSERT INTO ResearchProject
        (project_id, project_title, start_date, end_date,
         status, department_id, lead_faculty_id)
    VALUES
        (p_project_id, p_project_title, p_start_date, p_end_date,
         p_status, p_department_id, p_lead_faculty_id);

    INSERT INTO AuditLog (operation, table_name, record_pk, old_value, new_value)
    VALUES ('INSERT', 'ResearchProject', CAST(p_project_id AS CHAR),
            NULL, CONCAT('title=', p_project_title, '; status=', p_status));

    SET p_result_message = CONCAT('Project ', p_project_id, ' created successfully.');

END$$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE sp_RegisterStudentInProject (
    IN  p_student_id       INT,
    IN  p_project_id       INT,
    IN  p_project_role     VARCHAR(50),
    IN  p_contribution_pct DECIMAL(5,2),
    OUT p_result_message   VARCHAR(255)
)
proc_body: BEGIN
    DECLARE v_student_exists  INT DEFAULT 0;
    DECLARE v_project_exists  INT DEFAULT 0;
    DECLARE v_already_reg     INT DEFAULT 0;
    DECLARE v_current_total   DECIMAL(10,2) DEFAULT 0;

    IF p_student_id IS NULL OR p_project_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'student_id and project_id are required.';
    END IF;

    IF p_contribution_pct IS NULL
       OR p_contribution_pct < 0
       OR p_contribution_pct > 100 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'contribution_percentage must be between 0 and 100.';
    END IF;

    IF p_project_role NOT IN ('Researcher','Assistant','Lead Student','Intern','Volunteer') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid project_role.';
    END IF;

    SELECT COUNT(*) INTO v_student_exists
    FROM Student WHERE student_id = p_student_id;
    IF v_student_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Student does not exist.';
    END IF;

    SELECT COUNT(*) INTO v_project_exists
    FROM ResearchProject WHERE project_id = p_project_id;
    IF v_project_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Project does not exist.';
    END IF;

    SELECT COUNT(*) INTO v_already_reg
    FROM StudentProject
    WHERE student_id = p_student_id AND project_id = p_project_id;
    IF v_already_reg > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Student is already registered in this project.';
    END IF;

    SELECT COALESCE(SUM(contribution_percentage), 0)
      INTO v_current_total
    FROM StudentProject
    WHERE student_id = p_student_id;

    IF v_current_total + p_contribution_pct > 100 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Total contribution for this student would exceed 100%.';
    END IF;

    INSERT INTO StudentProject
        (student_id, project_id, project_role, contribution_percentage, join_date)
    VALUES
        (p_student_id, p_project_id, p_project_role, p_contribution_pct, CURDATE());

    INSERT INTO AuditLog (operation, table_name, record_pk, old_value, new_value)
    VALUES ('INSERT', 'StudentProject',
            CONCAT(p_student_id,'-',p_project_id),
            NULL,
            CONCAT('role=', p_project_role, '; pct=', p_contribution_pct));

    SET p_result_message = CONCAT('Student ', p_student_id,
                                  ' registered in project ', p_project_id, '.');

END$$
DELIMITER ;




DELIMITER $$

CREATE PROCEDURE sp_SubmitPublicationToConference (
    IN  p_publication_id INT,
    IN  p_conference_id  INT,
    IN  p_submission_date DATE,
    OUT p_result_message VARCHAR(255)
)
proc_body: BEGIN
    DECLARE v_pub_exists       INT DEFAULT 0;
    DECLARE v_conf_exists      INT DEFAULT 0;
    DECLARE v_deadline         DATE DEFAULT NULL;
    DECLARE v_duplicate        INT DEFAULT 0;
    DECLARE v_new_sub_id       INT DEFAULT 0;

    IF p_publication_id IS NULL OR p_conference_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'publication_id and conference_id are required.';
    END IF;

    IF p_submission_date IS NULL THEN
        SET p_submission_date = CURDATE();
    END IF;

    IF p_submission_date > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'submission_date cannot be in the future.';
    END IF;

    SELECT COUNT(*) INTO v_pub_exists
    FROM Publication WHERE publication_id = p_publication_id;
    IF v_pub_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Publication does not exist.';
    END IF;

    SELECT COUNT(*), MAX(submission_deadline)
      INTO v_conf_exists, v_deadline
    FROM Conference WHERE conference_id = p_conference_id;
    IF v_conf_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Conference does not exist.';
    END IF;

    IF v_deadline IS NOT NULL AND p_submission_date > v_deadline THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Submission date is after the conference deadline.';
    END IF;

    SELECT COUNT(*) INTO v_duplicate
    FROM Submission
    WHERE publication_id = p_publication_id
      AND conference_id  = p_conference_id;
    IF v_duplicate > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'This publication is already submitted to this conference.';
    END IF;

    SELECT COALESCE(MAX(submission_id), 0) + 1 INTO v_new_sub_id FROM Submission;

    INSERT INTO Submission
        (submission_id, publication_id, conference_id,
         submission_date, decision, decision_date)
    VALUES
        (v_new_sub_id, p_publication_id, p_conference_id,
         p_submission_date, 'Pending', NULL);

    INSERT INTO AuditLog (operation, table_name, record_pk, old_value, new_value)
    VALUES ('INSERT', 'Submission', CAST(v_new_sub_id AS CHAR), NULL,
            CONCAT('pub=', p_publication_id, '; conf=', p_conference_id));

    SET p_result_message = CONCAT('Submission ', v_new_sub_id, ' created with Pending status.');

END$$
DELIMITER ;



DELIMITER $$
CREATE FUNCTION fn_CalculateTotalProjectFunding (p_project_id INT)
RETURNS DECIMAL(14,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total   DECIMAL(14,2) DEFAULT 0;
    DECLARE v_exists  INT DEFAULT 0;

    IF p_project_id IS NULL OR p_project_id <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'fn_CalculateTotalProjectFunding: project_id must be positive.';
    END IF;

    SELECT COUNT(*) INTO v_exists
    FROM ResearchProject WHERE project_id = p_project_id;

    IF v_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'fn_CalculateTotalProjectFunding: project does not exist.';
    END IF;

    SELECT COALESCE(SUM(funding_amount), 0) INTO v_total
    FROM Funding WHERE project_id = p_project_id;

    RETURN v_total;
END$$
DELIMITER ;




DELIMITER $$
CREATE FUNCTION fn_CountFacultyPublications (p_faculty_id INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_count  INT DEFAULT 0;
    DECLARE v_exists INT DEFAULT 0;

    IF p_faculty_id IS NULL OR p_faculty_id <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'fn_CountFacultyPublications: faculty_id must be positive.';
    END IF;

    SELECT COUNT(*) INTO v_exists FROM Faculty WHERE faculty_id = p_faculty_id;
    IF v_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'fn_CountFacultyPublications: faculty does not exist.';
    END IF;

    SELECT COUNT(*) INTO v_count
    FROM PublicationAuthor WHERE faculty_id = p_faculty_id;

    RETURN v_count;
END$$
DELIMITER ;



DELIMITER $$
CREATE FUNCTION fn_TotalStudentContribution (p_student_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total  DECIMAL(10,2) DEFAULT 0;
    DECLARE v_exists INT DEFAULT 0;

    IF p_student_id IS NULL OR p_student_id <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'fn_TotalStudentContribution: student_id must be positive.';
    END IF;

    SELECT COUNT(*) INTO v_exists FROM Student WHERE student_id = p_student_id;
    IF v_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'fn_TotalStudentContribution: student does not exist.';
    END IF;

    SELECT COALESCE(SUM(contribution_percentage), 0) INTO v_total
    FROM StudentProject WHERE student_id = p_student_id;

    RETURN v_total;
END$$
DELIMITER ;



CALL sp_AddResearchProject(
    101, 'Test Project', '2024-01-01', '2025-12-31',
    'Active', 1, 1, @msg);
SELECT @msg AS procedure_1_result;


CALL sp_RegisterStudentInProject(28, 1, 'Researcher', 10, @msg);
SELECT @msg AS procedure_2_result;


CALL sp_SubmitPublicationToConference(7, 3, '2023-06-01', @msg);
SELECT @msg AS procedure_3_result;


SELECT fn_CalculateTotalProjectFunding(1)  AS funding_project_1;
SELECT fn_CalculateTotalProjectFunding(6)  AS funding_project_6;
SELECT fn_CalculateTotalProjectFunding(12) AS funding_project_12;

SELECT fn_CountFacultyPublications(1)      AS pubs_faculty_1;
SELECT fn_CountFacultyPublications(2)      AS pubs_faculty_2;

SELECT fn_TotalStudentContribution(1)      AS contrib_student_1;
SELECT fn_TotalStudentContribution(9)      AS contrib_student_9; 
