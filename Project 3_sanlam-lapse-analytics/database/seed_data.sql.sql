-- INSERT SAMPLE CUSTOMERS
INSERT INTO customers (customer_id, age, province, income_bucket, join_date) VALUES
('SAN00001', 28, 'Gauteng', 'R15k - R25k', '2025-01-15'),
('SAN00002', 45, 'Western Cape', 'R45k+', '2023-06-20'),
('SAN00003', 34, 'KwaZulu-Natal', 'R25k - R45k', '2024-11-01'),
('SAN00004', 52, 'Eastern Cape', 'Under R15k', '2022-03-10'),
('SAN00005', 23, 'Free State', 'Under R15k', '2026-02-01');

-- INSERT SAMPLE POLICIES
INSERT INTO policies (policy_id, customer_id, policy_type, monthly_premium, intermediary_channel) VALUES
('POL-9901', 'SAN00001', 'Life Insurance', 450.00, 'Direct Digital'),
('POL-9902', 'SAN00002', 'Comprehensive Wealth', 1200.00, 'Broker'),
('POL-9903', 'SAN00003', 'Funeral Cover', 250.00, 'Direct Digital'),
('POL-9904', 'SAN00004', 'Life Insurance', 600.00, 'Broker'),
('POL-9905', 'SAN00005', 'Funeral Cover', 180.00, 'Call Centre');

-- INSERT 3 MONTHS OF PAYMENT HISTORY (Simulating Failed Debit Orders)
INSERT INTO payment_history (policy_id, payment_date, payment_status, failure_reason) VALUES
-- POL-9901: Consistent payer
('POL-9901', '2026-03-01', 'Paid', NULL),
('POL-9901', '2026-04-01', 'Paid', NULL),
('POL-9901', '2026-05-01', 'Paid', NULL),

-- POL-9902: Consistent payer
('POL-9902', '2026-03-01', 'Paid', NULL),
('POL-9902', '2026-04-01', 'Paid', NULL),
('POL-9902', '2026-05-01', 'Paid', NULL),

-- POL-9903: High risk (2 recent consecutive failures)
('POL-9903', '2026-03-01', 'Paid', NULL),
('POL-9903', '2026-04-01', 'Failed', 'Insufficient Funds'),
('POL-9903', '2026-05-01', 'Failed', 'Insufficient Funds'),

-- POL-9904: Medium risk (1 recent failure)
('POL-9904', '2026-03-01', 'Paid', NULL),
('POL-9904', '2026-04-01', 'Paid', NULL),
('POL-9904', '2026-05-01', 'Failed', 'Account Closed/Frozen'),

-- POL-9905: New policy, first payment cleared
('POL-9905', '2026-05-01', 'Paid', NULL);


