USE BankingAnalytics_db;

-- Create Customer Table
CREATE TABLE customers (
    customer_id VARCHAR(10) PRIMARY KEY,
    age INT,
    province VARCHAR(20),
    income_bucket VARCHAR(20),
    join_date DATE
);

-- Create Policy Table
CREATE TABLE policies (
    policy_id VARCHAR(10) PRIMARY KEY,
    customer_id VARCHAR(10),
    policy_type VARCHAR(30), -- e.g., Life Insurance, Funeral Cover
    monthly_premium DECIMAL(10, 2),
    intermediary_channel VARCHAR(20), -- e.g., Broker, Direct Digital
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Create Payment History Table
CREATE TABLE payment_history (
    payment_id INT IDENTITY(1,1) PRIMARY KEY, -- Changed SERIAL to INT IDENTITY(1,1)
    policy_id VARCHAR(10),
    payment_date DATE,
    payment_status VARCHAR(15), -- e.g., Paid, Failed, Bounced
    failure_reason VARCHAR(50),
    FOREIGN KEY (policy_id) REFERENCES policies(policy_id)
);