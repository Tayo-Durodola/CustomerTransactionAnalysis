-- Assessment_Q3.sql

-- Identify all active savings and investment plans with no transactions in the last 365 days

WITH SavingsInactivity AS (
    SELECT
        p.id AS plan_id,
        p.owner_id,
        'Savings' AS plan_type,
        MAX(s.transaction_date) AS last_transaction_date,  -- Find the latest transaction date for each savings plan
        DATEDIFF(CURDATE(), MAX(s.transaction_date)) AS inactivity_days  -- Calculate days since the latest transaction
    FROM
        plans_plan p
        LEFT JOIN savings_savingsaccount s ON p.id = s.plan_id  -- Join plans with their savings transactions
    WHERE
        p.is_regular_savings = 1        -- Filter for savings plans
        AND p.is_deleted = 0             -- Filter for active plans (assuming 0 means active)
    GROUP BY
        p.id, p.owner_id                 -- Group by plan to get the latest transaction date for each
    HAVING
        last_transaction_date IS NOT NULL   -- Exclude savings plans with no transactions
        AND DATEDIFF(CURDATE(), last_transaction_date) > 365  -- Filter for plans with inactivity > 365 days
),
InvestmentInactivity AS (
    SELECT
        p.id AS plan_id,
        p.owner_id,
        'Investment' AS plan_type,
        COALESCE(p.last_charge_date, NULL) AS last_transaction_date,  -- Use last_charge_date for investments, or NULL if not available
        DATEDIFF(CURDATE(), COALESCE(p.last_charge_date, NULL)) AS inactivity_days -- Calculate inactivity days
    FROM
        plans_plan p
        LEFT JOIN savings_savingsaccount s ON p.id = s.plan_id  -- Join plans with savings transactions
    WHERE
        p.is_a_fund = 1               -- Filter for investment plans
        AND p.is_deleted = 0             -- Filter for active plans
    GROUP BY
        p.id, p.owner_id, p.last_charge_date  -- Group by plan and last_charge_date
    HAVING
        last_transaction_date IS NOT NULL   -- Exclude investment plans with no activity
        AND DATEDIFF(CURDATE(), last_transaction_date) > 365  -- Filter for plans inactive for > 365 days
)
-- Combine and Return Inactive Plans
SELECT
    plan_id,
    owner_id,
    plan_type,
    last_transaction_date,
    inactivity_days
FROM SavingsInactivity
UNION ALL   -- Combine results from savings and investment CTEs (keeping all rows)
SELECT
    plan_id,
    owner_id,
    plan_type,
    last_transaction_date,
    inactivity_days
FROM InvestmentInactivity
ORDER BY inactivity_days DESC;  -- Order by inactivity days (most inactive first)
