--select all data from vaccine
SELECT * from covidvaccinations order by date ;

--select all data from deaths
SELECT * from coviddeaths;


SELECT location, date, population, total_cases, new_cases, total_deaths 
FROM coviddeaths
WHERE continent is not null;


--death possiblity in a particular country --using INDIA for example
SELECT location, date, population, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as death_percent
FROM coviddeaths 
WHERE continent is not null and location like 'India' 
ORDER by location,date desc ;


--Percent of population affected by covid -- using INDIA for example
SELECT location, date, population, (total_cases/population)*100 as population_affected
FROM coviddeaths 
WHERE continent is not null and location='India' 
ORDER BY 1,2;


--Countries with highest covid infected rate
SELECT location, max(total_cases) as total_cases_so_far,max((total_cases/population)*100) as population_affected
FROM coviddeaths 
WHERE continent is not null
GROUP BY location
ORDER BY 3 desc, 1;


--people died who were affected - each country
SELECT location, max(cast(total_deaths as int)) as total_deaths_so_far
FROM coviddeaths 
WHERE continent is not null
GROUP BY location
ORDER BY 2 desc;

 
--people died who were affected - each continent
SELECT continent, max(cast(total_deaths as int)) as total_deaths_so_far
FROM coviddeaths 
WHERE continent is not null
GROUP BY continent
ORDER BY 2 desc;

SELECT location, max(cast(total_deaths as int)) as total_deaths_so_far
FROM coviddeaths 
WHERE continent is null
GROUP BY location
ORDER BY 2 desc;

--death vs population - each continent

select location as continent, total_deaths_so_far, pop, (total_deaths_so_far/pop)*100 as Percent_of_people_died_in_population 
FROM   (SELECT location, max(cast(total_deaths as int)) as total_deaths_so_far,max(population) as pop
		FROM coviddeaths 
		WHERE continent is null and location not in ('World','International')
		GROUP BY location) t 
ORDER BY 4 desc

-- Creating a view for death vs population
CREATE view death_vs_population as 
select location as continent, total_deaths_so_far, pop, (total_deaths_so_far/pop)*100 as Percent_of_people_died_in_population 
FROM   (SELECT location, max(cast(total_deaths as int)) as total_deaths_so_far,max(population) as pop
		FROM coviddeaths 
		WHERE continent is null and location not in ('World','International')
		GROUP BY location) t 


-- GLOBAL deaths each day

SELECT date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as death_ratio_so_far
FROM coviddeaths
WHERE continent is not null
GROUP BY date
ORDER BY date


--Joining deaths and vaccination tables

SELECT * 
FROM coviddeaths d inner join covidvaccinations v
on d.location=v.location and d.date=v.date
ORDER BY d.location,d.date


SELECT d.continent, d.location,d.date, d.population, d.total_deaths, v.new_vaccinations
FROM coviddeaths d inner join covidvaccinations v
on d.location=v.location and d.date=v.date
WHERE d.continent is not null
ORDER BY d.continent,d.location,d.date

--Total vaccinations doses administered - each country 

SELECT d.continent, d.location,d.date, d.population, d.total_deaths, v.new_vaccinations,sum(cast(new_vaccinations as int)) 
over (partition by d.location order by d.location , d.date) as total_vaccinated
FROM coviddeaths d inner join covidvaccinations v
on d.location=v.location and d.date=v.date
WHERE d.continent is not null
ORDER BY d.continent,d.location,d.date


-- Vaccination vs population
--Using subquery

SELECT t.continent,t.location, max(t.population) as population,max(t.total_vaccinated) as total_vaccinations,(max(t.total_vaccinated)/max(t.population))*100 as vaccine_percent 
FROM
(SELECT d.continent, d.location,d.date, d.population, d.total_deaths, v.new_vaccinations,sum(cast(new_vaccinations as int)) 
over (partition by d.location order by d.location , d.date) as total_vaccinated
FROM coviddeaths d inner join covidvaccinations v
on d.location=v.location and d.date=v.date
WHERE d.continent is not null
) t
GROUP BY t.continent,t.location
ORDER BY 1,2;

--Using CTE

With cte_vaccine (continent,location,date,population,total_deaths,new_vaccinations,total_vaccinated)
as
(
SELECT d.continent, d.location,d.date, d.population, d.total_deaths, v.new_vaccinations,sum(cast(new_vaccinations as int)) 
over (partition by d.location order by d.location , d.date) as total_vaccinated
FROM coviddeaths d inner join covidvaccinations v
on d.location=v.location and d.date=v.date
WHERE d.continent is not null
)
SELECT continent,location, max(population) as population,max(total_vaccinated) as total_vaccinations,(max(total_vaccinated)/max(population))*100 as vaccine_percent 
FROM cte_vaccine 
GROUP BY continent,location
ORDER BY  continent, location;


