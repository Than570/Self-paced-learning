SELECT *
FROM Portifolioproject..CovidDeaths$
ORDER BY 3,4

--SELECT *
--FROM Portifolioproject..CovidVaccinations$
--ORDER BY 3,4

--Select Data that we are gointo be using 

Select Location, date, total_cases, new_cases, total_deaths, population
From Portifolioproject..CovidDeaths$
order by 1,2

--Looking at Total Cases vs Total Deaths  in the United States
--Shows the likelihood of dying if you get COVID in the United States

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portifolioproject..CovidDeaths$
Where location like '%states%'
order by 1,2


--Looking at the Total Cases vs Population
--Shows what percentage of population got Covid

Select Location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
From Portifolioproject..CovidDeaths$
Where location like '%states%'
order by 1,2


--Looking at countries with highest infection rate compared to population

Select Location, population, Max(total_cases)as HighestInfectionCount, Max(total_cases/population)*100 as 
	PercentagePopulationInfected
From Portifolioproject..CovidDeaths$
--Where location like '%states%'
Group by Location, Population
order by PercentagePopulationInfected desc


--Showing Countries with the Highest Death Count per Population

Select Location, Max(cast(Total_cases as int)) as TotalDeathCount
From Portifolioproject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

--Grouping the data by continent

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From Portifolioproject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


--Showing the continents with the highest death counts 

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From Portifolioproject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Breaking the global Numbers 

Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
	SUM(cast(new_deaths as int))/ SUM(New_cases)*100 as DeathPercentage 
From Portifolioproject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
--Group By date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
	SUM(cast(new_deaths as int))/ SUM(New_cases)*100 as DeathPercentage 
From Portifolioproject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
--Group By date
order by 1,2

--Looking at Total population versus the vaccination

--USE CTE

With PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingVaccinatedIndividuals)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location  Order by dea.location,
	dea.Date) as RollingVaccinatedIndividuals
---, (RollingVaccinatedIndividuals/population)
From Portifolioproject..CovidDeaths$ dea
Join Portifolioproject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date =  vac.date
where dea.continent is not null
--Order by 2,3
)
Select *, (RollingVaccinatedIndividuals/Population)*100
From PopvsVac


--Temp Table

Drop Table if exists #PercentagePopulaionVaccinated
Create Table #PercentagePopulaionVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinentions numeric,
RollingVaccinatedIndividuals numeric
)

Insert Into #PercentagePopulaionVaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location  Order by dea.location,
	dea.Date) as RollingVaccinatedIndividuals
---, (RollingVaccinatedIndividuals/population)
From Portifolioproject..CovidDeaths$ dea
Join Portifolioproject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date =  vac.date
where dea.continent is not null
--Order by 2,3


Select *, (RollingVaccinatedIndividuals/Population)*100
From #PercentagePopulaionVaccinated


--Creating View to store data for later visualisations

Create View PercentagePopulaionVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location  Order by dea.location,
	dea.Date) as RollingVaccinatedIndividuals
---, (RollingVaccinatedIndividuals/population)
From Portifolioproject..CovidDeaths$ dea
Join Portifolioproject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date =  vac.date
where dea.continent is not null
--Order by 2,3

Select* 
From PercentagePopulaionVaccinated



