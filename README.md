# E-Commerce Churn Prediction 

End-to-end churn prediction on the Olist Brazilian e-commerce dataset, covering SQL-based, leakage-safe feature engineering, cohort analysis, cost-based threshold selection, SHAP interpretability, and a Streamlit demo.

> **Status:** 🚧 In progress. See [Roadmap](#roadmap).

---

## 1. Business Problem
[2-3 sentences: who loses money when customers don't return, what action a prediction would trigger (e.g., targeted discount, win-back email), and why early identification matters.]

## 2. Churn Definition
- **Unit of analysis:** one row per customer (`customer_unique_id`)
- **Snapshot date:** [TODO]
- **Observation window (features):** all activity before the snapshot date
- **Prediction window (label):** [N] days after the snapshot date
- **Label:** `churn = 1` if the customer places no order within [N] days after the snapshot
- **Why N = [value]:** [TODO: justify using the repeat-purchase gap distribution]

| Candidate N | Churn rate |
|-------------|-----------|
| [90]        | [TODO]    |
| [120]       | [TODO]    |
| [180]       | [TODO]    |

## 3. Dataset
[Olist Brazilian E-Commerce Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (Kaggle), 9 relational tables: orders, customers, items, payments, reviews, products, sellers, geolocation, category translation.

**Key data notes**
- `customer_id` is per-order; `customer_unique_id` identifies the actual customer.
- [TODO: share of one-time buyers, date range, class balance]

## 4. Approach
1. **Data audit (SQL):** nulls, duplicates, orphan keys, date ranges
2. **Cohort and retention analysis (SQL + Python)**
3. **Feature engineering (SQL):** recency, frequency, monetary value, average order gap, review scores, delivery delays, category diversity [edit to match what you build]
4. **Leakage prevention:** features use only data before the snapshot; train/validation/test split before any fitting; preprocessing inside pipelines
5. **Modeling:** dummy baseline → logistic regression → tree-based models; cross-validated tuning
6. **Evaluation:** PR-AUC, ROC-AUC, precision/recall/F1, calibration
7. **Threshold selection:** based on retention cost vs. lost-customer value
8. **Interpretability:** SHAP (global and per-customer)
9. **Demo:** Streamlit app returning churn probability

## 5. Results
[TODO: model comparison table]

| Model | PR-AUC | ROC-AUC | Precision | Recall | F1 |
|-------|--------|---------|-----------|--------|----|
| Dummy baseline | | | | | |
| Logistic Regression | | | | | |
| [Best model] | | | | | |

**Chosen threshold:** [TODO] because [cost reasoning]

## 6. Key Insights
- [TODO: 3-5 findings in business language]

## 7. Recommendations
- [TODO: actions the business could take based on the model and SHAP results]

## 8. Limitations
- [TODO: e.g., high share of one-time buyers, single-region data, no marketing/browsing data, snapshot-specific results]

## 9. Repository Structure
```
├── data/               # raw and processed data (not committed if large)
├── sql/                # schema, audit, cohort, feature queries
├── notebooks/          # EDA and modeling
├── src/                # reusable pipeline code
├── models/             # saved model artifacts
├── app/                # Streamlit demo
├── requirements.txt
└── README.md
```

## 10. How to Run
```bash
git clone https://github.com/[username]/ecommerce-churn-prediction.git
cd ecommerce-churn-prediction
pip install -r requirements.txt
# 1. Download dataset from Kaggle into data/raw/
# 2. Run SQL scripts in /sql in order
# 3. Run notebooks or src/ pipeline
# 4. streamlit run app/app.py
```

## 11. Tech Stack
Python, SQL ([SQLite/PostgreSQL]), pandas, scikit-learn, [XGBoost/LightGBM], SHAP, Streamlit
