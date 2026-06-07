/*
===============================================================================
COVID-19 DATA EXPLORATION PROJECT
Description: Analysing global COVID-19 death rates, infection rates, and 
             vaccination rollouts using standard T-SQL aggregation functions, 
             Window Functions, CTEs, Temporary Tables, and Views.
===============================================================================
*/

-- ---------------------------------------------------------------------
-- 1. DATABASE SETUP & INITIAL INGESTION CHECK
-- ---------------------------------------------------------------------

-- Create workspace database
CREATE DATABASE PortfolioProject;
GO

-- Review raw data structure and first entries from the deaths dataset
-- Note: Avoid running SELECT * on large production tables; use for initial checks only.
SELECT * 
FROM PortfolioProject..CovidDeaths
ORDER BY 3, 4;

-- Preview core demographic and basic case columns ordered by location and date
SELECT Location, 
       date,
       total_cases,
       new_cases,
       total_deaths,
       population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2;


-- ---------------------------------------------------------------------
-- 2. CASE VS. DEATH ANALYSIS
-- ---------------------------------------------------------------------

-- Calculate likelihood of dying if you contract COVID-19 in Africa
-- Fixed potential division-by-zero errors by ensuring total_cases > 0
SELECT Location, 
       date,
       total_cases,
       total_deaths,
       (CAST(total_deaths AS FLOAT) / NULLIF(total_cases, 0)) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location = 'Africa'
  AND total_cases > 0
ORDER BY 1, 2;


-- ---------------------------------------------------------------------
-- 3. INFECTION RATE ANALYSIS
-- ---------------------------------------------------------------------

-- Calculate what percentage of the population contracted COVID-19
-- FIX: Labeled column as 'InfectedPercentage' (was wrongly labeled DeathPercentage)
-- Optimization: Order by column index or alias name for better scannability
SELECT Location, 
       date,
       total_cases,
       Population,
       (CAST(total_cases AS FLOAT) / NULLIF(Population, 0)) * 100 AS InfectedPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY InfectedPercentage DESC;

-- Identify countries with the highest infection rates relative to their population
-- NOTE: Including 'date' in GROUP BY forces individual daily records instead of 
-- an absolute country peak. Remove 'date' if you want a single row per country.
SELECT Location, 
       Population,
       date,
       MAX(total_cases) AS HighestInfectionCount,
       MAX(CAST(total_cases AS FLOAT) / NULLIF(Population, 0)) * 100 AS InfectedPercentage
FROM PortfolioProject..CovidDeaths
GROUP BY Location, Population, date
ORDER BY InfectedPercentage DESC;


-- ---------------------------------------------------------------------
-- 4. REGIONAL AND CONTINENTAL AGGREGATIONS
-- ---------------------------------------------------------------------

-- Aggregate total deaths by continental regions
-- When continent is null, the 'Location' column contains the true continental group summary
SELECT Location, 
       SUM(new_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
  AND location NOT IN ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
GROUP BY Location
ORDER BY TotalDeathCount DESC;

-- Alternative continental peak total death breakdown
SELECT continent, 
       MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- ---------------------------------------------------------------------
-- 5. GLOBAL METRICS
-- ---------------------------------------------------------------------

-- Calculate overall worldwide cases, deaths, and mortality rate
SELECT SUM(new_cases) AS total_cases,
       SUM(new_deaths) AS total_deaths,
       (SUM(CAST(new_deaths AS FLOAT)) / NULLIF(SUM(new_cases), 0)) * 100 AS WorldDeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;

-- Track daily case mortality percentages specifically for the United States
SELECT date,
       total_cases,
       Population,
       total_deaths,
       (CAST(total_deaths AS FLOAT) / NULLIF(total_cases, 0)) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%states%'
  AND continent IS NOT NULL
ORDER BY DeathPercentage DESC;


-- ---------------------------------------------------------------------
-- 6. VACCINATION ANALYSIS WITH WINDOW FUNCTIONS
-- ---------------------------------------------------------------------

-- Compute a rolling sum of people vaccinated per day by location
-- Optimization: Converted numeric values using BIGINT to safely prevent integer overflow errors
SELECT cd.continent,
       cd.location,
       cd.date,
       cd.population,
       cv.new_vaccinations,
       SUM(CAST(cv.new_vaccinations AS BIGINT)) OVER (
           PARTITION BY cd.location 
           ORDER BY cd.location, cd.date
       ) AS RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths AS cd
JOIN PortfolioProject..CovidVaccinations AS cv
  ON cd.location = cv.location
  AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2, 3;


-- ---------------------------------------------------------------------
-- 7. ADVANCED DATA ISOLATION METRICS (CTE & TEMP TABLES)
-- ---------------------------------------------------------------------

-- Method A: Using a Common Table Expression (CTE) to calculate rolling vaccination percentages
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS (
    SELECT cd.continent,
           cd.location,
           cd.date,
           cd.population,
           cv.new_vaccinations,
           SUM(CAST(cv.new_vaccinations AS BIGINT)) OVER (
               PARTITION BY cd.location 
               ORDER BY cd.location, cd.date
           ) AS RollingPeopleVaccinated 
    FROM PortfolioProject..CovidDeaths AS cd
    JOIN PortfolioProject..CovidVaccinations AS cv
      ON cd.location = cv.location
      AND cd.date = cv.date
    WHERE cd.continent IS NOT NULL
)
SELECT *, 
       (CAST(RollingPeopleVaccinated AS FLOAT) / NULLIF(Population, 0)) * 100 AS PercentPopulationVaccinated
FROM PopvsVac;


-- Method B: Using a Temporary Table for multi-query data isolation
DROP TABLE IF EXISTS #PercentPopulationVaccinated; -- Ensures re-runnable execution script

CREATE TABLE #PercentPopulationVaccinated (
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

-- Optimization: Added missing "WHERE continent IS NOT NULL" to align data output with CTE results
INSERT INTO #PercentPopulationVaccinated
SELECT cd.continent,
       cd.location,
       cd.date,
       cd.population,
       cv.new_vaccinations,
       SUM(CAST(cv.new_vaccinations AS BIGINT)) OVER (
           PARTITION BY cd.location 
           ORDER BY cd.location, cd.date
       ) AS RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths AS cd
JOIN PortfolioProject..CovidVaccinations AS cv
  ON cd.location = cv.location
  AND cd.date = cv.date
WHERE cd.continent IS NOT NULL;

SELECT *, 
       (CAST(RollingPeopleVaccinated AS FLOAT) / NULLIF(Population, 0)) * 100 AS PercentPopulationVaccinated
FROM #PercentPopulationVaccinated;


-- ---------------------------------------------------------------------
-- 8. BUSINESS INTELLIGENCE LAYER (VIEWS)
-- ---------------------------------------------------------------------

-- Create permanent view schema structure for downstream Tableau / PowerBI visual connections
CREATE VIEW PercentPopulationVaccinated AS 
SELECT cd.continent,
       cd.location,
       cd.date,
       cd.population,
       cv.new_vaccinations,
       SUM(CAST(NULLIF(cv.new_vaccinations, '') AS BIGINT)) OVER (
           PARTITION BY CAST (cd.location AS NVARCHAR(255))
           ORDER BY CAST (cd.location AS NVARCHAR(255)), TRY_CONVERT(DATETIME, cd.date)
       ) AS RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths AS cd
JOIN PortfolioProject..CovidVaccinations AS cv
  ON cd.location = cv.location
  AND cd.date = cv.date
WHERE cd.continent IS NOT NULL;
GO

-- Test and verify created view output data streams
SELECT *
FROM PercentPopulationVaccinated;

