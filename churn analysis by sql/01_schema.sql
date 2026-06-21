-- ============================================================
-- Telco Customer Churn — Database Schema
-- ============================================================
-- Matches the cleaning done in TCA.ipynb:
--   - TotalCharges: blank -> "0", then cast to float
--   - SeniorCitizen: 0/1 -> "no"/"yes" (string, lowercase)
--   - All other Yes/No columns (Partner, Dependents, PhoneService,
--     PaperlessBilling, Churn, etc.) are left as-is: "Yes"/"No" strings
--
-- Run this first to create the table structure.
-- Usage:  psql -U your_user -d your_db -f 01_schema.sql
-- ============================================================

DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id        VARCHAR(20) PRIMARY KEY,
    gender              VARCHAR(10),
    senior_citizen      VARCHAR(5),    -- "yes" / "no" (lowercase, per notebook's conv())
    partner             VARCHAR(5),    -- "Yes" / "No"
    dependents          VARCHAR(5),    -- "Yes" / "No"
    tenure              INTEGER,
    phone_service       VARCHAR(5),    -- "Yes" / "No"
    multiple_lines      VARCHAR(20),
    internet_service    VARCHAR(20),
    online_security     VARCHAR(20),
    online_backup       VARCHAR(20),
    device_protection   VARCHAR(20),
    tech_support        VARCHAR(20),
    streaming_tv        VARCHAR(20),
    streaming_movies    VARCHAR(20),
    contract            VARCHAR(20),
    paperless_billing   VARCHAR(5),    -- "Yes" / "No"
    payment_method      VARCHAR(30),
    monthly_charges     NUMERIC(8,2),
    total_charges       NUMERIC(10,2), -- blanks already converted to 0 in notebook
    churn               VARCHAR(5)     -- "Yes" / "No"
);

-- Helpful indexes for the analysis queries we'll run later
CREATE INDEX idx_customers_contract ON customers(contract);
CREATE INDEX idx_customers_churn ON customers(churn);
CREATE INDEX idx_customers_internet_service ON customers(internet_service);
