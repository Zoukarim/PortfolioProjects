SELECT *
FROM PortfolioProject2.dbo.CovidDeaths$
ORDER BY 3,4

SELECT *
FROM PortfolioProject2.dbo.CovidVaccinations$
ORDER BY 3,4

SELECT Location, date, total_cases, new_cases,total_deaths, population
FROM PortfolioProject2.dbo.CovidDeaths$
ORDER BY 1,2

SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject2.dbo.CovidDeaths$
ORDER BY 1,2

SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject2.dbo.CovidDeaths$
WHERE Location LIKE '%canada%'
ORDER BY 1,2

SELECT Location, Date, total_cases, population, (total_cases/population)*100 as InfectionPercentage
FROM PortfolioProject2.dbo.CovidDeaths$
ORDER BY 1,2

SELECT Location, Date, total_cases, population, (total_cases/population)*100 as InfectionPercentage
FROM PortfolioProject2.dbo.CovidDeaths$
WHERE Location LIKE '%cana%'
ORDER BY 1,2

SELECT Location, population, Max(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectionPercentage
FROM PortfolioProject2.dbo.CovidDeaths$
--WHERE Location LIKE '%cana%'
WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY 4 DESC

SELECT Location, population, Max(cast(total_deaths as int)) as HighestDeathCount, MAX((total_deaths/population))*100 as DeathPerPopulation
FROM PortfolioProject2.dbo.CovidDeaths$
--WHERE Location LIKE '%cana%'
WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY 4 DESC

SELECT Location, Max(cast(total_deaths as int)) as TotalDeathCounts
FROM PortfolioProject2.dbo.CovidDeaths$	
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCounts DESC

SELECT continent, Max(cast(total_deaths as int)) as TotalDeathCounts
FROM PortfolioProject2.dbo.CovidDeaths$	
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCounts DESC

SELECT location, Max(cast(total_deaths as int)) as TotalDeathCounts
FROM PortfolioProject2.dbo.CovidDeaths$	
WHERE continent is NULL
GROUP BY location
ORDER BY TotalDeathCounts DESC

SELECT Date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentagePerDay
FROM PortfolioProject2.dbo.CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 4 DESC

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentagePerDay
FROM PortfolioProject2.dbo.CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2

SELECT location,SUM(CAST(new_deaths as int)) as total_deaths, SUM(cast(new_cases as int)) as total_cases, 
(SUM(cast(new_deaths as float))/SUM(cast(new_cases as float)))*100 as death_percentage
FROM PortfolioProject2.dbo.CovidDeaths$
WHERE location LIKE '%canada%'
GROUP BY location
ORDER BY 1,2

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as  RollingPeopleVaccinated
FROM PortfolioProject2..CovidDeaths$ dea
JOIN PortfolioProject2..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	ORDER BY 2,3

WITH CTE_MaxPeopleVaccinated AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as  RollingPeopleVaccinated
FROM PortfolioProject2..CovidDeaths$ dea
JOIN PortfolioProject2..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent IS NOT NULL

)
SELECT continent, location, date, population, new_vaccinations,
(MAX(RollingPeopleVaccinated)/population)*100 as RollingPercentagevaccinated
FROM CTE_MaxPeopleVaccinated
GROUP BY continent, location, date, population, new_vaccinations

WITH CTE_MaxPeopleVaccinated AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as  RollingPeopleVaccinated
FROM PortfolioProject2..CovidDeaths$ dea
JOIN PortfolioProject2..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent IS NOT NULL

)
SELECT continent, location, date, population, new_vaccinations,RollingPeopleVaccinated,
(MAX(RollingPeopleVaccinated)/population)*100 as RollingPercentagevaccinated
FROM CTE_MaxPeopleVaccinated
WHERE new_vaccinations is not null
GROUP BY continent, location, date, population, new_vaccinations,RollingPeopleVaccinated
ORDER BY location

WITH CTE_PeopleVaccinated (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as  RollingPeopleVaccinated
FROM PortfolioProject2..CovidDeaths$ dea
JOIN PortfolioProject2..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated)/(population)*100
FROM CTE_PeopleVaccinated

DROP TABLE IF EXISTS #temp_PeopleVaccinated
CREATE TABLE #temp_PeopleVaccinated (
continent VARCHAR(50),
location VARCHAR(50),
date datetime, 
population int, 
new_vaccinations int,
RollingPeopleVaccinated int
)

INSERT INTO #temp_PeopleVaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as  RollingPeopleVaccinated
FROM PortfolioProject2..CovidDeaths$ dea
JOIN PortfolioProject2..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent IS NOT NULL

select *, (RollingPeopleVaccinated)/(population)*100 as PercentageRollingPeopleVaccinated	
from #temp_PeopleVaccinated



CREATE VIEW PercentagePeopleVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as  RollingPeopleVaccinated
FROM PortfolioProject2..CovidDeaths$ dea
JOIN PortfolioProject2..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent IS NOT NULL

CREATE VIEW canada_death_percentage AS
SELECT 
    location,
    SUM(CAST(new_deaths AS INT)) AS total_deaths, 
    SUM(CAST(new_cases AS INT)) AS total_cases, 
    (SUM(CAST(new_deaths AS FLOAT)) / SUM(CAST(new_cases AS FLOAT))) * 100 AS death_percentage
FROM 
    PortfolioProject2.dbo.CovidDeaths$
WHERE 
    location LIKE '%Canada%'
GROUP BY 
    location;


CREATE VIEW death_percentage as
SELECT 
	location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM 
	PortfolioProject2.dbo.CovidDeaths$

CREATE VIEW infection_percentage as
SELECT Location, Date, total_cases, population, (total_cases/population)*100 as InfectionPercentage
FROM PortfolioProject2.dbo.CovidDeaths$
WHERE Location LIKE '%cana%'

CREATE VIEW infection_percentage_location as 
SELECT Location, population, Max(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectionPercentage
FROM PortfolioProject2.dbo.CovidDeaths$
--WHERE Location LIKE '%cana%'
WHERE continent is NOT NULL
GROUP BY location, population

CREATE VIEW death_percentage_location as 
SELECT Location, population, Max(cast(total_deaths as int)) as HighestDeathCount, MAX((total_deaths/population))*100 as DeathPerPopulation
FROM PortfolioProject2.dbo.CovidDeaths$
--WHERE Location LIKE '%cana%'
WHERE continent is NOT NULL
GROUP BY location, population
