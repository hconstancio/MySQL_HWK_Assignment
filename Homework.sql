/*
# +++ CONSTANCIO HERNANDEZ MySQL Homework Assignment +++  
*/

USE sakila;

/* 1a. Display the first and last names of all actors from the table `actor`.   */

SELECT * FROM actor;
SELECT first_name, last_name 
FROM actor;

/* 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`..  */

SELECT CONCAT(first_name, ' ', last_name) AS 'Actor Name' FROM actor;

/* 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
What is one query would you use to obtain this information?*/


SELECT actor_id, first_name, last_name 
FROM actor 
WHERE first_name LIKE "JOE";

/* 2b. Find all actors whose last name contain the letters `GEN`: */

SELECT actor_id, first_name, last_name 
FROM actor 
WHERE last_name LIKE "%GEN%";

/* 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order: */

SELECT actor_id, last_name, first_name 
FROM actor 
WHERE last_name LIKE "%LI%";

/* 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:   */

SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');


/*  3a. Add a `middle_name` column to the table `actor`. Position it between `first_name` and `last_name`.  Hint: you will need to specify the data type. */

ALTER TABLE actor
ADD middle_name VARCHAR(30) NOT NULL;
SELECT first_name, middle_name, last_name
FROM actor;

/* 3b. You realize that some of these actors have tremendously long last names.    Change the data type of the `middle_name` column to `blobs`.   */

ALTER TABLE actor
MODIFY COLUMN middle_name BLOB;

/* 3c. Now delete the `middle_name` column.  */

ALTER TABLE actor
DROP COLUMN middle_name;

/* 4a. List the last names of actors, as well as how many actors have that last name.  */

SELECT last_name, COUNT(last_name) AS 'Number'
FROM actor
GROUP BY last_name;

/* 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors */

SELECT last_name, COUNT(last_name) AS 'SAME'
FROM actor
GROUP BY last_name
HAVING SAME >1;

/* 4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`, the name of Harpo's second cousin's 
husband's yoga teacher. Write a query to fix the record. */

SET SQL_SAFE_UPDATES = 0;
UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';
SET SQL_SAFE_UPDATES = 1;

/* 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, 
if the first name of the actor is currently `HARPO`, change it to `GROUCHO`. Otherwise, change the first name to `MUCHO GROUCHO`, as that is exactly what 
the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, HOWEVER! 
(Hint: update the record using a unique identifier.) */

SET SQL_SAFE_UPDATES = 0;
SELECT first_name, last_name FROM actor;
UPDATE actor
SET first_name = 'GROUCHO' WHERE actor_id = 172;
UPDATE actor
SET first_name = 'MUCHO GROUCHO' WHERE actor_id = 78;
UPDATE actor
SET first_name = 'MUCHO GROUCHO' WHERE actor_id=106;
SET SQL_SAFE_UPDATES = 1;

/* 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?   Hint: <https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html>*/

SHOW CREATE TABLE address;

/* 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:   */

SELECT staff.first_name, staff.last_name, address.address
FROM staff
JOIN address
USING (address_id);

/* 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.   */

SELECT s.first_name, s.last_name, SUM(p.amount) AS tot_amount
FROM staff s
INNER JOIN payment p
ON s.staff_id = p.staff_id
WHERE p.payment_date BETWEEN '2005-08-01 00:00:00' AND '2005-08-31 23:59:59'
GROUP BY
	s.first_name, s.last_name;

/* 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.   */

SELECT COUNT(actor_id) AS 'Num.Actors', title
FROM film_actor
INNER JOIN film
USING (film_id)
GROUP BY title;

/* 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?  Use Film & Inventory via film_id  */

SELECT COUNT(film_id) AS 'Num.Copies For HUNCBACK IMPOSSIBLE'
FROM inventory
WHERE film_id IN
(
  SELECT film_id
   FROM film
   WHERE title = 'HUNCHBACK IMPOSSIBLE'
  );

/* 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:   */

SELECT SUM(amount) AS '$ Amount Paid', first_name, last_name
	FROM payment p
INNER JOIN customer c ON p.customer_id=c.customer_id
GROUP BY c.last_name, c.first_name
ORDER BY c.last_name ASC;

/* 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also 
soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.*/

SELECT title
FROM film
WHERE language_id IN
(
    SELECT language_id
    FROM language
    WHERE name = "English"  AND title LIKE 'Q%' OR title LIKE 'K%'
 );


/* 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.  */

SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(
  SELECT actor_id
  FROM film_actor
  WHERE film_id IN
  (
   SELECT film_id
   FROM film
   WHERE title = 'ALONE TRIP'
  )
);

/* 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
Use joins to retrieve this information.  */

SELECT first_name, last_name, email, country
FROM customer c
	INNER JOIN address a
		ON c.address_id = a.address_id
    INNER JOIN city ci
		ON a.city_id = ci.city_id
	INNER JOIN country co
		ON ci.country_id = co.country_id
GROUP BY c.first_name, c.last_name, c.email, co.country
HAVING co.country = "CANADA";

/* 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.   */

SELECT title, rating
FROM film
WHERE rating IN ('G', 'PG', 'PG13');

/* 7e. Display the most frequently rented movies in descending order.  */

SELECT f.title, COUNT(r.rental_id) AS 'Rental Amount'
FROM rental r
	INNER JOIN inventory i
		ON r.inventory_id = i.inventory_id
	INNER JOIN film f
		ON i.film_id = f.film_id
GROUP BY f.title
ORDER BY COUNT(r.rental_id) DESC;

/* 7f. Write a query to display how much business, in dollars, each store brought in.   */

SELECT s.store_id, SUM(p.amount) AS tot_amount
FROM staff s
INNER JOIN payment p
ON s.staff_id = p.staff_id
GROUP BY
	s.store_id;

/* 7g. Write a query to display for each store its store ID, city, and country.   */

SELECT s.store_id, c.city, p.country
FROM store s
	INNER JOIN address a
		ON s.address_id = a.address_id
	INNER JOIN city c
		ON a.city_id = c.city_id
	INNER JOIN country p
		ON c.country_id = p.country_id
GROUP BY s.store_id, c.city, p.country;

/* 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)  */

SELECT cat.name, SUM(pmt.amount) AS 'Gross Revenue ($)'
FROM category cat
INNER JOIN film_category fcat
	ON cat.category_id = fcat.category_id
INNER JOIN inventory i    
   ON fcat.film_id = i.film_id
INNER JOIN rental rent
	ON i.inventory_id = rent.inventory_id
INNER JOIN payment pmt    
	ON rent.rental_id = pmt.rental_id
GROUP BY cat.name
ORDER BY SUM(pmt.amount) DESC
LIMIT 5
;

/* 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view. */

CREATE VIEW TOP5_VIEW AS 
SELECT cat.name, SUM(pmt.amount) AS 'Gross Revenue ($)'
FROM category cat
INNER JOIN film_category fcat
	ON cat.category_id = fcat.category_id
INNER JOIN inventory i    
   ON fcat.film_id = i.film_id
INNER JOIN rental rent
	ON i.inventory_id = rent.inventory_id
INNER JOIN payment pmt    
	ON rent.rental_id = pmt.rental_id
GROUP BY cat.name
ORDER BY cat.name DESC
LIMIT 5;

/* 8b. How would you display the view that you created in 8a?   */

SELECT * FROM TOP5_VIEW;


/* 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.    */

DROP VIEW TOP5_VIEW;

