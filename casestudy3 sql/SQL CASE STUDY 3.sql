
SELECT * FROM Continent
SELECT * FROM Customers
SELECT * FROM [dbo].[Transaction]

--1. Display the count of customers in each region who have done the transaction in the year 2020.
SELECT region_id,COUNT(customer_id)AS num_of_customers FROM Customers
WHERE YEAR(end_date)=2020
GROUP BY region_id

--2. Display the maximum and minimum transaction amount of each transaction type.
SELECT txn_type FROM [dbo].[Transaction]
SELECT MAX(txn_amount)AS MAXIMUM_TRANSACTION_AMOUNT_IN_DEPOSIT  FROM [dbo].[Transaction] WHERE txn_type='deposit'
 SELECT MIN(txn_amount)AS MINIMUM_TRANSACTION_AMOUNT_IN_DEPOSIT FROM [dbo].[Transaction] WHERE txn_type='deposit'
 SELECT MAX(txn_amount)AS MAXIMUM_TRANSACTION_AMOUNT_IN_PURCHASE  FROM [dbo].[Transaction] WHERE txn_type='purchase'
 SELECT MIN(txn_amount)AS MINIMUM_TRANSACTION_AMOUNT_IN_PURCHASE FROM [dbo].[Transaction] WHERE txn_type='purchase'
 SELECT MAX(txn_amount)AS MAXIMUM_TRANSACTION_AMOUNT_IN_WITHDRAWAL  FROM [dbo].[Transaction] WHERE txn_type='withdrawal'
 SELECT MIN(txn_amount)AS MINIMUM_TRANSACTION_AMOUNT_IN_WITHDRAWAL FROM [dbo].[Transaction] WHERE txn_type='withdrawal'

--3. Display the customer id, region name and transaction amount where transaction type is deposit and transaction amount > 2000.
SELECT co.region_id , co.region_name,cu.customer_id ,cu.region_id ,[dbo].[Transaction].[customer_id] ,[dbo].[Transaction].[txn_amount]  FROM
Continent co,Customers cu,[dbo].[Transaction] WHERE txn_type='deposit' AND txn_amount>2000

--4. Find duplicate records in the Customer table.
SELECT [cu].[region_id],[cu].[start_date],[cu].[end_date],COUNT(*)AS Count_of_DUPS FROM [Customers] [cu]
GROUP BY [cu].[region_id],[cu].[start_date],[cu].[end_date]
HAVING COUNT(*) > 1

--5. Display the customer id, region name, transaction type and transaction amount for the minimum transaction amount in deposit.
SELECT MIN(txn_amount)AS MINIMUM_TRANSACTION_AMOUNT_IN_DEPOSIT FROM [dbo].[Transaction] WHERE txn_type='deposit'
SELECT  co.region_name,cu.customer_id,[dbo].[Transaction].[txn_type],[dbo].[Transaction].[txn_amount] FROM
Continent co,Customers cu,[dbo].[Transaction] WHERE txn_amount=0 AND txn_type='deposit'

--6. Create a stored procedure to display details of customers in the Transaction table where the transaction date is greater than Jun 2020.
CREATE PROCEDURE TRANSACTION_DATES3
      @transaction_date DATE 
	AS
	BEGIN
	    SELECT * FROM [dbo].[Transaction] 
		WHERE MONTH(txn_date)>MONTH(@transaction_date)
	END

	EXEC TRANSACTION_DATES3 @transaction_date='2020-06-30'

--7. Create a stored procedure to insert a record in the Continent table.
CREATE PROCEDURE new_record
(
      @region_id   INT ,
	  @region_name VARCHAR(60) 
)
	AS
	BEGIN 
		INSERT INTO Continent
		(
		region_id,
		region_name
		)
		VALUES
		(
		@region_id,
		@region_name
		)
END
GO
EXEC new_record
@region_id='6',
@region_name='India'

SELECT * FROM Continent

--8. Create a stored procedure to display the details of transactions that happened on a specific day.
CREATE PROCEDURE Specific_day
          @transaction_day DATE
AS
BEGIN
    SELECT * FROM [dbo].[Transaction]
    WHERE DAY(txn_date)=DAY(@transaction_day)
END

EXEC Specific_day @transaction_day='2020-01-17'

--9. Create a user defined function to add 10% of the transaction amount in a table.
CREATE FUNCTION Amount
(
@new_txn_amount DECIMAL(5,2),
@old_txn_amount INT)
RETURNS FLOAT
AS
BEGIN
      RETURN  @old_txn_amount+(@old_txn_amount * @new_txn_amount)  
END;

SELECT dbo.Amount(0.1,995)AS NEW_TRANSACTION_AMOUNT;

