SELECT *
FROM PortfolioProject..covid_death_data
where continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProject..covid_vaccinations
--order by 3,4

-- select data that we are going to be using 

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..covid_death_data
order by 1,2


-- looking at Total Cases vs Total Deaths
-- shows the likelihood of dying if you contract covid in US
SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..covid_death_data
where location like '%states%'
order by 1,2


-- looking at Total Cases vs Population
-- shows what percentage of US population who contracted covid
SELECT location,date,population, total_cases, (total_cases/population)*100 as Covidpercentage
FROM PortfolioProject..covid_death_data
where location like '%states%'
order by 1,2

-- looking at countries with the highest infection rate compared to population

SELECT location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as InfectedPercentage
FROM PortfolioProject..covid_death_data
group by location, population
order by InfectedPercentage desc


--showing the countries with the highest death count per population

SELECT location, MAX (cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..covid_death_data
where continent is not null
group by location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

--showing the continents with the highest death count per population

SELECT continent, MAX (cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..covid_death_data
where continent is not null
group by continent
order by TotalDeathCount desc



-- global numbers

SELECT sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths , SUM( cast (new_deaths as int))/ SUM (new_cases)*100 as DeathPercentage
FROM PortfolioProject..covid_death_data
where continent is not null
--group by date
order by 1,2


--joining death data and vaccination data

select *
from PortfolioProject..covid_death_data dea
join PortfolioProject..covid_vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
 
 --looking at Total Population vs Vaccinations
 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
from PortfolioProject..covid_death_data dea
join PortfolioProject..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..covid_death_data dea
join PortfolioProject..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..covid_death_data dea
join PortfolioProject..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

--use temp table

DROP table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric,
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..covid_death_data dea
join PortfolioProject..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



--creating view to store data for later visualizations 

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..covid_death_data dea
join PortfolioProject..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated