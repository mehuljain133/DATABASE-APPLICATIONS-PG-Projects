-- Unit-III Authorizations in SQL: System and user privileges, granting and revoking privileges, roles, authorization on views, limitations of SQL authorizations, audit trails.

-- ===================================================
-- UNIT-III: AUTHORIZATIONS IN SQL - ALL-IN-ONE SCRIPT
-- ===================================================

-- STEP 0: Setup - Create sample tables and data to work with

CREATE TABLE Employees (
    EmployeeID SERIAL PRIMARY KEY,
    Name VARCHAR(100),
    Salary NUMERIC
);

CREATE TABLE Departments (
    DeptID SERIAL PRIMARY KEY,
    DeptName VARCHAR(100)
);

INSERT INTO Employees (Name, Salary) VALUES
('Alice', 70000),
('Bob', 60000),
('Carol', 80000);

INSERT INTO Departments (DeptName) VALUES
('HR'),
('Finance'),
('Engineering');

-- ===================================================
-- STEP 1: SYSTEM AND USER PRIVILEGES (GRANT/REVOKE)
-- ===================================================

-- Create users (roles) with login (simulate users)
-- (In PostgreSQL, CREATE USER = CREATE ROLE WITH LOGIN)

CREATE ROLE analyst LOGIN PASSWORD 'analyst_pass';
CREATE ROLE manager LOGIN PASSWORD 'manager_pass';

-- Grant SELECT on Employees to analyst
GRANT SELECT ON Employees TO analyst;

-- Grant SELECT, INSERT, UPDATE on Employees to manager
GRANT SELECT, INSERT, UPDATE ON Employees TO manager;

-- Revoke UPDATE on Employees from manager (example)
REVOKE UPDATE ON Employees FROM manager;

-- ===================================================
-- STEP 2: ROLE CREATION AND ASSIGNMENT
-- ===================================================

-- Create a role for HR Department staff
CREATE ROLE hr_staff;

-- Grant SELECT on Employees, Departments to hr_staff
GRANT SELECT ON Employees, Departments TO hr_staff;

-- Assign hr_staff role to analyst
GRANT hr_staff TO analyst;

-- ===================================================
-- STEP 3: AUTHORIZATION ON VIEWS
-- ===================================================

-- Create a view that hides salary information
CREATE VIEW PublicEmployees AS
SELECT EmployeeID, Name FROM Employees;

-- Grant SELECT on view to everyone (public)
GRANT SELECT ON PublicEmployees TO PUBLIC;

-- Create a view that shows salary only to managers
CREATE VIEW ManagerEmployees AS
SELECT * FROM Employees;

GRANT SELECT ON ManagerEmployees TO manager;

-- ===================================================
-- STEP 4: LIMITATIONS OF SQL AUTHORIZATIONS (COMMENT)
-- ===================================================
/*
Limitations include:
- No fine-grained column-level security in some DBMSs (or complex to manage).
- Privilege cascading complexity.
- Privileges granted to roles/users must be carefully managed to avoid privilege escalation.
- Some privileges cannot be granted on temporary tables or session-specific objects.
- View updates may be restricted depending on DBMS capabilities.
*/

-- ===================================================
-- STEP 5: AUDIT TRAIL (SIMULATED VIA TRIGGERS AND LOGGING TABLE)
-- ===================================================

-- Create audit log table
CREATE TABLE AuditLog (
    AuditID SERIAL PRIMARY KEY,
    Username TEXT,
    Action TEXT,
    ObjectName TEXT,
    ActionTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create trigger function to log INSERT, UPDATE, DELETE on Employees table
CREATE OR REPLACE FUNCTION audit_employees()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO AuditLog(Username, Action, ObjectName)
    VALUES (current_user, TG_OP, 'Employees');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach triggers for INSERT, UPDATE, DELETE
CREATE TRIGGER trg_audit_insert
AFTER INSERT ON Employees
FOR EACH ROW EXECUTE FUNCTION audit_employees();

CREATE TRIGGER trg_audit_update
AFTER UPDATE ON Employees
FOR EACH ROW EXECUTE FUNCTION audit_employees();

CREATE TRIGGER trg_audit_delete
AFTER DELETE ON Employees
FOR EACH ROW EXECUTE FUNCTION audit_employees();

-- ===================================================
-- STEP 6: TESTING AND VALIDATION QUERIES
-- ===================================================

-- 1) Check privileges of analyst
-- (In PostgreSQL use psql meta-commands or query information_schema)

SELECT grantee, privilege_type
FROM information_schema.role_table_grants
WHERE grantee = 'analyst';

-- 2) Check roles granted to analyst
SELECT rolname FROM pg_roles
WHERE pg_has_role('analyst', oid, 'member');

-- 3) Check audit logs
SELECT * FROM AuditLog ORDER BY ActionTime DESC;

-- Insert a new employee as test (run as manager role)
-- Note: To fully test roles and privileges you must connect as those users in actual environment.

-- Example insert (simulate):
INSERT INTO Employees (Name, Salary) VALUES ('David', 65000);

-- ===================================================
-- END OF UNIT-III AUTHORIZATION SCRIPT
-- ===================================================
