import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report

# 1. GENERATE SIMULATED SANLAM DATASET
np.random.seed(42)
n_records = 1000

data = {
    'customer_id': [f'SAN{i:05d}' for i in range(n_records)],
    'age': np.random.randint(22, 65, n_records),
    'monthly_premium': np.random.choice([150, 350, 750, 1200], n_records, p=[0.4, 0.3, 0.2, 0.1]),
    'missed_payments_3m': np.random.choice([0, 1, 2, 3], n_records, p=[0.75, 0.15, 0.07, 0.03]),
    'policy_tenure_months': np.random.randint(1, 60, n_records),
    'digital_app_logins_3m': np.random.randint(0, 15, n_records),
}


df = pd.DataFrame(data)

# Create a realistic target variable: Higher missed payments & low tenure = High chance of lapse
lapse_probability = (df['missed_payments_3m'] * 0.25) - (df['policy_tenure_months'] * 0.002) + 0.1
df['is_lapsed'] = np.where(lapse_probability + np.random.normal(0, 0.1, n_records) > 0.4, 1, 0)

print(f"Dataset generated. Total records: {len(df)} | Total Lapsed: {df['is_lapsed'].sum()}")

# 2. DATA PREPARATION & CLEANING
X = df[['age', 'monthly_premium', 'missed_payments_3m', 'policy_tenure_months', 'digital_app_logins_3m']]
y = df['is_lapsed']

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42, stratify=y)

# 3. PREDICTIVE MODELING (Random Forest)
model = RandomForestClassifier(n_estimators=100, random_state=42)
model.fit(X_train, y_train)

# 4. EVALUATION
y_pred = model.predict(X_test)
print("\n--- Model Performance Evaluation ---")
print(classification_report(y_test, y_pred))

# 5. GENERATE HIGH-RISK ACTION LIST FOR SANLAM RETENTION TEAM
df['lapse_probability'] = model.predict_proba(X)[:, 1]
high_risk_list = df[df['is_lapsed'] == 0].sort_values(by='lapse_probability', ascending=False).head(50)

# Save to CSV for Tableau dashboard ingestion
high_risk_list.to_csv('sanlam_high_risk_retention_list.csv', index=False)
print("\nSuccess: 'sanlam_high_risk_retention_list.csv' generated for retention team action.")
