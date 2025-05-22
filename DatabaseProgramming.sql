-- Unit-II Database Programming: SQL user-defined data types, collection types; procedures and functions, exception handling, triggers, large objects, bulk loading of data.

-- ===========================================================================
-- UNIT-II DATABASE PROGRAMMING: ALL-IN-ONE SCRIPT
-- Demonstrating user-defined types, collections, procedures/functions,
-- exception handling, triggers, large objects (LOBs), and bulk loading
-- ===========================================================================

-- ================================
-- 1. USER-DEFINED DATA TYPES (UDT)
-- ================================

-- Create a composite type to store address info
CREATE TYPE AddressType AS (
    street VARCHAR(100),
    city VARCHAR(50),
    zip VARCHAR(10)
);

-- ================================
-- 2. COLLECTION TYPES (ARRAYS & TABLES)
-- ================================

-- Add a new table with a column using the UDT and an array column

CREATE TABLE Employee (
    EmployeeID SERIAL PRIMARY KEY,
    Name VARCHAR(100),
    Addr AddressType,              -- Using user-defined composite type
    PhoneNumbers TEXT[]            -- Array of phone numbers (collection)
);

-- ================================
-- 3. PROCEDURES & FUNCTIONS
-- ================================

-- Function to calculate yearly salary bonus
CREATE OR REPLACE FUNCTION calc_bonus(salary NUMERIC, bonus_percent NUMERIC)
RETURNS NUMERIC AS $$
BEGIN
    RETURN salary * bonus_percent / 100;
END;
$$ LANGUAGE plpgsql;

-- Procedure to add an employee (demonstrates exception handling)
CREATE OR REPLACE PROCEDURE add_employee(
    emp_name VARCHAR,
    street VARCHAR,
    city VARCHAR,
    zip VARCHAR,
    phones TEXT[]
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Employee (Name, Addr, PhoneNumbers)
    VALUES (emp_name, ROW(street, city, zip), phones);
EXCEPTION WHEN others THEN
    RAISE NOTICE 'Error inserting employee %', emp_name;
END;
$$;

-- ================================
-- 4. EXCEPTION HANDLING DEMO (In function)
-- ================================

CREATE OR REPLACE FUNCTION safe_divide(a NUMERIC, b NUMERIC)
RETURNS NUMERIC AS $$
BEGIN
    IF b = 0 THEN
        RAISE EXCEPTION 'Division by zero not allowed';
    END IF;
    RETURN a / b;
EXCEPTION WHEN division_by_zero THEN
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- ================================
-- 5. TRIGGERS
-- ================================

-- Create a logging table for audit
CREATE TABLE EmployeeAudit (
    AuditID SERIAL PRIMARY KEY,
    EmployeeID INT,
    Action VARCHAR(10),
    ActionTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trigger function to log INSERT and UPDATE on Employee
CREATE OR REPLACE FUNCTION log_employee_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO EmployeeAudit(EmployeeID, Action)
        VALUES (NEW.EmployeeID, 'INSERT');
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO EmployeeAudit(EmployeeID, Action)
        VALUES (NEW.EmployeeID, 'UPDATE');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach trigger to Employee table
CREATE TRIGGER trg_employee_audit
AFTER INSERT OR UPDATE ON Employee
FOR EACH ROW
EXECUTE FUNCTION log_employee_changes();

-- ================================
-- 6. LARGE OBJECTS (LOBs)
-- ================================

-- Table to store documents as large objects
CREATE TABLE Documents (
    DocID SERIAL PRIMARY KEY,
    DocName VARCHAR(100),
    DocData BYTEA           -- Binary large object column (LOB)
);

-- Insert sample document (simulate small file with bytea)
INSERT INTO Documents (DocName, DocData)
VALUES ('SampleDoc.txt', decode('48656c6c6f20576f726c6421', 'hex')); -- "Hello World!" in hex

-- ================================
-- 7. BULK LOADING SIMULATION (MULTI-ROW INSERT)
-- ================================

-- Insert multiple employees in bulk
INSERT INTO Employee (Name, Addr, PhoneNumbers) VALUES
('John Doe', ROW('123 Elm St', 'Springfield', '12345'), ARRAY['111-222-3333', '222-333-4444']),
('Jane Smith', ROW('456 Oak St', 'Shelbyville', '54321'), ARRAY['333-444-5555']),
('Bob Johnson', ROW('789 Pine St', 'Capital City', '67890'), ARRAY['444-555-6666', '555-666-7777', '666-777-8888']);

-- ================================
-- 8. TEST QUERIES TO VALIDATE
-- ================================

-- List employees with their addresses and phones
SELECT 
    EmployeeID, Name,
    (Addr).street AS Street,
    (Addr).city AS City,
    (Addr).zip AS Zip,
    PhoneNumbers
FROM Employee;

-- Calculate bonus example
SELECT Name, calc_bonus(50000, 10) AS Bonus FROM Employee WHERE Name = 'John Doe';

-- Safe division test (try dividing by zero)
SELECT safe_divide(10, 2) AS Result1, safe_divide(10, 0) AS Result2;

-- Show Employee audit log
SELECT * FROM EmployeeAudit ORDER BY ActionTime DESC;

-- Show documents stored
SELECT DocID, DocName, encode(DocData, 'escape') AS DocContent FROM Documents;

