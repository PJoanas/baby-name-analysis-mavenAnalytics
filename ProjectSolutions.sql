use baby_names_db;

select * from names;
select * from regions;

-- Find the overall most popular girl and boy names and show how they have changed in popularity rankings over the years
select * from names;

-- The most popular girl and boy names
with total_births as (select Gender, Name, sum(Births) as total_births
					  from names
					  group by Gender, Name),
                      
		  ranking as (select Gender,  Name,total_births,
					  rank() over (partition by Gender order by total_births desc) as birth_ranking
					  from total_births)
        
select * from ranking
where birth_ranking = 1;

-- Popularity over the years for the most popular female and male names
-- Ranking for Jessica over the years
select * from names;

with girl_names as (select Year, Name, sum(Births) as total_girls_births
					from names
					where gender = "F"
					group by Year, Name),
	 
     girls_rank as (select Year, Name, 
					dense_rank() over (partition by Year order by total_girls_births desc) as girls_rank
					from girl_names
					order by Year asc)

select * from girls_rank
where Name = 'Jessica';


-- Ranking for Michael over the years
with males_names as (select Year, Name, sum(Births) as total_males_births
					 from names
					 where gender = "M"
					 group by Year, Name),
                     
	  males_rank as (select Year, Name, 
				     dense_rank() over (partition by Year order by total_males_births desc) as males_rank
					 from males_names)

select * from males_rank
where Name = 'Michael';

-- Find the names with the biggest jump in popularity from the first year of the dataset to the last year of the dataset

with all_names as (select Year, Name, sum(Births) as total_births
				   from names
				   group by Year, Name),
                   
	   ranking as (select Year, Name, 
				   dense_rank() over (partition by Year order by total_births desc) as popularity
				   from all_names)

select *, cast(b.popularity as signed) - cast(a.popularity as signed) as popularity_jump
from 		(select * from ranking where Year = 1980) a
inner join  (select * from ranking where Year = 2009) b
			 on a.Name = b.Name
order by popularity_jump asc;


-- For each year, return the 3 most popular girl names and 3 most popular boy names
-- Checking for duplicates 
select		
	count(*)
from (select Gender, Year, Name from names) a
group by a.Gender, a.Year, a.Name;


with births_sum as (select Gender, Year, Name, sum(Births) as births_sum 
					from names 
					group by Gender, Year, Name ),
                    
	 names_rank as (select *,
					row_number() over (partition by Gender, Year order by births_sum desc) as name_rank
					from births_sum ),
	  top_three as (select * from names_rank
					where name_rank <= 3)

select Gender, Year, group_concat(Name ORDER BY births_sum DESC SEPARATOR ', ') as top_three_names
from top_three
group by Gender, year;


-- For each decade, return the 3 most popular girl names and 3 most popular boy names
with births_sum as (select Gender, round(Year,-1) as decade, Name, sum(Births) as births_sum 
					from names 
					group by Gender, decade, Name ),
                    
	 names_rank as (select *,
					row_number() over (partition by Gender, decade order by births_sum desc) as name_rank
					from births_sum ),
                    
	 top_three as (select * from names_rank
				   where name_rank <= 3 )

select Gender, decade, 
	   group_concat(Name ORDER BY births_sum DESC SEPARATOR ', ') as top_three_names
from top_three
group by Gender, decade;


-- Return the number of babies born in each of the six regions (NOTE: The state of MI should be in the Midwest region)
select * from names;
select * from regions;

with clear_regions as (select n.*,
					   case when r.region = 'New England' then 'New_England' else r.region  end as regions
					   from names n left join regions r 
					   on n.state = r.state)

select coalesce(regions, 'Midwest') as c_regions, sum(Births) as total_births
from clear_regions
group by c_regions
order by total_births desc;

-- Return the 3 most popular girl names and 3 most popular boy names within each region
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


-- Find the 10 most popular androgynous names (names given to both females and males)
select * from names;

with total_babies as (select Gender, Name, sum(Births) as total_babies
					 from names
                     group by Gender, Name),
							
     common_name as (select * from
							(select Name as f_name, total_babies as f_total_babies
							from total_babies
							where Gender = "F") f
						inner join
							(select Name as m_name, total_babies as m_total_babies
							from total_babies
							where Gender = "M") m
						on f.f_name = m.m_name)
                        
select f_name 						   as a_Name,
	   f_total_babies + m_total_babies as total
from common_name
order by total desc
limit 10;


-- Find the length of the shortest and longest names, and identify the most popular short names 
-- (those with the fewest characters) and long names (those with the most characters)

select * from names;

with total_babies as (select Name, sum(Births) as total_babies
					  from names
					  group by Name),
               
-- longest names have 15 characters 
-- shortest names have 2 characters

name_length as (select Name, total_babies, 
	            length(Name) as name_length
			    from total_babies),
 popularity as (select *,
			    row_number() over (partition by name_length order by total_babies desc) as popularity
			    from name_length
			    where name_length in (2, 15))  

select * from popularity 
where popularity = 1;

-- The founder of Maven Analytics is named Chris. Find the state with the highest percent of babies named "Chris".
select * from names;
select * from regions;

with total_births as (select State,
					  sum(Births) as total_births
					  from names 
					  group by State),
                      
total_births_chris as (select State,
						sum(Births) as total_births_chris
						from names
						where Name = 'Chris'
						group by State)

select tb.State, tb.total_births, tbc.total_births_chris,
	   cast(tbc.total_births_chris as decimal(18,8))  / tb.total_births * 100 as prt_chris
from total_births tb inner join total_births_chris tbc
	on tb.State = tbc.State
order by prt_chris asc;


