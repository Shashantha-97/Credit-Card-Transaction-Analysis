# Credit Card Transactions Analysis

## Table of Contents
1. [Description](#description)
2. [Folder Structure](#folder-structure)
3. [Dataset](#dataset)
4. [Data Exploration](#data-exploration)
5. [ADHOC Analysis](#adhoc-analysis)
6. [Stored Procedures](#stored-procedures)
7. [Stored Procedure Usage](#stored-procedure-usage)
8. [Highlights](#highlights)

---

## Description
This project analyzes the Kaggle **Credit Card Transactions** dataset. It demonstrates:

- Exploratory data analysis (EDA) to understand patterns and distributions in the dataset
- SQL questions and solutions to perform ad-hoc queries and gain insights
- Stored procedures for automated trend analysis and high-risk transaction detection 

The analysis covers **transactions by card type, expense type, city, gender, and time trends**, helping identify usage patterns and high-risk behaviors.

---

## Folder Structure
CreditCardTransactions/
├─ StoredProcedure/ # Key stored procedure for analysis
├─ AdhocAnlaysis/ # SQL queries to perform the analysis
├─ DataExploration/ # SQL scripts exploring the dataset
├─ Dataset/ # Raw CSV dataset
└─ README.md # Project documentation (this file)

---

## Dataset
- **File:** `credit_card_transactions.csv` (https://www.kaggle.com/datasets/thedevastator/analyzing-credit-card-spending-habits-in-india)
- **Columns include:**  
  - `transaction_id` – Unique identifier for each transaction  
  - `city` – City where transaction occurred  
  - `transaction_date` – Date of the transaction  
  - `card_type` – Card type: Gold, Platinum, Silver, Signature  
  - `exp_type` – Expense type: Bills, Food, Entertainment, Grocery, Fuel, Travel  
  - `gender` – Customer gender: M/F  
  - `amount` – Transaction amount  

The dataset covers transactions from **2013-10-04 to 2015-05-26**.

---

## Data Exploration
- Scripts in the `DataExploration/` folder explore dataset properties:  
  - Transaction counts and uniqueness  
  - Date ranges and trends  
  - Distribution of card types and expense types  
  - Top cities by spend and transaction count  
  - Gender-based expense patterns  

This helps understand **behavior patterns** before running advanced analysis.

---

## ADHOC Analysis
- Scripts in the `AdhocAnlaysis/` folder include 9 SQL questions with answers:  
	1- Top 5 cities with highest spends and their percentage contribution of total credit card spends 
	2- Highest spend month and amount spent in that month for each card type
	3- Transaction details(all columns from the table) for each card type when it reaches a cumulative of 1000000 total spends
	4- City which had lowest percentage spend for gold card type
	5- Print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)
	6- Percentage contribution of spends by females for each expense type
	7- Card and expense type combination having highest month over month growth in Jan-2014
	9- City with Highest total spend to total no of transcations ratio during weekends
   10- City that took least number of days to reach its 500th transaction after the first transaction in that city
 

Each query is documented with **description and takeaway insights**.

# Stored Procedures
- Key stored procedure: `AnalyzeCardTypeExpYearCombined.sql`  
- **Purpose:**  
  - Provides **combined summary and trend analysis** for each card type and expense type by year  
  - Flags **high-risk transactions** automatically (above-average spending)  
- Stored procedures are saved in the `StoredProcedures/` folder.

---

## Stored Procedure Usage
-- Analyze a specific card type (e.g., Gold)
CALL AnalyzeCardTypeExpYearCombined('Gold');

-- Analyze all card types
CALL AnalyzeCardTypeExpYearCombined(NULL); or CALL AnalyzeCardTypeExpYearCombined('');

 1- The output includes year-wise summary, total transactions, total amount, average amount, and high-risk flag
 2- Useful for dashboards and reports for non-technical users
 
--
 
## Highlights
 - Automatic high-risk transaction detection per card type

 - Year-wise trend and summary per card type and expense type

 - Organized folder structure for professional GitHub presentation

 - Clean and documented SQL scripts for exploration and ad-hoc analysis