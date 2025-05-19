-- Find accounts with no transactions in the last 365 days
-- Savings plans
SELECT 
    p.id AS plan_id,
    p.owner_id,
    'Savings' AS type,
    MAX(s.transaction_date) AS last_transaction_date,
    DATEDIFF(CURDATE(), MAX(s.transaction_date)) AS inactivity_days
FROM 
    plans_plan p
    LEFT JOIN savings_savingsaccount s ON p.id = s.plan_id
WHERE 
    p.is_regular_savings = 1
    AND p.is_deleted = 0
GROUP BY 
    p.id, p.owner_id
HAVING 
    last_transaction_date IS NOT NULL
    AND DATEDIFF(CURDATE(), last_transaction_date) > 365
UNION
-- Investment plans
SELECT 
    p.id AS plan_id,
    p.owner_id,
    'Investment' AS type,
    COALESCE(p.last_charge_date, MAX(s.transaction_date)) AS last_transaction_date,
    DATEDIFF(CURDATE(), COALESCE(p.last_charge_date, MAX(s.transaction_date))) AS inactivity_days
FROM 
    plans_plan p
    LEFT JOIN savings_savingsaccount s ON p.id = s.plan_id
WHERE 
    p.is_a_fund = 1
    AND p.is_deleted = 0
GROUP BY 
    p.id, p.owner_id, p.last_charge_date
HAVING 
    last_transaction_date IS NOT NULL
    AND DATEDIFF(CURDATE(), last_transaction_date) > 365;