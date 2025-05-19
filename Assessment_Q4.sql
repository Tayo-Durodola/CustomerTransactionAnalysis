-- Assessment_Q4.sql

-- Calculating CLV for each customer based on account tenure and transaction volume.
-- where CLV = (total_transactions / tenure) * 12 * avg_profit_per_transaction
-- and Profit per transaction is 0.1% of the transaction value.

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
        
        -- Calculating tenure in months, ensuring a minimum of 1 month
        GREATEST(TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()), 1) AS tenure_months,
        COUNT(t.amount) AS total_transactions,
        
        -- Calculate average profit per transaction (0.1% of average transaction value, kobo to base unit)
        CASE
            WHEN COUNT(t.amount) > 0 THEN AVG(t.amount) / 100 * 0.001
            ELSE 0  -- Handling cases where a customer has no transactions
        END AS avg_profit_per_transaction
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

    -- Calculate estimated CLV
    ROUND((total_transactions / tenure_months) * 12 * avg_profit_per_transaction, 2) AS estimated_clv
FROM
    CustomerStats
ORDER BY
    estimated_clv DESC;
