--Working with COVID Excel data files( Deaths, Vaccinations) to analyze and draw some conclusion.

--Checking if Covid Deaths file imported Correctly 
Select * 
from PortfolioProject..CovidDeaths$
order by 3,4

--Checking if Covid Vaccination file imported Correctly 
--Select *
--from PortfolioProject..CovidVaccination$
--order by 3,4


--Checking Location and data wise Covid deaths
Select Location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths$
order by 1,2

--Looking at Covid Death Percentage in Nepal and India
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where Location like '%nepal%'
order by 1,2

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where Location like '%India%'
order by 1,2

--looking at Total Cases vs Population --(% of people getting covid)
Select Location, date,population, total_cases, total_deaths, (total_cases/population)*100 as CovidPercentage
from PortfolioProject..CovidDeaths$
where Location like '%India%'
order by 1,2

Select Location, date, population, total_cases, total_deaths, (total_cases/population)*100 as CovidPercentage
from PortfolioProject..CovidDeaths$
where Location like '%Nepal%'
order by 1,2

--Countries having the highest Covid Cases w.r.t it's Population 
Select Location, population, Max(total_cases) as MaxTotalCases,  Max((total_cases/population)*100) as CovidCasePercentage
from PortfolioProject..CovidDeaths$
group by Location, population
order by CovidCasePercentage desc

--Total Covid Deaths by Continent
Select continent, Max(cast(total_deaths as int)) as MaxTotalDeaths
from PortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by MaxTotalDeaths desc

--total cases, total deaths and death percent in the world

Select Sum(cast(new_cases as int)) as totalcasesintheworld, Sum(cast(new_deaths as int)) as totaldeathsintheworld
from PortfolioProject..CovidDeaths$
where continent is not null

--implementation of joins in two table
--Total amount of people vaccinated in the world

select  Dea.continent, Dea.Location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(cast(Vac.new_vaccinations as int)) OVER (Partition by Dea.Location Order by Dea.Location, Dea.date) as RollingCountOfVaccination
from PortfolioProject..CovidDeaths$ as Dea
join PortfolioProject..CovidVaccination$ as Vac
on Dea.location = Vac.location 
and Dea.date = Vac.date
where Dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingCountOfVaccination)
as
(
select  Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(cast(Vac.new_vaccinations as int)) OVER (Partition by Dea.Location Order by Dea.Location, Dea.date)
as RollingCountOfVaccination
from PortfolioProject..CovidDeaths$ as Dea
join PortfolioProject..CovidVaccination$ as Vac
on Dea.location = Vac.location 
and Dea.date = Vac.date
where Dea.continent is not null
--order by 2,3
)

Select *, (RollingCountOfVaccination/Population)*100
from PopvsVac

--Using Temp Table
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(250),
Location nvarchar(250),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingCountOfVaccination numeric
)

Insert into #PercentPopulationVaccinated
select  Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(cast(Vac.new_vaccinations as int)) OVER (Partition by Dea.Location Order by Dea.Location, Dea.date)
as RollingCountOfVaccination
from PortfolioProject..CovidDeaths$ as Dea
join PortfolioProject..CovidVaccination$ as Vac
on Dea.location = Vac.location 
and Dea.date = Vac.date
where Dea.continent is not null
--order by 2,3

Select *, (RollingCountOfVaccination/Population)*100
from #PercentPopulationVaccinated

--create View to store data for later

Create View PercentPopulationVaccinatedd as
Select  Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(cast(Vac.new_vaccinations as int)) OVER (Partition by Dea.Location Order by Dea.Location, Dea.date)
as RollingCountOfVaccination
from PortfolioProject..CovidDeaths$ as Dea
join PortfolioProject..CovidVaccination$ as Vac
on Dea.location = Vac.location 
and Dea.date = Vac.date
where Dea.continent is not null

Select * from PercentPopulationVaccinatedd