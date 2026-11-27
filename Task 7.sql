
DELIMITER $$
CREATE TRIGGER trg_studentproject_contrib_limit_insert
BEFORE INSERT ON StudentProject FOR EACH ROW
BEGIN
    DECLARE v_current_total DECIMAL(10,2);
    SELECT COALESCE(SUM(contribution_percentage),0) INTO v_current_total
    FROM StudentProject WHERE student_id = NEW.student_id;
    IF v_current_total + NEW.contribution_percentage > 100 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Total contribution for this student would exceed 100%.';
    END IF;
END$$

CREATE TRIGGER trg_studentproject_contrib_limit_update
BEFORE UPDATE ON StudentProject FOR EACH ROW
BEGIN
    DECLARE v_other_total DECIMAL(10,2);
    SELECT COALESCE(SUM(contribution_percentage),0) INTO v_other_total
    FROM StudentProject
    WHERE student_id = NEW.student_id
      AND NOT (student_id = OLD.student_id AND project_id = OLD.project_id);
    IF v_other_total + NEW.contribution_percentage > 100 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Total contribution for this student would exceed 100%.';
    END IF;
END$$


CREATE TRIGGER trg_student_valid_supervisor_insert
BEFORE INSERT ON Student FOR EACH ROW
BEGIN
    DECLARE v_exists INT DEFAULT 0;
    DECLARE v_fac_dept INT;
    DECLARE v_fac_title VARCHAR(50);
    DECLARE v_stu_dept INT;
    IF NEW.supervisor_id IS NOT NULL THEN
        SELECT COUNT(*), MAX(department_id), MAX(title)
          INTO v_exists, v_fac_dept, v_fac_title
        FROM Faculty WHERE faculty_id = NEW.supervisor_id;
        IF v_exists = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Supervisor does not exist in Faculty.';
        END IF;
        SELECT department_id INTO v_stu_dept FROM Program WHERE program_id = NEW.program_id;
        IF v_fac_dept <> v_stu_dept THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Supervisor must belong to the same department as the student''s program.';
        END IF;
        IF v_fac_title NOT IN ('Professor','Associate Professor','Assistant Professor') THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Only Professor/Associate/Assistant Professor may supervise.';
        END IF;
    END IF;
END$$


CREATE TRIGGER trg_student_valid_supervisor_update
BEFORE UPDATE ON Student FOR EACH ROW
BEGIN
    DECLARE v_exists INT DEFAULT 0;
    DECLARE v_fac_dept INT;
    DECLARE v_fac_title VARCHAR(50);
    DECLARE v_stu_dept INT;
    IF NEW.supervisor_id IS NOT NULL THEN
        SELECT COUNT(*), MAX(department_id), MAX(title)
          INTO v_exists, v_fac_dept, v_fac_title
        FROM Faculty WHERE faculty_id = NEW.supervisor_id;
        IF v_exists = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Supervisor does not exist in Faculty.';
        END IF;
        SELECT department_id INTO v_stu_dept FROM Program WHERE program_id = NEW.program_id;
        IF v_fac_dept <> v_stu_dept THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Supervisor must belong to the same department as the student''s program.';
        END IF;
        IF v_fac_title NOT IN ('Professor','Associate Professor','Assistant Professor') THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Only Professor/Associate/Assistant Professor may supervise.';
        END IF;
    END IF;
END$$


CREATE TRIGGER trg_funding_no_negative_insert
BEFORE INSERT ON Funding FOR EACH ROW
BEGIN
    IF NEW.funding_amount < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Funding amount cannot be negative.';
    END IF;
    IF NEW.funding_date > CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Funding date cannot be in the future.';
    END IF;
END$$

CREATE TRIGGER trg_funding_no_negative_update
BEFORE UPDATE ON Funding FOR EACH ROW
BEGIN
    IF NEW.funding_amount < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Funding amount cannot be negative.';
    END IF;
    IF NEW.funding_date > CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Funding date cannot be in the future.';
    END IF;
END$$


CREATE TRIGGER trg_project_audit_insert AFTER INSERT ON ResearchProject FOR EACH ROW
BEGIN
    INSERT INTO AuditLog (operation, table_name, record_pk, old_value, new_value)
    VALUES ('INSERT','ResearchProject',CAST(NEW.project_id AS CHAR),NULL,
            CONCAT('title=',NEW.project_title,'; status=',NEW.status,
                   '; start=',NEW.start_date,'; end=',COALESCE(NEW.end_date,'NULL'),
                   '; dept=',NEW.department_id,'; lead=',COALESCE(NEW.lead_faculty_id,'NULL')));
END$$

