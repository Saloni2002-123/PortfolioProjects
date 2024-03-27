--select * from PortfolioProject..CovidDeath
--select * from PortfolioProject..CovidVaccination
select location,date,total_cases,new_cases,total_deaths,population from PortfolioProject..CovidDeath order by 1,2
--looking at Total cases vs toatal deaths
--shows the likelyhood of dying if you contract covid in your country
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeath
where location like '%states%'
order by 1,2

--looking at Toal cases vs population
--shows what % of population got covid
select location,date,total_cases,population,(total_cases/population)*100 as PopulationPercentage
from PortfolioProject..CovidDeath
order by 1,2

--looking at countries with highest infection rate compared to population
select location,population,Max(total_cases) as HighestInfectionCount,(Max(total_cases)/population)*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeath
--where location like '%states%'
Group by location,Population
order by PercentagePopulationInfected desc

--showing countries with highest death count per population
select location,Max(cast(total_deaths as int)) as TotalDeathCount from PortfolioProject..CovidDeath Group by location order by TotalDeathCount desc
--break things by continent
select continent,Max(cast(total_deaths as int ) )as TotalDeathCount from PortfolioProject..CovidDeath
where continent is not null
group by continent
order by TotalDeathCount desc

--showing continent with highest death counts
select continent,Max(cast(total_deaths as int ) )as TotalDeathCount from PortfolioProject..CovidDeath
group by continent
order by TotalDeathCount desc
-- Global numbers
select date,sum(new_cases) as TotalNewCase,sum(cast(new_deaths as int)) from PortfolioProject..CovidDeath
where continent is not null
group by date
order by 1,2

select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeath,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeath
order by 1,2

--looking at total vaccination vs total populations
select dea.location,dea.continent,dea.date,dea.population,vacc.new_vaccinations,
Sum(Convert(int,vacc.new_vaccinations))Over (Partition by dea.location)
from PortfolioProject..CovidDeath dea join PortfolioProject..CovidVaccination vacc
on dea.location=vacc.location
and dea.date=vacc.date
where dea.continent is not null
order by 2,3

--use CTE
With PopVsVac(Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as
(
select dea.location,dea.continent,dea.date,dea.population,vacc.new_vaccinations,
Sum(Convert(bigint,vacc.new_vaccinations))Over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeath dea join PortfolioProject..CovidVaccination vacc
on dea.location=vacc.location
and dea.date=vacc.date
where dea.continent is not null
)
select *,(RollingPeopleVaccinated/Population)*100  from PopvsVac

--Temp table
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.location,dea.continent,dea.date,dea.population,vacc.new_vaccinations,
Sum(Convert(bigint,vacc.new_vaccinations))Over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeath dea join PortfolioProject..CovidVaccination vacc
on dea.location=vacc.location
and dea.date=vacc.date
where dea.continent is not null
select *,(RollingPeopleVaccinated/Population)*100  from #PercentPopulationVaccinated
