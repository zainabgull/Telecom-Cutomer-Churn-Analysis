create database churn_analysis;
use churn_analysis;

--  Query 1: Considering the top 5 groups with the highest average monthly charges among churned customers,
--  how can personalized offers be tailored based on age,gender, and contract type to potentially improve customer retention rates?
SELECT 
	cd.Age,
    cd.Gender,
    cs.Contract,
    avg(cs.`Monthly Charge`) as Average_Monthly_Rate,
    COUNT(*) AS NumberOfCustomers
FROM 
    telco_customer_churn_status cst
Join
	telco_customer_churn_services cs	
On
	cst.`Customer ID`=cs.`Customer ID`
Join 
	telco_customer_churn_demographics cd
On
	cs.`Customer ID`=cd.`Customer ID`
WHERE 
	`Churn Label`='Yes' 
Group by 
	cd.Age, cd.Gender,cs.Contract
ORDER BY 
    Average_Monthly_Rate DESC
LIMIT 5;

# add age_group column with help of age
SELECT 
   CASE 
      WHEN cd.Age < 30 THEN 'Young Adults'
      WHEN cd.Age >= 30 AND Age < 50 THEN 'Middle-Aged Adults'
      ELSE 'Seniors'
   END AS AgeGroup,
   -- ROUND(AVG(`Tenure in Months`),2) AS AvgTenure,
	cd.Gender,
    cs.Contract,
    ROUND(avg(cs.`Monthly Charge`),2) as Average_Monthly_Rate,
    ROUND(AVG(cs.`Tenure in Months`),2) AS AvgTenure,
    COUNT(*) AS NumberOfCustomers
FROM 
    telco_customer_churn_status cst
Join
	telco_customer_churn_services cs	
On
	cst.`Customer ID`=cs.`Customer ID`
Join 
	telco_customer_churn_demographics cd
On
	cs.`Customer ID`=cd.`Customer ID`
WHERE 
	`Churn Label`='Yes' 
Group by 
	AgeGroup, cd.Gender,cs.Contract
ORDER BY 
    Average_Monthly_Rate DESC
LIMIT 5;

-- Query 2: What are the feedback or complaints from those churned customers

SELECT 
    `Churn Category`, COUNT(*) AS churn_count
FROM
    telco_customer_churn_status
WHERE
    `Churn Label` = 'Yes'
GROUP BY `Churn Category`
ORDER BY churn_count DESC;

#use churn Reason for better understanding
SELECT 
	`Churn Category`,
	`Churn Reason`, 
    COUNT(*) AS NumberOfChurns
FROM 
   telco_customer_churn_status
WHERE 
	`Churn Label`='Yes'
GROUP BY 
    `Churn Category`,`Churn Reason`
ORDER BY 
    `Churn Category` ASC, NumberOfChurns DESC;

-- proportion of churned customers within each category
SELECT 
    `Churn Category`, 
    COUNT(`Customer ID`) AS Total_Churned_Customers, 
    ROUND(COUNT(`Customer ID`) / (SELECT COUNT(*) FROM churn_analysis WHERE `Churn Category` <> '') * 100, 2) AS Proportion_In_Percent
FROM 
    telco_customer_churn_status
WHERE 
    `Churn Category` <> '' 
GROUP BY 
    `Churn Category`
ORDER BY 
    Total_Churned_Customers DESC;

-- Query 3: How does the payment method influence churn behavior?
WITH ChurnData AS(
SELECT 
    cs.`Payment Method` as payment_method,
    COUNT(CASE WHEN cst.`Churn Label` = 'Yes' THEN 1 END) AS ChurnedCustomers,
    COUNT(CASE WHEN cst.`Churn Label` = 'No' THEN 1 END) AS RetainedCustomers,
    COUNT(*) AS TotalCustomers
--     ROUND(COUNT(CASE WHEN cst.`Churn Label` = 'Yes' THEN 1 END) * 100.0 / COUNT(*), 2) AS ChurnRate
FROM 
    telco_customer_churn_status cst
Join
	telco_customer_churn_services cs	
On
	cst.`Customer ID`=cs.`Customer ID`
GROUP BY 
    cs.`Payment Method`
)
select 
	payment_method,
    ChurnedCustomers,
    RetainedCustomers,
    TotalCustomers,
    ROUND(ChurnedCustomers/ (ChurnedCustomers + RetainedCustomers) * 100, 2) AS ChurnRate
from 
	ChurnData
order by
	ChurnRate DESC;
    
-- What is the Impact of Contract Type on Churn Rate?
SELECT 
    `Contract`, 
    COUNT(`Customer ID`) AS TotalCustomers,
    SUM(CASE WHEN `Churn Label` = 'Yes' THEN 1 ELSE 0 END) AS ChurnedCustomers,
    ROUND(SUM(CASE WHEN `Churn Label` = 'Yes' THEN 1 ELSE 0 END) / COUNT(`Customer ID`), 2) AS ChurnRate
FROM churn_analysis
GROUP BY `Contract`
ORDER BY ChurnRate DESC;

-- Which States or Cities Have the Highest Churn Rates?
SELECT 
    cl.`City`, 
    COUNT(cst.`Customer ID`) AS TotalCustomers,
    SUM(CASE WHEN cst.`Churn Label` = 'Yes' THEN 1 ELSE 0 END) AS ChurnedCustomers,
    ROUND(SUM(CASE WHEN cst.`Churn Label` = 'Yes' THEN 1 ELSE 0 END) / COUNT(cst.`Customer ID`), 2) AS ChurnRate
FROM 
    telco_customer_churn_status cst
Join
	telco_customer_churn_location cl	
On
	cst.`Customer ID`=cl.`Customer ID`
GROUP BY cl.`City`
ORDER BY ChurnRate Desc;

-- Which Internet Types Are Linked to Higher Churn Rates?
SELECT 
    cs.`Internet Type`, 
    COUNT(cst.`Customer ID`) AS TotalCustomers,
    SUM(CASE WHEN cst.`Churn Label` = 'Yes' THEN 1 ELSE 0 END) AS ChurnedCustomers,
    ROUND(SUM(CASE WHEN cst.`Churn Label` = 'Yes' THEN 1 ELSE 0 END) / COUNT(cst.`Customer ID`), 2) AS ChurnRate
FROM telco_customer_churn_status cst
Join
	telco_customer_churn_services cs	
On
	cst.`Customer ID`=cs.`Customer ID`
GROUP BY cs.`Internet Type`
ORDER BY ChurnRate DESC;

-- Do Streaming Services Impact Churn Rates?
SELECT 
    CASE 
        WHEN cs.`Streaming TV` = 'Yes' THEN 'Streaming TV Users'
        ELSE 'Non-Streaming TV Users'
    END AS StreamingTVStatus,
    COUNT(cst.`Customer ID`) AS TotalCustomers,
    SUM(CASE WHEN cst.`Churn Label` = 'Yes' THEN 1 ELSE 0 END) AS ChurnedCustomers,
    ROUND(SUM(CASE WHEN cst.`Churn Label` = 'Yes' THEN 1 ELSE 0 END) / COUNT(cst.`Customer ID`), 2) AS ChurnRate
FROM telco_customer_churn_status cst
Join
	telco_customer_churn_services cs	
On
	cst.`Customer ID`=cs.`Customer ID`
GROUP BY StreamingTVStatus
ORDER BY ChurnRate DESC;