CREATE TRIGGER trg_project_audit_update AFTER UPDATE ON ResearchProject FOR EACH ROW
BEGIN
    INSERT INTO AuditLog (operation, table_name, record_pk, old_value, new_value)
    VALUES ('UPDATE','ResearchProject',CAST(NEW.project_id AS CHAR),
            CONCAT('title=',OLD.project_title,'; status=',OLD.status,
                   '; start=',OLD.start_date,'; end=',COALESCE(OLD.end_date,'NULL'),
                   '; dept=',OLD.department_id,'; lead=',COALESCE(OLD.lead_faculty_id,'NULL')),
            CONCAT('title=',NEW.project_title,'; status=',NEW.status,
                   '; start=',NEW.start_date,'; end=',COALESCE(NEW.end_date,'NULL'),
                   '; dept=',NEW.department_id,'; lead=',COALESCE(NEW.lead_faculty_id,'NULL')));
END$$

CREATE TRIGGER trg_project_audit_delete AFTER DELETE ON ResearchProject FOR EACH ROW
BEGIN
    INSERT INTO AuditLog (operation, table_name, record_pk, old_value, new_value)
    VALUES ('DELETE','ResearchProject',CAST(OLD.project_id AS CHAR),
            CONCAT('title=',OLD.project_title,'; status=',OLD.status,
                   '; start=',OLD.start_date,'; end=',COALESCE(OLD.end_date,'NULL'),
                   '; dept=',OLD.department_id,'; lead=',COALESCE(OLD.lead_faculty_id,'NULL')),NULL);
END$$

CREATE TRIGGER trg_faculty_prevent_delete_if_supervising
BEFORE DELETE ON Faculty FOR EACH ROW
BEGIN
    DECLARE v_students INT DEFAULT 0;
    DECLARE v_projects INT DEFAULT 0;
    DECLARE v_lead     INT DEFAULT 0;
    SELECT COUNT(*) INTO v_students FROM Student        WHERE supervisor_id  = OLD.faculty_id;
    SELECT COUNT(*) INTO v_projects FROM FacultyProject WHERE faculty_id     = OLD.faculty_id;
    SELECT COUNT(*) INTO v_lead     FROM ResearchProject WHERE lead_faculty_id = OLD.faculty_id;
    IF v_students > 0 OR v_projects > 0 OR v_lead > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot delete faculty: still assigned as supervisor/lead. Reassign first.';
    END IF;
END$$

CREATE TRIGGER trg_publication_audit_insert AFTER INSERT ON Publication FOR EACH ROW
BEGIN
    INSERT INTO AuditLog (operation, table_name, record_pk, old_value, new_value)
    VALUES ('INSERT','Publication',CAST(NEW.publication_id AS CHAR),NULL,
            CONCAT('title=',NEW.title,'; type=',NEW.publication_type,
                   '; year=',NEW.publication_year,'; doi=',COALESCE(NEW.doi,'NULL'),
                   '; journal=',COALESCE(NEW.journal_name,'NULL')));
END$$

CREATE TRIGGER trg_publication_audit_update AFTER UPDATE ON Publication FOR EACH ROW
BEGIN
    INSERT INTO AuditLog (operation, table_name, record_pk, old_value, new_value)
    VALUES ('UPDATE','Publication',CAST(NEW.publication_id AS CHAR),
            CONCAT('title=',OLD.title,'; type=',OLD.publication_type,
                   '; year=',OLD.publication_year,'; doi=',COALESCE(OLD.doi,'NULL'),
                   '; journal=',COALESCE(OLD.journal_name,'NULL')),
            CONCAT('title=',NEW.title,'; type=',NEW.publication_type,
                   '; year=',NEW.publication_year,'; doi=',COALESCE(NEW.doi,'NULL'),
                   '; journal=',COALESCE(NEW.journal_name,'NULL')));
END$$

CREATE TRIGGER trg_publication_audit_delete AFTER DELETE ON Publication FOR EACH ROW
BEGIN
    INSERT INTO AuditLog (operation, table_name, record_pk, old_value, new_value)
    VALUES ('DELETE','Publication',CAST(OLD.publication_id AS CHAR),
            CONCAT('title=',OLD.title,'; type=',OLD.publication_type,
                   '; year=',OLD.publication_year,'; doi=',COALESCE(OLD.doi,'NULL'),
                   '; journal=',COALESCE(OLD.journal_name,'NULL')),NULL);
END$$
DELIMITER ;



INSERT INTO StudentProject (student_id, project_id, project_role, contribution_percentage)
VALUES (1, 11, 'Researcher', 50);

UPDATE ResearchProject SET status = 'Completed' WHERE project_id = 2;
SELECT * FROM AuditLog WHERE table_name = 'ResearchProject' ORDER BY audit_id DESC LIMIT 1;

UPDATE Publication SET journal_name = 'New Journal' WHERE publication_id = 1;
SELECT * FROM AuditLog WHERE table_name = 'Publication' ORDER BY audit_id DESC LIMIT 1;
