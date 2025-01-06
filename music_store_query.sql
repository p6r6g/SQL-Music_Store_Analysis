-- [Question Set 1 - Basic]

-- Q1: Who is the senior most employee based on the job title? 
select * from employee 
order by levels desc
limit 1;

-- Q2: Which countries have the highest invoices?
select count(*) as qty, billing_country 
from invoice 
group by billing_country
order by qty desc;

-- Q3: What are top 3 values of total invoice? 
select total
from invoice
order by total desc
limit 3;

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals */

select billing_city, sum(total) from invoice
group by billing_city
order by sum(total) desc
limit 1;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select c.customer_id, c.first_name, c.last_name, c.city, c.state, c.country, sum(i.total) as total_spending
from customer as c
join invoice as i on c.customer_id = i.customer_id
group by c.customer_id
order by total_spending desc
limit 1;

-------------------------------

-- [Question Set 2 - Intermediate]

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A. */

select distinct c.email, c.first_name, c.last_name, g.name as genre
from customer as c
join invoice as i on c.customer_id = i.customer_id 
join invoice_line as il on i.invoice_id = il.invoice_id
join track as t on il.track_id = t.track_id
join genre as g on g.genre_id = t.genre_id 
where g.name like 'Rock'
order by c.email asc;

/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select ar.artist_id, ar.name as artistname, count(track_id) as trackcount, g.name as genre
from artist as ar
join album as al on ar.artist_id  = al.artist_id
join track as t on t.album_id = al.album_id
join genre as g on g.genre_id = t.genre_id
where g.name like 'Rock'
group by ar.artist_id, genre
order by trackcount desc 
limit 10;

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select name, milliseconds 
from track
where milliseconds > (
	select avg(milliseconds)
	from track
)
order by milliseconds desc;

-------------------------------

-- [Question Set 2 - Advance]

/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

select c.first_name, c.last_name, ar.name, sum(il.unit_price*il.quantity) as totalspent
from invoice_line il
join invoice i on i.invoice_id = il.invoice_id 
join customer c on c.customer_id = i.customer_id
join track t on t.track_id = il.track_id
join album al on al.album_id = t.album_id
join artist ar on ar.artist_id = al.artist_id
group by c.first_name, c.last_name, ar.name
order by totalspent desc;


/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. 
Write a query that returns each country along with the top Genre. */

with popular_genre as(
	select count(il.quantity) as purchase, c.country, g.name as genre, g.genre_id, row_number() over (partition by c.country order by count(il.quantity) desc)
	from invoice_line il
	join invoice i on i.invoice_id = il.invoice_id
	join customer c on c.customer_id = i.customer_id
	join track t on t.track_id = il.track_id
	join genre g on g.genre_id = t.genre_id
	group by 2,3,4
	order by 2 asc, 1 desc
)

select * from popular_genre where row_number = 1;


/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. */

with max_purchase as(
	select c.customer_id, c.country, c.first_name, c.last_name, sum(i.total) as total_spending, 
	row_number() over (partition by c.country order by sum(i.total) desc)
	from customer c
	join invoice i on i.customer_id = c.customer_id
	group by 1,2,3,4
	order by 1 asc, 4 desc
)

select * from max_purchase where row_number = 1;

-- Thank You :)