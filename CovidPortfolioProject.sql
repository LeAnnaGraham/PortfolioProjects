Select *
From CovidDeaths
WHERE continent is not null
Order by 3,4

--Select *
--From CovidVaccinations
--Order by 3,4

--Select Data that I am going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
ORDER BY 1,2

-- Looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country
Select location, date, total_cases,total_deaths, (total_deaths / total_cases)*100 AS DeathPercentage
From CovidDeaths
Where location like '%states%'
and continent is not null
ORDER BY 1,2

-- looking at Total Cases vs Population
--shows what percentage of population got covid
Select location, date, population, total_cases, (total_cases/ population)*100 AS InfectedRatePercentage
From CovidDeaths
--Where location like '%states%'
ORDER BY 1,2

--which countries have highest infection rates compared to population?
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/ population))*100 AS PercentPopulationInfected
From CovidDeaths
--Where location like '%states%'
GROUP BY Location, population
ORDER BY PercentPopulationInfected desc

--show how many people actually died. countries with highest death count per population
Select location, MAX(cast(Total_deaths as int))AS TotalDeathCount
From CovidDeaths
--Where location like '%states%'
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc

--break things down my continent
-- Showing the Continents with the highest death count

Select continent, MAX(cast(Total_deaths as int))AS TotalDeathCount
From CovidDeaths
--Where location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--global numbers
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
From CovidDeaths
--Where location like '%states%'
where continent is not null
Group by date
ORDER BY 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
From CovidDeaths
--Where location like '%states%'
where continent is not null
ORDER BY 1,2


 -- total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , SUM(cast(vac.new_vaccinations as int)) 
	OVER (Partition by dea.location Order by dea.location, dea.Date) AS RollingPeopleVaccinated,
	(RollingPeopleVaccinated/Population)*100
From CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-- USE CTE
With PopvsVac (Continent, location, Date, population, New_vaccinations, RollingPeopleVaccianated)
as(

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , SUM(cast(vac.new_vaccinations as int)) 
	OVER (Partition by dea.location Order by dea.location, dea.Date) AS RollingPeopleVaccinated
--	(RollingPeopleVaccinated/Population)*100
From CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccianated/population)*100
From PopvsVac

--using a Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , SUM(cast(vac.new_vaccinations as int)) 
	OVER (Partition by dea.location Order by dea.location, dea.Date) AS RollingPeopleVaccinated
--	(RollingPeopleVaccinated/Population)*100
From CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , SUM(cast(vac.new_vaccinations as int)) 
	OVER (Partition by dea.location Order by dea.location, dea.Date) AS RollingPeopleVaccinated
--	(RollingPeopleVaccinated/Population)*100
From CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select*
From PercentPopulationVaccinated
