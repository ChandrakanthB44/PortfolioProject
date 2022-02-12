select * 
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select * 
--from PortfolioProject..CovidVaccination
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--TotalCases vs TotalDeaths
-- shows likelyhood of deaths in country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2

-- looking at total cases vs population
select location, date, population, total_cases, (total_cases/population)*100 as InfectionPercentage
from PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2

-- Looking at countries with highest infection rate campared to population

select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 
as InfectionPercentage
from PortfolioProject..CovidDeaths
group by location, population
order by InfectionPercentage desc

-- How many people died or DeathCount in each country
select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- Death Count in each continent per population
select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS
--select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--from PortfolioProject..CovidDeaths
--where continent is not null
--group by date
--order by 1,2

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))
as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2

-- JOINING BOTH TABLES

--select *
--from PortfolioProject..CovidDeaths dea
--join PortfolioProject..CovidDeaths vac
--	 on dea.location = vac.location
--	 and dea.date = vac.date

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	 on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert (int,vac.new_vaccinations)) over 
(Partition by dea.location order by dea.location)
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	 on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Looking at total Vaccinations vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert (bigint,vac.new_vaccinations)) over 
(Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	 on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE
with PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) over 
(Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	 on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 as PerPop
from PopvsVac 

-- TEMP TABLE
Create table #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) over 
(Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	 on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
select *, (RollingPeopleVaccinated/population)*100 as PerPop
from #PercentagePopulationVaccinated 


-- Creat Views to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) over 
(Partition by dea.location order by dea.location, dea.Date)
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	 on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null

select * 
from PercentPopulationVaccinated

--Table 1 for Tableau
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))
as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2

--Table 2 for Tableau
select location, SUM(convert (bigint,new_deaths)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is null
and location not in ('world','European Union', 'International', 'Upper middle income',
'High income', 'Lower middle income','Low income')
group by location
order by TotalDeathCount desc

--Table 3 for Tableau
select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 
as InfectionPercentage
from PortfolioProject..CovidDeaths
group by location, population
order by InfectionPercentage desc

--Table 4 for Tableau
select location, population,date, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 
as InfectionPercentage
from PortfolioProject..CovidDeaths
group by location, population, date
order by InfectionPercentage desc
