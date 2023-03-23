 -- covid Data Exploration using SQL
--I selected the Top 10 rows to confirm the dataset was imported properly
SELECT TOP 10 * 
FROM CovidDeaths

SELECT TOP 10 * 
FROM 
CovidVaccinations

SELECT COUNT(*) FROM CovidDeaths
SELECT MAX(date) FROM CovidDeaths  
SELECT MIN(date) FROM CovidDeaths 

SELECT COUNT(*) FROM CovidVaccinations 
SELECT MAX(date) FROM CovidVaccinations  
SELECT MIN(date) FROM CovidVaccinations 

--Calculating the percentage of deaths from covid in each country
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS int)/total_cases)*100 AS DeathPercentage
FROM CovidDeaths

--Calculating percentage death by date
SELECT date, SUM(CAST(new_deaths AS int)) AS TotalDeaths,
SUM(new_cases) AS TotalCases,
SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
GROUP BY date

--Taking a look at the percentage of people infected in each country
SELECT location, population, MAX(total_cases) AS TotalInfectionCount, MAX((total_cases/population)*100) AS PercentPopuationInfected
FROM CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC

--taking a look at the death count per country
SELECT location, MAX(total_cases) AS TotalCases
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

--taking a look at total infection per country
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

--Calculating the number of deaths from covid by year
SELECT YEAR(date) AS Year, SUM(CAST(new_deaths AS int)) AS TotalDeaths
FROM CovidDeaths
GROUP BY YEAR(date)
ORDER BY 2 DESC

--Global Death from covid
SELECT SUM(new_cases) AS TotalCases, 
SUM(CAST(new_deaths AS int)) AS TotalDeath, 
SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercantage
FROM CovidDeaths
WHERE continent IS NOT NULL

--Calculating the total amount of vaccinations to date by country
SELECT cd.continent,  cd.location, cd.date, cd.population, cv.new_vaccinations, 
	SUM(CAST(cv.new_vaccinations AS int)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS VaccinationsToDate
FROM CovidDeaths AS cd
JOIN CovidVaccinations AS cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2, 3

--Calculating the percentage of the population vaccinated using CTE method
WITH PopvsVac (location, date, population, new_vaccinations, VaccinationsToDate)
AS
(
SELECT cd.location, cd.date, cd.population, cv.new_vaccinations, 
	SUM(CAST(cv.new_vaccinations AS int)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS VaccinationsToDate
FROM CovidDeaths AS cd
JOIN CovidVaccinations AS cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
)
SELECT * , (VaccinationsToDate/population)*100 AS PercentageVaccinated
FROM PopvsVac

--creating view to be used for later visualization
CREATE VIEW PercentPopulationsVaccinated 
AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	SUM(CAST(cv.new_vaccinations AS int)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS VaccinationsToDate
FROM CovidDeaths AS cd
JOIN CovidVaccinations AS cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL