/* Question Set #1 

Question 1
We want to understand more about the movies that families are watching.
 The following categories are considered family movies: Animation, Children, Classics, Comedy, Family and Music.
Create a query that lists each movie, the film category it is classified in,
 and the number of times it has been rented out.*/




WITH sub
AS
(SELECT
    f.title
   ,COUNT(r.rental_id) AS rental_count
  FROM film f
  JOIN inventory i
    ON i.film_id = f.film_id
  JOIN rental r
    ON i.inventory_id = r.inventory_id
  GROUP BY f.title
  ORDER BY f.title
)

SELECT
  f.title
 ,c.name AS category_film
 ,sub.rental_count
FROM film f
JOIN inventory i
  ON i.film_id = f.film_id
JOIN rental r
  ON i.inventory_id = r.inventory_id
JOIN film_category fc
  ON fc.film_id = f.film_id
JOIN category c
  ON fc.category_id = c.category_id
JOIN sub
  ON f.title = sub.title
GROUP BY 1,2,3
ORDER BY 2, 1;
/*   
----------------------------------
 Question Set #2

Question 1:

We want to find out how the two stores compare in their count 
of rental orders during every month for all the years we have data for.
 Write a query that returns the store ID for the store, 
the year and month and the number of rental orders each store has fulfilled for that month.
 Your table should include a column for each of the following:
 year, month, store ID and count of rental orders fulfilled during that month.*/



SELECT
  date_part('month', r.rental_date) AS rental_month
 ,date_part('year', r.rental_date) AS
  rental_year
 ,s.store_id
 ,COUNT(r.rental_id) AS count_rental
FROM rental r
JOIN staff sf
  ON sf.staff_id = r.staff_id
JOIN store s
  ON s.store_id = sf.store_id
GROUP BY 1,2,3
ORDER BY 4 DESC; 

/*
--------------------------------------------------------
Question 2

We would like to know who were our top 10 paying customers,
 how many payments they made on a monthly basis during 2007, 
and what was the amount of the monthly payments.
 Can you write a query to capture the customer name,
 month and year of payment, and total payment amount for each month by these top 10 paying customers?
*/


WITH  
  sub AS (  
    SELECT  
      p.customer_id,  
      CONCAT(c.first_name, '', c.last_name) AS fullName,  
      SUM(p.amount) AS total_amount_PerMonth  
    FROM  
      PAYMENT p  
      JOIN CUSTOMER c ON p.customer_id = c.customer_id  
    WHERE  
      DATE_PART('year', p.payment_date) = 2007  
    GROUP BY  
      1,  
      c.first_name,  
      c.last_name  
    ORDER BY  
      3 DESC  
    LIMIT  
      10  
  )  
SELECT  
  DATE_TRUNC('month', p.payment_date) AS mon_payment,  
  sub.fullName,  
  COUNT(p.customer_id) AS Pay_CountPerMonth,  
  SUM(p.amount) AS total_amount_PerMonth  
FROM  
  PAYMENT p  
  JOIN CUSTOMER c ON p.customer_id = c.customer_id  
  JOIN sub ON p.customer_id = sub.customer_id  
GROUP BY  
  1,  
  2  
ORDER BY  
  2,  
  1;  


/*
-------------------------------------------------------
Question 3

Finally, for each of these top 10 paying customers,
 I would like to find out the difference across their monthly payments during 2007. 
Please go ahead and write a query to compare the payment amounts in each successive month.
 Repeat this for each of these 10 paying customers.
 Also, it will be tremendously helpful if you can identify the customer 
name who paid the most difference in terms of payments.*/


WITH sub AS (  
    SELECT  
        p.customer_id,  
        CONCAT(c.first_name, '', c.last_name) AS fullName,  
        SUM(p.amount) AS total_amount_PerMonth  
    FROM PAYMENT p  
    JOIN CUSTOMER c ON p.customer_id = c.customer_id  
    WHERE DATE_PART('year', p.payment_date) = 2007  
    GROUP BY 1, c.first_name, c.last_name  
    ORDER BY 3 DESC  
    LIMIT 10  
),  

month_payment AS (  
    SELECT  
        DATE_TRUNC('month', p.payment_date) AS mon_payment,  
        sub.fullName,  
        COUNT(p.customer_id) AS Pay_CountPerMonth,  
        SUM(p.amount) AS total_amount_PerMonth  
    FROM PAYMENT p  
    JOIN CUSTOMER c ON p.customer_id = c.customer_id  
    JOIN sub ON p.customer_id = sub.customer_id  
    GROUP BY 1, 2  
    ORDER BY 2, 1  
),  

month_diff AS (  
    SELECT  
        mon_payment,  
        fullName,  
        total_amount_PerMonth,  
        LAG(total_amount_PerMonth) OVER (PARTITION BY fullName ORDER BY mon_payment) AS past_month_payment,  
        total_amount_PerMonth - LAG(total_amount_PerMonth) OVER (PARTITION BY fullName ORDER BY mon_payment)  
        AS payment_difference  
    FROM month_payment  
)  

SELECT  
    mon_payment,  
    fullName,  
    total_amount_PerMonth,  
    past_month_payment,  
    payment_difference  
FROM month_diff  
ORDER BY ABS(payment_difference) DESC NULLS LAST;  
