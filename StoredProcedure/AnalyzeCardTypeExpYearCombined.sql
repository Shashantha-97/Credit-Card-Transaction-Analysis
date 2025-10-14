-- =============================================
-- Credit Card Transactions Analysis
-- Stored Procedure: AnalyzeCardTypeExpYearCombined
-- Description: 
--   1. Analyzes credit card transactions dataset from Kaggle
--   2. Outputs summary and trend analysis per card_type
--   3. High Risk flags included -- If more than 50% of transactions in a card type exceed the average amount, flagging them 'High Risk'.
-- Usage:
--   CALL AnalyzeCardTypeExpYearCombined('Gold');  -- Specific card type
--   CALL AnalyzeCardTypeExpYearCombined('');    -- '' or NULL for All card types
-- =============================================

DELIMITER $$

DROP PROCEDURE IF EXISTS AnalyzeCardTypeExpYearCombined $$

CREATE PROCEDURE AnalyzeCardTypeExpYearCombined(
    IN selected_card_type VARCHAR(20)  -- pass NULL or '' for all card types
)
BEGIN
    -- 0️  Optional -  if NULL or empty, treat as all card types
    IF selected_card_type IS NULL OR selected_card_type = '' THEN
        SET selected_card_type = NULL;
    END IF;

    -- 1️ Drop temporary tables if they exist
    DROP TEMPORARY TABLE IF EXISTS temp_avg;
    DROP TEMPORARY TABLE IF EXISTS temp_counts;
    DROP TEMPORARY TABLE IF EXISTS temp_trend;

    -- 2️ Temporary table: calculate average amount per card_type + exp_type + year
    CREATE TEMPORARY TABLE temp_avg AS
    SELECT 
        card_type,
        exp_type,
        YEAR(transaction_date) AS trans_year,
        AVG(amount) AS avg_amount
    FROM credit_card_transactions
    WHERE selected_card_type IS NULL OR card_type = selected_card_type
    GROUP BY card_type, exp_type, YEAR(transaction_date);

    -- 3 Temporary table: calculate counts above/below average amount + risk flag 
    CREATE TEMPORARY TABLE temp_counts AS
    SELECT 
        t.card_type,
        t.exp_type,
        YEAR(t.transaction_date) AS trans_year,
        COUNT(*) AS total_transactions,
        SUM(CASE WHEN t.amount > a.avg_amount THEN 1 ELSE 0 END) AS above_avg_count,
        SUM(CASE WHEN t.amount <= a.avg_amount THEN 1 ELSE 0 END) AS below_avg_count,
        a.avg_amount,
        CASE 
            WHEN SUM(CASE WHEN t.amount > a.avg_amount THEN 1 ELSE 0 END)/COUNT(*) > 0.5
            THEN 'High Risk'
            ELSE 'Normal'
        END AS risk_flag
    FROM credit_card_transactions t
    JOIN temp_avg a
      ON t.card_type = a.card_type
     AND t.exp_type = a.exp_type
     AND YEAR(t.transaction_date) = a.trans_year
    WHERE selected_card_type IS NULL OR t.card_type = selected_card_type
    GROUP BY t.card_type, t.exp_type, YEAR(t.transaction_date);

    -- 4️ Temporary table: trend analysis - number of years that are High Risk
    CREATE TEMPORARY TABLE temp_trend AS
    SELECT 
        card_type,
        exp_type,
        COUNT(*) AS high_risk_years
    FROM temp_counts
    WHERE risk_flag = 'High Risk'
    GROUP BY card_type, exp_type;

    -- 5️ Combining main summary and trend into one final result
    SELECT 
        c.trans_year AS year,
        c.card_type,
        c.exp_type,
        c.total_transactions,
        c.above_avg_count,
        c.below_avg_count,
        c.avg_amount,
        c.risk_flag,
        COALESCE(t.high_risk_years, 0) AS high_risk_years
    FROM temp_counts c
    LEFT JOIN temp_trend t
      ON c.card_type = t.card_type
     AND c.exp_type = t.exp_type
    ORDER BY c.trans_year, c.card_type, c.exp_type;

END $$

DELIMITER ;
