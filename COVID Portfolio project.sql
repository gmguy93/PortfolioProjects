Select*
From PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3,4

--Select*
--From PortfolioProject.dbo.CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 1,2

--Alter vchar into floats for calculations
ALTER TABLE dbo.CovidDeaths ALTER COLUMN total_deaths FLOAT
ALTER TABLE dbo.CovidDeaths ALTER COLUMN total_cases FLOAT
ALTER TABLE dbo.CovidDeaths ALTER COLUMN new_cases FLOAT
ALTER TABLE dbo.CovidDeaths ALTER COLUMN new_deaths FLOAT

-- Looking at the Total Cases vs Total Deaths in Canada

Select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where location like '%canada%'
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentatge of population got Covid in Canada
Select location, date, Population,total_cases,(total_cases/population)*100 as total_cases_percentage
From PortfolioProject.dbo.CovidDeaths
Where location like '%canada%'
order by 1,2

--Country with the highest infection rate
Select location, Population,max(total_cases) as Highest_infection_count,Max((total_cases/population))*100 as total_cases_percentage
From PortfolioProject.dbo.CovidDeaths
where continent is not null
group by location, population
order by total_cases_percentage desc


--Showing Countries with Highest Death Count
Select location, max(total_deaths) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
where continent is not null
Group By location
order by TotalDeathCount desc

--LETS BREAK THINGS DOWN BY CONTINENT

Select continent, max(total_deaths) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
where continent is not null
Group By continent
order by TotalDeathCount desc

-- Global Numbers
Select SUM(new_cases) as total_new_cases, SUM(new_deaths) as total_new_deaths,
Sum(new_deaths)/Sum(new_cases) *100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
--Group by date
order by total_new_cases desc

--Looking at Total Population vs Vaccinations
-- Use CT

With PopvsVac (Continent, location, date, population, new_Vaccinations, RollingPeopleVaccinated) 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 

)
Select *,(RollingPeopleVaccinated/Population)*100 as Vaccinated_percentage
From PopvsVac

--Creating View for visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 


Select *
From PercentPopulationVaccinated
