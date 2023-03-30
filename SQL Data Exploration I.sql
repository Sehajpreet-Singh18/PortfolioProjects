/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2


--LOOKING AT TOTAL CASES VS TOTAL DEATHS 
-- SHOWS THE LIKELIHOOD IF YOU CONTACT COVID IN YOUR COUNTRY

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolioproject..CovidDeaths
where location like '%states%'
order by 1,2

--LOOKING AT TOTAL CASES VS POPUTATION 
--shows what percentage of population got covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From Portfolioproject..CovidDeaths
where location like '%states%'
order by 1,2 

--LOOKING AT COUNTRIES WITH HEIGHEST INFECTION RATE AS COMPARED TO POPULATION 

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
From Portfolioproject..CovidDeaths
--where location like '%states%'
Group by Location, population
Order by PercentPopulationInfected desc

--SHOWING COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULATION 

Select Location,MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolioproject..CovidDeaths
--where location like '%states%'
Where continent is not null
Group by Location
Order by TotalDeathCount desc 

--LET'S BREAK THINGS DOWN BY CONTINENT
--SHOWING THE CONTINENTS WITH THE HEIGHEST DEATH COUNT PER POPULATION 

Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolioproject..CovidDeaths
--where location like '%states%'
Where continent is  null
Group by location
Order by TotalDeathCount desc 

--GLOBAL NUMBERS 

Select date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Portfolioproject..CovidDeaths
--where location like '%states%'
where continent is not null 
 group by date 
order by 1,2


SELECT *
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date =vac.date
	order by dea.location

--LOOKING AT TOTAL POPULATION VS VACCINATION

SELECT dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations
,SUM(CONVERT(int,Vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date =vac.date
where dea.continent is not null
order by 2,3

--USE CTE 

with PopvsVac(continent, location,date,population,new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations
,SUM(CONVERT(int,Vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date =vac.date
where dea.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/population)*100
From PopvsVac

--CREATE TEMP TABLE to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations
,SUM(CONVERT(int,Vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date =vac.date
--where dea.continent is not null
--order by 2,3

Select *,(RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated
 

 --CREATING VIEW TO STORE DATA FOR LATER VISULATIONS 

 Create View PercentPopulationVaccinated as
 SELECT dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations
,SUM(CONVERT(int,Vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date =vac.date
where dea.continent is not null
--order by 2,3

--VIEWS
select *
from PercentPopulationVaccinated