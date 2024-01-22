Select * 
from PortfolioProject..CovidDeaths
order by 3,4;

--Select * 
--from PortfolioProject..CovidVacinations
--order by 3,4;

-- Likelihood of death by Covid
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2;

-- Total cases vs Population
SELECT Location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2;

-- Looking at countries with highest infectionrate
SELECT Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as InfectedPercentage
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
group by location,population
order by InfectedPercentage desc;

-- Showing countries with highest death count per population

SELECT Location, population, max(total_deaths) as TotalDeathCount
	FROM PortfolioProject..CovidDeaths
	--Where location like '%states%'
	where continent is not null 
	group by location, population
	order by TotalDeathCount desc;

-- Continent break-down

-- Showing continents with highest death count per population
SELECT continent, max(total_deaths) as TotalDeathCount
	FROM PortfolioProject..CovidDeaths
	--Where location like '%states%'
	where continent is not null 
	group by continent
	order by TotalDeathCount desc;

-- GLOBAL NUMBERS
SELECT date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage--total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
--Where location like '%states%'
group by date
order by 1,2;

SELECT sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage--total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
--Where location like '%states%'
order by 1,2;


-- Looking at total vaccinations & population

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations as new_vacc_per_day,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3;

-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
	(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations as new_vacc_per_day,
	sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
	from PortfolioProject..CovidVaccinations vac
	join PortfolioProject..CovidDeaths dea
	on dea.location=vac.location and dea.date=vac.date
	where dea.continent is not null)
Select *, (RollingPeopleVaccinated/Population)*100 as TotalVaccinationRate
FROM PopvsVac;


-- Create Temp Table
Drop table if exists #PercentPopVac
Create table #PercentPopVac
	(Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVac numeric)


Insert into #PercentPopVac
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations as new_vacc_per_day,
	sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
	from PortfolioProject..CovidVaccinations vac
	join PortfolioProject..CovidDeaths dea
	on dea.location=vac.location and dea.date=vac.date
	where dea.continent is not null

Select *, (RollingPeopleVac/Population)*100 as TotalVaccinationRate
FROM #PercentPopVac;

-- Create view for visualizations

DROP VIEW IF EXISTS PercentPopVac;

Create View PercentPopVac as 
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations as new_vacc_per_day,
	sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
	from PortfolioProject..CovidVaccinations vac
	join PortfolioProject..CovidDeaths dea
	on dea.location=vac.location and dea.date=vac.date
	where dea.continent is not null;

SELECT * FROM PercentPopVac;