--10. Create a user defined function to find the total transaction amount for a given transaction type.
CREATE FUNCTION TXN_TYPE()
RETURNS TABLE
AS
RETURN
    SELECT SUM(txn_amount)AS TOTAL_TRANSACTION_AMOUNT_WITHDRAWAL FROM [dbo].[Transaction] 
	WHERE txn_type='withdrawal';

SELECT * FROM dbo.TXN_TYPE();

--11. Create a table value function which comprises the columns customer_id,region_id ,txn_date , txn_type , txn_amount which will retrieve data from the above table.
CREATE FUNCTION CHANDRAYAAN_3()
RETURNS TABLE
AS
RETURN
    SELECT Cu.customer_id,Cu.region_id,tr.txn_date,tr.txn_type,tr.txn_amount 
	FROM Customers Cu,[Transaction] [tr];

SELECT * FROM dbo.CHANDRAYAAN_3();

--12. Create a TRY...CATCH block to print a region id and region name in a single column.
BEGIN TRY
      SELECT CONCAT_WS(' ','1',' Australia')AS SINGLE_COLUMN FROM [dbo].[Continent]
	  WHERE region_id=1;
END TRY
BEGIN CATCH
	  SELECT ERROR_MESSAGE() AS error_messages;
END CATCH

--13. Create a TRY...CATCH block to insert a value in the Continent table.
BEGIN TRY
      INSERT INTO Continent(region_id,region_name)
	  VALUES('7','Russia'),('8','China'),('9','Japan'),('10','Germany');
END TRY
BEGIN CATCH
     SELECT ERROR_LINE() AS error1;
END CATCH

--14. Create a trigger to prevent deleting a table in a database.

CREATE TRIGGER Ankitasingh 
ON Continent
FOR
delete
AS
PRINT'Sorry!You cannot have access to delete table'
ROLLBACK;


--15. Create a trigger to audit the data in a table.
CREATE TABLE transaction_audit_table
(
customer_id INT PRIMARY KEY,
txn_date DATETIME,
txn_type NVARCHAR(100),
txn_amount MONEY,
updatedby NVARCHAR(130),
updatedon DATETIME
)
CREATE TRIGGER Transactionauditrecords ON [dbo].[Transaction]
AFTER UPDATE,INSERT
AS
BEGIN
     INSERT INTO transaction_audit_table
	 (customer_id,txn_date,txn_type,txn_amount,updatedby,updatedon)
	 SELECT t.customer_id,t.txn_date,t.txn_type,t.txn_amount,SUSER_SNAME(),GETDATE()
	 FROM [Transaction] a
	 INNER JOIN inserted  t ON t.customer_id=a.customer_id
END 
GO
INSERT INTO  [Transaction](txn_date,txn_amount) VALUES('2023-05-07',894)
INSERT INTO [Transaction](txn_date,txn_amount,txn_type)VALUES('2022-06-29',1200,'deposit')

SELECT * FROM  [Transaction]
SELECT * FROM transaction_audit_table

UPDATE  [Transaction]
SET txn_date='2023-05-19',
txn_type='NOT UPDATED',
txn_amount=6500
WHERE customer_id=460
GO

SELECT * FROM [Transaction]
SELECT * FROM transaction_audit_table ORDER BY customer_id,customer_audit_id
GO

--16. Create a trigger to prevent login of the same user id in multiple pages.
USE master;
GO
CREATE LOGIN login_test1 WITH PASSWORD = N'*RamukHsengiV_786$' MUST_CHANGE,
     CHECK_EXPIRATION = ON;
GO
GRANT VIEW SERVER STATE TO login_test1;
GO
CREATE TRIGGER connections_limit_trigger
ON ALL SERVER WITH EXECUTE AS N'login_test1'
FOR LOGON
AS
BEGIN
IF ORIGINAL_LOGIN() = N'login_test1' AND
   (SELECT COUNT(*) FROM sys.dm_exec_sessions
     WHERE is_user_process = 1 AND
	   original_login_name = N'login_test1') > 3
	   ROLLBACK;
END;

--17. Display top n customers on the basis of transaction type.
SELECT TOP  5* FROM [Transaction] WHERE txn_type='withdrawal'
ORDER  BY txn_amount DESC;

SELECT TOP  5* FROM [Transaction] WHERE txn_type='deposit'
ORDER  BY txn_amount DESC;

SELECT TOP  5* FROM [Transaction] WHERE txn_type='purchase'
ORDER  BY txn_amount DESC;

--18. Create a pivot table to display the total purchase, withdrawal and deposit for all the customers.
SELECT * FROM (SELECT txn_type,txn_amount FROM [dbo].[Transaction])
AS T
PIVOT
(
SUM(txn_amount) FOR txn_type IN (purchase,withdrawal,deposit)
)AS Y