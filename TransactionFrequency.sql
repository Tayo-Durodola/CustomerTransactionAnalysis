-- TransactionFrequency.sql

-- To calculate the average number of transactions per customer per month and categorize them:
--    "High Frequency" (>= 10 transactions/month)
--    "Medium Frequency" (3-9 transactions/month)
--    "Low Frequency" (<= 2 transactions/month)

WITH SavingsTransactions AS (
    SELECT owner_id, transaction_date
    FROM savings_savingsaccount
    WHERE transaction_date IS NOT NULL
),
WithdrawalTransactions AS (
    SELECT owner_id, transaction_date
    FROM withdrawals_withdrawal
    WHERE transaction_date IS NOT NULL
),
AllTransactions AS (
    SELECT owner_id, transaction_date
    FROM SavingsTransactions
    UNION ALL
    SELECT owner_id, transaction_date
    FROM WithdrawalTransactions
),
TransactionCounts AS (
    SELECT
        u.id AS customer_id,
        COUNT(t.transaction_date) AS total_transactions,
        CASE
            WHEN MIN(t.transaction_date) IS NULL OR MAX(t.transaction_date) IS NULL THEN 1  -- Avoid division by zero if no transactions
            ELSE TIMESTAMPDIFF(MONTH, MIN(t.transaction_date), MAX(t.transaction_date)) + 1  -- Calculate active months
        END AS active_months
    FROM
        users_customuser u
        LEFT JOIN AllTransactions t ON u.id = t.owner_id
    GROUP BY
        u.id
)
SELECT
    CASE
        WHEN (total_transactions / active_months) >= 10 THEN 'High Frequency'
        WHEN (total_transactions / active_months) BETWEEN 3 AND 9 THEN 'Medium Frequency'
        ELSE 'Low Frequency'
    END AS frequency_category,  -- Categorize transaction frequency
    COUNT(customer_id) AS customer_count,
    ROUND(AVG(total_transactions / active_months), 1) AS avg_transactions_per_month  -- Calculate average transactions per month
FROM
    TransactionCounts
WHERE
    active_months > 0  -- Ensure we don't divide by zero
GROUP BY
    frequency_category
ORDER BY
    avg_transactions_per_month DESC;
