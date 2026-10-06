/* =====================================================================
   churn_analysis_full.sql
   Telecom Customer Churn Analysis: complete SQL pipeline in one file.
   Run in SSMS (SQL Server 2017 or later), top to bottom.

   Before running:
   - Part 2 (IMPORT): edit the CSV path in BULK INSERT, or load stg_Churn
     with the SSMS Import Flat File wizard and skip the BULK INSERT block.
   - Parts 1 and 2 are reconstructed (not in the original tutorial SQL) and
     were not executed against SQL Server by the author of this file.

   Source:
   - Parts 3, 4 and 5 = tutorial queries (exploration, NULL cleaning, views)
   - Items marked "MY ADDITION" were added later (checks, re-run safety, Part 6)

   Contents:
   Part 1  Setup: database and staging table
   Part 2  Import: load CSV, sanity checks
   Part 3  Data exploration (before cleaning)
   Part 4  Cleaning and ETL into prod_Churn
   Part 5  Views for Power BI and the model
   Part 6  KPI cross-check queries (MY ADDITION)
   ===================================================================== */

/* #####################################################################
   PART 1: SETUP
   ##################################################################### */
IF DB_ID('db_Churn') IS NULL
    CREATE DATABASE db_Churn;
GO

USE db_Churn;
GO

-- Staging table: raw copy of the CSV, loaded as-is (NULLs kept as NULL).
-- Money columns use DECIMAL(10,2) (recommended). Using FLOAT/REAL produces
-- values such as 95.099998 instead of 95.10.
IF OBJECT_ID('dbo.stg_Churn', 'U') IS NOT NULL DROP TABLE dbo.stg_Churn;
GO

CREATE TABLE dbo.stg_Churn (
    Customer_ID                 VARCHAR(50),
    Gender                      VARCHAR(50),
    Age                         INT,
    Married                     VARCHAR(50),
    State                       VARCHAR(50),
    Number_of_Referrals         INT,
    Tenure_in_Months            INT,
    Value_Deal                  VARCHAR(50),
    Phone_Service               VARCHAR(50),
    Multiple_Lines              VARCHAR(50),
    Internet_Service            VARCHAR(50),
    Internet_Type               VARCHAR(50),
    Online_Security             VARCHAR(50),
    Online_Backup               VARCHAR(50),
    Device_Protection_Plan      VARCHAR(50),
    Premium_Support             VARCHAR(50),
    Streaming_TV                VARCHAR(50),
    Streaming_Movies            VARCHAR(50),
    Streaming_Music             VARCHAR(50),
    Unlimited_Data              VARCHAR(50),
    Contract                    VARCHAR(50),
    Paperless_Billing           VARCHAR(50),
    Payment_Method              VARCHAR(50),
    Monthly_Charge              DECIMAL(10,2),
    Total_Charges               DECIMAL(10,2),
    Total_Refunds               DECIMAL(10,2),
    Total_Extra_Data_Charges    INT,
    Total_Long_Distance_Charges DECIMAL(10,2),
    Total_Revenue               DECIMAL(10,2),
    Customer_Status             VARCHAR(50),
    Churn_Category              VARCHAR(50),
    Churn_Reason                VARCHAR(100)
);
GO

/* #####################################################################
   PART 2: IMPORT
   ##################################################################### */
USE db_Churn;
GO

-- Option A: BULK INSERT (edit the path first; the file must be readable by the SQL Server service)
-- FORMAT = 'CSV' needs SQL Server 2017 or later. KEEPNULLS keeps empty cells as NULL.
BULK INSERT dbo.stg_Churn
FROM 'C:\path\to\telecom-churn-analysis\data\stg_Churn.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    KEEPNULLS
);
GO

-- Option B: SSMS > right-click db_Churn > Tasks > Import Flat File... > choose stg_Churn.csv

-- Sanity checks. Expected values come from the CSV in this repo:
SELECT COUNT(*)                      AS Row_Count          FROM dbo.stg_Churn;  -- expected 6418
SELECT COUNT(DISTINCT Customer_ID)   AS Distinct_Customers FROM dbo.stg_Churn;  -- expected 6418 (no duplicate IDs)
SELECT Customer_Status, COUNT(*)     AS Customers
FROM dbo.stg_Churn GROUP BY Customer_Status;  -- expected Stayed 4275, Churned 1732, Joined 411
GO

/* #####################################################################
   PART 3: DATA EXPLORATION
   ##################################################################### */
