
SHOW GRANTS FOR CURRENT_USER();
CREATE USER IF NOT EXISTS 'dba_admin'@'localhost'         IDENTIFIED BY 'Dba#Str0ng!2024';
CREATE USER IF NOT EXISTS 'research_admin'@'localhost'    IDENTIFIED BY 'Res#Str0ng!2024';
CREATE USER IF NOT EXISTS 'faculty_researcher'@'localhost' IDENTIFIED BY 'Fac#Str0ng!2024';
CREATE USER IF NOT EXISTS 'student_user'@'localhost'      IDENTIFIED BY 'Stu#Str0ng!2024';
CREATE USER IF NOT EXISTS 'auditor_user'@'localhost'      IDENTIFIED BY 'Aud#Str0ng!2024';


DROP ROLE IF EXISTS role_dba;
DROP ROLE IF EXISTS role_research_admin;
DROP ROLE IF EXISTS role_faculty_researcher;
DROP ROLE IF EXISTS role_student;
DROP ROLE IF EXISTS role_auditor;

CREATE ROLE role_dba;
CREATE ROLE role_research_admin;
CREATE ROLE role_faculty_researcher;
CREATE ROLE role_student;
CREATE ROLE role_auditor;


GRANT ALL PRIVILEGES ON research_db.* TO role_dba;
GRANT CREATE USER, DROP USER, CREATE ROLE, DROP ROLE
    ON *.* TO role_dba;
GRANT ROLE_ADMIN ON *.* TO role_dba;
GRANT PROCESS ON *.* TO role_dba;


GRANT SELECT, INSERT, UPDATE, DELETE ON research_db.ResearchProject TO role_research_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON research_db.FacultyProject  TO role_research_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON research_db.StudentProject  TO role_research_admin;

GRANT SELECT, INSERT, UPDATE, DELETE ON research_db.FundingSource TO role_research_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON research_db.Funding       TO role_research_admin;

GRANT SELECT, INSERT, UPDATE, DELETE ON research_db.Conference    TO role_research_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON research_db.Submission    TO role_research_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON research_db.Review        TO role_research_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON research_db.Revision      TO role_research_admin;

GRANT SELECT, INSERT, UPDATE, DELETE ON research_db.Publication       TO role_research_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON research_db.PublicationAuthor TO role_research_admin;

GRANT SELECT, INSERT, UPDATE, DELETE ON research_db.Equipment        TO role_research_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON research_db.EquipmentUsage   TO role_research_admin;

GRANT SELECT ON research_db.vw_StudentResearchProfile TO role_research_admin;

GRANT SELECT ON research_db.vw_FacultyResearchProfile TO role_research_admin;

GRANT SELECT ON research_db.Department TO role_research_admin;
GRANT SELECT ON research_db.Program    TO role_research_admin;

GRANT SELECT ON research_db.vw_ProjectFundingSummary       TO role_research_admin;
GRANT SELECT ON research_db.vw_PublicationAuthorSummary    TO role_research_admin;
GRANT SELECT ON research_db.vw_ConferenceSubmissionStatus  TO role_research_admin;

GRANT EXECUTE ON PROCEDURE research_db.sp_AddResearchProject           TO role_research_admin;
GRANT EXECUTE ON PROCEDURE research_db.sp_RegisterStudentInProject     TO role_research_admin;
GRANT EXECUTE ON PROCEDURE research_db.sp_SubmitPublicationToConference TO role_research_admin;
GRANT EXECUTE ON PROCEDURE research_db.sp_UpdateSubmissionDecision     TO role_research_admin;



