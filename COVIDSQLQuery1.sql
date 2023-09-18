

SELECT	*
FROM	PortfolioProject..CovidDeath$
WHERE	continent IS NULL
ORDER BY	3,4
;

-- Choosen Data that will be utilized
SELECT	location, date, total_cases, new_cases, total_deaths, population
FROM	PortfolioProject..CovidDeath$
ORDER BY	1,2
;

-- Total case vs. Total death
-- Death Percentage show likelihood of dying when you contract covid 
SELECT	location, date, total_cases, total_deaths, 
		(CAST (	total_deaths AS float) / 
				total_cases)*100 AS DeathPercentage
FROM	PortfolioProject..CovidDeath$
WHERE	location = 'Malaysia'
ORDER BY	1,2
;

-- Total case vs. Population
-- Infected percentage show population got Covid
SELECT	location, date, total_cases, population, 
		(total_cases / population )*100 AS InfectedPercentage
FROM	PortfolioProject..CovidDeath$
WHERE	location = 'Malaysia'
ORDER BY	1,2
;

-- Country with highest Infection Rate per Population
SELECT	location, population, MAX (total_cases) AS HighestInfectionCount, 
		(MAX(total_cases)/population)*100 AS HighestInfectedPercentage
FROM	PortfolioProject..CovidDeath$
WHERE	continent IS NOT NULL -- to only include country data
GROUP BY	Location, population
ORDER BY	4 DESC
;

-- Highest Death Count per Population
SELECT	location, MAX (CAST(total_deaths as int)) AS HighestDeathCount
FROM	PortfolioProject..CovidDeath$
WHERE	continent IS NOT NULL -- to only include country data
GROUP BY	Location
ORDER BY	2 DESC
;

-- Highest Death Count per Continent
SELECT	continent, MAX (CAST(total_deaths as int)) AS HighestDeathCount
FROM	PortfolioProject..CovidDeath$
WHERE	continent IS NOT NULL -- to only include country data
GROUP BY	continent
ORDER BY	1 DESC
;

-- Daily Case Number untill March 
SELECT	date, 
		SUM (new_cases)								AS Total_Cases_Daily, 
		SUM (ISNULL(CAST (new_deaths as int),0))	AS Total_Death_Daily,
		SUM (ISNULL(CAST (new_deaths as int),0)) / 
		SUM (NULLIF((new_cases),0)) * 100	-- NULL IF to turn 0 value to NULL so can divide without zero value
		AS Daily_Global_DeathPercentage
FROM	PortfolioProject..CovidDeath$
WHERE	continent IS NOT NULL -- to only include country data
GROUP BY	date
ORDER BY	1,2
;

-- Global Number untill March 
SELECT	SUM (new_cases)								AS Total_Cases_Daily, 
		SUM (ISNULL(CAST (new_deaths as int),0))	AS Total_Death_Daily,
		SUM (ISNULL(CAST (new_deaths as int),0)) / 
		SUM (NULLIF((new_cases),0)) * 100	-- NULL IF to turn 0 value to NULL so can divide without zero value
		AS Daily_Global_DeathPercentage
FROM	PortfolioProject..CovidDeath$
WHERE	continent IS NOT NULL -- to only include country data
AND		YEAR(date) != 2023
ORDER BY	1,2
; 

-- Joining both table
SELECT	*
FROM	PortfolioProject..CovidDeath$		AS D
JOIN	PortfolioProject..CovidVaccination$ AS V
		ON		D.date = V.date
		AND		D.location = V.location
WHERE	d.continent IS NOT NULL
ORDER BY	3,4
;

-- Choose Data that will be utilized
SELECT	D.continent,D.location,D.date,D.population,V.new_vaccinations,
		SUM(CAST(V.new_vaccinations as bigint)) 
		OVER	
		(
		PARTITION BY	D.location
		ORDER BY		D.location,D.date
		) AS rolling_total_vaccination_by_country
FROM	PortfolioProject..CovidDeath$		AS D
JOIN	PortfolioProject..CovidVaccination$ AS V
		ON		D.date = V.date
		AND		D.location = V.location
WHERE	d.continent IS NOT NULL
ORDER BY	2,3
;

-- using CTE

