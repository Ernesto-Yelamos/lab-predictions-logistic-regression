# Lab | Making predictions with logistic regression
# In this lab, you will be using the Sakila database of movie rentals.

use sakila;
set sql_safe_updates=0;
SET sql_mode=(SELECT REPLACE(@@sql_mode, 'ONLY_FULL_GROUP_BY', ''));

# In order to optimize our inventory, we would like to know which films will be rented next month and we are asked to create a model to predict it.
### Instructions
	-- 1. Create a query or queries to extract the information you think may be relevant for building the prediction model. It should include some film features and some rental features.
select * from sakila.film;
select * from sakila.rental;
select * from sakila.inventory;

select c.title, c.release_year, e.name as 'category', b.store_id, count(a.customer_id) as 'amount_customers' from sakila.rental as a
join sakila.inventory as b on b.inventory_id = a.inventory_id
join sakila.film as c on c.film_id = b.film_id
join sakila.film_category as d on d.film_id = c.film_id
join sakila.category as e on e.category_id = d.category_id
group by title
order by title;


# Get the star actor, who has appeared in most films from each film.
drop view film_film_actor;
create view film_film_actor as

with cte_af as 
	(select actor_id, count(film_id) as amount_film from sakila.film_actor
    group by actor_id
    order by actor_id)

select fa.film_id, f.title, fa.actor_id, concat(a.first_name, ' ', a.last_name) as star_actor,
cte.amount_film
from sakila.film_actor as fa
right join sakila.film as f on f.film_id = fa.film_id
right join sakila.actor as a on a.actor_id = fa.actor_id
right join cte_af as cte on cte.actor_id = a.actor_id
order by fa.film_id, f.title, amount_film desc;

select * from film_film_actor;

# Query to get the rank (which has been in most films) of actors per film using the create view table.
select film_id, title, star_actor, dense_rank() over (partition by film_id order by amount_film desc) as 'rank' from film_film_actor;

# Query to be able to use rank in the where clause.
select title, star_actor from 
(
	select film_id, title, star_actor, dense_rank() over (partition by film_id order by amount_film desc) as 'ranking' from film_film_actor
) as sub
where ranking = 1
order by title;


	-- 4. Create a query to get the list of films and a boolean indicating if it was rented last month. This would be our target variable.
# Most rented film
select * from sakila.film;
select*from rental;
select*from inventory;

use sakila;
SELECT a.title, a.film_id, COUNT(c.rental_date) as 'amount_rented_films' from sakila.film AS a
LEFT JOIN sakila.inventory AS b 
ON a.film_id = b.film_id
LEFT JOIN sakila.rental AS c 
ON c.inventory_id = b.inventory_id
where rental_date >= 20050501 and rental_date <= 20050530
group by a.film_id
order by film_id; 





use sakila;
SELECT a.title, a.film_id, COUNT(c.rental_date) as 'amount_rented_films', 
case
	when count(rental_date) > 0 then "Y"
    else "N"
end as "Rented May"
from sakila.film AS a
LEFT JOIN sakila.inventory AS b 
ON a.film_id = b.film_id
LEFT JOIN sakila.rental AS c 
ON c.inventory_id = b.inventory_id
where rental_date >= 20050515 and rental_date <= 20050530
group by a.film_id
order by film_id; 


