SHOW VARIABLES LIKE 'local_infile';

-- ============================================================
-- IMPORT LOAN RISK CSV
-- ============================================================

USE loan_risk_analysis;

LOAD DATA LOCAL INFILE 'E:/c disk/Downloads/loan_risk_dashboard.csv'
INTO TABLE loan_risk_dashboard
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- ============================================================
-- VERIFY IMPORT
-- ============================================================

USE loan_risk_analysis;

SELECT COUNT(*) AS rows_imported
FROM loan_risk_dashboard;

-- ============================================================
-- VALIDATE IMPORTED DATA
-- ============================================================

USE loan_risk_analysis;

SELECT
    COUNT(*) AS total_applications,
    COUNT(DISTINCT loan_id) AS unique_loans,
    MIN(loan_amnt) AS minimum_loan_amount,
    MAX(loan_amnt) AS maximum_loan_amount,
    ROUND(AVG(loan_amnt), 2) AS average_loan_amount,
    ROUND(AVG(predicted_default_probability) * 100, 2) AS average_predicted_risk
FROM loan_risk_dashboard;

-- ============================================================
-- RISK BAND ANALYSIS
-- ============================================================

SELECT
    risk_band,
    COUNT(*) AS applications,
    ROUND(AVG(predicted_default_probability) * 100, 2)
        AS average_predicted_risk,
    ROUND(SUM(loan_amnt), 2)
        AS total_loan_exposure,
    ROUND(AVG(loan_amnt), 2)
        AS average_loan_amount
FROM loan_risk_dashboard
GROUP BY risk_band
ORDER BY
    CASE risk_band
        WHEN 'Low Risk' THEN 1
        WHEN 'Moderate Risk' THEN 2
        WHEN 'High Risk' THEN 3
        WHEN 'Very High Risk' THEN 4
    END;
    
-- ============================================================
-- MANUAL REVIEW ANALYSIS
-- ============================================================

SELECT
    CASE
        WHEN manual_review = 1 THEN 'Manual Review'
        ELSE 'No Manual Review'
    END AS review_status,
    COUNT(*) AS applications,
    ROUND(SUM(loan_amnt), 2) AS total_loan_exposure,
    ROUND(AVG(loan_amnt), 2) AS average_loan_amount,
    ROUND(AVG(predicted_default_probability) * 100, 2)
        AS average_predicted_risk
FROM loan_risk_dashboard
GROUP BY manual_review
ORDER BY manual_review DESC;

-- ============================================================
-- RISK BY INCOME SEGMENT
-- ============================================================

SELECT
    income_band,
    COUNT(*) AS applications,
    ROUND(AVG(predicted_default_probability) * 100, 2)
        AS average_predicted_risk,
    ROUND(SUM(loan_amnt), 2)
        AS total_loan_exposure,
    ROUND(AVG(loan_amnt), 2)
        AS average_loan_amount
FROM loan_risk_dashboard
GROUP BY income_band
ORDER BY
    CASE income_band
        WHEN '<30K' THEN 1
        WHEN '30K-50K' THEN 2
        WHEN '50K-75K' THEN 3
        WHEN '75K-100K' THEN 4
        WHEN '100K-150K' THEN 5
        WHEN '150K+' THEN 6
        ELSE 7
    END;
    
-- ============================================================
-- RISK BY FICO SEGMENT
-- ============================================================

SELECT
    fico_band,
    COUNT(*) AS applications,
    ROUND(AVG(predicted_default_probability) * 100, 2)
        AS average_predicted_risk,
    ROUND(SUM(loan_amnt), 2)
        AS total_loan_exposure,
    ROUND(AVG(loan_amnt), 2)
        AS average_loan_amount
FROM loan_risk_dashboard
GROUP BY fico_band
ORDER BY
    CASE fico_band
        WHEN '600-649' THEN 1
        WHEN '650-679' THEN 2
        WHEN '680-699' THEN 3
        WHEN '700-719' THEN 4
        WHEN '720-749' THEN 5
        WHEN '750+' THEN 6
        ELSE 7
    END;
