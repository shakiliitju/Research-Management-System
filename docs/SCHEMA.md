# Schema reference

MySQL 8.0.16+, `InnoDB`, UTF-8. 18 tables. Every table uses a surrogate integer primary key except the three junction tables and the audit log.

## Organisation

### `Department`
| Column | Type | Notes |
|---|---|---|
| `department_id` | INT PK | |
| `department_name` | VARCHAR(100) | NOT NULL, UNIQUE |
| `building`, `phone` | VARCHAR | nullable |
| `head_faculty_id` | INT FK → `Faculty(faculty_id)` | nullable; `ON DELETE SET NULL`. Circular FK added via `ALTER TABLE` because Faculty references Department. |

### `Program`
| Column | Type | Notes |
|---|---|---|
| `program_id` | INT PK | |
| `program_name` | VARCHAR(100) | NOT NULL |
| `degree_level` | VARCHAR(20) | `Bachelor`, `Master`, `PhD`, `Diploma` |
| `department_id` | INT FK → `Department` | `RESTRICT / CASCADE` |

### `Faculty`
Recursive mentoring: `mentor_id` → `Faculty(faculty_id)`, `ON DELETE SET NULL`. A trigger blocks self-mentoring.

| Column | Type | Notes |
|---|---|---|
| `faculty_id` | INT PK | |
| `first_name`, `last_name` | VARCHAR(50) | NOT NULL |
| `email` | VARCHAR(120) | NOT NULL, UNIQUE, must contain `@` |
| `phone` | VARCHAR(20) | nullable |
| `hire_date` | DATE | default `CURRENT_DATE` |
| `title` | VARCHAR(50) | Professor / Associate Professor / Assistant Professor / Lecturer / Researcher |
| `salary` | DECIMAL(12,2) | nullable, ≥ 0 |
| `department_id` | INT FK → `Department` | RESTRICT / CASCADE |
| `mentor_id` | INT FK → `Faculty` | nullable, SET NULL / CASCADE |

### `Student`
| Column | Type | Notes |
|---|---|---|
| `student_id` | INT PK | |
| `first_name`, `last_name` | VARCHAR(50) | NOT NULL |
| `email` | VARCHAR(120) | NOT NULL, UNIQUE, contains `@` |
| `phone`, `date_of_birth` | | nullable |
| `enrollment_date` | DATE | default `CURRENT_DATE` |
| `academic_status` | VARCHAR(20) | `Active` (default), `Suspended`, `Graduated`, `Withdrawn` |
| `program_id` | INT FK → `Program` | RESTRICT / CASCADE |
| `supervisor_id` | INT FK → `Faculty` | nullable, SET NULL / CASCADE; triggers require an existing faculty member |

## Projects

### `ResearchProject`
| Column | Type | Notes |
|---|---|---|
| `project_id` | INT PK | |
| `project_title` | VARCHAR(200) | NOT NULL |
| `start_date`, `end_date` | DATE | start defaults today; `end_date >= start_date` |
| `status` | VARCHAR(20) | `Proposed`, `Active` (default), `Completed`, `Cancelled` |
| `department_id` | INT FK → `Department` | RESTRICT / CASCADE |
| `lead_faculty_id` | INT FK → `Faculty` | nullable, SET NULL / CASCADE |

### `FacultyProject` (junction)
PK `(faculty_id, project_id)`. `supervision_role` ∈ `Principal Investigator`, `Co-Investigator` (default), `Supervisor`, `Advisor`, `Consultant`. Both FKs `CASCADE / CASCADE`.

### `StudentProject` (junction)
PK `(student_id, project_id)`. `project_role` ∈ `Researcher` (default), `Assistant`, `Lead Student`, `Intern`, `Volunteer`. `contribution_percentage` DECIMAL(5,2) between 0 and 100 (also trigger-enforced). `join_date` defaults today. Both FKs cascade.

## Funding

### `FundingSource`
`source_id` PK, `source_name` UNIQUE, `source_type` ∈ `Government`, `Industry`, `University`, `Non-Profit`, `International` (nullable), `contact_email`, `country`.

### `Funding`
| Column | Notes |
|---|---|
| `funding_id` PK | |
| `project_id` FK → `ResearchProject` | CASCADE / CASCADE |
| `source_id` FK → `FundingSource` | RESTRICT / CASCADE |
| `funding_amount` DECIMAL(14,2) | NOT NULL, ≥ 0 (also trigger-enforced) |
| `funding_date` DATE | default today; triggers reject future dates |

