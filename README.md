# Telco Customer Churn Analysis

Exploratory data analysis of customer churn for a fictional telecom company,
using **Python** (pandas, matplotlib, seaborn) for EDA and **SQL** (PostgreSQL)
for business-question-driven analysis.

## Dataset

[Telco Customer Churn](https://www.kaggle.com/datasets/blastchar/telco-customer-churn)
— 7,043 customers, 21 columns (demographics, account info, services subscribed,
billing, and churn label).

## Project Structure

```
project 1 python/
├── TCA.ipynb              # Python EDA: cleaning, visualization, insights
└── sql/
    ├── 01_schema.sql            # PostgreSQL table schema
    └── 02_analysis_queries.sql  # 13 business-question SQL queries
```

## How it fits together

1. **`TCA.ipynb`** loads the raw CSV, cleans it (fixes blank `TotalCharges`
   values, converts `SeniorCitizen` to yes/no), explores churn patterns with
   charts, and exports a cleaned `data.csv`.
2. **`sql/01_schema.sql`** creates a matching PostgreSQL table for that
   cleaned data.
3. **`sql/02_analysis_queries.sql`** answers business questions directly in
   SQL — churn rate by contract/tenure/payment method, revenue at risk,
   highest-risk customer segment, and a window-function ranking query.

## Setup

```bash
createdb telco_churn
psql -d telco_churn -f "project 1 python/sql/01_schema.sql"
# load the cleaned data.csv from TCA.ipynb into the customers table
psql -d telco_churn -f "project 1 python/sql/02_analysis_queries.sql"
```

## Key Findings

| Finding | Detail |
|---|---|
| **Overall churn rate** | 26.5% (1,869 of 7,043 customers) |
| **Contract type is the dominant driver** | Month-to-month churn: 42.7% vs. two-year: 2.8% |
| **Risk is front-loaded** | 0–6 month tenure churns at ~53%, vs. ~9.5% for 49+ months |
| **Churners pay more** | Avg. $74.44/mo for churned vs. $61.27/mo for retained |
| **Payment method matters** | Electronic check churns at 45.3% — 3x automatic payment methods |
| **Add-on services correlate with retention** | Churn falls from ~30–39% (0–1 services) to 5.3% (all 4 services) |
| **Revenue at risk** | ~30.5% of monthly recurring revenue sits with already-churned accounts |
| **Highest-risk segment** | Month-to-month + Fiber optic + tenure ≤ 12 months → **70.2% churn rate** |

## Tools Used

- **Python** — pandas, matplotlib, seaborn
- **PostgreSQL** — SQL aggregations, `CASE` statements, `HAVING`, window functions
