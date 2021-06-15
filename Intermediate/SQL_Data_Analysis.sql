use SuperStore
-- Show qua các bảng có trong database
SELECT table_name 
FROM information_schema.tables;
-- Show qua các khóa ngoại có trong database
select table_name, constraint_name, constraint_type
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
where CONSTRAINT_TYPE = 'FOREIGN KEY';


--Q1
with a as(
	select sum(sales) as total_sales from Orders
	)
select segment, round(sum(sales/a.total_sales*100),0) as '%' from orders o, a, Customer c
where o.CustomerID = c.CustomerID
group by Segment;


--Q2
select distinct(ProductName) from Product;
select distinct(ProductID) from orders;
----
WITH Topfive AS (
    SELECT *, ROW_NUMBER() 
    over (
        PARTITION BY b.segment
        order by b.total desc
    ) AS ranker 
    FROM (SELECT segment,ProductName, sum(Quantity) as total
    FROM orders o 
	join Customer c on o.CustomerID = c.CustomerID
	join Product p on p.ProductID = o.ProductID
group by Segment, ProductName) as b)
SELECT * FROM Topfive WHERE ranker <= 5
order by Segment, total desc


-- Q3:
select category, SubCategory, sum(Profit) from orders o
join Product p on p.ProductID = o.ProductID
group by category, SubCategory
order by Category, SUM(profit) desc


-- Q4:
select column_name, data_type from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'Time';
with a as (
select sales, OrderYear,
case
	when OrderMonth between 1 and 3 then 1
	when OrderMonth between 4 and 6 then 2
	when OrderMonth between 7 and 9 then 3
	else 4
end as quarters
from orders o
join Time t on o.TimeID = t.TimeID
)
select OrderYear, quarters,round(sum(sales),0) from a
group by OrderYear, quarters
order by OrderYear, quarters


--Q5
select market,round(total_profit_market,0) as total_profit_market, ProductName, round(total_profit_product,0) as total_profit_product from(
	select *, sum(total_profit_product) over(partition by market) as total_profit_market from (
		select *, ROW_NUMBER() over(partition by b.Market order by b.total_profit_product desc) as ranker
			from (
				select market, ProductName,
					sum(profit) as total_profit_product
					from orders o 
					join Product p on p.ProductID = o.ProductID
					join Location l on l.LocationID = o.LocationID
					group by Market, ProductName) as b) as c) as d
					where ranker <= 3
					order by total_profit_market desc
	

-- Q6
with a as( select OrderMonth, round(sum(sales), 0) as total_sales, round(sum(profit),0) as total_profit from orders o
join time t on t.TimeID = o.TimeID
where OrderYear = 2017	
group by OrderMonth)
select *, round(total_profit/total_sales*100, 0) as 'ROS(%)',
		case
			when round(total_profit/total_sales*100, 0) >= 12 then 'Good'
			when round(total_profit/total_sales*100, 0) < 12 and round(total_profit/total_sales*100, 0) >=10 then 'Normal'
			when round(total_profit/total_sales*100, 0) < 10 then 'Bad'
		end as statuss
from a
order by orderMonth asc


with a as(
select productID,
		(cast(SUBSTRING(ProductID,len(ProductID)-3,1) as int)
		+ cast(SUBSTRING(ProductID,len(ProductID)-2,1) as int)
		+ cast(SUBSTRING(ProductID,len(ProductID)-1,1) as int)
		+ cast(SUBSTRING(ProductID,len(ProductID),1) as int))
		as sum_4_number
from Orders)
select *, iif(a.sum_4_number >= 20, concat('XY',substring(ProductID, 3, len(ProductID))),
		  iif(a.sum_4_number >= 10 and a.sum_4_number < 20, concat(substring(ProductID,1,1),'YZ',substring(ProductID,4,len(ProductID))),
		  concat(substring(ProductID,1,2),'Z',substring(ProductID,4,len(ProductID))))) as productId_final from a