USE db_Churn;
GO

/* ---- 1. Distinct values and share of total ------------------------- */
SELECT Gender, COUNT(Gender) AS TotalCount,
       COUNT(Gender) * 1.0 / (SELECT COUNT(*) FROM stg_Churn) AS Percentage
FROM stg_Churn
GROUP BY Gender;

SELECT Contract, COUNT(Contract) AS TotalCount,
       COUNT(Contract) * 1.0 / (SELECT COUNT(*) FROM stg_Churn) AS Percentage
FROM stg_Churn
GROUP BY Contract;

-- Revenue by customer status
SELECT Customer_Status, COUNT(Customer_Status) AS TotalCount,
       SUM(Total_Revenue) AS TotalRev,
       SUM(Total_Revenue) / (SELECT SUM(Total_Revenue) FROM stg_Churn) * 100 AS RevPercentage
FROM stg_Churn
GROUP BY Customer_Status;

SELECT State, COUNT(State) AS TotalCount,
       COUNT(State) * 1.0 / (SELECT COUNT(*) FROM stg_Churn) AS Percentage
FROM stg_Churn
GROUP BY State
ORDER BY Percentage DESC;

/* ---- 2. NULL counts per column -------------------------------------- */
SELECT
    SUM(CASE WHEN Customer_ID IS NULL THEN 1 ELSE 0 END)                  AS Customer_ID_Null_Count,
    SUM(CASE WHEN Gender IS NULL THEN 1 ELSE 0 END)                       AS Gender_Null_Count,
    SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END)                          AS Age_Null_Count,
    SUM(CASE WHEN Married IS NULL THEN 1 ELSE 0 END)                      AS Married_Null_Count,
    SUM(CASE WHEN State IS NULL THEN 1 ELSE 0 END)                        AS State_Null_Count,
    SUM(CASE WHEN Number_of_Referrals IS NULL THEN 1 ELSE 0 END)          AS Number_of_Referrals_Null_Count,
    SUM(CASE WHEN Tenure_in_Months IS NULL THEN 1 ELSE 0 END)             AS Tenure_in_Months_Null_Count,
    SUM(CASE WHEN Value_Deal IS NULL THEN 1 ELSE 0 END)                   AS Value_Deal_Null_Count,
    SUM(CASE WHEN Phone_Service IS NULL THEN 1 ELSE 0 END)                AS Phone_Service_Null_Count,
    SUM(CASE WHEN Multiple_Lines IS NULL THEN 1 ELSE 0 END)               AS Multiple_Lines_Null_Count,
    SUM(CASE WHEN Internet_Service IS NULL THEN 1 ELSE 0 END)             AS Internet_Service_Null_Count,
    SUM(CASE WHEN Internet_Type IS NULL THEN 1 ELSE 0 END)                AS Internet_Type_Null_Count,
    SUM(CASE WHEN Online_Security IS NULL THEN 1 ELSE 0 END)              AS Online_Security_Null_Count,
    SUM(CASE WHEN Online_Backup IS NULL THEN 1 ELSE 0 END)                AS Online_Backup_Null_Count,
    SUM(CASE WHEN Device_Protection_Plan IS NULL THEN 1 ELSE 0 END)       AS Device_Protection_Plan_Null_Count,
    SUM(CASE WHEN Premium_Support IS NULL THEN 1 ELSE 0 END)              AS Premium_Support_Null_Count,
    SUM(CASE WHEN Streaming_TV IS NULL THEN 1 ELSE 0 END)                 AS Streaming_TV_Null_Count,
    SUM(CASE WHEN Streaming_Movies IS NULL THEN 1 ELSE 0 END)             AS Streaming_Movies_Null_Count,
    SUM(CASE WHEN Streaming_Music IS NULL THEN 1 ELSE 0 END)              AS Streaming_Music_Null_Count,
    SUM(CASE WHEN Unlimited_Data IS NULL THEN 1 ELSE 0 END)               AS Unlimited_Data_Null_Count,
    SUM(CASE WHEN Contract IS NULL THEN 1 ELSE 0 END)                     AS Contract_Null_Count,
    SUM(CASE WHEN Paperless_Billing IS NULL THEN 1 ELSE 0 END)            AS Paperless_Billing_Null_Count,
    SUM(CASE WHEN Payment_Method IS NULL THEN 1 ELSE 0 END)               AS Payment_Method_Null_Count,
    SUM(CASE WHEN Monthly_Charge IS NULL THEN 1 ELSE 0 END)               AS Monthly_Charge_Null_Count,
    SUM(CASE WHEN Total_Charges IS NULL THEN 1 ELSE 0 END)                AS Total_Charges_Null_Count,
    SUM(CASE WHEN Total_Refunds IS NULL THEN 1 ELSE 0 END)                AS Total_Refunds_Null_Count,
    SUM(CASE WHEN Total_Extra_Data_Charges IS NULL THEN 1 ELSE 0 END)     AS Total_Extra_Data_Charges_Null_Count,
    SUM(CASE WHEN Total_Long_Distance_Charges IS NULL THEN 1 ELSE 0 END)  AS Total_Long_Distance_Charges_Null_Count,
    SUM(CASE WHEN Total_Revenue IS NULL THEN 1 ELSE 0 END)                AS Total_Revenue_Null_Count,
    SUM(CASE WHEN Customer_Status IS NULL THEN 1 ELSE 0 END)              AS Customer_Status_Null_Count,
    SUM(CASE WHEN Churn_Category IS NULL THEN 1 ELSE 0 END)               AS Churn_Category_Null_Count,
    SUM(CASE WHEN Churn_Reason IS NULL THEN 1 ELSE 0 END)                 AS Churn_Reason_Null_Count