## Publications

### `Publication`
`publication_id` PK, `title` VARCHAR(300), `publication_type` ∈ `Journal`, `Conference`, `Book Chapter`, `Workshop`, `publication_year` between 1900 and 2100, `doi` UNIQUE, `journal_name`.

### `PublicationAuthor` (junction)
PK `(publication_id, faculty_id)`. `author_order` > 0 and UNIQUE per publication. `is_corresponding` BOOLEAN default FALSE. Both FKs cascade.

### `Conference`
`conference_id` PK, `conference_name`, `location`, `conference_date` NOT NULL, `submission_deadline` ≤ `conference_date`.

### `Submission`
`submission_id` PK; `publication_id` and `conference_id` FKs (composite UNIQUE, both cascade); `submission_date` default today; `decision` ∈ `Pending` (default), `Accepted`, `Rejected`, `Revision`; `decision_date`.

### `Review`
`review_id` PK; `submission_id` FK cascade; `reviewer_faculty_id` FK SET NULL; `reviewer_name` (free text for external reviewers); `review_score` DECIMAL(4,2) between 0 and 10; `review_comments`; `review_date`. A trigger requires a reviewer identity (faculty ID or name).

### `Revision`
`revision_id` PK; `submission_id` FK cascade; `revision_number` > 0 and UNIQUE per submission; `revision_date`; `revision_notes`.

## Resources & audit

### `Equipment`
`equipment_id` PK, `equipment_name`, `serial_number` UNIQUE, `purchase_date`, `condition_status` ∈ `Good` (default), `Fair`, `Poor`, `Out of Service`, `department_id` FK RESTRICT / CASCADE.

### `EquipmentUsage` (junction with date)
PK `(equipment_id, project_id, usage_date)`. FKs to `Equipment` and `ResearchProject`, both cascade. `usage_purpose` optional.

### `AuditLog` (append-only)
| Column | Notes |
|---|---|
| `audit_id` | BIGINT AUTO_INCREMENT PK |
| `db_user` | VARCHAR(100), default `CURRENT_USER()`; `RMS.sql` overrides via `fn_current_app_user()` |
| `operation` | `INSERT`, `UPDATE`, `DELETE` |
| `table_name`, `record_pk` | NOT NULL identifiers |
| `old_value`, `new_value` | TEXT snapshots |
| `change_time` | TIMESTAMP default `CURRENT_TIMESTAMP` |

`BEFORE UPDATE` and `BEFORE DELETE` triggers raise `SQLSTATE '45000'`, so rows can only be appended.

## Trigger inventory (`RMS.sql`, 31 definitions)

| Trigger | Rule |
|---|---|
| `trg_faculty_no_self_mentor_insert/update` | Faculty cannot mentor themselves |
| `trg_review_reviewer_present_insert/update` | Review needs a reviewer identity |
| `trg_studentproject_contrib_limit_insert/update` | Contribution between 0 and 100 |
| `trg_student_valid_supervisor_insert/update` | Supervisor must exist in Faculty |
| `trg_funding_no_negative_insert/update` | Amount ≥ 0, date not in the future |
| `trg_faculty_prevent_delete_if_supervising` | Block deletion of active supervisors |
| `trg_student_audit_*`, `trg_funding_audit_*` | Append audit rows with acting user |
| `trg_project_audit_*`, `trg_publication_audit_*` | Append audit rows (redefined later with `db_user`) |
| `trg_auditlog_no_update`, `trg_auditlog_no_delete` | Append-only enforcement |

Later sections of `RMS.sql` intentionally `DROP TRIGGER IF EXISTS` and recreate the project/publication/student/funding audit triggers to add `db_user`. This is why `RMS.sql` has 31 definitions but fewer active triggers.

## Design notes

- **Circular reference**: `Department.head_faculty_id` → `Faculty` is added with `ALTER TABLE` after both tables exist.
- **Soft dependency**: `supervisor_id`, `mentor_id`, and `lead_faculty_id` are nullable with `SET NULL` so deleting a faculty member does not destroy historical records — but a trigger blocks deletion while they are actively assigned.
- **All cascade paths terminate** at the junction tables or `AuditLog`, preventing orphan rows.
