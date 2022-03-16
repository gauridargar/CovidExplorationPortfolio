--select *
--from PortfolioProject..CovidDeaths
--order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

--Exploring CovidDeaths Dataset

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Total cases vs Total Deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
from PortfolioProject..CovidDeaths
where location = 'India' and continent is not null
order by Death_percentage, 2 desc

--Look for total cases by population showing percentage of population that got covid for India
select location, date, total_cases,population, (total_cases/population)*100 as Cases_by_population
from PortfolioProject..CovidDeaths
where location = 'India'
order by 2 desc


--Look for total cases by population showing percentage of population that got covid
select location, date, total_cases,population, (total_cases/population)*100 as Cases_by_population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2 desc

--looking at countries with highest infection compared to population
select location, max(total_cases)as HighestInfectionCount, population, max((total_cases/population))*100 as populationInfectedPercent
from PortfolioProject..CovidDeaths
where continent is not null
group by location,population
order by populationInfectedPercent desc


--looking at countries with highest death counts compared to population
select location, max(cast(total_deaths as int))as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by HighestDeathCount desc



--showing continent with highest death count 
select continent, max(cast(total_deaths as int)) as DeathCountTotal
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by DeathCountTotal desc


--Global numbers

select sum(new_cases) as TotalNewCases, sum(cast(new_deaths as int)) as TotalNewDeaths , sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by DeathPercentage



--Exploring CovidVaccinations Dataset

select * 
from PortfolioProject..CovidDeaths deaths join PortfolioProject..CovidVaccinations vaccine On deaths.location = vaccine.location and deaths.date = vaccine.date

--Looking at total poulation Vs Vaccination

select deaths.continent, deaths.location, deaths.date, deaths.population, vaccine.new_vaccinations
, sum(convert(numeric,vaccine.new_vaccinations)) over (partition by deaths.location order by deaths.location, deaths.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths deaths join PortfolioProject..CovidVaccinations vaccine On deaths.location = vaccine.location and deaths.date = vaccine.date
where deaths.continent is not null
order by 2,3

--Use CTE

with PopulationVsVaccine (continent, location, date, population,new_vaccinations, RollingPeopleVaccinted)
as 
(
select deaths.continent, deaths.location, deaths.date, deaths.population, vaccine.new_vaccinations
, sum(convert(numeric,vaccine.new_vaccinations)) over (partition by deaths.location order by deaths.location, deaths.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths deaths join PortfolioProject..CovidVaccinations vaccine On deaths.location = vaccine.location and deaths.date = vaccine.date
where deaths.continent is not null

)
select * ,(RollingPeopleVaccinted/population) *100 as VaccPercent
from PopulationVsVaccine


--temp table

drop table if exists #PercentPopulationVaccinated

create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select deaths.continent, deaths.location, deaths.date, deaths.population, vaccine.new_vaccinations
, sum(convert(numeric,vaccine.new_vaccinations)) over (partition by deaths.location order by deaths.location, deaths.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths deaths join PortfolioProject..CovidVaccinations vaccine On deaths.location = vaccine.location and deaths.date = vaccine.date
where deaths.continent is not null

select * ,(RollingPeopleVaccinated/population) *100 as VaccPercent
from #PercentPopulationVaccinated


--Looking at Vaccinations in India  

select deaths.continent, deaths.location, deaths.date, vaccine.new_vaccinations
from PortfolioProject..CovidDeaths deaths join PortfolioProject..CovidVaccinations vaccine On deaths.location = vaccine.location and deaths.date = vaccine.date
where deaths.continent is not null and deaths.location ='India'
order by 2,3



--Creating a view to store data for later visualizations

Create View PercentPopulationVaccinated as
select deaths.continent, deaths.location, deaths.date, deaths.population, vaccine.new_vaccinations
, sum(convert(numeric,vaccine.new_vaccinations)) over (partition by deaths.location order by deaths.location, deaths.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths deaths join PortfolioProject..CovidVaccinations vaccine On deaths.location = vaccine.location and deaths.date = vaccine.date
where deaths.continent is not null


Select *
From PercentPopulationVaccinated