FROM stg_Churn;
/* Counts found in the CSV in this repo (for reference):
   Value_Deal 3548 | Multiple_Lines 622 | Internet_Type and the 8 internet add-on columns 1390 each
   | Churn_Category 4686 | Churn_Reason 4686. All other columns: 0. */

/* ---- 3. WHY the NULLs exist (MY ADDITION) --------------------------- */
-- Multiple_Lines is NULL only when there is no phone service (622 = Phone_Service 'No').
-- Internet add-ons are NULL only when there is no internet service (1390 = Internet_Service 'No').
-- Churn_Category / Churn_Reason are NULL for everyone who did not churn (6418 - 1732 = 4686).
SELECT 'Multiple_Lines NULL but Phone_Service = Yes' AS Check_Name, COUNT(*) AS Rows_Found
FROM stg_Churn WHERE Multiple_Lines IS NULL AND Phone_Service = 'Yes'          -- expect 0
UNION ALL
SELECT 'Internet_Type NULL but Internet_Service = Yes', COUNT(*)
FROM stg_Churn WHERE Internet_Type IS NULL AND Internet_Service = 'Yes'         -- expect 0
UNION ALL
SELECT 'Churn_Reason NULL but Status = Churned', COUNT(*)
FROM stg_Churn WHERE Churn_Reason IS NULL AND Customer_Status = 'Churned';      -- expect 0

/* ---- 4. Duplicates and value-range checks (MY ADDITION) ------------- */
-- Duplicate customer IDs (expect none)
SELECT Customer_ID, COUNT(*) AS Occurrences
FROM stg_Churn GROUP BY Customer_ID HAVING COUNT(*) > 1;

-- Negative monthly charges. The CSV has 107 rows between -10 and -1.
-- A negative monthly charge is unusual. It could be a credit or a data error.
-- Check with the data owner before deciding; see Part 4.
SELECT COUNT(*) AS Negative_Monthly_Charge_Rows FROM stg_Churn WHERE Monthly_Charge < 0;

-- Revenue consistency: Total_Revenue should equal
-- Total_Charges - Total_Refunds + Total_Extra_Data_Charges + Total_Long_Distance_Charges.
-- (In the CSV this holds for every row.)
SELECT COUNT(*) AS Revenue_Mismatch_Rows
FROM stg_Churn
WHERE ABS(Total_Revenue - (Total_Charges - Total_Refunds + Total_Extra_Data_Charges + Total_Long_Distance_Charges)) > 0.01;
GO

/* #####################################################################
   PART 4: CLEANING AND ETL
   ##################################################################### */
USE db_Churn;
GO

-- Re-runnable: drop the production table if it already exists.
IF OBJECT_ID('dbo.prod_Churn', 'U') IS NOT NULL DROP TABLE dbo.prod_Churn;
GO

/* Cleaning rules (and why):
   - Value_Deal NULL            -> 'None'   (customer is not on a deal)
   - Multiple_Lines NULL        -> 'No'     (no phone service, so no multiple lines)
   - Internet_Type NULL         -> 'None'   (no internet service)
   - Internet add-ons NULL      -> 'No'     (cannot have add-ons without internet)
   - Churn_Category / Reason NULL -> 'Others' (customer did not churn)
   Customer_ID, demographics, charges and status have no NULLs, so no rule is needed. */
