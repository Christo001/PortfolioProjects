Select Location, Date, total_cases, new_cases, total_deaths, population
From CovidPortfolioProject. .CovidDeaths
order by 1,2


--Looking at Total Cases vs Total Deaths
--Shows Likelihood of dying if you contract covid in your country (United States for example)
Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidPortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2


--Looking at Total Cases vs Population
--Shows what percentage of population got Covid in the United States
Select Location, Date, population, total_cases, (total_cases/population)*100 as InfectedPercentage
From CovidPortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2


--Looking at Countries with Highest Infection Rate compared to Population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPercentage
From CovidPortfolioProject..CovidDeaths
Group by Location, Population
order by InfectedPercentage desc


--Showing Countries with Highest Death Count per Population
Select Location,MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidPortfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc

--Total Death Count per Continent
Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidPortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc


--Global Numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidPortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


With PopsVac (Continent, location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER(Partition by dea.location)
From CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
from PopsVac


--TEMP TABLE 
DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated (
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER(Partition by dea.location)
From CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER(Partition by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
from PercentPopulationVaccinated



