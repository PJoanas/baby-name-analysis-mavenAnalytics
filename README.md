# Advanced SQL Querying by Maven Analytics - Final Project

## Purpose of the project
This repository contains an independent data analysis project based on the "Baby Names" dataset. The goal was to practice and showcase advanced SQL querying techniques by analyzing real-world data trends.

## SQL techniques used
* **Multi-table analysis** (Basic JOINs, joining multiple tables, UNION)
* **Subqueries** (Subqueries in SELECT, FROM, and WHERE clauses)
* **Common Table Expressions (CTEs)** (Structuring complex, multi-step queries)
* **Window Functions** (RANK(), DENSE_RANK(), LEAD(), LAG(), rolling averages)
* **Functions by Data Type** (String manipulation, CAST, aggregate functions)
* **Data Analysis Application** (Trend analysis, filtering, grouping)

## Business problems
In this project, I stepped into the role of a Data Analyst for a popular baby names website that collects data on names parents give their children each year. 
My duty was to analyze the database and track specific indicators over time to uncover trends:
* How does the popularity of specific names change over time?
* What are the most popular names across different decades?
* How does name popularity vary across different regions?
* What are the trends regarding unique or rare names?

## Dataset 
The dataset used in this project was provided by the Maven Analytics platform and is attached in the files.

## Code example
Below is an example of an SQL query used in this project to answer one of the business questions:

```sql-- Return the 3 most popular girl names and 3 most popular boy names within each region
with clear_regions as (select  state, case when region = 'New England' then 'New_England' else region end as c_region
					   from regions
					   union
					   select 'MI' as state, 'Midwest' as region),
                        
	 total_babies as (select cr.c_region, n.Gender, n.Name, sum(n.Births) as total_births
					  from names n left join clear_regions cr
					  on n.state = cr.state
					  group by cr.c_region, n.Gender, n.Name),
                      
		  ranking as (select *,
					  row_number() over (partition by c_region, Gender order by total_births desc) as ranking
					  from total_babies)
                      
select c_region, Gender, group_concat(Name order by ranking asc separator ', ') as top_names
from ranking
where ranking < 4
group by c_region, Gender;
```