SELECT
    Customer_ID,
    Gender,
    Age,
    Married,
    State,
    Number_of_Referrals,
    Tenure_in_Months,
    ISNULL(Value_Deal, 'None')              AS Value_Deal,
    Phone_Service,
    ISNULL(Multiple_Lines, 'No')            AS Multiple_Lines,
    Internet_Service,
    ISNULL(Internet_Type, 'None')           AS Internet_Type,
    ISNULL(Online_Security, 'No')           AS Online_Security,
    ISNULL(Online_Backup, 'No')             AS Online_Backup,
    ISNULL(Device_Protection_Plan, 'No')    AS Device_Protection_Plan,
    ISNULL(Premium_Support, 'No')           AS Premium_Support,
    ISNULL(Streaming_TV, 'No')              AS Streaming_TV,
    ISNULL(Streaming_Movies, 'No')          AS Streaming_Movies,
    ISNULL(Streaming_Music, 'No')           AS Streaming_Music,
    ISNULL(Unlimited_Data, 'No')            AS Unlimited_Data,
    Contract,
    Paperless_Billing,
    Payment_Method,
    Monthly_Charge,
    Total_Charges,
    Total_Refunds,
    Total_Extra_Data_Charges,
    Total_Long_Distance_Charges,
    Total_Revenue,
    Customer_Status,
    ISNULL(Churn_Category, 'Others')        AS Churn_Category,
    ISNULL(Churn_Reason,  'Others')         AS Churn_Reason
INTO [db_Churn].[dbo].[prod_Churn]
FROM [db_Churn].[dbo].[stg_Churn];
GO

/* MY ADDITION (recommended, not applied): label clash.
   Churners with a real category of 'Other' (174 rows) and non-churners filled with 'Others'
   look almost the same. Using 'Not Applicable' for non-churners avoids confusion:
       ISNULL(Churn_Category, 'Not Applicable')
   If you change it, re-check any Power BI visual that filters on Churn_Category. */

/* MY ADDITION (recommended, not applied): negative Monthly_Charge (107 rows).
   Options after confirming with the data owner:
     a) keep as is and document it (what this repo does)
     b) add a flag column:  CASE WHEN Monthly_Charge < 0 THEN 1 ELSE 0 END AS Negative_Charge_Flag
     c) exclude from analysis (changes customer counts, so decide deliberately) */

-- Post-load validation (MY ADDITION)
SELECT COUNT(*) AS prod_rows FROM prod_Churn;                          -- expect 6418
SELECT SUM(CASE WHEN Value_Deal IS NULL OR Internet_Type IS NULL OR Churn_Reason IS NULL THEN 1 ELSE 0 END) AS Remaining_Nulls
FROM prod_Churn;                                                       -- expect 0
GO

/* #####################################################################
   PART 5: VIEWS
   ##################################################################### */
USE db_Churn;
GO

CREATE OR ALTER VIEW dbo.vw_ChurnData AS
    SELECT * FROM dbo.prod_Churn WHERE Customer_Status IN ('Churned', 'Stayed');
GO

CREATE OR ALTER VIEW dbo.vw_JoinData AS
    SELECT * FROM dbo.prod_Churn WHERE Customer_Status = 'Joined';
GO

-- Row counts expected from the CSV: vw_ChurnData 6007, vw_JoinData 411
SELECT (SELECT COUNT(*) FROM dbo.vw_ChurnData) AS ChurnData_Rows,
       (SELECT COUNT(*) FROM dbo.vw_JoinData)  AS JoinData_Rows;
GO
-- Export both views to Excel (sheets vw_ChurnData and vw_JoinData) -> data/Prediction_Data.xlsx
-- (the notebook reads that file).

/* #####################################################################
   PART 6: KPI CROSS-CHECKS
   ##################################################################### */
USE db_Churn;
GO

/* ---- KPI 1-4 as shown on the dashboard ------------------------------- */
SELECT
    COUNT(*)                                                              AS Total_Customers,   -- 6418
    SUM(CASE WHEN Customer_Status = 'Joined'  THEN 1 ELSE 0 END)          AS New_Joiners,       -- 411
    SUM(CASE WHEN Customer_Status = 'Churned' THEN 1 ELSE 0 END)          AS Total_Churn,       -- 1732
    CAST(100.0 * SUM(CASE WHEN Customer_Status = 'Churned' THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,1)) AS Churn_Rate_Pct  -- 27.0
