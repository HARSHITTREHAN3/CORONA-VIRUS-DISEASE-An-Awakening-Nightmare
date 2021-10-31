
-- select the data that we are going to be using

SELECT 
location, date, total_cases, new_cases, total_deaths, population
FROM
Project_Portfolio..CovidDeaths
WHERE continent is not null
ORDER BY 1,2;


--Looking at total cases v. total deaths
--Shows the liklyhood of dying if you get in contact with covid
select
location, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage  
FROM Project_Portfolio..CovidDeaths 
ORDER BY 1,2;

--looking at the total cases v population

SELECT 
location, date, total_cases, population, (total_cases/population)*100 AS population_infected  
FROM Project_Portfolio..CovidDeaths
WHERE continent is not null
--WHERE location = 'India' 
ORDER BY 1,2;

--COUNTRY WITH THE HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT 
continent, population, Max(total_cases) AS highest_infection_rate, MAX(total_cases/population)*100 AS PercentagePopulationInfected  
FROM Project_Portfolio..CovidDeaths
WHERE continent is not null
--WHERE location = 'India' 
group by  continent, population
ORDER BY PercentagePopulationInfected desc;


--Showing Countries With Highest Death Count Per Population

SELECT 
continent, Max(cast(total_deaths as int)) AS TotalDeathCount  
FROM Project_Portfolio..CovidDeaths
WHERE continent is not null
--WHERE location = 'India' 
group by  continent
ORDER BY TotalDeathCount desc;

--LET'S BREAK THINGS DOWN BY CONTINENT



--SHOWING CONTINENTS WITH HIGHEST DEATH COUNT PER POPULATION

SELECT 
continent, Max(cast(total_deaths as int)) AS TotalDeathCount  
FROM Project_Portfolio..CovidDeaths
where continent is not null
--WHERE location = 'India' 
group by  continent
ORDER BY TotalDeathCount desc;

--GLOBAL NUMBERS

select
sum(new_cases) as total_cases, sum(cast(New_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage 
FROM Project_Portfolio..CovidDeaths 
where continent is not null
--group by date
ORDER BY 1,2;


--looking for total population v vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER (PARTITION by dea.location ORDER BY dea.location, 
	dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
from Project_Portfolio..CovidDeaths dea
join Project_Portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;

-- USE CTE 

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER (PARTITION by dea.location ORDER BY dea.location, 
	dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from Project_Portfolio..CovidDeaths dea
join Project_Portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select
*, (RollingPeopleVaccinated/population)*100 as percentageRollingPeopleVaccinated
from
PopvsVac


--USE TEMP TABLE

drop table if exists #PERCENTPOPULATIONVACCINATED

CREATE TABLE #PERCENTPOPULATIONVACCINATED
(
Continent nvarchar (255),
Location nvarchar (255),
date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PERCENTPOPULATIONVACCINATED
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER (PARTITION by dea.location ORDER BY dea.location, 
	dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from Project_Portfolio..CovidDeaths dea
join Project_Portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select
*, (RollingPeopleVaccinated/population)*100 as percentageRollingPeopleVaccinated
from #PERCENTPOPULATIONVACCINATED


--CREATING VIEW FOR LATER DATA VISUALISATIONS

CREATE VIEW PERCENT_POPULATION_VACCINATE AS
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER (PARTITION by dea.location ORDER BY dea.location, 
	dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from Project_Portfolio..CovidDeaths dea
join Project_Portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3;

SELECT * 
FROM PERCENTPOPULATIONVACCINATED;




Select dea.Continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from Project_Portfolio..CovidDeaths dea
join Project_Portfolio..CovidVaccinations vac
	ON dea.continent = vac.continent
where dea.continent is not null
order by 2,3