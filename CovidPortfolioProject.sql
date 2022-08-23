select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

select Location, date,total_cases,new_cases,total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--Looking at total cases vs total Deaths
--Shows likelihood of dying if you contractt covid in your country
select Location, date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

--Looking at Totalcases vs Population
--Shows what percentage of population got covid
select Location, date,total_cases,population, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

--Looking at countries with highest infection rate compared to population

select Location, population,MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
group by Location, Population
order by PercentPopulationInfected desc

--Showing countries with highets death count per population
select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by Location
order by TotalDeathCount desc

--LETS BREAK THINGS DOWN BY CONTINENT
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


--Showing the continents with the highest death count per population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

select SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
--group by date
order by 1,2


--Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order  by dea.location,
dea.date ) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (continent, location, date, population,new_vaccinations,RollingPeopleVaccinated)
as (


Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order  by dea.location,
dea.date ) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/population)*100
From PopvsVac

-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(continent nvarchar(255),
location  nvarchar(255),
date datetime, 
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order  by dea.location,
dea.date ) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

Select *,(RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 

Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order  by dea.location,
dea.date ) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

Select*
from PercentPopulationVaccinated
