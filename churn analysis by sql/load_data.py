"""
load_data.py
============
Loads the cleaned Telco Customer Churn data into a PostgreSQL table
called `customers`. Run 01_schema.sql first to create the table.

This expects the CSV that TCA.ipynb produces at its last cell:
    df.to_csv('data.csv', index=False)

That notebook already does the cleaning we need:
    - TotalCharges: blank -> "0", then cast to float
    - SeniorCitizen: 0/1 -> "no"/"yes"
So this script does NOT re-clean anything — it just renames columns to
snake_case to match the SQL schema and loads as-is. If you re-run the
notebook and regenerate data.csv, just re-run this script.

Usage:
    1. Run TCA.ipynb through the last cell so data.csv exists.
    2. Copy data.csv into the data/ folder of this project
       (or update CSV_PATH below to point at it directly).
    3. python load_data.py

Requires a .env file (see .env.example) or environment variables:
    DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD
"""

import os
import pandas as pd
from sqlalchemy import create_engine
from dotenv import load_dotenv

load_dotenv()

# Point this at the data.csv produced by TCA.ipynb
CSV_PATH = "../data/data.csv"

COLUMN_RENAME_MAP = {
    "customerID": "customer_id",
    "gender": "gender",
    "SeniorCitizen": "senior_citizen",
    "Partner": "partner",
    "Dependents": "dependents",
    "tenure": "tenure",
    "PhoneService": "phone_service",
    "MultipleLines": "multiple_lines",
    "InternetService": "internet_service",
    "OnlineSecurity": "online_security",
    "OnlineBackup": "online_backup",
    "DeviceProtection": "device_protection",
    "TechSupport": "tech_support",
    "StreamingTV": "streaming_tv",
    "StreamingMovies": "streaming_movies",
    "Contract": "contract",
    "PaperlessBilling": "paperless_billing",
    "PaymentMethod": "payment_method",
    "MonthlyCharges": "monthly_charges",
    "TotalCharges": "total_charges",
    "Churn": "churn",
}


def main():
    print(f"Reading {CSV_PATH} ...")
    df = pd.read_csv(CSV_PATH)
    print(f"Loaded {len(df)} rows, {len(df.columns)} columns")

    # Sanity checks — confirm the notebook's cleaning already happened
    if df["TotalCharges"].dtype == object:
        raise ValueError(
            "TotalCharges is still text — make sure you're loading the "
            "data.csv produced AFTER the cleaning cell in TCA.ipynb, "
            "not the raw CSV."
        )
    if set(df["SeniorCitizen"].unique()) - {"yes", "no"}:
        raise ValueError(
            "SeniorCitizen contains values other than 'yes'/'no' — "
            "make sure you're loading the cleaned data.csv."
        )

    df = df.rename(columns=COLUMN_RENAME_MAP)

    conn_str = (
        f"postgresql+psycopg2://{os.getenv('DB_USER', 'postgres')}:"
        f"{os.getenv('DB_PASSWORD', '')}@"
        f"{os.getenv('DB_HOST', 'localhost')}:"
        f"{os.getenv('DB_PORT', '5432')}/"
        f"{os.getenv('DB_NAME', 'telco_churn')}"
    )
    engine = create_engine(conn_str)

    print("Loading into PostgreSQL table 'customers' ...")
    df.to_sql("customers", engine, if_exists="append", index=False)
    print(f"Done. Inserted {len(df)} rows into 'customers'.")

c
if __name__ == "__main__":
    main()
