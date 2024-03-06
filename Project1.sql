select * 
from [Portfolio project]..CovidDeaths
where continent <> ''
order by 3

select * 
from [Portfolio project]..CovidVaccination
order by 3

select location, date, total_cases, new_cases, total_deaths,  population
from [Portfolio project]..CovidDeaths
order by 1

--total cases vs total deaths

Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
From [Portfolio project]..CovidDeaths
--where location = 'china'
order by 1

--total cases vs total population

Select Location, date, total_cases, population, (CONVERT(float, total_cases) / CONVERT(float, population))*100 as infectedrate
From [Portfolio project]..CovidDeaths
--where location = 'china'
order by 1

--countries with highest infection rate to population

Select Location, population, MAX(convert(float,total_cases)) as highestinfectioncount, Max(Isnull(CONVERT(float, total_cases) / Nullif(CONVERT(float, population),0),0))*100 as infectedrate
From [Portfolio project]..CovidDeaths
group by location, population
order by infectedrate desc

--countries with highest death

Select location, MAX(convert(bigint,total_deaths)) as deathcount
From [Portfolio project]..CovidDeaths
where continent <> ''
group by location
order by deathcount desc

--continent with highest deathcount

Select continent, MAX(convert(bigint,total_deaths)) as deathcount
From [Portfolio project]..CovidDeaths
where continent <> ''
group by continent
order by deathcount desc

--global numbers

Select date, sum(convert(float,new_cases)) as total_cases, sum(convert(float,new_deaths)) as total_deaths, (sum(CONVERT(float, new_deaths)) / (sum(NULLIF(CONVERT(float, new_cases), 0))))*100 as DeathPercentage
From [Portfolio project]..CovidDeaths
group by date
order by 1
 
 --total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(float,vac.new_vaccinations)) OVER (partition by dea.location
order by dea.location,dea.date) as RollingPeopleVaccinated
from [Portfolio project]..CovidVaccination vac
join [Portfolio project]..CovidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent <> ''
order by 2,3
 
 --use cte
 With PopvsVac (continent, location, date, population, new_vaccinations,
 Rollingpeoplevaccinated) as 
 (select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(float,vac.new_vaccinations)) OVER (partition by dea.location
order by dea.location,dea.date) as RollingPeopleVaccinated
from [Portfolio project]..CovidVaccination vac
join [Portfolio project]..CovidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent <> ''
--order by 2,3
)

Select * , (Rollingpeoplevaccinated/population)*100 as VaccinatedPopulationRate
from PopvsVac

--Create view to store data for later visualization

Create view VaccinatedPopulationPercent as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(float,vac.new_vaccinations)) OVER (partition by dea.location
order by dea.location,dea.date) as RollingPeopleVaccinated
from [Portfolio project]..CovidVaccination vac
join [Portfolio project]..CovidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent <> ''
--order by 2,3