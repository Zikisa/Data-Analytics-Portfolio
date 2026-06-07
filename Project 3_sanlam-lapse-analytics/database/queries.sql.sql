SELECT 
    c.customer_id,
    c.province,
    p.policy_id,
    p.policy_type,
    p.monthly_premium,
    ph.payment_date,
    ph.payment_status,
    ISNULL(ph.failure_reason, 'N/A') AS failure_reason
FROM customers c
INNER JOIN policies p ON c.customer_id = p.customer_id
INNER JOIN payment_history ph ON p.policy_id = ph.policy_id
ORDER BY ph.payment_date DESC, p.policy_id;

SELECT 
    c.province AS [Province],
    COUNT(DISTINCT p.policy_id) AS [Total Active Policies],
    SUM(p.monthly_premium) AS [Expected Monthly Revenue (ZAR)],
    SUM(CASE WHEN ph.payment_status = 'Paid' THEN p.monthly_premium ELSE 0 END) AS [Collected Revenue (ZAR)],
    SUM(CASE WHEN ph.payment_status = 'Failed' THEN p.monthly_premium ELSE 0 END) AS [Revenue Lost (ZAR)],
    ROUND(
        (SUM(CASE WHEN ph.payment_status = 'Failed' THEN p.monthly_premium ELSE 0 END) * 100.0) / 
        NULLIF(SUM(p.monthly_premium), 0), 2
    ) AS [Revenue Loss Percentage (%)]
FROM customers c
INNER JOIN policies p ON c.customer_id = p.customer_id
INNER JOIN payment_history ph ON p.policy_id = ph.policy_id
-- Filters for the most recent month of activity to provide an operational snapshot
WHERE ph.payment_date = '2026-05-01' 
GROUP BY c.province
ORDER BY [Revenue Loss Percentage (%)] DESC;