FROM prod_Churn;

/* KPI DEFINITION NOTE
   The dashboard's 27.0% = Churned / ALL customers (6,418), which includes the 411 new joiners.
   Joiners have not had time to churn, so a common alternative divides by customers with a
   known outcome (Stayed + Churned = 6,007), which gives 28.8%. Neither is "wrong", but the
   definition should be stated on the dashboard. */
SELECT
    CAST(100.0 * SUM(CASE WHEN Customer_Status = 'Churned' THEN 1 ELSE 0 END)
         / NULLIF(SUM(CASE WHEN Customer_Status IN ('Churned','Stayed') THEN 1 ELSE 0 END), 0) AS DECIMAL(5,1)) AS Churn_Rate_Excl_Joiners_Pct  -- 28.8
FROM prod_Churn;

/* ---- Churn rate by contract (dashboard: 46.5 / 11.0 / 2.7 %) --------- */
SELECT Contract,
       COUNT(*) AS Customers,
       SUM(CASE WHEN Customer_Status = 'Churned' THEN 1 ELSE 0 END) AS Churned,
       CAST(100.0 * SUM(CASE WHEN Customer_Status = 'Churned' THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,1)) AS Churn_Rate_Pct
FROM prod_Churn GROUP BY Contract ORDER BY Churn_Rate_Pct DESC;

/* ---- Churn rate by payment method (37.8 / 34.4 / 14.8 %) ------------- */
SELECT Payment_Method,
       COUNT(*) AS Customers,
       SUM(CASE WHEN Customer_Status = 'Churned' THEN 1 ELSE 0 END) AS Churned,
       CAST(100.0 * SUM(CASE WHEN Customer_Status = 'Churned' THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,1)) AS Churn_Rate_Pct
FROM prod_Churn GROUP BY Payment_Method ORDER BY Churn_Rate_Pct DESC;

/* ---- Churn rate by internet type (41.1 / 25.7 / 19.4 / 7.8 %) -------- */
SELECT Internet_Type,
       COUNT(*) AS Customers,
       SUM(CASE WHEN Customer_Status = 'Churned' THEN 1 ELSE 0 END) AS Churned,
       CAST(100.0 * SUM(CASE WHEN Customer_Status = 'Churned' THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,1)) AS Churn_Rate_Pct
FROM prod_Churn GROUP BY Internet_Type ORDER BY Churn_Rate_Pct DESC;

/* ---- Churn rate by state, with customer counts (small states are noisy)  */
SELECT State,
       COUNT(*) AS Customers,
       SUM(CASE WHEN Customer_Status = 'Churned' THEN 1 ELSE 0 END) AS Churned,
       CAST(100.0 * SUM(CASE WHEN Customer_Status = 'Churned' THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,1)) AS Churn_Rate_Pct
FROM prod_Churn GROUP BY State ORDER BY Churn_Rate_Pct DESC;   -- top: Jammu & Kashmir 57.2 (320 customers)

/* ---- Why customers left (dashboard: Competitor 761, Attitude 301, Dissatisfaction 300, Price 196, Other 174) */
SELECT Churn_Category, COUNT(*) AS Churned_Customers
FROM prod_Churn WHERE Customer_Status = 'Churned'
GROUP BY Churn_Category ORDER BY Churned_Customers DESC;

SELECT TOP 10 Churn_Reason, COUNT(*) AS Churned_Customers
FROM prod_Churn WHERE Customer_Status = 'Churned'
GROUP BY Churn_Reason ORDER BY Churned_Customers DESC;

/* ---- Gender: churn COUNT vs churn RATE (MY ADDITION) ------------------
   The dashboard donut shows churn counts by gender (Female 1,111 / Male 621). Counts mostly
   mirror the customer mix (63% of customers are female). Rates answer the business question. */
SELECT Gender,
       COUNT(*) AS Customers,
       SUM(CASE WHEN Customer_Status = 'Churned' THEN 1 ELSE 0 END) AS Churned,
       CAST(100.0 * SUM(CASE WHEN Customer_Status = 'Churned' THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,1)) AS Churn_Rate_Pct  -- Female 27.4, Male 26.2
FROM prod_Churn GROUP BY Gender;
GO
