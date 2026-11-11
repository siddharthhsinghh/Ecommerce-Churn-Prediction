# E-Commerce Churn Prediction (SQL + ML)

End-to-end churn prediction on the Olist Brazilian e-commerce dataset: SQL-based, leakage-safe feature engineering, temporal validation, cost-aware evaluation, SHAP interpretability, and a Streamlit demo.

> **Status:** 🚧 In progress.

---

## 1. Business Problem
Most customers on a marketplace buy once and never return, and acquiring new customers costs more than retaining existing ones. This project scores customers who have already ordered by how likely they are to place another order in the next 90 days, so retention offers (vouchers, win-back emails) can be targeted at the right people instead of sent to everyone.

## 2. Target Definition
- **Unit of analysis:** one row per customer (`customer_unique_id`)
- **Eligible customers:** customers whose first valid order is before the snapshot date
- **Valid order:** any order not `canceled` or `unavailable`
- **Prediction window:** 90 days after the snapshot date
- **Target:** `returned = 1` if the customer places a valid order within the window, else `0` (churn = 1 − returned)
- **Features:** use only information available before the snapshot date

**Why this framing:** only 3.04% of customers ever order twice, so "will this customer return?" is the meaningful, honest question. Modeling the rare class directly keeps the evaluation honest.

### Why 90 days
Gap analysis of days between a customer's consecutive orders (see `sql/04_gap_analysis.sql`):

| Gap (days) | Share of repeat gaps | Cumulative |
|---|---|---|
| 0-30 | 50.54% | 50.5% |
| 31-60 | 11.50% | 62.0% |
| 61-90 | 6.96% | 69.0% |
| 91-180 | 14.73% | 83.7% |
| 181-365 | 13.55% | 97.3% |
| 365+ | 2.70% | 100% |

- There is no sharp "elbow", so 90 days is a business-horizon choice (a realistic retention-campaign window) that captures about 69% of repeat behavior.
- It leaves room for two non-overlapping snapshots before the data ends (see below).
- **Trade-off:** about 31% of repeat-order gaps are longer than 90 days, so some customers labeled "did not return" will return later.

### Snapshots (temporal validation)
| Set | Snapshot date | Window | Eligible customers | Returners | Return rate |
|---|---|---|---|---|---|
| Train | 2018-03-01 | to ~2018-05-30 | 56,630 | 395 | 0.70% |
| Test | 2018-06-01 | to ~2018-08-30 | 76,845 | 432 | 0.56% |

The model is trained on one period and tested on the following one, which mimics real deployment. (Counts are from the eligibility check queries; final table counts: TODO.)

## 3. Dataset
[Olist Brazilian E-Commerce Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (Kaggle), 9 relational tables, 99,441 orders.

**Key data findings (from `sql/02_data_exploration.sql`)**
- `customer_id` is per-order; `customer_unique_id` identifies the real customer. After excluding canceled/unavailable orders there are **94,990 customers, 2,888 (3.04%) with more than one order**.
- **28.9% of repeat "gaps" are same-day orders** (930 of 3,217), likely split carts or multi-seller checkouts, so frequency features count distinct purchase dates, not orders.
- **Usable date range is 2017-01 to 2018-08.** 2016 has almost no orders, and Sep 2018 (16 orders) and Oct 2018 (4) are effectively empty.
- **Empty date fields** (160 missing approval dates, 1,783 missing carrier dates, 2,965 missing delivery dates) were loaded by MySQL as `0000-00-00`; the import now converts them to NULL.
- **Duplicate reviews:** some `review_id`s appear up to 3 times and some orders have 2-3 reviews, so reviews are aggregated to one row per order before joining.
- No orphan keys (orders without customers, items without orders: 0).

## 4. Approach
1. **Import and audit (SQL):** schema, loading, null/duplicate/orphan checks
2. **Business analysis (SQL):** order volume, review scores, delivery performance
3. **Gap analysis (SQL):** choose the prediction window from repeat-order gaps
4. **Cohort retention (SQL):** TODO
5. **Feature engineering (SQL):** recency, distinct purchase dates, spend, tenure, average gap between purchases, first-order delivery delay vs. estimate, freight-to-price ratio, payment type, installments, item count, state, last review score [edit to match what you build]
6. **Leakage prevention:** features use only pre-snapshot data; reviews and delivery dates are included only if known before the snapshot; temporal train/test split
7. **Modeling:** dummy baseline → logistic regression → tree-based models; tuning on the training snapshot only
8. **Evaluation:** PR-AUC and lift in the top 5-10% of scored customers (random baseline = 0.56-0.70%), with bootstrap confidence intervals. Accuracy and ROC-AUC are not used as headline metrics because of the class imbalance.
9. **Threshold / targeting:** based on retention-offer cost vs. customer value: TODO
10. **Interpretability:** SHAP (global and per-customer)
11. **Demo:** Streamlit app returning return probability

## 5. Results
TODO: add after modeling.

| Model | PR-AUC | Lift @ top 5% | Lift @ top 10% |
|-------|--------|---------------|----------------|
| Dummy baseline | | | |
| Logistic Regression | | | |
| [Best model] | | | |

## 6. Key Insights
- TODO: 3-5 findings in business language (e.g., churn rate by delivery delay, review score, state)

## 7. Recommendations
- TODO: actions the business could take based on the model and SHAP results

## 8. Limitations
- Very low base rate (0.56-0.70%) with about 400 positives per snapshot, so metrics are noisy; confidence intervals are reported.
- 90-day window misses customers who return later.
- The dataset covers only 2017-2018 and a single marketplace, with no marketing, browsing, or app data.
- Same-day orders inflate the apparent repeat rate; handled in feature design but not removable from the label.
- Results are specific to these snapshot dates.

## 9. Repository Structure
```
├── Dataset/                    # raw CSVs (not committed)
├── sql/
│   ├── 01_import.sql
│   ├── 02_data_exploration.sql
│   ├── 03_business_analysis.sql
│   ├── 04_gap_analysis.sql
│   ├── 05_cohort_retention.sql
│   └── 06_build_features.sql
├── notebooks/                  # EDA and modeling
├── src/                        # reusable pipeline code
├── models/                     # saved model artifacts
├── app/                        # Streamlit demo
├── requirements.txt
└── README.md
```

## 10. How to Run
1. Download the dataset from Kaggle and place the CSVs in a `Dataset/` folder in the project root.
2. Open a terminal in the project root and start MySQL with local infile enabled:
   ```bash
   mysql --local-infile=1 -u root -p
   ```
3. Run the scripts in order:
   ```sql
   SOURCE sql/01_import.sql;
   SOURCE sql/02_data_exploration.sql;
   -- ... through 06_build_features.sql
   ```
4. Run the notebooks in `notebooks/`, then `streamlit run app/app.py`.

Note: `01_import.sql` skips the 1M-row geolocation table by default (not used for features).

## 11. Tech Stack
Python, MySQL, pandas, scikit-learn, [XGBoost/LightGBM], SHAP, Streamlit

## Roadmap
- [x] Problem framing
- [x] Database setup and import (verified row counts and date handling)
- [x] Data audit
- [x] Gap analysis and window selection (90 days)
- [x] Snapshot design and class-balance check
- [ ] Cohort retention analysis
- [ ] Feature engineering in SQL (train and test tables)
- [ ] Modeling and evaluation
- [ ] Targeting / cost analysis
- [ ] SHAP interpretability
- [ ] Streamlit demo
- [ ] Final write-up
