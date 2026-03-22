-- ============================================================
--   BANKING MANAGEMENT SYSTEM DATABASE
--   Project Type : SQL Developer / Database Developer Portfolio
--   Database     : MySQL 8.0+
--   Author       : Banking DB Project
--   Description  : Complete Banking DB with Tables, Views,
--                  Stored Procedures, Triggers, Transactions
-- ============================================================


-- ============================================================
-- SECTION 1: DATABASE CREATION
-- ============================================================

DROP DATABASE IF EXISTS banking_db;
CREATE DATABASE banking_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE banking_db;


-- ============================================================
-- SECTION 2: TABLE CREATION
-- ============================================================

-- ------------------------------------------------------------
-- Table: branches
-- ------------------------------------------------------------
CREATE TABLE branches (
    branch_id       INT             NOT NULL AUTO_INCREMENT,
    branch_name     VARCHAR(100)    NOT NULL,
    city            VARCHAR(100)    NOT NULL,
    address         VARCHAR(255),
    phone           VARCHAR(15),
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_branches PRIMARY KEY (branch_id)
);

-- ------------------------------------------------------------
-- Table: customers
-- ------------------------------------------------------------
CREATE TABLE customers (
    customer_id     INT             NOT NULL AUTO_INCREMENT,
    name            VARCHAR(100)    NOT NULL,
    email           VARCHAR(150)    NOT NULL,
    phone           VARCHAR(15)     NOT NULL,
    address         VARCHAR(255),
    dob             DATE,
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_customers     PRIMARY KEY (customer_id),
    CONSTRAINT uq_cust_email    UNIQUE      (email),
    CONSTRAINT uq_cust_phone    UNIQUE      (phone)
);

