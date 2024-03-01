SELECT * FROM swiggy.orders;
SELECT * FROM swiggy.menu;
SELECT * FROM swiggy.delivery_partner;
SELECT * FROM swiggy.restaurants;
SELECT * FROM swiggy.users;
SELECT * FROM swiggy.order_details;
SELECT * FROM swiggy.food;

#1. Find customers who have never ordered 
Select name from users
where user_id not in (select user_id from orders)

#2. Average Price/dish
with cte as(Select a.f_id,b.f_name,a.price 
from menu a join food b
on a.f_id=b.f_id)
select f_name, avg(price) as price
from cte
group by f_name

Select b.f_name,avg(a.price) 
from menu a join food b
on a.f_id=b.f_id
group by b.f_name

#3. Find the top restaurant in terms of the number of orders for a given month
select b.r_name,count(*) as cnt from orders a join restaurants b on a.r_id=b.r_id where Monthname(date) like 'May'
group by b.r_name
order by cnt desc
limit 1

#4. restaurants with monthly sales greater than x for 
select b.r_name,sum(amount) as revenue from orders a join restaurants b on a.r_id=b.r_id
where monthname(date) like 'June'
group by b.r_name
having revenue>500

#5.Show all orders with order details for a particular customer in a particular date range
select a.order_id,b.r_name,d.f_name
from orders a Join restaurants b
on a.r_id=b.r_id
join order_details c
on a.order_id=c.order_id
join food d
on c.f_id=d.f_id
where user_id = (select user_id from users where name Like "Ankit")
and (date > '2022-06-10' and date < '2022-07-10')

#6.Find restaurants with max repeated customers 
select r.r_name, count(*) as loyal_cust from
(select r_id,user_id,Count(*) as visits
from orders
group by r_id,user_id
having visits>1) t
join restaurants r on t.r_id=r.r_id
group by r.r_name
order by loyal_cust desc limit 1

#7. Month over month revenue growth of swiggy
select month, round(((revenue-prev)/prev)*100) as growth from
(with Sales as (select Monthname(date) as month, sum(amount) as revenue
from orders
group by month
order by month desc)
select *,Lag(revenue,1) over(order by revenue) as prev
from sales) t

#8. Customer - favorite food
with cte as (select o.user_id,od.f_id, Count(*) as freq
from orders o
join order_details od on o.order_id=od.order_id
group by o.user_id,od.f_id)
select u.name,f.f_name
from cte c1 
join users u on u.user_id=c1.user_id
join food f on f.f_id=c1.f_id
where c1.freq=(select max(freq) from cte c2 where c1.user_id=c2.user_id) 