GRANT SELECT ON research_db.ResearchProject       TO role_faculty_researcher;
GRANT SELECT ON research_db.FacultyProject        TO role_faculty_researcher;
GRANT SELECT ON research_db.StudentProject        TO role_faculty_researcher;
GRANT SELECT ON research_db.Publication           TO role_faculty_researcher;
GRANT SELECT ON research_db.PublicationAuthor     TO role_faculty_researcher;
GRANT SELECT ON research_db.Conference            TO role_faculty_researcher;
GRANT SELECT ON research_db.Submission            TO role_faculty_researcher;
GRANT SELECT ON research_db.Review                TO role_faculty_researcher;
GRANT SELECT ON research_db.Revision              TO role_faculty_researcher;
GRANT SELECT ON research_db.Equipment             TO role_faculty_researcher;
GRANT SELECT ON research_db.EquipmentUsage        TO role_faculty_researcher;
GRANT SELECT ON research_db.Department            TO role_faculty_researcher;
GRANT SELECT ON research_db.Program               TO role_faculty_researcher;

GRANT SELECT ON research_db.vw_FacultyOwnProfile        TO role_faculty_researcher;
GRANT SELECT ON research_db.vw_FacultyResearchProfile   TO role_faculty_researcher;

GRANT INSERT, UPDATE ON research_db.Publication       TO role_faculty_researcher;
GRANT INSERT, UPDATE ON research_db.PublicationAuthor TO role_faculty_researcher;
GRANT INSERT          ON research_db.Submission       TO role_faculty_researcher;
GRANT INSERT          ON research_db.Review           TO role_faculty_researcher;
GRANT INSERT          ON research_db.Revision         TO role_faculty_researcher;

GRANT SELECT ON research_db.vw_PublicationAuthorSummary    TO role_faculty_researcher;
GRANT SELECT ON research_db.vw_ProjectFundingSummary       TO role_faculty_researcher;

GRANT EXECUTE ON FUNCTION research_db.fn_CalculateTotalProjectFunding TO role_faculty_researcher;
GRANT EXECUTE ON FUNCTION research_db.fn_CountFacultyPublications     TO role_faculty_researcher;
GRANT EXECUTE ON PROCEDURE research_db.sp_GetFacultyPublications       TO role_faculty_researcher;
GRANT EXECUTE ON PROCEDURE research_db.sp_SubmitPublicationToConference TO role_faculty_researcher;



GRANT SELECT ON research_db.vw_StudentOwnProfile TO role_student;
GRANT SELECT ON research_db.vw_StudentOwnProjects       TO role_student;
GRANT SELECT ON research_db.vw_StudentPermittedPubs     TO role_student;

GRANT SELECT ON research_db.ResearchProject   TO role_student;  
GRANT SELECT ON research_db.Publication       TO role_student;
GRANT SELECT ON research_db.PublicationAuthor TO role_student;
GRANT SELECT ON research_db.Conference        TO role_student;
GRANT SELECT ON research_db.Department        TO role_student;
GRANT SELECT ON research_db.Program           TO role_student;


REVOKE SELECT ON research_db.ResearchProject FROM role_student;
GRANT SELECT (project_id, project_title, start_date, end_date, status)
    ON research_db.ResearchProject TO role_student;

REVOKE SELECT ON research_db.Publication FROM role_student;
GRANT SELECT (publication_id, title, publication_type, publication_year, journal_name)
    ON research_db.Publication TO role_student;


GRANT SELECT ON research_db.AuditLog TO role_auditor;
GRANT SELECT ON research_db.Department        TO role_auditor;
GRANT SELECT ON research_db.Program           TO role_auditor;
GRANT SELECT ON research_db.Faculty           TO role_auditor;
GRANT SELECT ON research_db.Student           TO role_auditor;
GRANT SELECT ON research_db.ResearchProject   TO role_auditor;
GRANT SELECT ON research_db.FacultyProject    TO role_auditor;
GRANT SELECT ON research_db.StudentProject    TO role_auditor;
GRANT SELECT ON research_db.FundingSource     TO role_auditor;
GRANT SELECT ON research_db.Funding           TO role_auditor;
GRANT SELECT ON research_db.Publication       TO role_auditor;
GRANT SELECT ON research_db.PublicationAuthor TO role_auditor;
GRANT SELECT ON research_db.Conference        TO role_auditor;
GRANT SELECT ON research_db.Submission        TO role_auditor;
GRANT SELECT ON research_db.Review            TO role_auditor;
GRANT SELECT ON research_db.Revision          TO role_auditor;
GRANT SELECT ON research_db.Equipment         TO role_auditor;
GRANT SELECT ON research_db.EquipmentUsage    TO role_auditor;