-- ============================================================
-- RISK BY DTI SEGMENT
-- ============================================================

SELECT
    dti_band,
    COUNT(*) AS applications,
    ROUND(AVG(predicted_default_probability) * 100, 2)
        AS average_predicted_risk,
    ROUND(SUM(loan_amnt), 2)
        AS total_loan_exposure,
    ROUND(AVG(loan_amnt), 2)
        AS average_loan_amount
FROM loan_risk_dashboard
GROUP BY dti_band
ORDER BY
    CASE dti_band
        WHEN '<10' THEN 1
        WHEN '10-20' THEN 2
        WHEN '20-30' THEN 3
        WHEN '30-40' THEN 4
        WHEN '40-50' THEN 5
        WHEN '50+' THEN 6
        ELSE 7
    END;
-- ============================================================
-- RISK BY LOAN PURPOSE
-- ============================================================

SELECT
    purpose,
    COUNT(*) AS applications,
    ROUND(AVG(predicted_default_probability) * 100, 2)
        AS average_predicted_risk,
    ROUND(SUM(loan_amnt), 2)
        AS total_loan_exposure,
    ROUND(AVG(loan_amnt), 2)
        AS average_loan_amount
FROM loan_risk_dashboard
GROUP BY purpose
HAVING COUNT(*) >= 500
ORDER BY average_predicted_risk DESC;

-- ============================================================
-- RISK BY STATE
-- ============================================================

SELECT
    addr_state,
    COUNT(*) AS applications,
    ROUND(AVG(predicted_default_probability) * 100, 2)
        AS average_predicted_risk,
    ROUND(SUM(loan_amnt), 2)
        AS total_loan_exposure,
    ROUND(AVG(loan_amnt), 2)
        AS average_loan_amount
FROM loan_risk_dashboard
GROUP BY addr_state
HAVING COUNT(*) >= 1000
ORDER BY average_predicted_risk DESC;

-- ============================================================
-- MANUAL REVIEW QUEUE
-- ============================================================

SELECT
    loan_id,
    loan_amnt,
    predicted_default_probability,
    risk_band,
    fico_score,
    dti_clean,
    annual_inc,
    emp_length_years,
    purpose,
    addr_state,
    int_rate
FROM loan_risk_dashboard
WHERE manual_review = 1
ORDER BY predicted_default_probability DESC
LIMIT 100;

-- ============================================================
-- HIGH-RISK PORTFOLIO EXPOSURE
-- ============================================================

SELECT
    risk_band,
    COUNT(*) AS applications,
    ROUND(SUM(loan_amnt), 2) AS total_loan_exposure,
    ROUND(AVG(predicted_default_probability) * 100, 2)
        AS average_predicted_risk
FROM loan_risk_dashboard
WHERE risk_band IN ('High Risk', 'Very High Risk')
GROUP BY risk_band
ORDER BY
    CASE risk_band
        WHEN 'High Risk' THEN 1
        WHEN 'Very High Risk' THEN 2
    END;
-- ============================================================
-- OVERALL PORTFOLIO RISK SUMMARY
-- ============================================================

SELECT
    COUNT(*) AS total_applications,
    ROUND(SUM(loan_amnt), 2) AS total_loan_exposure,
    ROUND(AVG(loan_amnt), 2) AS average_loan_amount,
    ROUND(AVG(predicted_default_probability) * 100, 2)
        AS average_predicted_risk,
    SUM(manual_review) AS manual_review_applications,
    ROUND(
        SUM(manual_review) * 100.0 / COUNT(*),
        2
    ) AS manual_review_rate,
    ROUND(
        SUM(CASE
            WHEN risk_band IN ('High Risk', 'Very High Risk')
            THEN loan_amnt
            ELSE 0
        END),
        2
    ) AS high_risk_loan_exposure
FROM loan_risk_dashboard;