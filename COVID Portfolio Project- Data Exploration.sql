/* 
Covid 19 Data Exploration 

Skills used: Joins, CTEs, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
  FROM PortfolioProject.[dbo].[CovidDeaths]
  where continent is not null
  order by 3,4

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
  FROM PortfolioProject.[dbo].[CovidDeaths]
  where continent is not null
  order by 1,2  /*based on location and date*/

-- Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract COVID in your country
	
SELECT 
	Location, date, total_cases, total_deaths,
	(total_deaths/total_cases)*100 AS DeathPercentage
  FROM PortfolioProject.[dbo].[CovidDeaths]
  where Location like '%states%'
  and continent is not null
  order by 1,2

  -- Total cases vs Population
  -- Shows the Percentage of the Population that was infected with COVID

SELECT 
	Location, date, total_cases, population,(total_cases/population)*100 AS PercentOfPopulationinfected
  FROM PortfolioProject.[dbo].[CovidDeaths]
  where Location like '%states%'
  and continent is not null
  order by 1,2

-- Country with the highest Infection rates compared to the Population

SELECT 
	Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) AS PercentOfPopulationinfected
FROM PortfolioProject.[dbo].[CovidDeaths]
where continent is not null
	group by Location, population
	order by PercentOfPopulationinfected desc

-- Countries with the highest death count per population 

SELECT 
	Location, MAX(cast(total_deaths as int)) as totalDeathCounts
FROM PortfolioProject..[CovidDeaths]
where continent is not null
	group by Location
	order by totalDeathCounts desc

-- Breaking things down by continent
-- Showing continents with the highest death count per population

SELECT 
	continent, MAX(cast(total_deaths as int)) as totalDeathCounts
FROM PortfolioProject..[CovidDeaths]
where continent is not null
	group by continent
	order by totalDeathCounts desc

-- Global Numbers

SELECT 
--	date, 
	sum(new_cases) as TotalCases, 
	sum(cast(new_deaths as int)) as TotalDeaths, 
	sum(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM PortfolioProject.[dbo].[CovidDeaths]
  where continent is not null
  order by 1,2


-- Total Population vs Vaccinations
-- Shows the Percentage of the Population that has received at least one COVID Vaccine

select 
	cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	SUM(CONVERT(INT, cv.new_vaccinations)) OVER (Partition By cd.Location ORDER BY cd.Location) as RollingCountofPeopleVaccinated
from PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
	where cd.continent is not null
	order by 2,3


-- Using CTE to perform Calculation on Partition By in previous Query

With PopvsVacc (Continent, Date, Location, Population, RollingCountofPeopleVaccinated, new_vaccinations) 
as (
	select 
	cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	SUM(CONVERT(INT, cv.new_vaccinations)) OVER (Partition By cd.Location ORDER BY cd.Location) as RollingCountofPeopleVaccinated
from PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
	where cd.continent is not null
	)
	select 
		*
		,(RollingCountofPeopleVaccinated/Population)*100
	from PopvsVacc



-- Using TEMP Table to perform the calculation on Partition by in the previous query

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingCountofPeopleVaccinated numeric
)
	
Insert into #PercentPopulationVaccinated
	select 
		cd.continent, 
		cd.location, 
		cd.date, 
		cd.population, 
		cv.new_vaccinations,
		SUM(CONVERT(INT, cv.new_vaccinations)) OVER (Partition By cd.Location ORDER BY cd.Location) as RollingCountofPeopleVaccinated
from PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
	select 
		*
		,(RollingCountofPeopleVaccinated/Population)*100
	from #PercentPopulationVaccinated



-- Creating a View to store data for later visualizations

 create view PercentPopulationVaccinated as 
 	select 
		cd.continent, 
		cd.location, 
		cd.date, 
		cd.population, 
		cv.new_vaccinations,
		SUM(CONVERT(INT, cv.new_vaccinations)) OVER (Partition By cd.Location ORDER BY cd.Location) as RollingCountofPeopleVaccinated
from PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
	where cd.continent is not null
