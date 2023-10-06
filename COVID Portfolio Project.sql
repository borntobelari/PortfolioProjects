--TABELAS--

SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4


SELECT *
FROM CovidVaccinations
ORDER BY 3,4



--Selecionando dados que serao utilizados

SELECT Location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2



--Mostrando a probabilidade(%) de morrer ao pegar covid

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths
--WHERE Location = 'Brazil'
WHERE continent IS NOT NULL
ORDER BY 1,2



--Mostrando a porcentagem da populacao (separado por pais) que pegou covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS PopulationPercentage 
FROM PortfolioProject..CovidDeaths
--WHERE Location = 'Brazil'
WHERE continent IS NOT NULL
ORDER BY 1,2




--Paises com a maior taxa de casos comparado com total da populacao

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS CasesPercentage 
FROM PortfolioProject..CovidDeaths
--WHERE Location = 'Brazil'
WHERE continent IS NOT NULL
GROUP BY Location, population
ORDER BY CasesPercentage DESC


--Mostrando paises com maior taxa de morte 

SELECT Location, MAX(cast(Total_deaths as bigint)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location = 'Brazil'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC


--Mostrando os continentes com maior taxa de morte

SELECT continent, MAX(cast(Total_deaths as bigint)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location = 'Brazil'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--NUMEROS GLOBAIS

SELECT date, SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths as int)) AS Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--Total da populacao morta por covid

SELECT SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths as int)) AS Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2



--Total da populacao que foi vacinada

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac 
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--CTE--
WITH PopVSVac (Continent, Location, Date, Population, new_vaccinations, PeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac 
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (PeopleVaccinated/population)*100 AS VaccinationPorcentage
FROM PopVSVac



--Criando view para visualizacao posterior

--Porcentagem Vacinada Populacao
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac 
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


--Total da populacao morta por covid
CREATE VIEW PercentPopulationDeath AS
SELECT SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths as int)) AS Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL


--Continentes com maior taxa de morte
CREATE VIEW PercentContinentDeath AS
SELECT continent, MAX(cast(Total_deaths as bigint)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent

--Paises com maior taxa de morte
CREATE VIEW CountryDeathTotal AS
SELECT Location, MAX(cast(Total_deaths as bigint)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location