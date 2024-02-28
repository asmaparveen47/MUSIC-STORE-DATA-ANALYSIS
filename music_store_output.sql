select * from album
select * from artist
select * from customer
select * from employee
select * from invoice

--who is the senior most employee based on job title?
select CONCAT(first_name,' ',last_name) as emp_name,levels from employee
order by levels desc
limit 1;

--which countries have the most invoices?
select count(distinct(invoice_id)) as invoices,billing_country 
from invoice
group by billing_country
order by invoices desc
limit 1;

--what are top 3 values of total invoice?
select invoice_id,total as total_invoices from invoice
order by total desc 
limit 3

--which city has the best customer?we would like to throw a 
--promotional misic festivsalin the city we made the most money .
--write a query that returns one city that has 
--the highest sum of invoice totals return both the city name and
--sum of all invoice totals

select billing_city ,sum(total) as invoice_totals from invoice
group by billing_city
order by invoice_totals desc
limit 1

--who is the best customer? the customer who has spent the most money 
--will be declared the best customer write a query that returns the
--person who has spent the most money?

select concat(first_name,' ',last_name) as full_name,c.customer_id,sum(i.total) as spent_money from invoice i
join customer c
on i.customer_id=c.customer_id
group by c.customer_id
order by spent_money desc
limit 1

--write a qy=uery to return the email,first name,lasst name,& genre
--of all rock music listeners.return your list ordered alphabetically
--by email starting with a

select distinct email,first_name,last_name from customer c
join invoice i on c.customer_id=i.customer_id
join invoice_line il on i.invoice_id=il.invoice_id
--join track tr on il.track_id=tr.track_id
--join genre g on tr.genre_id=tr.genre_id
--where g.name='Rock'
--order by email
where track_id in
             (select t.track_id from track t
               join genre g
                on t.genre_id = g.genre_id
                where g.name='Rock')
order by email 

--find how much amount spent by each customer on artists 
--write a query to return customer name atrist name total spent

 with best_selling_artist as (select sum(i.unit_price*i.quantity)as total
							  ,a.name as artist_name,a.artist_id 
 from invoice_line i
 join track t on i.track_id=t.track_id
 join album al on t.album_id=al.album_id
 join artist a on al.album_id=a.artist_id
 group by a.artist_id
 order by total desc
 limit 1)
 select c.customer_id,c.first_name,c.last_name,b.artist_name,
sum(i.unit_price*i.quantity)as total_spend
from invoice iv
join customer c on iv.customer_id=c.customer_id
join invoice_line i on iv.invoice_id=i.invoice_id
join track t on i.track_id=t.track_id
join album al on t.album_id=al.album_id
join artist a on al.artist_id=a.artist_id
join best_selling_artist b on a.artist_id=b.artist_id
group by 1,2,3,4
order by total_spend desc

--we want to find out the most popular music genre for eacj country
--we determine the most popular genre as the genre with the higherst
--amount of purchasses write a query that returns each country along
--with the top genre.for countries where the maximum number of purchases
--is shared return all genres

with popular_music as 
(select count(il.quantity)as qty,c.country,g.name,g.genre_id,
row_number() over 
(partition by c.country order by count(il.quantity)desc) as rowno from invoice_line il
join invoice i 
on il.invoice_id=i.invoice_id
join customer c on i.customer_id=c.customer_id	
join track t on il.track_id=t.track_id
join genre g on t.genre_id=g.genre_id
group by 2,3,4
order by 2 asc,1 desc
						)
select * from popular_music where rowno <= 1

--write a query that determines the customer that has spent the most on music for
--each country .write a query that returns the country along with the top customer
--and how much they spent.for countries where the top amount spent is shared proviedd
--customer who spent this aomount


with spend as(select sum(i.total) ,c.customer_id,c.country,c.first_name,
			  c.last_name,
row_number() over (partition by c.country order by sum(i.total) desc) as rowno 
			  from customer c
join invoice i 
on c.customer_id=i.customer_id
			 group by 2,3,4,5
			 order by 3,4 desc)
select * from spend where rowno <= 1








