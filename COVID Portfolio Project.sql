SELECT Top 100 *
FROM CovidDeaths$
Where continent is not null
Order By 3,4

--SELECT Top 100 *
--From CovidVacinations$
--Order By 3,4

SELECT Top 100 
	Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths$
Order By 1,2


--Looking at Total Cases vs Total Deaths
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths$
Where Location like '%apa%'
Order By 1,2 desc


--Looking at Total Cases vs Population
SELECT Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
FROM CovidDeaths$
Where Location like '%states'
Order By 1,2 desc


-----------------------
-- Data Visualization for creating Tableau dashboard

-- 1
-- GLOBAL NUMBERS
SELECT 
	SUM(New_cases) as total_cases
	, SUM(cast(New_deaths as int)) as total_deaths
	, Sum(cast(New_deaths as int))/SUM(New_cases)*100 as DeathPercentage 
FROM CovidDeaths$
WHERE Continent is not NULL
ORDER BY 1,2


-- 2
--Death Count per Continent
--European Union is a part of Europe
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths$
--Where Location LIKE '$tate$'
Where continent is null
and location not in ('World', 'High income', 'Upper middle income', 'Lower middle income', 'European Union', 'Low income', 'International')
Group By location
Order By TotalDeathCount desc


-- 3
--Looking at Countries with Highest Infection Rate compared to Population
SELECT
	Location, population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM CovidDeaths$
--Where Location LIKE '$tate$'
Group By Location, population, date
Order By PercentPopulationInfected desc


-- 4
SELECT
	Location, population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM CovidDeaths$
--Where Location LIKE '$tate$'
Group By Location, population, date
Order By PercentPopulationInfected desc


------------------

--Looking at Total Population vs Vaccinations
SELECT
		dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
		, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition By dea.Location Order By dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths$ as Dea
Join CovidVacinations$ as Vac
	ON Dea.location = Vac.location
	and Dea.date = Vac.date
Where dea.continent is not NULL
--Group By dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
Order by 2,3



-- USE CTE
WITH PopVsVac as(
SELECT
		dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
		, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition By dea.Location Order By dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths$ as Dea
Join CovidVacinations$ as Vac
	ON Dea.location = Vac.location
	and Dea.date = Vac.date
Where dea.continent is not NULL
--Order by 2,3
)

SELECT * 
--	, RollingPeopleVaccinated
--	, (RollingPeopleVaccinated/Population)*100 as PER
From PopVsVac
ORDER BY ((RollingPeopleVaccinated/Population)*100) desc



--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE
#PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT
		dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
		, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition By dea.Location Order By dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths$ as Dea
Join CovidVacinations$ as Vac
	ON Dea.location = Vac.location
	and Dea.date = Vac.date
--Where dea.continent is not NULL
--Order by 2,3

SELECT*, (RollingPeopleVaccinated/Population)*100 as PER
FROM #PercentPopulationVaccinated


--Creating View To Store Data For Visualizations
Create View Percent_Population_Vaccinated as
SELECT
		dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
		, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition By dea.Location Order By dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths$ as Dea
Join CovidVacinations$ as Vac
	ON Dea.location = Vac.location
	and Dea.date = Vac.date
Where dea.continent is not NULL
--Order by 2,3


SELECT*
FROM Percent_Population_Vaccinated