WITH	PopulationVSVaccination (continent,location,date,population,new_vaccinations,rolling_total_vaccination_by_country)
AS
(
SELECT	D.continent,D.location,D.date,D.population,V.new_vaccinations,
		SUM(CAST(V.new_vaccinations as bigint)) 
		OVER	
		(
		PARTITION BY	D.location
		ORDER BY		D.location,D.date
		) AS rolling_total_vaccination_by_country
FROM	PortfolioProject..CovidDeath$		AS D
JOIN	PortfolioProject..CovidVaccination$ AS V
		ON		D.date = V.date
		AND		D.location = V.location
WHERE	d.continent IS NOT NULL
)
SELECT	*,(rolling_total_vaccination_by_country / population)*100
FROM	PopulationVSVaccination

-- TEMP TABLE

DROP TABLE if exists #PercentagePopulationVSVaccination
CREATE TABLE #PercentagePopulationVSVaccination
(
Continent			nvarchar(255),
Location			nvarchar(255),
Date				datetime,
Population			numeric,
New_vaccinations	numeric,
rolling_total_vaccination_by_country numeric
)
Insert into #PercentagePopulationVSVaccination
SELECT	D.continent,D.location,D.date,D.population,V.new_vaccinations,
		SUM(CAST(V.new_vaccinations as bigint)) 
		OVER	
		(
		PARTITION BY	D.location
		ORDER BY		D.location,D.date
		) AS rolling_total_vaccination_by_country
FROM	PortfolioProject..CovidDeath$		AS D
JOIN	PortfolioProject..CovidVaccination$ AS V
		ON		D.date = V.date
		AND		D.location = V.location
WHERE	d.continent IS NOT NULL

SELECT	*,(rolling_total_vaccination_by_country / population)*100
FROM	#PercentagePopulationVSVaccination

-- VIEW FOR LATER DATA VISUALISATION

CREATE VIEW 
PercentPopulationVaccinated AS
SELECT	D.continent,
		D.location,
		D.date,
		D.population,
		V.new_vaccinations,
		SUM(CAST(V.new_vaccinations as bigint)) 
		OVER	
		(
		PARTITION BY	D.location
		ORDER BY		D.location,D.date
		) AS rolling_total_vaccination_by_country
FROM	PortfolioProject..CovidDeath$		AS D
JOIN	PortfolioProject..CovidVaccination$ AS V
		ON		D.date = V.date
		AND		D.location = V.location
WHERE	d.continent IS NOT NULL
;

SELECT MAX(new_cases) AS Max_New_Cases, 
       location--,
	 --  MAX(date) AS Date
FROM PortfolioProject..CovidDeath$
WHERE location IN ('Brunei', 'Cambodia', 'Indonesia', 'Laos', 'Malaysia', 'Myanmar', 'Philippines', 'Singapore', 'Thailand', 'Vietnam')
      AND YEAR(date) != 2023
GROUP BY location
ORDER BY Max_New_Cases DESC;

SELECT MAX(new_cases) AS Max_New_Cases, 
       location--,
	 --  MAX(date) AS Date
FROM PortfolioProject..CovidDeath$
WHERE location IN ('Brunei', 'Cambodia', 'Indonesia', 'Laos', 'Malaysia', 'Myanmar', 'Philippines', 'Singapore', 'Thailand', 'Vietnam')
      AND YEAR(date) != 2023
GROUP BY location
ORDER BY Max_New_Cases DESC;

SELECT
    A.Max_New_Cases,
    A.location,
    B.date AS Date_Recorded
FROM
    (
        SELECT MAX(new_cases) AS Max_New_Cases,
               location
        FROM PortfolioProject..CovidDeath$
        WHERE location IN ('Brunei', 'Cambodia', 'Indonesia', 'Laos', 'Malaysia', 'Myanmar', 'Philippines', 'Singapore', 'Thailand', 'Vietnam')
              AND YEAR(date) != 2023
        GROUP BY location
    ) A
JOIN PortfolioProject..CovidDeath$ B
    ON A.location = B.location
    AND A.Max_New_Cases = B.new_cases
ORDER BY A.Max_New_Cases DESC;

SELECT	continent, location, MAX (population)
FROM	PortfolioProject..CovidDeath$
WHERE	location IN ('Brunei', 'Cambodia', 'Indonesia', 'Laos', 'Malaysia', 'Myanmar', 'Philippines', 'Singapore', 'Thailand', 'Vietnam')
        AND YEAR(date) != 2023
GROUP BY	continent,Location
ORDER BY	3 DESC