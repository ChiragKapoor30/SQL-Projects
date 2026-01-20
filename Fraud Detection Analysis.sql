Select * from "Transaction";

-- 1. Detecting Recursive Fraudulent Transactions

WITH RecursiveFraudChain AS (
    -- Anchor: Starting fraud transfers
    SELECT nameOrig AS initial_account,
           nameDest AS next_account,
           step,
           amount,
           newbalanceOrig
    FROM [dbo].[Transaction]
    WHERE isFraud = 1 AND type = 'TRANSFER'

    UNION ALL

    -- Recursive: Chain next fraud transfers
    SELECT fc.initial_account,
           t.nameDest AS next_account,
           t.step,
           t.amount,
           t.newbalanceOrig
    FROM RecursiveFraudChain fc
    JOIN [dbo].[Transaction] t ON fc.next_account = t.nameOrig 
                               AND fc.step < t.step
    WHERE t.isFraud = 1 AND t.type = 'TRANSFER'
)
SELECT * FROM RecursiveFraudChain
OPTION (MAXRECURSION 100);

-- 2. Detecting Fraudulent activity over time.

WITH rolling_fraud AS (
    SELECT
        nameOrig,
        step,
        SUM(isFraud) OVER (
            PARTITION BY nameOrig
            ORDER BY step
            ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
        ) AS fraud_rolling
    FROM [dbo].[Transaction]
)
SELECT *
FROM rolling_fraud
Where fraud_rolling > 0;

-- 3. Complex Fraud Detection using multiple CTEs
-- Question:
-- Use multiple CTEs to identify accounts with suspicious activity, including large transfers, consecutive transactions without balance change and flagged transactions.

WITH large_transfers AS (
    SELECT
        nameOrig,
        step,
        amount
    FROM [dbo].[Transaction]
    WHERE type = 'TRANSFER'
      AND amount > 500000
),
no_balance_change AS (
    SELECT
        nameOrig,
        step,
        oldbalanceOrg,
        newbalanceOrig
    FROM [dbo].[Transaction]
    WHERE oldbalanceOrg = newbalanceOrig
),
flagged_transactions AS (
    SELECT
        nameOrig,
        step
    FROM [dbo].[Transaction]
    WHERE isFlaggedFraud = 1
)

SELECT
    lt.nameOrig
FROM large_transfers lt
JOIN no_balance_change nbc
    ON lt.nameOrig = nbc.nameOrig
   AND lt.step = nbc.step
JOIN flagged_transactions ft
    ON lt.nameOrig = ft.nameOrig
   AND lt.step = ft.step;

-- 4. Write a query that checks if the completed new_updated_balance is the same as the actual newbalanceDest in the table. If they are equal, it returns those rows.

With CTE as (
	Select amount, nameOrig, oldbalanceDest, newbalanceDest, (amount+oldbalanceDest) as new_updated_balance
	From [dbo].[Transaction]
	)
Select * From CTE where new_updated_balance = newbalanceDest;

-- 5. Write a query to list transactions where oldbalanceDest or newbalanceDest is zero.

With XTE as (
	Select amount, nameOrig, oldbalanceDest, newbalanceDest
	From [dbo].[Transaction]
	)
Select * From XTE where oldbalanceDest = 0 or newbalanceDest = 0;