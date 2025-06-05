# CustomerTransactionAnalysis

This repository contains my solutions for a data analysis assessment. The project focuses on analyzing customer transaction data within a financial database, providing insights into customer behavior, account activity, and lifetime value. Using a dataset containing customer profiles, savings transactions, investment plans, and withdrawals, I designed four SQL queries to address key business questions: identifying high-value customers, analyzing transaction frequency, detecting inactive accounts, and estimating customer lifetime value (CLV). Each query is stored in a separate SQL file (`HighValueCustomers.sql, TransactionFrequency.sql, AccountInactivity.sql, CustomerLifetimeValue.sql`), and this `README` provides a detailed explanation of my approach, logic, and challenges encountered. 
This project showcases my ability to write efficient, accurate, and well-structured SQL queries, making it a valuable addition to my data analytics portfolio.

The dataset includes four tables:
- users_customuser: Customer demographic and account information.
- savings_savingsaccount: Records of deposit transactions.
- plans_plan: Details of customer savings and investment plans.
- withdrawals_withdrawal: Records of withdrawal transactions.

---

### Question 1: Identifying High-Value Customers with Multiple Products
The goal was to identify customers with at least one funded savings plan (`is_regular_savings = 1`) and one funded investment plan (`is_a_fund = 1`), and rank them by total deposits.

**Approach**:
-   Joined `users_customuser` with `plans_plan` twice: once for savings plans and once for investment plans, using `owner_id`.
-   Linked `savings_savingsaccount` to `plans_plan` via `plan_id` to verify funded transactions, where `confirmed_amount > 0` indicates a funded plan.
-   Used `COUNT(DISTINCT)` to count unique savings and investment plans per customer, ensuring no double-counting.
-   Calculated `total_deposits` by summing `confirmed_amount` from `savings_savingsaccount` and converting from kobo to NGN (divide by 100).
-   Applied `HAVING` to filter customers with at least one of each plan type, then sorted by `total_deposits` in descending order.

**Challenges and Assumptions**:

-   `is_regular_savings` was found in `plans_plan` rather than `savings_savingsaccount` as hinted, requiring a join via `plan_id`.
-   **Assumption:** All deposits in `savings_savingsaccount` are considered 'funded' for the purpose of this analysis.
-   Made reasonable assumptions due to schema limitations, such as counting all deposits regardless of plan type.

---

### Question 2: Transaction Frequency Analysis
The task was to calculate the average number of transactions per customer per month and categorize them into High Frequency (≥ 10), Medium Frequency (3–9), and Low Frequency (≤ 2).

**Approach**:
- Created a CTE (`AllTransactions`) to combine deposits (`savings_savingsaccount.confirmed_amount`) and withdrawals (`withdrawals_withdrawal.amount_withdrawn`) using `UNION ALL`, using `transaction_date` for timestamps.
- Calculated `total_transactions` and `active_months` per customer with `TIMESTAMPDIFF(MONTH, MIN(transaction_date), MAX(transaction_date)) + 1` to include the full period, avoiding division by zero.
- Computed `avg_transactions_per_month` by dividing `total_transactions` by `active_months`.
- Used a `CASE` statement to categorize customers and grouped by category to get `customer_count` and the average, rounding to 1 decimal place.
- Ordered by `avg_transactions_per_month` in descending order.

**Challenges**:
- Included both deposits and withdrawals as transactions, which matches with the schema’s transaction tracking.
- Added 1 to `TIMESTAMPDIFF` to handle cases where a customer’s first and last transaction are in the same month.
- Used `HAVING total_transactions > 0` to exclude customers with no transactions, ensuring meaningful averages.

---

### Question 3: Account Inactivity Alert
The objective was to flag active accounts (savings or investments) with no transactions in the last 365 days as of 04:24 PM WAT on May 19, 2025.

**Approach**:
- Used `UNION` to combine results for savings and investment plans.
- For savings plans (`plans_plan.is_regular_savings = 1`), joined with `savings_savingsaccount` to find the latest `transaction_date` using `MAX`, and calculated `inactivity_days` with `DATEDIFF(CURDATE(), MAX(transaction_date))`.
- For investment plans (`plans_plan.is_a_fund = 1`), used `COALESCE(p.last_charge_date, MAX(s.transaction_date))` to prioritize `last_charge_date` or the latest transaction date, filtered by `is_deleted = 0` for active plans.
- Applied `HAVING` to include only plans inactive for over 365 days.

**Challenges**:
- Handled cases where `last_charge_date` might be NULL by using `COALESCE` with `transaction_date` from `savings_savingsaccount`.
- Used `MAX` to determine the latest transaction per plan, ensuring accuracy.
- Adjusted for the current date (May 19, 2025) for the purpose of this analysis.

---

### Question 4: Customer Lifetime Value (CLV) Estimation
The task was to estimate CLV based on tenure (months since signup), total transactions, and profit (0.1% of transaction value).

**Approach**:
- Combined deposits (`savings_savingsaccount.confirmed_amount`) and withdrawals (`withdrawals_withdrawal.amount_withdrawn`) in a CTE (`AllTransactions`) using `UNION ALL`.
- Calculated `tenure_months` with `TIMESTAMPDIFF(MONTH, date_joined, CURDATE())`, ensuring at least 1 month with `GREATEST(..., 1)`.
- Counted `total_transactions` and computed `avg_profit_per_transaction` as 0.1% of the average transaction value (converted from kobo to NGN by dividing by 100 and multiplying by 0.001).
- Calculated CLV as `(total_transactions / tenure_months) * 12 * avg_profit_per_transaction`, rounding to 2 decimal places.
- Ordered by `estimated_clv` in descending order.

**Challenges**:
- Included both deposits and withdrawals in transaction counts to reflect total activity.
- Used `GREATEST` to prevent division by zero for customers with zero tenure.
- Converted amounts from kobo to NGN for profit calculation, ensuring consistency with the formula.

---

### Submission Notes
- All SQL files (`HighValueCustomers.sql, TransactionFrequency.sql, AccountInactivity.sql, CustomerLifetimeValue.sql`) contain single queries with proper formatting and comments.
- This work is my original creation and has not been shared with other candidates.
