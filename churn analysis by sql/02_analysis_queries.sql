-- ============================================================
-- Telco Customer Churn — Analysis Queries
-- ============================================================
-- Matches the schema/cleaning from TCA.ipynb:
--   - churn, partner, dependents, phone_service, paperless_billing
--     are stored as 'Yes' / 'No' strings (not booleans)
--   - senior_citizen is stored as 'yes' / 'no' (lowercase)
--   - total_charges is already numeric (blanks -> 0 in the notebook)
--
-- Each query is labeled with the business question it answers.
-- ============================================================


-- ------------------------------------------------------------
-- Q1. What is the overall churn rate?
-- ------------------------------------------------------------
SELECT
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2
    ) AS churn_rate_pct
FROM customers;


-- ------------------------------------------------------------
-- Q2. How does churn rate vary by contract type?
--     (Hypothesis: month-to-month customers churn far more
--      than those locked into 1- or 2-year contracts.)
-- ------------------------------------------------------------
SELECT
    contract,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2
    ) AS churn_rate_pct
FROM customers
GROUP BY contract
ORDER BY churn_rate_pct DESC;


-- ------------------------------------------------------------
-- Q3. How does churn rate vary by tenure bucket?
--     (Are new customers more likely to leave?)
-- ------------------------------------------------------------
SELECT
    CASE
        WHEN tenure <= 6   THEN '0-6 months'
        WHEN tenure <= 12  THEN '7-12 months'
        WHEN tenure <= 24  THEN '13-24 months'
        WHEN tenure <= 48  THEN '25-48 months'
        ELSE '49+ months'
    END AS tenure_bucket,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2
    ) AS churn_rate_pct
FROM customers
GROUP BY tenure_bucket
ORDER BY MIN(tenure);


-- ------------------------------------------------------------
-- Q4. How does churn rate vary by payment method?
--     (Hypothesis: electronic check users churn more.)
-- ------------------------------------------------------------
SELECT
    payment_method,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2
    ) AS churn_rate_pct
FROM customers
GROUP BY payment_method
ORDER BY churn_rate_pct DESC;


-- ------------------------------------------------------------
-- Q5. Does internet service type relate to churn?
-- ------------------------------------------------------------
SELECT
    internet_service,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2
    ) AS churn_rate_pct
FROM customers
GROUP BY internet_service
ORDER BY churn_rate_pct DESC;


-- ------------------------------------------------------------
-- Q6. Do customers without add-on services (security, backup,
--     tech support, device protection) churn more? Build a
--     "support services" score.
-- ------------------------------------------------------------
SELECT
    (
        CASE WHEN online_security   = 'Yes' THEN 1 ELSE 0 END +
        CASE WHEN online_backup     = 'Yes' THEN 1 ELSE 0 END +
        CASE WHEN device_protection = 'Yes' THEN 1 ELSE 0 END +
        CASE WHEN tech_support      = 'Yes' THEN 1 ELSE 0 END
    ) AS support_services_count,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2
    ) AS churn_rate_pct
FROM customers
GROUP BY support_services_count
ORDER BY support_services_count;


-- ------------------------------------------------------------
-- Q7. How much monthly recurring revenue is "at risk" right now?
--     (Sum of monthly_charges for currently-churned customers —
--      i.e. revenue already lost — vs. total revenue base.)
-- ------------------------------------------------------------
SELECT
    ROUND(SUM(CASE WHEN churn = 'Yes' THEN monthly_charges ELSE 0 END), 2) AS revenue_lost_monthly,
    ROUND(SUM(monthly_charges), 2) AS total_monthly_revenue,
    ROUND(
        100.0 * SUM(CASE WHEN churn = 'Yes' THEN monthly_charges ELSE 0 END)
        / SUM(monthly_charges), 2
    ) AS pct_revenue_lost
FROM customers;


-- ------------------------------------------------------------
-- Q8. Average monthly charges: churned vs. retained customers.
--     (Are churners paying more or less than loyal customers?)
-- ------------------------------------------------------------
SELECT
    churn,
    COUNT(*) AS total_customers,
    ROUND(AVG(monthly_charges), 2) AS avg_monthly_charges,
    ROUND(AVG(tenure), 1) AS avg_tenure_months,
    ROUND(AVG(total_charges), 2) AS avg_total_charges
FROM customers
GROUP BY churn;


-- ------------------------------------------------------------
-- Q9. Senior citizens vs. non-senior citizens — churn comparison.
--     Note: senior_citizen is lowercase 'yes'/'no' per the notebook's
--     conv() function, unlike the other Yes/No columns.
-- ------------------------------------------------------------
SELECT
    senior_citizen,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2
    ) AS churn_rate_pct
FROM customers
GROUP BY senior_citizen;


-- ------------------------------------------------------------
-- Q10. Highest-risk customer segment: combine contract type +
--      tenure bucket + internet service to find the worst
--      combination for churn (with a minimum sample size so we
--      don't flag tiny, noisy segments).
-- ------------------------------------------------------------
SELECT
    contract,
    internet_service,
    CASE
        WHEN tenure <= 12 THEN '0-12 months'
        ELSE '13+ months'
    END AS tenure_bucket,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2
    ) AS churn_rate_pct
FROM customers
GROUP BY contract, internet_service, tenure_bucket
HAVING COUNT(*) >= 30
ORDER BY churn_rate_pct DESC
LIMIT 10;


-- ------------------------------------------------------------
-- Q11. Paperless billing vs. churn.
-- ------------------------------------------------------------
SELECT
    paperless_billing,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2
    ) AS churn_rate_pct
FROM customers
GROUP BY paperless_billing;


-- ------------------------------------------------------------
-- Q12. Rank payment methods by churn rate using a window function
--      (demonstrates window function usage for the portfolio).
-- ------------------------------------------------------------
SELECT
    payment_method,
    churn_rate_pct,
    RANK() OVER (ORDER BY churn_rate_pct DESC) AS churn_rank
FROM (
    SELECT
        payment_method,
        ROUND(
            100.0 * SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2
        ) AS churn_rate_pct
    FROM customers
    GROUP BY payment_method
) AS payment_churn;


-- ------------------------------------------------------------
-- Q13. Gender breakdown of churn (matches the gender chart in
--      TCA.ipynb cell 13).
-- ------------------------------------------------------------
SELECT
    gender,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2
    ) AS churn_rate_pct
FROM customers
GROUP BY gender;
