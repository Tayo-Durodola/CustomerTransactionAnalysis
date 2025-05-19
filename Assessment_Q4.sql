-- Calculate Customer Lifetime Value (CLV) for each customer
WITH AllTransactions AS (
    SELECT owner_id, confirmed_amount AS amount
    FROM savings_savingsaccount
    WHERE transaction_date IS NOT NULL
    UNION ALL
    SELECT owner_id, amount_withdrawn AS amount
    FROM withdrawals_withdrawal
    WHERE transaction_date IS NOT NULL
),
CustomerStats AS (
    SELECT 
        u.id AS customer_id,
        u.name,
        GREATEST(TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()), 1) AS tenure_months,
        COUNT(t.amount) AS total_transactions,
        AVG(t.amount) / 100 * 0.001 AS avg_profit_per_transaction -- 0.1% of avg transaction value (kobo to NGN)
    FROM 
        users_customuser u
        LEFT JOIN AllTransactions t ON u.id = t.owner_id
    GROUP BY 
        u.id, u.name, u.date_joined
)
SELECT 
    customer_id,
    name,
    tenure_months,
    total_transactions,
    ROUND((total_transactions / tenure_months) * 12 * avg_profit_per_transaction, 2) AS estimated_clv
FROM 
    CustomerStats
ORDER BY 
    estimated_clv DESC;