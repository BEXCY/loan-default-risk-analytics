# Loan Default Risk Analytics

An end-to-end risk analytics project using Python, SQL, Machine Learning, and Power BI to analyze loan default patterns, estimate default probability, and support risk-based manual review.

---

## 📌 Project Overview

Lending decisions involve evaluating borrower characteristics, loan attributes, credit history, and other risk indicators to determine the likelihood of repayment.

This project analyzes historical LendingClub loan data to answer:

> **Which loan applications show elevated default risk, and how can risk teams prioritize applications for additional review?**

The project combines exploratory data analysis, machine learning, SQL-based analysis, and business intelligence to create an end-to-end risk analytics workflow.

---

## 🎯 Business Questions

The analysis focuses on questions such as:

- Which borrower and loan characteristics are associated with higher observed default rates?
- How does default risk vary across income, FICO score, DTI, employment history, loan purpose, and geography?
- Can machine learning estimate the probability of loan default?
- How well does the model separate lower-risk and higher-risk applications?
- How can predicted risk be translated into practical risk segments?
- Which applications could be prioritized for additional manual review?
- How much loan exposure is associated with higher-risk applications?

---

## 🗂️ Dataset

The project uses historical LendingClub accepted-loan data.

The original dataset contains millions of loan records and numerous borrower, loan, credit, and performance attributes.

For this project, relevant application-time variables were selected for analysis and modeling.

### Modeling Dataset

After filtering to loans with known final outcomes:

- **Total modeling observations:** 1,348,099
- **Observed default rate:** 19.98%
- **Non-default:** 80.02%
- **Default:** 19.98%

Current/ongoing loans were excluded because their final repayment outcome was not yet known.

### Target Variable

The target variable `default` was created from historical loan outcomes:

- `1` → Default / Charged Off
- `0` → Fully Paid

Historical status categories were mapped into these two outcome classes for supervised learning.

---

## 🛠️ Tools & Technologies

| Category | Tools |
|---|---|
| Programming | Python |
| Data Analysis | Pandas, NumPy |
| Visualization | Matplotlib |
| Machine Learning | Scikit-learn, LightGBM |
| Database | MySQL |
| Business Intelligence | Power BI |
| Development | Google Colab, MySQL Workbench |
| Version Control | Git, GitHub |

---

## 🔍 Analytical Approach

### 1. Data Preparation

The raw dataset was processed to:

- Select relevant variables
- Filter loans with known outcomes
- Handle missing values
- Convert loan term into numeric months
- Convert employment length into numeric years
- Create a consolidated FICO score
- Clean DTI and utilization values
- Create analytical risk bands
- Add geographic information
- Prepare categorical and numerical features

---

### 2. Exploratory Data Analysis

Default rates were analyzed across:

- Loan grade
- Income
- FICO score
- Debt-to-income ratio
- Interest rate
- Loan amount
- Employment history
- Loan purpose
- Home ownership
- Verification status
- Geographic state

Some notable observed patterns included increasing default rates across several higher-risk borrower/loan segments.

For example, observed default rates by LendingClub grade ranged from approximately:

**6.04% for Grade A → 49.67% for Grade G**

These are historical associations in the dataset and should not be interpreted as causal relationships.

---

## 🤖 Machine Learning

Two classification models were evaluated.

### Logistic Regression

Used as a baseline model.

**ROC-AUC: 0.7139**

### LightGBM

A gradient-boosting model was trained using the selected borrower, loan, credit, and geographic characteristics.

**ROC-AUC: 0.7283**

LightGBM improved ROC-AUC by approximately **0.0144** over the logistic regression baseline.

---

## 📊 Model Features

The final model uses 26 features covering:

### Loan characteristics
- Loan amount
- Funded amount
- Loan term
- Interest rate
- Installment
- Loan purpose

### Borrower characteristics
- Annual income
- Employment length
- Home ownership
- Verification status

### Credit characteristics
- FICO score
- DTI
- Delinquencies
- Recent inquiries
- Open accounts
- Public records
- Revolving balance
- Revolving utilization
- Total accounts
- Current balance
- Total revolving credit limit
- Recent account activity
- Average current balance
- Bankcard utilization
- Mortgage accounts

### Geography
- State

LendingClub `grade` and `sub_grade` were excluded from the predictive model because they represent existing lender risk classifications and could allow the model to largely reproduce an existing risk assessment rather than independently estimate risk from underlying characteristics.

---

## 🔎 Model Feature Importance

The most influential features in the LightGBM model included:

1. `addr_state`
2. `int_rate`
3. `acc_open_past_24mths`
4. `annual_inc`
5. `dti_clean`
6. `loan_amnt`
7. `total_rev_hi_lim`
8. `purpose`
9. `total_acc`
10. `emp_length_years`

Feature importance indicates which variables the model relied on most heavily; it does not establish causation.

---

## 🚦 Risk Segmentation

Predicted default probabilities were converted into four illustrative risk bands:

| Risk Band | Predicted Default Probability |
|---|---:|
| Low Risk | <20% |
| Moderate Risk | 20–30% |
| High Risk | 30–40% |
| Very High Risk | ≥40% |

On the held-out test set, observed default rates increased across these bands:

| Risk Band | Observed Default Rate |
|---|---:|
| Low Risk | 10.92% |
| Moderate Risk | 24.75% |
| High Risk | 34.46% |
| Very High Risk | 49.09% |

This indicates that the model's predicted risk segmentation meaningfully separated applications by observed historical outcomes in the test set.

---

## 🧑‍💼 Manual Review Scenario

An illustrative threshold of **30% predicted default probability** was used to demonstrate how model predictions could support risk triage.

Under this scenario:

- **269,620** test applications were scored
- **55,449** applications were flagged
- **20.57%** of applications were flagged for review

The threshold is presented as an illustrative business scenario rather than an approved credit-policy threshold.

A production implementation would require validation, calibration, business capacity considerations, and appropriate risk-policy review before selecting an operational threshold.

---

## 🗄️ SQL Analysis

The scored applications will be loaded into MySQL to answer business questions such as:

- What percentage of applications require manual review?
- How much loan exposure is associated with reviewed applications?
- Which income segments have higher predicted risk?
- How does predicted risk vary by loan purpose?
- Which states have higher average predicted risk?
- What does the manual-review queue look like?

SQL scripts will be added to the `/sql` directory.

---

## 📊 Power BI Dashboard

The final Power BI dashboard will provide an interactive view of:

- Overall application volume
- Predicted risk distribution
- Loan exposure by risk segment
- Default-risk patterns across borrower segments
- Geographic risk patterns
- Manual-review volume
- Manual-review exposure
- Application-level review queue

The Power BI file and dashboard screenshots will be added to the `/powerbi` directory after completion.

---

## 📁 Project Structure

```text
loan-default-risk-analytics/
│
├── README.md
│
├── notebooks/
│   └── loan_default_risk_analysis.ipynb
│
├── sql/
│   ├── 01_create_database.sql
│   ├── 02_create_table.sql
│   ├── 03_risk_analysis.sql
│   └── 04_manual_review_queue.sql
│
├── powerbi/
│   └── loan_risk_dashboard.pbix
│
├── outputs/
│   ├── model_metrics.csv
│   └── risk_band_summary.csv
│
├── data/
│   └── README.md
│
└── requirements.txt
