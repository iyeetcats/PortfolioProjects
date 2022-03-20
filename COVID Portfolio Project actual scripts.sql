--select *
--from PortfolioProjects..CovidVaccinations
--order by 3, 4

--select *
--from PortfolioProjects..CovidDeaths
--order by 3, 4

--select data that we will be working on

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProjects..CovidDeaths
order by 1,2

--looking at total cases vs total deaths
--shows likelihood of dying if contract covid

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from PortfolioProjects..CovidDeaths
Where location like 'Malaysia'
order by 1,2

--looking at total cases vs population
--shows what percentage of population got covid

select location, date, population, total_cases, (total_cases/population)*100 as PositiveCasePercentage 
from PortfolioProjects..CovidDeaths
--Where location like 'Malaysia'
order by 1,2

--looking at countries with highest infection rate compared to population

Select location, population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as PositiveCasePercent
from PortfolioProjects..CovidDeaths
group by location,population
order by PositiveCasePercent desc


--showing the countries with the highest death count per population
--columns data type is nvarchar 255
--use 'cast' change to integer
--start including "where continent is not 'null'" 

Select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjects..CovidDeaths
where continent is not null
group by location, population
order by TotalDeathCount desc

--lets break it down by continent

Select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjects..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc


-- global numbers 
--for total case, total deaths and death percentage throughout time

Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage 
--(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProjects..CovidDeaths
--where location like 'Malaysia'
where continent is not null
group by date
order by 1,2

--for total case, total deaths and death percentage throughout time
--removed select date and group by date. just one entry for total overall. no time.

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage 
--(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProjects..CovidDeaths
--where location like 'Malaysia'
where continent is not null
order by 1,2

--looking at total population vs vaccination per day
--used convert instead of cast to change column data type
--joining two tables and pulling data from both

--important point here is addition of vaccination rate on daily basis with partition 
--(must include location+date) 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)
as rolling_people_vaccinated
--(rolling_people_vaccinated/population)*100 as percentage_vaccinated (gave back error since cant use table that just created. new to make temp table
from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
--and dea.location = 'Malaysia'
order by 2,3
--above shows error. need create table first using CTE or temp. prefer temp.


--use CTE
--make sure number of column is the same
--changed from int to bigint. number too large

with PopvsVAC (Continent, Location, Date, Population, New_Vaccinations,RollingPeopleVaccinated) 
as

(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)
as rolling_people_vaccinated
from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
)

Select *, ((RollingPeopleVaccinated/Population)*100) as percentage_vaccinated
from PopvsVac

--temp table
--added drop table if exists

drop table if exists #PercentPopulationVaccinated  
create table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)
as rolling_people_vaccinated
from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 

select *, (RollingPeopleVaccinated/Population)*100 as RollingPercentageVaccinated
from #PercentPopulationVaccinated
--where location = 'Malaysia'

--obviously percentage is not 200%. indicates double dose.


--creating View to store data for later visualisations

CREATE VIEW PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)
as rolling_people_vaccinated
from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 



