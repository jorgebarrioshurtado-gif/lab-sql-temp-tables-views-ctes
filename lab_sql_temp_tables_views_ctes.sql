-- Creating a Customer Summary Report
-- In this exercise, you will create a customer summary report that summarizes key information about customers in the Sakila database, including their rental history and payment details. 
-- The report will be generated using a combination of views, CTEs, and temporary tables.
-- Step 1: Create a View
-- First, create a view that summarizes rental information for each customer. 
-- The view should include the customer's ID, name, email address, and total number of rentals (rental_count).

CREATE VIEW rental_info_per_customer AS
SELECT c.customer_id, c.first_name, c.email, COUNT(r.customer_id) rental_count
FROM customer c
INNER JOIN rental r
ON c.customer_id = r.customer_id
WHERE active = 1 -- in the documentation it says "active: Indicates whether the customer is an active customer. Setting this to FALSE serves as an alternative to deleting a customer outright. Most queries should have a WHERE active = TRUE clause."
				-- so, in order not to have unactive customers I am filtering them. 
GROUP BY r.customer_id;

-- Step 2: Create a Temporary Table
-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
-- The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.

CREATE TEMPORARY TABLE temp_total_paid AS
SELECT r.*, SUM(p.amount) total_paid
FROM rental_info_per_customer r
INNER JOIN payment p
ON r.customer_id = p.customer_id
GROUP BY r.customer_id;
-- I guess it makes sense because they are asking to do that. But, in my mind, 
-- it's weird creating a view which advantadge is that it updates automatically each time you use it to just store it in a temp table
-- does it update everytime you use it the temp table? it would make sense actually.
-- (sometimes i just think while writing and I leave the comments to see them if I come back at any moment)

-- Step 3: Create a CTE and the Customer Summary Report
-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. 
-- The CTE should include the customer's name, email address, rental count, and total amount paid.

SELECT first_name, email, rental_count, total_paid
FROM temp_total_paid; -- I don't know if I should have removed the rest of the columns and just leave the customer ID and total paid when creating the temp table.
					-- but, as I didn't this is working and show the required info. Anyway, even though it doesn't make sense for me, I'll make it.
					-- (I'm going to act as if this temp table only had the customer_id and total_paid)
WITH cte_customer_summary_report AS (
	SELECT r.first_name, r.email, r.rental_count, t.total_paid
	FROM rental_info_per_customer r
	INNER JOIN temp_total_paid t
	ON r.customer_id = t.customer_id);
    
    
-- Next, using the CTE, create the query to generate the final customer summary report, which should include: 
-- customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.

WITH cte_customer_summary_report AS (
	SELECT r.first_name, r.email, r.rental_count, t.total_paid
	FROM rental_info_per_customer r
	INNER JOIN temp_total_paid t
	ON r.customer_id = t.customer_id)
SELECT *,
    ROUND(total_paid/rental_count, 2) average_payment_per_rental
FROM cte_customer_summary_report;