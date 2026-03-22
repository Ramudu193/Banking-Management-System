# Banking Management System Database

## Overview
A professional Banking Management System database built entirely 
using MySQL, designed to simulate real-world banking operations 
including account management, transactions, loans, and branch reporting.

## Tech Stack
- Database : MySQL 8.0+
- Tool     : MySQL Workbench

## Features
- 8 Tables  : Customers, Accounts, Transactions, Branches,
              Loans, Employees, Cards, Audit Log
- 4 Triggers : Auto balance update, overdraft prevention,
               audit logging
- 7 Stored Procedures : deposit, withdraw, transfer,
                        create account, balance inquiry
- 3 Views   : Customer accounts, transaction history,
              branch summary
- Indexes, Constraints, Foreign Keys
- COMMIT / ROLLBACK Transactions

## Database Operations
- Deposit & Withdrawal
- Fund Transfer between accounts
- Loan management
- Branch-wise reporting
- Complete audit trail

## How to Run
1. Open MySQL Workbench
2. File → Open SQL Script
3. Select banking_management_system.sql
4. Press Ctrl + Shift + Enter
