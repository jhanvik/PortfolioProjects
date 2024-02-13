SELECT *
  FROM [ResearcherDatabase].[dbo].[CovidDeaths]
  where continent is not null
  order by 3,4


--SELECT *
--  FROM [ResearcherDatabase]..[CovidVaccinations]
--  order by 3,4

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
  FROM [ResearcherDatabase].[dbo].[CovidDeaths]
  where continent is not null
  order by 1,2  /*based on location and date*/

-- Looking at Total Cases vs Total Deaths
-- shows the likelihood of dying if you contract covid in your country
SELECT 
	Location, date, total_cases, total_deaths,
	(total_deaths/total_cases)*100 AS DeathPercentage
  FROM [ResearcherDatabase].[dbo].[CovidDeaths]
  where Location like '%states%'
  and continent is not null
  order by 1,2

  -- Looking at the total cases vs the population
  -- shows % of population got covid

SELECT 
	Location, date, total_cases, population,(total_cases/population)*100 AS PercentOfPopulationinfected
  FROM [ResearcherDatabase].[dbo].[CovidDeaths]
  where Location like '%states%'
  and continent is not null
  order by 1,2

-- What country has the highest infection rates compared to the poplation

SELECT 
	Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) AS PercentOfPopulationinfected
FROM [ResearcherDatabase].[dbo].[CovidDeaths]
where continent is not null
	group by Location, population
	order by PercentOfPopulationinfected desc

-- Looking at countries with the highest death count per population 

SELECT 
	Location, MAX(cast(total_deaths as int)) as totalDeathCounts
FROM [ResearcherDatabase]..[CovidDeaths]
where continent is not null
	group by Location
	order by totalDeathCounts desc

-- lets break things down by continents
-- showing the continents with the highest death points

SELECT 
	continent, MAX(cast(total_deaths as int)) as totalDeathCounts
FROM [ResearcherDatabase]..[CovidDeaths]
where continent is not null
	group by continent
	order by totalDeathCounts desc

-- global numbers

SELECT 
--	date, 
	sum(new_cases) as TotalCases, 
	sum(cast(new_deaths as int)) as TotalDeaths, 
	sum(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM [ResearcherDatabase].[dbo].[CovidDeaths]
  where continent is not null
 -- group by date
  order by 1,2


-- Looking at total population vs vaccinations


select 
	cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	SUM(CONVERT(INT, cv.new_vaccinations)) OVER (Partition By cd.Location ORDER BY cd.Location) as RollingCountofPeopleVaccinated
from ResearcherDatabase..CovidDeaths cd
Join ResearcherDatabase..CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
	where cd.continent is not null
	order by 2,3


-- USE CTE

With PopvsVacc (Continent, Date, Location, Population, RollingCountofPeopleVaccinated, new_vaccinations) 
as (
	select 
	cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	SUM(CONVERT(INT, cv.new_vaccinations)) OVER (Partition By cd.Location ORDER BY cd.Location) as RollingCountofPeopleVaccinated
from ResearcherDatabase..CovidDeaths cd
Join ResearcherDatabase..CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
	where cd.continent is not null
--	order by 2,3
	)
	select 
		*
		,(RollingCountofPeopleVaccinated/Population)*100
	from PopvsVacc



--- TEMP Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingCountofPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
	select 
	cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	SUM(CONVERT(INT, cv.new_vaccinations)) OVER (Partition By cd.Location ORDER BY cd.Location) as RollingCountofPeopleVaccinated
from ResearcherDatabase..CovidDeaths cd
Join ResearcherDatabase..CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
--	where cd.continent is not null
--	order by 2,3
	select 
		*
		,(RollingCountofPeopleVaccinated/Population)*100
	from #PercentPopulationVaccinated



-- Creating a View for later visualizations

 create view PercentPopulationVaccinated as 
 	select 
	cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	SUM(CONVERT(INT, cv.new_vaccinations)) OVER (Partition By cd.Location ORDER BY cd.Location) as RollingCountofPeopleVaccinated
from ResearcherDatabase..CovidDeaths cd
Join ResearcherDatabase..CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
	where cd.continent is not null
--	order by 2,3

select * from PercentPopulationVaccinated