-- ------------------------------------------------------------
-- Table: employees
-- ------------------------------------------------------------
CREATE TABLE employees (
    employee_id     INT             NOT NULL AUTO_INCREMENT,
    name            VARCHAR(100)    NOT NULL,
    branch_id       INT             NOT NULL,
    role            VARCHAR(50)     NOT NULL,
    salary          DECIMAL(12, 2)  NOT NULL CHECK (salary >= 0),
    email           VARCHAR(150),
    hire_date       DATE,
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_employees     PRIMARY KEY (employee_id),
    CONSTRAINT fk_emp_branch    FOREIGN KEY (branch_id)
        REFERENCES branches(branch_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT uq_emp_email     UNIQUE (email)
);

-- ------------------------------------------------------------
-- Table: accounts
-- ------------------------------------------------------------
CREATE TABLE accounts (
    account_id      INT             NOT NULL AUTO_INCREMENT,
    customer_id     INT             NOT NULL,
    branch_id       INT             NOT NULL,
    account_type    ENUM('SAVINGS','CURRENT','FIXED_DEPOSIT','SALARY')
                                    NOT NULL DEFAULT 'SAVINGS',
    balance         DECIMAL(15, 2)  NOT NULL DEFAULT 0.00,
    status          ENUM('ACTIVE','INACTIVE','FROZEN','CLOSED')
                                    NOT NULL DEFAULT 'ACTIVE',
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_accounts      PRIMARY KEY (account_id),
    CONSTRAINT fk_acc_customer  FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_acc_branch    FOREIGN KEY (branch_id)
        REFERENCES branches(branch_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_balance      CHECK (balance >= 0)
);

-- ------------------------------------------------------------
-- Table: transactions
-- ------------------------------------------------------------
CREATE TABLE transactions (
    transaction_id      INT             NOT NULL AUTO_INCREMENT,
    account_id          INT             NOT NULL,
    transaction_type    ENUM('DEPOSIT','WITHDRAWAL','TRANSFER_IN','TRANSFER_OUT')
                                        NOT NULL,
    amount              DECIMAL(15, 2)  NOT NULL CHECK (amount > 0),
    balance_after       DECIMAL(15, 2)  NOT NULL,
    reference_id        VARCHAR(50),        -- e.g., linked transfer transaction
    description         VARCHAR(255),
    transaction_date    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_transactions  PRIMARY KEY (transaction_id),
    CONSTRAINT fk_txn_account   FOREIGN KEY (account_id)
        REFERENCES accounts(account_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ------------------------------------------------------------
-- Table: loans
-- ------------------------------------------------------------
CREATE TABLE loans (
    loan_id         INT             NOT NULL AUTO_INCREMENT,
    customer_id     INT             NOT NULL,
    branch_id       INT             NOT NULL,
    loan_amount     DECIMAL(15, 2)  NOT NULL CHECK (loan_amount > 0),
    loan_type       ENUM('HOME','PERSONAL','CAR','EDUCATION','BUSINESS')
                                    NOT NULL,
    interest_rate   DECIMAL(5, 2)   NOT NULL DEFAULT 8.50,
    tenure_months   INT             NOT NULL DEFAULT 12,
    status          ENUM('PENDING','APPROVED','ACTIVE','CLOSED','REJECTED')
                                    NOT NULL DEFAULT 'PENDING',
    applied_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    approved_at     TIMESTAMP       NULL,

    CONSTRAINT pk_loans         PRIMARY KEY (loan_id),
    CONSTRAINT fk_loan_cust     FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_loan_branch   FOREIGN KEY (branch_id)
        REFERENCES branches(branch_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ------------------------------------------------------------
-- Table: cards
-- ------------------------------------------------------------
CREATE TABLE cards (
    card_id         INT             NOT NULL AUTO_INCREMENT,
    account_id      INT             NOT NULL,
    card_type       ENUM('DEBIT','CREDIT','PREPAID') NOT NULL DEFAULT 'DEBIT',
    card_number     VARCHAR(19)     NOT NULL,       -- stored as masked/hashed
    expiry_date     DATE            NOT NULL,
    status          ENUM('ACTIVE','BLOCKED','EXPIRED') NOT NULL DEFAULT 'ACTIVE',
    issued_at       TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_cards         PRIMARY KEY (card_id),
    CONSTRAINT fk_card_account  FOREIGN KEY (account_id)
        REFERENCES accounts(account_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT uq_card_number   UNIQUE (card_number)
);

-- ------------------------------------------------------------
-- Table: audit_log  (bonus – tracks sensitive operations)
-- ------------------------------------------------------------
CREATE TABLE audit_log (
    log_id          INT             NOT NULL AUTO_INCREMENT,
    table_name      VARCHAR(50)     NOT NULL,
    operation       VARCHAR(20)     NOT NULL,
    record_id       INT             NOT NULL,
    description     TEXT,
    logged_at       TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_audit PRIMARY KEY (log_id)
);


-- ============================================================
-- SECTION 3: INDEXES
-- ============================================================

-- Speed up common lookups
CREATE INDEX idx_accounts_customer   ON accounts(customer_id);
CREATE INDEX idx_accounts_branch     ON accounts(branch_id);
CREATE INDEX idx_txn_account         ON transactions(account_id);
CREATE INDEX idx_txn_date            ON transactions(transaction_date);
CREATE INDEX idx_loans_customer      ON loans(customer_id);
CREATE INDEX idx_loans_status        ON loans(status);
CREATE INDEX idx_cards_account       ON cards(account_id);
CREATE INDEX idx_employees_branch    ON employees(branch_id);


-- ============================================================
-- SECTION 4: SAMPLE DATA
-- ============================================================

-- Branches
INSERT INTO branches (branch_name, city, address, phone) VALUES
('Head Office',         'Mumbai',    '123 Marine Drive, Mumbai',       '022-11112222'),
('Connaught Branch',    'Delhi',     '45 Connaught Place, New Delhi',  '011-33334444'),
('Koramangala Branch',  'Bangalore', '7th Block, Koramangala',         '080-55556666'),
('Salt Lake Branch',    'Kolkata',   'Sector V, Salt Lake City',       '033-77778888'),
('T-Nagar Branch',      'Chennai',   '22 Usman Road, T-Nagar',        '044-99990000');

-- Customers
INSERT INTO customers (name, email, phone, address, dob) VALUES
('Aarav Sharma',    'aarav.sharma@email.com',   '9876543210', '12 MG Road, Mumbai',       '1990-05-15'),
('Priya Mehta',     'priya.mehta@email.com',    '9876543211', '34 Park Street, Delhi',    '1985-08-22'),
('Rohan Das',       'rohan.das@email.com',      '9876543212', '56 Brigade Rd, Bangalore', '1992-11-30'),
('Sunita Patel',    'sunita.patel@email.com',   '9876543213', '78 Lake Road, Kolkata',    '1988-03-10'),
('Vikram Rao',      'vikram.rao@email.com',     '9876543214', '90 Anna Salai, Chennai',   '1995-07-25'),
('Deepa Nair',      'deepa.nair@email.com',     '9876543215', '11 Bandra West, Mumbai',   '1993-01-14'),
('Amit Gupta',      'amit.gupta@email.com',     '9876543216', '22 Lajpat Nagar, Delhi',   '1987-09-08'),
('Kavya Reddy',     'kavya.reddy@email.com',    '9876543217', '33 Indiranagar, Bangalore','1991-06-19');

-- Employees
INSERT INTO employees (name, branch_id, role, salary, email, hire_date) VALUES
('Ravi Kumar',      1, 'Branch Manager',  85000.00, 'ravi.kumar@bank.com',   '2015-03-01'),
('Sneha Singh',     1, 'Loan Officer',    55000.00, 'sneha.singh@bank.com',  '2018-07-15'),
('Arjun Verma',     2, 'Branch Manager',  82000.00, 'arjun.verma@bank.com',  '2016-01-10'),
('Pooja Iyer',      2, 'Teller',          38000.00, 'pooja.iyer@bank.com',   '2020-04-22'),
('Kiran Joshi',     3, 'Branch Manager',  80000.00, 'kiran.joshi@bank.com',  '2017-09-05'),
('Meera Thomas',    3, 'Accountant',      48000.00, 'meera.thomas@bank.com', '2019-11-30'),
('Suresh Pillai',   4, 'Branch Manager',  79000.00, 'suresh.pillai@bank.com','2014-06-18'),
('Anita Bose',      5, 'Teller',          37000.00, 'anita.bose@bank.com',   '2021-02-14');

-- Accounts (balances set here; triggers will maintain thereafter)
INSERT INTO accounts (customer_id, branch_id, account_type, balance, status) VALUES
(1, 1, 'SAVINGS',       50000.00, 'ACTIVE'),
(1, 1, 'CURRENT',       120000.00,'ACTIVE'),
(2, 2, 'SAVINGS',       75000.00, 'ACTIVE'),
(3, 3, 'SAVINGS',       30000.00, 'ACTIVE'),
(4, 4, 'FIXED_DEPOSIT', 200000.00,'ACTIVE'),
(5, 5, 'SAVINGS',       45000.00, 'ACTIVE'),
(6, 1, 'SALARY',        60000.00, 'ACTIVE'),
(7, 2, 'SAVINGS',       15000.00, 'ACTIVE'),
(8, 3, 'CURRENT',       90000.00, 'ACTIVE');

-- Transactions (historical; auto-trigger won't fire on direct inserts)
INSERT INTO transactions (account_id, transaction_type, amount, balance_after, description) VALUES
(1, 'DEPOSIT',      50000.00, 50000.00, 'Initial deposit'),
(2, 'DEPOSIT',     120000.00,120000.00, 'Initial deposit'),
(3, 'DEPOSIT',      75000.00, 75000.00, 'Initial deposit'),
(1, 'DEPOSIT',      10000.00, 60000.00, 'Salary credit'),
(1, 'WITHDRAWAL',    5000.00, 55000.00, 'ATM withdrawal'),
(3, 'WITHDRAWAL',   10000.00, 65000.00, 'Bill payment'),
(4, 'DEPOSIT',      30000.00, 30000.00, 'Initial deposit'),
(5, 'DEPOSIT',     200000.00,200000.00, 'FD opening'),
(6, 'DEPOSIT',      60000.00, 60000.00, 'Salary credit'),
(7, 'DEPOSIT',      15000.00, 15000.00, 'Cash deposit');

-- Loans
INSERT INTO loans (customer_id, branch_id, loan_amount, loan_type, interest_rate, tenure_months, status, approved_at) VALUES
(1, 1, 500000.00, 'HOME',      8.50, 240, 'ACTIVE',   NOW()),
(2, 2, 150000.00, 'PERSONAL',  11.00, 36, 'ACTIVE',   NOW()),
(3, 3,  80000.00, 'CAR',        9.25, 60, 'APPROVED', NOW()),
(4, 4, 200000.00, 'EDUCATION',  7.00,120, 'PENDING',  NULL),
(5, 5,  50000.00, 'PERSONAL',  12.00, 24, 'REJECTED', NULL),
(6, 1, 800000.00, 'HOME',       8.00,300, 'ACTIVE',   NOW());

-- Cards
INSERT INTO cards (account_id, card_type, card_number, expiry_date, status) VALUES
(1, 'DEBIT',  'XXXX-XXXX-XXXX-1001', '2027-12-31', 'ACTIVE'),
(2, 'CREDIT', 'XXXX-XXXX-XXXX-2002', '2026-06-30', 'ACTIVE'),
(3, 'DEBIT',  'XXXX-XXXX-XXXX-3003', '2028-03-31', 'ACTIVE'),
(4, 'DEBIT',  'XXXX-XXXX-XXXX-4004', '2027-09-30', 'ACTIVE'),
(6, 'DEBIT',  'XXXX-XXXX-XXXX-5005', '2026-12-31', 'ACTIVE'),
(7, 'PREPAID','XXXX-XXXX-XXXX-6006', '2025-06-30', 'EXPIRED'),
(8, 'DEBIT',  'XXXX-XXXX-XXXX-7007', '2028-01-31', 'ACTIVE'),
(9, 'CREDIT', 'XXXX-XXXX-XXXX-8008', '2027-03-31', 'ACTIVE');


-- ============================================================
-- SECTION 5: VIEWS
-- ============================================================

-- ------------------------------------------------------------
-- View 1: customer_accounts_view
--   Shows every customer with their account details & branch
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW customer_accounts_view AS
SELECT
    c.customer_id,
    c.name              AS customer_name,
    c.email,
    c.phone,
    a.account_id,
    a.account_type,
    a.balance,
    a.status            AS account_status,
    b.branch_name,
    b.city,
    a.created_at        AS account_opened
FROM customers  c
JOIN accounts   a ON a.customer_id = c.customer_id
JOIN branches   b ON b.branch_id   = a.branch_id;

-- ------------------------------------------------------------
-- View 2: transaction_history_view
--   Full transaction log enriched with customer & account data
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW transaction_history_view AS
SELECT
    t.transaction_id,
    c.customer_id,
    c.name              AS customer_name,
    a.account_id,
    a.account_type,
    t.transaction_type,
    t.amount,
    t.balance_after,
    t.description,
    t.transaction_date
FROM transactions   t
JOIN accounts       a ON a.account_id   = t.account_id
JOIN customers      c ON c.customer_id  = a.customer_id
ORDER BY t.transaction_date DESC;

-- ------------------------------------------------------------
-- View 3: branch_summary_view
--   Aggregated branch-level KPIs
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW branch_summary_view AS
SELECT
    b.branch_id,
    b.branch_name,
    b.city,
    COUNT(DISTINCT a.account_id)    AS total_accounts,
    COUNT(DISTINCT a.customer_id)   AS total_customers,
    COALESCE(SUM(a.balance), 0)     AS total_deposits,
    COUNT(DISTINCT e.employee_id)   AS total_employees,
    COUNT(DISTINCT l.loan_id)       AS total_loans,
    COALESCE(SUM(l.loan_amount), 0) AS total_loan_amount
FROM branches   b
LEFT JOIN accounts   a ON a.branch_id  = b.branch_id  AND a.status = 'ACTIVE'
LEFT JOIN employees  e ON e.branch_id  = b.branch_id
LEFT JOIN loans      l ON l.branch_id  = b.branch_id  AND l.status IN ('ACTIVE','APPROVED')
GROUP BY b.branch_id, b.branch_name, b.city;


-- ============================================================
-- SECTION 6: TRIGGERS
-- ============================================================

DELIMITER $$

-- ------------------------------------------------------------
-- Trigger 1: trg_prevent_negative_balance
--   BEFORE INSERT on transactions — blocks overdraft
-- ------------------------------------------------------------
CREATE TRIGGER trg_prevent_negative_balance
BEFORE INSERT ON transactions
FOR EACH ROW
BEGIN
    DECLARE v_balance DECIMAL(15,2);
    DECLARE v_status  VARCHAR(20);

    SELECT balance, status
    INTO   v_balance, v_status
    FROM   accounts
    WHERE  account_id = NEW.account_id;

    -- Block operations on non-active accounts
    IF v_status != 'ACTIVE' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Operation denied: Account is not ACTIVE.';
    END IF;

    -- Block withdrawals that would create negative balance
    IF NEW.transaction_type IN ('WITHDRAWAL', 'TRANSFER_OUT')
       AND v_balance < NEW.amount THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Insufficient funds: Balance too low for this transaction.';
    END IF;

    -- Compute balance_after automatically
    IF NEW.transaction_type IN ('DEPOSIT', 'TRANSFER_IN') THEN
        SET NEW.balance_after = v_balance + NEW.amount;
    ELSE
        SET NEW.balance_after = v_balance - NEW.amount;
    END IF;
END$$

-- ------------------------------------------------------------
-- Trigger 2: trg_update_balance_after_transaction
--   AFTER INSERT on transactions — syncs accounts.balance
-- ------------------------------------------------------------
CREATE TRIGGER trg_update_balance_after_transaction
AFTER INSERT ON transactions
FOR EACH ROW
BEGIN
    UPDATE accounts
    SET    balance = NEW.balance_after
    WHERE  account_id = NEW.account_id;
END$$

-- ------------------------------------------------------------
-- Trigger 3: trg_audit_account_changes
--   AFTER UPDATE on accounts — logs balance changes
-- ------------------------------------------------------------
CREATE TRIGGER trg_audit_account_changes
AFTER UPDATE ON accounts
FOR EACH ROW
BEGIN
    IF OLD.balance != NEW.balance THEN
        INSERT INTO audit_log (table_name, operation, record_id, description)
        VALUES (
            'accounts',
            'BALANCE_UPDATE',
            NEW.account_id,
            CONCAT('Balance changed from ', OLD.balance, ' to ', NEW.balance)
        );
    END IF;
END$$

-- ------------------------------------------------------------
-- Trigger 4: trg_log_new_account
--   AFTER INSERT on accounts — audit trail for account creation
-- ------------------------------------------------------------
CREATE TRIGGER trg_log_new_account
AFTER INSERT ON accounts
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, operation, record_id, description)
    VALUES (
        'accounts',
        'INSERT',
        NEW.account_id,
        CONCAT('New ', NEW.account_type, ' account created for customer_id=', NEW.customer_id)
    );
END$$

DELIMITER ;


-- ============================================================
-- SECTION 7: STORED PROCEDURES
-- ============================================================

DELIMITER $$

-- ------------------------------------------------------------
-- SP 1: create_account
--   Opens a new bank account for an existing customer
-- ------------------------------------------------------------
CREATE PROCEDURE create_account (
    IN  p_customer_id   INT,
    IN  p_branch_id     INT,
    IN  p_account_type  VARCHAR(20),
    IN  p_initial_dep   DECIMAL(15,2),
    OUT p_account_id    INT,
    OUT p_message       VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_message = 'ERROR: Account creation failed. Transaction rolled back.';
    END;

    START TRANSACTION;

    -- Validate customer
    IF NOT EXISTS (SELECT 1 FROM customers WHERE customer_id = p_customer_id) THEN
        SET p_message = 'ERROR: Customer not found.';
        ROLLBACK;
    ELSE
        -- Validate branch
        IF NOT EXISTS (SELECT 1 FROM branches WHERE branch_id = p_branch_id) THEN
            SET p_message = 'ERROR: Branch not found.';
            ROLLBACK;
        ELSE
            -- Insert account
            INSERT INTO accounts (customer_id, branch_id, account_type, balance)
            VALUES (p_customer_id, p_branch_id, p_account_type, 0.00);

            SET p_account_id = LAST_INSERT_ID();

            -- Record initial deposit if provided
            IF p_initial_dep > 0 THEN
                INSERT INTO transactions
                    (account_id, transaction_type, amount, description)
                VALUES
                    (p_account_id, 'DEPOSIT', p_initial_dep, 'Initial deposit on account opening');
            END IF;

            COMMIT;
            SET p_message = CONCAT('SUCCESS: Account #', p_account_id, ' created successfully.');
        END IF;
    END IF;
END$$

-- ------------------------------------------------------------
-- SP 2: deposit_money
--   Credits an amount into an account
-- ------------------------------------------------------------
CREATE PROCEDURE deposit_money (
    IN  p_account_id    INT,
    IN  p_amount        DECIMAL(15,2),
    IN  p_description   VARCHAR(255),
    OUT p_new_balance   DECIMAL(15,2),
    OUT p_message       VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_message = 'ERROR: Deposit failed. Transaction rolled back.';
    END;

    START TRANSACTION;

    IF p_amount <= 0 THEN
        SET p_message = 'ERROR: Deposit amount must be greater than zero.';
        ROLLBACK;
    ELSEIF NOT EXISTS (SELECT 1 FROM accounts WHERE account_id = p_account_id AND status = 'ACTIVE') THEN
        SET p_message = 'ERROR: Account not found or not active.';
        ROLLBACK;
    ELSE
        INSERT INTO transactions (account_id, transaction_type, amount, description)
        VALUES (p_account_id, 'DEPOSIT', p_amount, IFNULL(p_description, 'Cash deposit'));

        SELECT balance INTO p_new_balance
        FROM accounts WHERE account_id = p_account_id;

        COMMIT;
        SET p_message = CONCAT('SUCCESS: ₹', p_amount, ' deposited. New balance: ₹', p_new_balance);
    END IF;
END$$

-- ------------------------------------------------------------
-- SP 3: withdraw_money
--   Debits an amount from an account (trigger handles overdraft)
-- ------------------------------------------------------------
CREATE PROCEDURE withdraw_money (
    IN  p_account_id    INT,
    IN  p_amount        DECIMAL(15,2),
    IN  p_description   VARCHAR(255),
    OUT p_new_balance   DECIMAL(15,2),
    OUT p_message       VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_message = 'ERROR: Withdrawal failed — insufficient funds or account issue.';
    END;

    START TRANSACTION;

    IF p_amount <= 0 THEN
        SET p_message = 'ERROR: Withdrawal amount must be greater than zero.';
        ROLLBACK;
    ELSEIF NOT EXISTS (SELECT 1 FROM accounts WHERE account_id = p_account_id AND status = 'ACTIVE') THEN
        SET p_message = 'ERROR: Account not found or not active.';
        ROLLBACK;
    ELSE
        INSERT INTO transactions (account_id, transaction_type, amount, description)
        VALUES (p_account_id, 'WITHDRAWAL', p_amount, IFNULL(p_description, 'Cash withdrawal'));

        SELECT balance INTO p_new_balance
        FROM accounts WHERE account_id = p_account_id;

        COMMIT;
        SET p_message = CONCAT('SUCCESS: ₹', p_amount, ' withdrawn. New balance: ₹', p_new_balance);
    END IF;
END$$

-- ------------------------------------------------------------
-- SP 4: transfer_money
--   Moves funds between two accounts atomically
-- ------------------------------------------------------------
CREATE PROCEDURE transfer_money (
    IN  p_from_account  INT,
    IN  p_to_account    INT,
    IN  p_amount        DECIMAL(15,2),
    IN  p_description   VARCHAR(255),
    OUT p_message       VARCHAR(255)
)
BEGIN
    DECLARE v_ref VARCHAR(50);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_message = 'ERROR: Transfer failed. Transaction rolled back.';
    END;

    START TRANSACTION;

    IF p_amount <= 0 THEN
        SET p_message = 'ERROR: Transfer amount must be greater than zero.';
        ROLLBACK;
    ELSEIF p_from_account = p_to_account THEN
        SET p_message = 'ERROR: Source and destination accounts cannot be the same.';
        ROLLBACK;
    ELSEIF NOT EXISTS (SELECT 1 FROM accounts WHERE account_id = p_from_account AND status = 'ACTIVE') THEN
        SET p_message = 'ERROR: Source account not found or not active.';
        ROLLBACK;
    ELSEIF NOT EXISTS (SELECT 1 FROM accounts WHERE account_id = p_to_account AND status = 'ACTIVE') THEN
        SET p_message = 'ERROR: Destination account not found or not active.';
        ROLLBACK;
    ELSE
        SET v_ref = CONCAT('TXN-', UNIX_TIMESTAMP(), '-', p_from_account, '-', p_to_account);

        -- Debit source (trigger validates sufficient balance)
        INSERT INTO transactions
            (account_id, transaction_type, amount, reference_id, description)
        VALUES
            (p_from_account, 'TRANSFER_OUT', p_amount, v_ref,
             IFNULL(p_description, CONCAT('Transfer to account #', p_to_account)));

        -- Credit destination
        INSERT INTO transactions
            (account_id, transaction_type, amount, reference_id, description)
        VALUES
            (p_to_account, 'TRANSFER_IN', p_amount, v_ref,
             IFNULL(p_description, CONCAT('Transfer from account #', p_from_account)));

        COMMIT;
        SET p_message = CONCAT('SUCCESS: ₹', p_amount,
            ' transferred from account #', p_from_account,
            ' to account #', p_to_account,
            '. Reference: ', v_ref);
    END IF;
END$$

-- ------------------------------------------------------------
-- SP 5: get_account_balance
--   Returns current balance and mini-statement
-- ------------------------------------------------------------
CREATE PROCEDURE get_account_balance (
    IN  p_account_id    INT
)
BEGIN
    -- Account summary
    SELECT
        a.account_id,
        c.name      AS customer_name,
        a.account_type,
        a.balance   AS current_balance,
        a.status,
        b.branch_name,
        b.city
    FROM accounts   a
    JOIN customers  c ON c.customer_id = a.customer_id
    JOIN branches   b ON b.branch_id   = a.branch_id
    WHERE a.account_id = p_account_id;

    -- Last 5 transactions
    SELECT
        transaction_id,
        transaction_type,
        amount,
        balance_after,
        description,
        transaction_date
    FROM transactions
    WHERE account_id = p_account_id
    ORDER BY transaction_date DESC
    LIMIT 5;
END$$

-- ------------------------------------------------------------
-- SP 6: get_transaction_history
--   Returns paginated transaction history for an account
-- ------------------------------------------------------------
CREATE PROCEDURE get_transaction_history (
    IN p_account_id     INT,
    IN p_limit          INT,
    IN p_offset         INT
)
BEGIN
    SELECT
        t.transaction_id,
        t.transaction_type,
        t.amount,
        t.balance_after,
        t.description,
        t.transaction_date
    FROM transactions t
    WHERE t.account_id = p_account_id
    ORDER BY t.transaction_date DESC
    LIMIT  p_limit
    OFFSET p_offset;
END$$

-- ------------------------------------------------------------
-- SP 7: get_branch_report
--   Full KPI report for a specific branch
-- ------------------------------------------------------------
CREATE PROCEDURE get_branch_report (
    IN p_branch_id INT
)
BEGIN
    SELECT * FROM branch_summary_view
    WHERE branch_id = p_branch_id;

    -- Top 5 accounts by balance in branch
    SELECT
        a.account_id,
        c.name  AS customer_name,
        a.account_type,
        a.balance
    FROM accounts   a
    JOIN customers  c ON c.customer_id = a.customer_id
    WHERE a.branch_id = p_branch_id AND a.status = 'ACTIVE'
    ORDER BY a.balance DESC
    LIMIT 5;
END$$

DELIMITER ;


-- ============================================================
-- SECTION 8: ANALYTICAL & OPERATIONAL QUERIES
-- ============================================================

-- ------------------------------------------------------------
-- Q1: Get all customers with their account details (INNER JOIN)
-- ------------------------------------------------------------
SELECT
    c.customer_id,
    c.name          AS customer_name,
    c.email,
    a.account_id,
    a.account_type,
    a.balance,
    b.branch_name
FROM customers  c
INNER JOIN accounts  a ON a.customer_id = c.customer_id
INNER JOIN branches  b ON b.branch_id   = a.branch_id
ORDER BY c.customer_id;

-- ------------------------------------------------------------
-- Q2: Total balance per customer (GROUP BY + ORDER BY)
-- ------------------------------------------------------------
SELECT
    c.customer_id,
    c.name          AS customer_name,
    COUNT(a.account_id)     AS number_of_accounts,
    SUM(a.balance)          AS total_balance
FROM customers  c
JOIN accounts   a ON a.customer_id = c.customer_id
GROUP BY c.customer_id, c.name
ORDER BY total_balance DESC;

-- ------------------------------------------------------------
-- Q3: Customers with total balance > ₹50,000 (HAVING)
-- ------------------------------------------------------------
SELECT
    c.customer_id,
    c.name              AS customer_name,
    SUM(a.balance)      AS total_balance
FROM customers  c
JOIN accounts   a ON a.customer_id = c.customer_id
GROUP BY c.customer_id, c.name
HAVING total_balance > 50000
ORDER BY total_balance DESC;

-- ------------------------------------------------------------
-- Q4: Transaction history with customer name (multi-table JOIN)
-- ------------------------------------------------------------
SELECT
    t.transaction_id,
    c.name              AS customer_name,
    a.account_type,
    t.transaction_type,
    t.amount,
    t.balance_after,
    t.description,
    t.transaction_date
FROM transactions   t
JOIN accounts       a ON a.account_id   = t.account_id
JOIN customers      c ON c.customer_id  = a.customer_id
ORDER BY t.transaction_date DESC
LIMIT 20;

-- ------------------------------------------------------------
-- Q5: Branch-wise total deposits (GROUP BY + SUM)
-- ------------------------------------------------------------
SELECT
    b.branch_name,
    b.city,
    COUNT(a.account_id)     AS total_accounts,
    SUM(a.balance)          AS total_deposits
FROM branches   b
LEFT JOIN accounts a ON a.branch_id = b.branch_id AND a.status = 'ACTIVE'
GROUP BY b.branch_id, b.branch_name, b.city
ORDER BY total_deposits DESC;

-- ------------------------------------------------------------
-- Q6: Customers who have taken a loan (SUBQUERY)
-- ------------------------------------------------------------
SELECT
    customer_id,
    name,
    email
FROM customers
WHERE customer_id IN (
    SELECT DISTINCT customer_id FROM loans WHERE status IN ('ACTIVE','APPROVED')
);

-- ------------------------------------------------------------
-- Q7: Accounts with above-average balance (SUBQUERY)
-- ------------------------------------------------------------
SELECT
    a.account_id,
    c.name      AS customer_name,
    a.account_type,
    a.balance
FROM accounts   a
JOIN customers  c ON c.customer_id = a.customer_id
WHERE a.balance > (SELECT AVG(balance) FROM accounts WHERE status = 'ACTIVE')
ORDER BY a.balance DESC;

-- ------------------------------------------------------------
-- Q8: Monthly transaction summary (GROUP BY DATE functions)
-- ------------------------------------------------------------
SELECT
    YEAR(transaction_date)  AS txn_year,
    MONTH(transaction_date) AS txn_month,
    transaction_type,
    COUNT(*)                AS txn_count,
    SUM(amount)             AS total_amount
FROM transactions
GROUP BY txn_year, txn_month, transaction_type
ORDER BY txn_year, txn_month;

-- ------------------------------------------------------------
-- Q9: Employee salary report per branch
-- ------------------------------------------------------------
SELECT
    b.branch_name,
    COUNT(e.employee_id)    AS headcount,
    MIN(e.salary)           AS min_salary,
    MAX(e.salary)           AS max_salary,
    AVG(e.salary)           AS avg_salary,
    SUM(e.salary)           AS payroll
FROM branches   b
LEFT JOIN employees e ON e.branch_id = b.branch_id
GROUP BY b.branch_id, b.branch_name
ORDER BY payroll DESC;

-- ------------------------------------------------------------
-- Q10: Loan status breakdown
-- ------------------------------------------------------------
SELECT
    loan_type,
    status,
    COUNT(*)            AS count,
    SUM(loan_amount)    AS total_loan_amount,
    AVG(loan_amount)    AS avg_loan_amount
FROM loans
GROUP BY loan_type, status
ORDER BY loan_type, status;

-- ------------------------------------------------------------
-- Q11: Customers with NO account (LEFT JOIN + IS NULL)
-- ------------------------------------------------------------
SELECT
    c.customer_id,
    c.name,
    c.email
FROM customers  c
LEFT JOIN accounts a ON a.customer_id = c.customer_id
WHERE a.account_id IS NULL;

-- ------------------------------------------------------------
-- Q12: Total bank balance (aggregate)
-- ------------------------------------------------------------
SELECT
    COUNT(account_id)   AS total_active_accounts,
    SUM(balance)        AS total_bank_balance,
    AVG(balance)        AS average_account_balance,
    MAX(balance)        AS highest_balance,
    MIN(balance)        AS lowest_balance
FROM accounts
WHERE status = 'ACTIVE';

-- ------------------------------------------------------------
-- Q13: Active cards with account & customer details
-- ------------------------------------------------------------
SELECT
    cd.card_id,
    c.name          AS customer_name,
    a.account_type,
    cd.card_type,
    cd.card_number,
    cd.expiry_date,
    cd.status       AS card_status
FROM cards      cd
JOIN accounts   a ON a.account_id   = cd.account_id
JOIN customers  c ON c.customer_id  = a.customer_id
WHERE cd.status = 'ACTIVE'
ORDER BY cd.expiry_date;

-- ------------------------------------------------------------
-- Q14: Update customer address
-- ------------------------------------------------------------
UPDATE customers
SET    address = '99 New Horizon, Mumbai'
WHERE  customer_id = 1;

-- ------------------------------------------------------------
-- Q15: Freeze an account
-- ------------------------------------------------------------
UPDATE accounts
SET    status = 'FROZEN'
WHERE  account_id = 8;   -- example: freeze account 8

-- Restore it back
UPDATE accounts
SET    status = 'ACTIVE'
WHERE  account_id = 8;

-- ------------------------------------------------------------
-- Q16: Delete a card (safe delete — card only, not account)
-- ------------------------------------------------------------
-- DELETE FROM cards WHERE card_id = 6 AND status = 'EXPIRED';
-- (Commented out to preserve sample data integrity)

-- ------------------------------------------------------------
-- Q17: Rank accounts by balance using window function
-- ------------------------------------------------------------
SELECT
    a.account_id,
    c.name          AS customer_name,
    a.account_type,
    a.balance,
    RANK() OVER (ORDER BY a.balance DESC)   AS balance_rank,
    DENSE_RANK() OVER (
        PARTITION BY a.account_type
        ORDER BY a.balance DESC
    )                                        AS rank_within_type
FROM accounts   a
JOIN customers  c ON c.customer_id = a.customer_id
WHERE a.status = 'ACTIVE';

-- ------------------------------------------------------------
-- Q18: Running balance per account (window function)
-- ------------------------------------------------------------
SELECT
    t.transaction_id,
    t.account_id,
    t.transaction_type,
    t.amount,
    t.balance_after,
    SUM(CASE
            WHEN t.transaction_type IN ('DEPOSIT','TRANSFER_IN')  THEN  t.amount
            WHEN t.transaction_type IN ('WITHDRAWAL','TRANSFER_OUT') THEN -t.amount
        END)
        OVER (PARTITION BY t.account_id ORDER BY t.transaction_date
              ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )                       AS running_balance,
    t.transaction_date
FROM transactions t
ORDER BY t.account_id, t.transaction_date;


-- ============================================================
-- SECTION 9: DEMO — CALLING STORED PROCEDURES
-- ============================================================

-- 9a. Create a new account for customer 1 at branch 2
CALL create_account(1, 2, 'SAVINGS', 25000.00, @new_acc, @msg);
SELECT @new_acc AS new_account_id, @msg AS result_message;

-- 9b. Deposit ₹15,000 into account 1
CALL deposit_money(1, 15000.00, 'Freelance income', @bal, @msg);
SELECT @bal AS new_balance, @msg AS result_message;

-- 9c. Withdraw ₹5,000 from account 1
CALL withdraw_money(1, 5000.00, 'Grocery expenses', @bal, @msg);
SELECT @bal AS new_balance, @msg AS result_message;

-- 9d. Transfer ₹10,000 from account 1 to account 3
CALL transfer_money(1, 3, 10000.00, 'Rent payment', @msg);
SELECT @msg AS result_message;

-- 9e. Get account balance & mini-statement for account 1
CALL get_account_balance(1);

-- 9f. Get last 10 transactions for account 1
CALL get_transaction_history(1, 10, 0);

-- 9g. Branch report for branch 1
CALL get_branch_report(1);


-- ============================================================
-- SECTION 10: QUERYING VIEWS
-- ============================================================

-- All customers and accounts
SELECT * FROM customer_accounts_view ORDER BY customer_id;

-- Full transaction history
SELECT * FROM transaction_history_view LIMIT 20;

-- Branch performance summary
SELECT * FROM branch_summary_view ORDER BY total_deposits DESC;


-- ============================================================
-- SECTION 11: AUDIT LOG CHECK
-- ============================================================

SELECT * FROM audit_log ORDER BY logged_at DESC LIMIT 20;


-- ============================================================
-- END OF SCRIPT
-- ============================================================
