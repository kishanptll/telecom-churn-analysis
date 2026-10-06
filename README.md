# Telecom Customer Churn Analysis & Prediction

## 📌 Project Overview

Customer churn is a major challenge for telecom companies because losing existing customers can directly impact revenue, customer lifetime value, and long-term business growth.

This project analyzes **6,418 telecom customer records** to understand:

* Who is leaving the company?
* Which customer segments have the highest churn?
* Why are customers leaving?
* Which services, contracts, and payment methods are associated with churn?
* Which newly joined customers may be at higher risk of churning?
* Can machine learning be used to predict potential customer churn?

The project follows an **end-to-end data analytics and machine learning workflow** using **SQL Server, Python, Jupyter Notebook, and Power BI**.

---

## 📂 Dataset

**Dataset:** Telecom Customer Churn Dataset
**Total Records:** 6,418 customers
**Prediction Records:** 411 customers

### Key Features

**Customer Demographics**

* Customer ID
* Gender
* Age
* Age Group
* Senior Citizen
* Partner
* Dependents

**Account Information**

* Tenure
* Contract Type
* Payment Method
* Monthly Charges
* Total Charges
* Internet Service

**Services**

* Phone Service
* Multiple Lines
* Online Security
* Online Backup
* Device Protection
* Tech Support
* Streaming TV
* Streaming Movies

**Churn Information**

* Churn Status
* Churn Reason
* Churn Category

---

## 🛠️ Tools & Technologies

| Tool             | Purpose                                   |
| ---------------- | ----------------------------------------- |
| SQL Server       | Data storage, cleaning, and analysis      |
| SQL              | Data transformation and business analysis |
| Python           | Data analysis and machine learning        |
| Pandas           | Data cleaning and manipulation            |
| NumPy            | Numerical analysis                        |
| Jupyter Notebook | Exploratory analysis and ML development   |
| Scikit-learn     | Machine learning model                    |
| Random Forest    | Churn prediction                          |
| Power BI         | Interactive dashboard and visualization   |

---

## 🔄 Project Workflow

### 1. Data Cleaning & ETL

* Imported and cleaned the telecom customer dataset using **SQL Server**.
* Handled missing values, data types, duplicates, and inconsistencies.
* Created useful fields for churn analysis and reporting.

### 2. Exploratory & SQL Analysis

* Analyzed churn patterns across **tenure, contract, payment method, services, age, and monthly charges**.
* Used SQL Server to identify key churn drivers and high-risk customer segments.

### 3. Power BI Dashboard

* Used **Power Query** for data transformation and preparation.
* Built an interactive dashboard covering **customer count, churn rate, revenue, churn drivers, and customer segments**.
* Added slicers for interactive customer analysis.

### 4. Machine Learning — Churn Prediction

* Built a **Random Forest classification model** using Python and Scikit-learn.
* Prepared features, encoded categorical data, trained the model, and generated churn predictions.
* Integrated prediction results into **Power BI** to identify customers at higher risk of churn.

### 5. Business Insights

* Identified key customer groups associated with higher churn.
* Used the analysis and predictions to support **targeted customer retention strategies**.


---

## 📊 Dashboard

The Power BI dashboard provides an interactive overview of **telecom customer churn, key churn drivers, and churn prediction results**.

### 📌 Summary Dashboard

<img width="605" height="336" alt="image" src="https://github.com/user-attachments/assets/59631d7b-64f2-464c-a5fe-016fb2855d86" />


### 🤖 Churn Prediction Dashboard

<img width="607" height="337" alt="image" src="https://github.com/user-attachments/assets/a9797d6f-a6fd-48b7-aee5-6d8901f4b2d8" />

---

## 🤖 Machine Learning Model

### Random Forest Classifier

A **Random Forest classification model** was used to predict whether a customer is likely to churn.

The model considers multiple customer attributes and learns patterns associated with previous churn behavior.


---

## 📈 Business Insights & Recommendations

The analysis helps identify several potential areas for improving customer retention.

### Customer Retention

Focus retention campaigns on customer segments with higher historical churn rates.

### Contract Strategy

Encourage customers to move toward longer-term contracts through suitable offers and incentives.

### New Customer Monitoring

Newly joined customers can be monitored more closely when they show characteristics associated with higher churn risk.

### Pricing & Charges

Review customers with higher monthly charges and understand whether pricing, service usage, or perceived value is contributing to churn.

### Service Adoption

Promote useful additional services such as security, support, and protection plans where they can improve customer retention.

### Predictive Retention

Use machine learning predictions to identify high-risk customers before they leave and prioritize them for targeted retention campaigns.

---

## 🎯 Skills Demonstrated

* Data Cleaning & Preprocessing
* SQL Server & SQL
* Exploratory Data Analysis
* Python & Pandas
* Machine Learning
* Random Forest Classification
* Power BI & Power Query
* Data Visualization
* Churn Analysis
* Predictive Analytics
* Business Analysis

---

## 🎯 Project Outcome

This project demonstrates an end-to-end approach to solving a real-world business problem using **SQL, Python, Machine Learning, and Power BI**.

The analysis combines historical customer behavior with predictive modeling to help telecom businesses:

* Understand why customers churn
* Identify high-risk customer segments
* Monitor important churn drivers
* Predict customers who may leave
* Develop targeted customer retention strategies
* Make data-driven business decisions

---

## 👤 Author

**Kishan Patel**

Aspiring Data Analyst | SQL | Python | Power BI | Excel

**GitHub:** https://github.com/kishanptll
**LinkedIn:** https://www.linkedin.com/in/kishan-patell-dataanalyst/

This project was developed as part of my data analytics portfolio to demonstrate an end-to-end approach to **customer churn analysis, predictive modeling, and business intelligence**.