GRANT SELECT ON research_db.vw_StudentResearchProfile      TO role_auditor;
GRANT SELECT ON research_db.vw_FacultyResearchProfile      TO role_auditor;
GRANT SELECT ON research_db.vw_ProjectFundingSummary       TO role_auditor;
GRANT SELECT ON research_db.vw_PublicationAuthorSummary    TO role_auditor;
GRANT SELECT ON research_db.vw_ConferenceSubmissionStatus  TO role_auditor;
GRANT SELECT ON research_db.vw_FacultyOwnProfile           TO role_auditor;


GRANT role_dba                TO 'dba_admin'@'localhost';
GRANT role_research_admin     TO 'research_admin'@'localhost';
GRANT role_faculty_researcher TO 'faculty_researcher'@'localhost';
GRANT role_student            TO 'student_user'@'localhost';
GRANT role_auditor            TO 'auditor_user'@'localhost';

SET DEFAULT ROLE ALL TO 'dba_admin'@'localhost';
SET DEFAULT ROLE ALL TO 'research_admin'@'localhost';
SET DEFAULT ROLE ALL TO 'faculty_researcher'@'localhost';
SET DEFAULT ROLE ALL TO 'student_user'@'localhost';
SET DEFAULT ROLE ALL TO 'auditor_user'@'localhost';


REVOKE SELECT ON research_db.Student FROM role_research_admin;
REVOKE SELECT ON research_db.Faculty FROM role_research_admin;
REVOKE DELETE ON research_db.Publication FROM role_faculty_researcher;
REVOKE UPDATE ON research_db.Student FROM role_student;
REVOKE INSERT ON research_db.AuditLog FROM role_auditor;
REVOKE ALL PRIVILEGES, GRANT OPTION FROM role_research_admin;


USE research_db;
SELECT COUNT(*) FROM Student;                      
CREATE TABLE test_ddl (id INT);         
DROP TABLE test_ddl;                           

SET ROLE role_research_admin;
SELECT COUNT(*) FROM ResearchProject;              
INSERT INTO Funding (funding_id, project_id, source_id, funding_amount, funding_date)
       VALUES (900, 1, 1, 1000.00, CURDATE());      
SELECT * FROM vw_StudentResearchProfile;            
SELECT * FROM vw_FacultyResearchProfile;            
SET ROLE role_faculty_researcher;
SELECT * FROM ResearchProject;                     
SELECT * FROM Publication;                          
SELECT * FROM vw_FacultyOwnProfile;                 
INSERT INTO Publication (publication_id, title, publication_type, publication_year)
       VALUES (999, 'New Paper', 'Journal', 2024); 

SET ROLE role_student;
SELECT * FROM vw_StudentOwnProfile;           
SELECT * FROM vw_StudentOwnProjects;         
SELECT * FROM vw_StudentPermittedPubs;          
SELECT title FROM Publication;                 

SET ROLE role_auditor;
SELECT * FROM AuditLog;                        
SELECT * FROM ResearchProject;        
SELECT * FROM Funding;               


SHOW GRANTS FOR role_dba;
SHOW GRANTS FOR role_research_admin;
SHOW GRANTS FOR role_faculty_researcher;
SHOW GRANTS FOR role_student;
SHOW GRANTS FOR role_auditor;

SELECT * FROM mysql.role_edges;
SELECT * FROM mysql.default_roles;

SELECT CURRENT_ROLE();


