select Location, date, total_cases, new_cases, total_deaths, population
from MyPortfolioProject..coviddeathsk$
order by 1,2


--Looking at the Total cases vs Total Deaths per country
--shows the likelihood of dying if caught covid in Nigeria
select Location, date, total_cases , total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from MyPortfolioProject..coviddeathsk$
where [location] = 'Nigeria'
order by 1,2



--Looking at Total Cases vs Population
--shows what percentage of population caught covid
select Location, date, total_cases , population, (total_cases/population)*100 as PercentPopulationInfected
from MyPortfolioProject..coviddeathsk$
where [location] = 'Nigeria'
order by 1,2



--Looking at the country with the highest infection rate
select Location,population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
from MyPortfolioProject..coviddeathsk$
where continent is not null
group by location, population
order by 4 desc



--showing countries with the highest Deathcount per poulation
select Location, MAX(total_deaths) as TotalDeathCount
from MyPortfolioProject..coviddeathsk$
where continent is not null
group by location
order by 2 desc

--GLOBAL NUMBERS

--showing continent with highest death count
select location,MAX(total_deaths) as TotalDeathCount
from MyPortfolioProject..coviddeathsk$
where continent is null and location IN ('Europe', 'Africa', 'North America','South America', 'Asia', 'Oceania')
group by location
order by 2 desc


--Death Percentage across the Globe

select sum(total_cases) as total_cases, sum(total_deaths) as total_deaths, (sum(total_deaths)/sum(total_cases))*100 as GlobalDeathPercentage
from MyPortfolioProject..coviddeathsk$
where continent is not null
order by 1


select date, sum(new_cases) as new_cases, sum(total_cases) as total_cases, sum(total_deaths) as total_deaths, 
(sum(total_deaths)/sum(total_cases))*100 as GlobalDeathPercentage
from MyPortfolioProject..coviddeathsk$
where continent is not null
group by date
order by 1


--Looking at How many people in the world has been vacccinated



select dea.continent, dea.[location], dea.date, dea.population,vac.new_vaccinations, 
sum(vac.new_vaccinations) OVER (partition by dea.Location order by dea.location, dea.date) as PeopleVaccinatedCumulative
from MyPortfolioProject..coviddeathsk$ as dea
JOIN MyPortfolioProject..covidvaccinations$ as vac
    on dea.[location] = vac.[location] and dea.[date]=vac.[date]
where dea.continent is not null
order by 2,3


-- Using CTE 

WITH PopvsVac (continent, Location, Date, Population, new_vaccinations, PeopleVaccinatedCumulative) as
(
select dea.continent, dea.[location], dea.date, dea.population,vac.new_vaccinations, 
sum(vac.new_vaccinations) OVER (partition by dea.Location order by dea.location, dea.date) as PeopleVaccinatedCumulative
from MyPortfolioProject..coviddeathsk$ as dea
JOIN MyPortfolioProject..covidvaccinations$ as vac
    on dea.[location] = vac.[location] and dea.[date]=vac.[date]
where dea.continent is not null
)
SELECT *, (PeopleVaccinatedCumulative/Population)*100 as PercentagePopulationVaccinated
FROM PopvsVac


--USING TEMP TABLE

DROP Table if exists #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinatedCumulative NUMERIC
)
Insert into #PercentagePopulationVaccinated
select dea.continent, dea.[location], dea.date, dea.population,vac.new_vaccinations, 
sum(vac.new_vaccinations) OVER (partition by dea.Location order by dea.location, dea.date) as PeopleVaccinatedCumulative
from MyPortfolioProject..coviddeathsk$ as dea
JOIN MyPortfolioProject..covidvaccinations$ as vac
    on dea.[location] = vac.[location] and dea.[date]=vac.[date]
where dea.continent is not null

SELECT *, (PeopleVaccinatedCumulative/Population)*100 as PercentagePopulationVaccinated
FROM #PercentagePopulationVaccinated


--Creating views to store data later for visualization

Create view PercentagePopulationVaccinatedView as
Select dea.continent, dea.[location], dea.date, dea.population,vac.new_vaccinations, 
sum(vac.new_vaccinations) OVER (partition by dea.Location order by dea.location, dea.date) as PeopleVaccinatedCumulative
from MyPortfolioProject..coviddeathsk$ as dea
JOIN MyPortfolioProject..covidvaccinations$ as vac
    on dea.[location] = vac.[location] and dea.[date]=vac.[date]
where dea.continent is not null
--order by 2,3

Create view GlobalDeathPercentageView AS
select date, sum(new_cases) as new_cases, sum(total_cases) as total_cases, sum(total_deaths) as total_deaths, 
(sum(total_deaths)/sum(total_cases))*100 as GlobalDeathPercentage
from MyPortfolioProject..coviddeathsk$
where continent is not null
group by date
--order by 1

Create View AfricanDeathPercentage as
select date, sum(new_cases) as new_cases, sum(total_cases) as total_cases, sum(total_deaths) as total_deaths, 
(sum(total_deaths)/sum(total_cases))*100 as AfricaDeathPercentage
from MyPortfolioProject..coviddeathsk$
where continent = 'Africa'
group by date


Create view NigeriaInfectedPopulation as
select Location, date, total_cases , population, (total_cases/population)*100 as PercentPopulationInfected
from MyPortfolioProject..coviddeathsk$
where [location] = 'Nigeria'


--Worked view querying
select*
from NigeriaInfectedPopulation
order by 2







