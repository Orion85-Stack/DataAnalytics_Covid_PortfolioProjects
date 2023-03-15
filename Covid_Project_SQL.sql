select *
from Covid_Project..CovidDeaths
where continent is not null
order by 3,4

--select *
--from [dbo].[CovidVaccines]
--order by 3,4

--Select the data that we are going to use

select location, date, total_cases, new_cases, total_deaths, population
from Covid_Project..CovidDeaths
order by 1,2


-- Looking at Total cases vs Total deaths
-- Shows liklyhood of dying from Covid contraction in your country (South Africa)
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from Covid_Project..CovidDeaths
where location like '%south africa%'
order by 1,2


-- Looking at total cases vs population
-- Shows what % of population has Covid

select location, date, total_cases as Cumulative_cases, new_cases, total_deaths as Cumulative_deaths, new_deaths, population, (total_cases/population)*100 as Total_Cases_per_Population
from Covid_Project..CovidDeaths
where location like '%south africa'
order by 1,2


-- Looking at countries with the highest infection rate compared to population

select location, max(total_cases) as Highest_infection_Count, population, max((total_cases/population))*100 as Percent_Population_Infected
from Covid_Project..CovidDeaths
--where location like '%south africa'
group by location, population
order by Percent_Population_Infected desc


-- Looking at countries with the highest death count per population

select location, max(total_deaths) as Highest_death_count, population, max((total_deaths/population))*100 as Percent_Population_death
from Covid_Project..CovidDeaths
where continent is not null
group by location, population
order by Highest_death_count desc


-- Breakdown by continent
-- Showing the continents with the highest death count

select continent, max(total_deaths) as Highest_death_count
-- select continent, max(cast(total_deaths as int)) as death_count = to cast is to change the data type
from Covid_Project..CovidDeaths
where continent is not null
group by continent
order by Highest_death_count desc


-- Global numbers

select date, sum(new_cases) as Total_Cases, sum(new_deaths) as Total_Deaths --sum(new_deaths)/sum(new_cases)*100 as Death_Percentage
from Covid_Project..CovidDeaths
--where location like '%south africa'
where continent is not null
group by date
order by 1,2


---- Looking at total population vs vaccinations

select *
from Covid_Project..CovidVaccines

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_Vaccinated
--,
from Covid_Project..CovidDeaths dea
join Covid_Project..CovidVaccines vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
group by dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
order by 2,3


-- Use CTE

with PopvsVac (continent, location, date, population, new_vaccinations, Rolling_Vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_Vaccinated
--,
from Covid_Project..CovidDeaths dea
join Covid_Project..CovidVaccines vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
group by dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--order by 2,3
)
select *, (Rolling_Vaccinated/population)*100
from PopvsVac


-- Creating views to store data for later visualisations

Create view Percent_Pop_Vaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_Vaccinated
--,
from Covid_Project..CovidDeaths dea
join Covid_Project..CovidVaccines vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
group by dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--order by 2,3


select *
from Percent_Pop_Vaccinated