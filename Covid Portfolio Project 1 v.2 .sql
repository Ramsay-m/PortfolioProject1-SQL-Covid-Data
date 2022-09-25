-- COVID PORTFOLIO PROJECT (Part 1)
-- This project will explore some global Covid death and vaccination data

-- It shows the following skills: Selecting data from a table, ordering data, 
-- Doing simple mathematical functions, using CTE, and Creating a view.

SELECT *
 FROM public.coviddeaths
 WHERE continent is not null
 ORDER BY 3,4
 
SELECT *
 FROM public.covidvaccinations
 ORDER BY 3,4

-- Select Data that we're going to use

SELECT location, date, total_cases, new_cases, total_deaths, population
 FROM public.coviddeaths
 WHERE continent is not null
 ORDER BY 1,2
 
-- Looking at the total cases vs. total deaths (and percentage)
-- The liklihood of dying if you contract Covid in Canada
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 FROM public.coviddeaths
 WHERE location = 'Canada'
 AND continent IS NOT null
 ORDER BY 1,2
 
 -- The liklihood of dying if you contract Covid in United States
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 FROM public.coviddeaths
 WHERE location = 'United States'
 ORDER BY 1,2
 
-- Looking at the total cases vs. the Population in Canada
-- Shows what percentage of population got Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as CasePercentage
 FROM public.coviddeaths
 WHERE location = 'Canada'
 ORDER BY 1,2

-- Looking at countries with highest infection rates compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as CasePercentage
 FROM public.coviddeaths
 GROUP BY location, population
 ORDER BY CasePercentage DESC
 
-- Looking at countries with highest death count compared to population
SELECT location, MAX(total_deaths) as TotalDeathCount
 FROM public.coviddeaths
 WHERE continent is not null
 GROUP BY location
 ORDER BY TotalDeathCount DESC
 
-- Breaking things down by continent
-- Showing continents with the highest death count
SELECT location, MAX(total_deaths) as TotalDeathCount
 FROM public.coviddeaths
 WHERE continent is null
 GROUP BY location
 ORDER BY TotalDeathCount DESC
 
-- Global Numbers
-- Showing new deaths as a percentage of new cases for the world each day
SELECT date, SUM(new_cases) as new_cases, SUM(new_deaths) as new_deaths, SUM(new_deaths)/SUM(new_cases)*100 as new_death_percentage
 FROM public.coviddeaths
 WHERE continent is not null
 GROUP BY date
 ORDER BY 1,2

-- Showing new deaths as a percentage of new cases for the world
SELECT SUM(new_cases) as new_cases, SUM(new_deaths) as new_deaths, SUM(new_deaths)/SUM(new_cases)*100 as new_death_percentage
 FROM public.coviddeaths
 WHERE continent is not null
 ORDER BY 1,2
 
-- Join the two tables
-- Looking at total population vs. vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as Rolling_people_vaccinated,
 --We're partitioning so that your sum doesn't keep going, it stops at the end of each country 
 FROM public.coviddeaths dea
 JOIN public.covidvaccinations vac
   ON dea.location = vac.location
   AND dea.date = vac.date
   WHERE dea.continent is not null
  ORDER BY 2,3

-- Using a CTE

WITH PopvsVac (Continent, location, date, population, new_vaccinations, Rolling_people_vaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as Rolling_people_vaccinated
 FROM public.coviddeaths dea
 JOIN public.covidvaccinations vac
   ON dea.location = vac.location
   AND dea.date = vac.date
   WHERE dea.continent is not null
)
SELECT *, (Rolling_people_vaccinated/population)*100
FROM PopvsVac

-- Creating View to store data for later visualizations
CREATE VIEW  PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as Rolling_people_vaccinated
 FROM public.coviddeaths dea
 JOIN public.covidvaccinations vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated