-- HighValueCustomers.sql

-- To find customers with at least one savings plan (is_regular_savings = 1)
--     that has a confirmed deposit (confirmed_amount > 0) AND at least one
--     investment plan (is_a_fund = 1).

SELECT
    u.id AS owner_id, 
    u.name,          
    COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 AND s.confirmed_amount > 0 THEN p.id ELSE NULL END) AS savings_count,
                                -- Counting distinct savings plan IDs for each customer that have deposits
    COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN p.id ELSE NULL END) AS investment_count,
                                -- Count distinct investment plan IDs for each customer
    SUM(CASE WHEN p.is_regular_savings = 1 THEN COALESCE(s.confirmed_amount, 0) ELSE 0 END) / 100 AS total_deposits
                                -- Calculate the total deposits from savings plans (converting kobo to base unit)
FROM
    users_customuser u  -- Starting with the users table
INNER JOIN
    plans_plan p ON u.id = p.owner_id  -- Joining with the plans table using the owner_id
LEFT JOIN
    savings_savingsaccount s ON p.id = s.plan_id
    AND p.is_regular_savings = 1 -- Join savings transactions only for savings plans
WHERE
    (p.is_regular_savings = 1 OR p.is_a_fund = 1) -- Considering both savings and investment plans
GROUP BY
    u.id, u.name 
HAVING
    savings_count > 0 AND investment_count > 0 -- Filtering for customers with at least one funded savings and one investment plan
ORDER BY
    total_deposits DESC; 
