select *
from [Portfolio Project new].dbo.Data1$

select *
from [Portfolio Project new].dbo.Data2;

--Number of rows in the dataset
select count(*) from [Portfolio Project new]..Data1$   --1000
select count(*) from [Portfolio Project new]..Data2    --999

-- dataset for Jharkhand and Bihar

select * from [Portfolio Project new]..data1$ 
where state in ('Jharkhand','Bihar')

--population of India

select sum(population) as total_population
from [Portfolio Project new]..data2

--Avg Growth of India

select avg(growth)*100 Avg_growth
from [Portfolio Project new]..Data1$ 

--Avg Growth of States and UTs

select (state),avg(growth)*100 Avg_growth_state_Uts
from [Portfolio Project new]..Data1$ 
group by state

--Avg sex ratio

select state,round(avg(Sex_Ratio),0) avg_sex_ratio 
from [Portfolio Project new]..Data1$
group by state
order by avg_sex_ratio desc ;


--Use of Having clause

select state,round(avg(Sex_Ratio),0) avg_sex_ratio     --Order of Execution FJWGHSDOL
from [Portfolio Project new]..Data1$
group by state
having round(avg(Sex_Ratio),0) >1000
order by avg_sex_ratio desc ;

--avg literacy rate

select state, round(avg(literacy),0) avg_literacy_ratio 
from [Portfolio Project new]..Data1$
group by state
having round(avg(literacy),0) >90
order by avg_literacy_ratio desc;

--top 5 states showing highest sex ratio

select top 5 state,round(avg(Sex_Ratio),0) avg_sex_ratio      -- Most of them are South India Region
from [Portfolio Project new]..Data1$
group by state 
order by avg_sex_ratio desc


--Top 2 districts in each state showing Highest Sex ratio
select *
from (
select district,state,growth,literacy,sex_ratio,                    --Window Functions &Subquery Usage.
max(sex_ratio) over (partition by state) as Max_Sex_ratio,
dense_rank() over (partition by state order by sex_ratio desc) as Dense_rank
from [Portfolio Project new].dbo.Data1$ as d1
where district not like 'NULL%'
) x
where x.Dense_rank <3 
order by Max_Sex_ratio desc,Sex_Ratio desc;


---creating table then applying union operator

drop table if exists #topstates                                   -- Top 3 states showing max avg literacy ratio
create table #topstates
   (state nvarchar(255),
   topstate float)
insert into #topstates
select state, round(avg(literacy),0) avg_literacy_ratio 
from [Portfolio Project new]..Data1$
group by state
order by avg_literacy_ratio desc;

select top 3 *from #topstates order by #topstates.topstate desc;


drop table if exists #bottomstates;                                   -- Bottom 3 states showing max avg literacy ratio
create table #bottomstates
   (state nvarchar(255),
   bottomstate float)
insert into #bottomstates
select  state, round(avg(literacy),0) avg_literacy_ratio 
from [Portfolio Project new]..Data1$
group by state
having state not in ('NULL','State')
order by avg_literacy_ratio ;

select top 3 * from #bottomstates order by #bottomstates.bottomstate 

--union operator

select * from (
select top 3 *from #topstates order by #topstates.topstate desc)  a
union
select * from (
select top 3 * from #bottomstates order by #bottomstates.bottomstate) b
order by topstate desc;

--Joining Both tables                                            --Including Males &Females using maths formula
                                                                 --males = population/(sex_ratio +1)
select d1.district,d1.state,sex_ratio,population                 --females =(population*(sex_raio))/(sex_ratio+1)
from [Portfolio Project new]..Data1$ d1
inner join [Portfolio Project new]..Data2 d2
on d1.District=d2.District;

--Males and Females in each district.
select d3.district ,d3.state,round(d3.population/(d3.sex_ratio +1),0) males,round((d3.population*d3.sex_ratio)/(d3.sex_ratio+1),0) females
from (select d1.district,d1.[State ],d1.sex_ratio/1000 sex_ratio,d2.population                 
from [Portfolio Project new]..Data1$ d1
inner join [Portfolio Project new]..Data2 d2
on d1.District=d2.District) d3

--Total Males &Total Females in each state.


select d4.state,sum(males) as Total_males ,sum(females) Total_females
from (select d3.district ,d3.state,round(d3.population/(d3.sex_ratio +1),0) males,round((d3.population*d3.sex_ratio)/(d3.sex_ratio+1),0) females
from (select d1.district,d1.[State ],d1.sex_ratio/1000 sex_ratio,d2.population                 
from [Portfolio Project new]..Data1$ d1
inner join [Portfolio Project new]..Data2 d2
on d1.District=d2.District) d3)d4
group by d4.state;

--CENSUS comparison
--population in previous census of India                                              --previous_census+growth*previous_census=population
 

 select '1' as keyy,d8.*                                                             --keyy not key
 from
 (select sum(d7.previous_census_population)India_previous_census_population,sum(d7.current_census_population) India_current_census_poplation                                                                            -- previous_census=population/(1+growth)
 from 

--population in previous census by each state.
(select d6.state,sum(d6.previous_census_population) previous_census_population,sum(d6.current_census_population) current_census_population

from
(select d5.district,d5.state,round(population/(1+d5.growth),0) previous_census_population,population current_census_population
from
(select d1.district,d1.[State ],d1.Growth growth,d2.population               
from [Portfolio Project new]..Data1$ d1
inner join [Portfolio Project new]..Data2 d2
on d1.District=d2.District )d5)d6
group by state)d7)d8
 
--Comparing Population Density


select d10.* from 
(select '1' as keyy,d9.*
from
(select sum(Area_km2) Total_area_India
from [Portfolio Project new].dbo.Data2)d9)d10



select round(d11.India_previous_census_population/d11.Total_area_India ,0)Previous_population_density,round(d11.India_current_census_poplation/d11.Total_area_India,0)
Current_population_density 
from
(select d9.*,d10.Total_area_India from 
(select '1' as keyy,d8.*                                                             --keyy not key
from
(select sum(d7.previous_census_population)India_previous_census_population,sum(d7.current_census_population) India_current_census_poplation                                                                            -- previous_census=population/(1+growth)
from(select d6.state,sum(d6.previous_census_population) previous_census_population,sum(d6.current_census_population) current_census_population
from(select d5.district,d5.state,round(population/(1+d5.growth),0) previous_census_population,population current_census_population
from(select d1.district,d1.[State ],d1.Growth growth,d2.population               
from [Portfolio Project new]..Data1$ d1
inner join [Portfolio Project new]..Data2 d2
on d1.District=d2.District )d5)d6                                  --clearly the population density has increased in current census.
group by state)d7)d8)d9                                               
inner join 
(select '1' as keyy,d9.*
from
(select sum(Area_km2) Total_area_India
from [Portfolio Project new].dbo.Data2)d9)d10
on d9.keyy =d10.keyy)d11

