
# Olist E-Commerce Customer Retention Analysis

## Project Overview

This project analyzes the Brazilian Olist E-Commerce dataset to understand customer purchasing behaviour, retention patterns, revenue contribution, and delivery performance.

The objective is to extract actionable business insights using MySQL, Python, and Power BI, with a focus on customer segmentation, repeat purchases, and customer retention.

## Business Objectives

- Analyze customer purchasing behaviour and revenue trends.
- Identify high-value, loyal, at-risk, and inactive customers.
- Measure repeat purchase rates and customer retention.
- Perform monthly cohort analysis to understand customer retention patterns.
- Evaluate delivery performance and its relationship with customer satisfaction.
- Build an interactive dashboard to communicate business insights.

## Tools & Technologies

| Tool | Purpose |
|---|---|
| MySQL 8.0 | Data querying, cleaning, joins, and analysis |
| Python | Data analysis and preprocessing |
| Pandas | Data manipulation |
| NumPy | Numerical operations |
| Matplotlib | Data visualization |
| Seaborn | Statistical visualization |
| Power BI | Interactive dashboard and reporting |

## Dataset Information

The project uses the Brazilian Olist E-Commerce public dataset.

The analysis covers nine relational tables:

1. Customers
2. Orders
3. Order Items
4. Order Payments
5. Order Reviews
6. Products
7. Sellers
8. Geolocation
9. Product Category Translation

The dataset contains approximately 100K orders and interconnected customer, product, payment, seller, and delivery records.

## Project Structure

```text
olist-customer-retention-analysis/
│
├── sql/
│   ├── 01_schema.sql
│   ├── 02_data_validation.sql
│   ├── 03_customer_analysis.sql
│   ├── 04_repeat_purchase.sql
│   ├── 05_cohort_analysis.sql
│   ├── 06_delivery_review_analysis.sql
│   └── 07_rfm_segmentation.sql
│
├── python/
│   └── analysis.ipynb
│
├── powerbi/
│   └── olist_dashboard.pbix
│
├── images/
│   └── dashboard.png
│
└── README.md
```

## SQL Analysis

| File | Analysis |
|---|---|
| 01_schema.sql | Database schema inspection |
| 02_data_validation.sql | Data quality and validation |
| 03_customer_analysis.sql | Customer behaviour and revenue |
| 04_repeat_purchase.sql | Repeat purchase analysis |
| 05_cohort_analysis.sql | Monthly cohort retention |
| 06_delivery_review_analysis.sql | Delivery and review analysis |
| 07_rfm_segmentation.sql | Customer RFM segmentation |

### SQL Concepts Used

- Joins and aggregations
- Common Table Expressions (CTEs)
- Subqueries
- Window Functions
- CASE statements
- Date and time functions
- Data validation
- Customer segmentation

## Key Business Findings

### 1. Customer Analysis

| Metric | Result |
|---|---:|
| Total customer records | 99,441 |
| Total unique customers | 96,096 |
| Customers with delivered orders | 93,358 |
| Total delivered orders | 96,478 |

### 2. RFM Customer Segmentation

Developed a rule-based RFM segmentation model using Recency, Frequency, and Monetary metrics.

The analysis classified 93,358 customers into eight populated segments.

| Customer Segment | Customers | Percentage |
|---|---:|---:|
| Loyal Customers | 27,247 | 29.19% |
| Hibernating | 15,050 | 16.12% |
| Cannot Lose Them | 14,826 | 15.88% |
| Potential Loyalists | 11,250 | 12.05% |
| At Risk | 7,468 | 8.00% |
| Need Attention | 7,339 | 7.86% |
| Champions | 6,473 | 6.93% |
| New Customers | 3,705 | 3.97% |

### 3. Revenue Contribution by Customer Segment

| Customer Segment | Revenue (BRL) | Revenue Share |
|---|---:|---:|
| Loyal Customers | 3,649,480.91 | 23.66% |
| Cannot Lose Them | 2,519,035.99 | 16.33% |
| Hibernating | 2,451,333.19 | 15.89% |
| Champions | 2,020,937.27 | 13.10% |
| Potential Loyalists | 1,847,957.58 | 11.98% |
| At Risk | 1,205,711.29 | 7.82% |
| Need Attention | 1,132,766.36 | 7.34% |
| New Customers | 595,239.18 | 3.86% |

**Key Insights:**

- Hibernating customers account for 16.12% of the customer base and 15.89% of analyzed revenue.
- Champions represent 6.93% of customers but contribute 13.10% of revenue.
- Loyal Customers form the largest segment, representing 29.19% of customers.

### 4. Cohort Analysis

Performed monthly cohort analysis to understand customer retention behaviour.

Key observations:

- Monthly repeat activity was very low across the analyzed cohorts.
- Month 1 retention was below 1% for the displayed cohorts.
- The findings highlight opportunities to improve customer engagement and repeat purchasing.

### 5. Delivery Performance

Analyzed delivery delays, estimated versus actual delivery dates, and customer review scores.

The analysis evaluates the relationship between delivery performance and customer satisfaction.

## Power BI Dashboard

The dashboard is designed to track:

- Revenue trends
- Customer segmentation
- Product category performance
- Payment distribution
- Delivery performance
- Customer retention metrics

![Power BI Dashboard](images/dashboard.png)

## Business Recommendations

1. **Customer Reactivation:** Develop targeted campaigns for Hibernating customers.
2. **Customer Retention:** Prioritize At Risk and Cannot Lose Them customers.
3. **Customer Loyalty:** Introduce loyalty incentives for Champions and Loyal Customers.
4. **Repeat Purchases:** Investigate strategies to increase repeat purchasing.
5. **Delivery Optimization:** Identify delivery bottlenecks and improve fulfillment performance.

## How to Run This Project

1. Clone or download this repository.
2. Import the Olist dataset into MySQL.
3. Create or select the `olist_analysis` database.
4. Execute SQL scripts in numerical order.
5. Run the Python notebook for exploratory analysis, if included.
6. Open the Power BI dashboard to explore visualizations.

## Skills Demonstrated

- SQL Data Analysis
- Data Cleaning and Validation
- Exploratory Data Analysis (EDA)
- Customer Segmentation
- RFM Analysis
- Cohort Analysis
- Customer Retention Analysis
- Business Intelligence
- Data Visualization
- Business Insight Generation

## Author

**Md Sami Ahmad**

B.Tech - Computer Science and Engineering

Interested in Data Analytics, Business Intelligence, and Data-Driven Decision Making.

---

*This project was developed as a practical data analytics portfolio project using the Olist Brazilian E-Commerce dataset.*
