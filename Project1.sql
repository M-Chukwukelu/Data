
select *
from PortfolioProject1 ..CovidDeaths
where continent is not null
order by 3,4


--select *
--from PortfolioProject1 ..CovidVaccinations
--order by 3,4

--Selecting the data to be used
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject1 ..CovidDeaths
where continent is not null
order by 1, 2

--Looking at Total Cases vs Total Death
--Shows how likely you are to die if you get Covid in Canada
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject1 ..CovidDeaths
where continent is not null
and location like 'Canada'
order by 1, 2

--Looking at Total Cases vs Population
--Shows what percentage of population contracted Covid
select location, date,  population, total_cases, (total_cases/population)*100 as PercentageInfected
from PortfolioProject1 ..CovidDeaths
where location like 'Canada'
and continent is not null
order by 1, 2


--Countries with the Highest Infection Rate compared to their population
select location, population, max(total_cases) as HighestInfectionCount, (max(total_cases)/population)*100 as MaxPercentageInfected
from PortfolioProject1 ..CovidDeaths
where continent is not null
Group by location, population
order by 4 desc

--Countries with Highest Death Count per population
select location,  max(cast(total_deaths as bigint)) as TotalDeathCount
from PortfolioProject1 ..CovidDeaths
where continent is not null
Group by location
order by 2 desc


-- Breaking things by Continent Now

--Showing the continents with Highest Death Count
select location,  max(cast(total_deaths as bigint)) as TotalDeathCount
from PortfolioProject1 ..CovidDeaths
where continent is null
Group by location
order by 2 desc



--Global Numbers

--Likelihood of dying by continents
select sum(cast(new_deaths as int)) as total_deaths, sum(new_cases) as total_cases, 
sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
where continent is not null
group by continent
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 



