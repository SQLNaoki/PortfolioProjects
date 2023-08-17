Select *
From [Portfolio Project]..[Covid Deaths]
Where continent is not null
order by 3,4

Select *
From [Portfolio Project]..[Covid Vaccinations]
Where continent is not null
order by 3,4

--Selecting Data we want to use
Select location,date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..[Covid Deaths]
Where continent is not null
order by 1,2

-- Total cases vs Total Deaths
-- To determine the percentage of you dying when you have Covid
Select location,date, total_cases, total_deaths,  CONVERT(DECIMAL(18, 4), (CONVERT(DECIMAL(18, 4), total_deaths) / CONVERT(DECIMAL (18, 4), total_cases))) *100 As Deathpercentage
From [Portfolio Project]..[Covid Deaths]
Where location like '%philippines%'
order by 1,2	


-- Total cases vs population
-- What percentage got covid 
Select location,date, total_cases, population,  (total_cases/population)*100 as Covidrate
From [Portfolio Project]..[Covid Deaths]
Where location like '%philippines%'
order by 1,2

-- Looking at Countries with Highest Infection Rate vs Population

Select location, population, Max(total_cases) as InfectionCount , Max((Total_cases/population))*100 as Infectionrate
From [Portfolio Project]..[Covid Deaths]
Where continent is not null
Group by location, population
order by Infectionrate Desc

-- Looking at countries with highest death count vs population

Select location, population, Max(cast(total_deaths as int))as DeathCount , Max((total_deaths/population))*100 as deathrate
From [Portfolio Project]..[Covid Deaths]
Where continent is not null
Group by location, population
order by deathrate Desc	

-- By continent
Select location, Max(cast(total_deaths as int))as DeathCount
From [Portfolio Project]..[Covid Deaths]
Where continent is null
Group by location
order by deathcount Desc


-- Global Numbers

Select Date , SUM(new_cases) As Globaltotalcase, SUM(cast(new_deaths as bigint)) as GlobalTotalDeath,
SUM(Convert(bigint, new_deaths)) / Sum(new_cases) as GlobalPercentage
From [Portfolio Project]..[Covid Deaths] 
Where continent is null
Group by date
Order by 1,2
-- haven't achieved yet


-- Total Population vs Vaccinations

Select Death.continent, Death.location, Death.date, Death.population, Vacc.new_vaccinations,
SUM(Cast(vacc.new_vaccinations as bigint)) over (Partition by death.location order by death.location,death.date) as	RollingPeopleVaccinated
From [Portfolio Project]..[Covid Deaths] Death
Join [Portfolio Project]..[Covid Vaccinations] Vacc
	on Death.location = Vacc.location
	and Death.date = Vacc.date
Where Death.continent is not null
order by 2,3

-- Using CTE

With PopvsVac (Continent, location, Date, Population,new_vaccinations, RollingPeopleVaccinated)
as
(Select Death.continent, Death.location, Death.date, Death.population, Vacc.new_vaccinations,
SUM(Cast(vacc.new_vaccinations as bigint)) over (Partition by death.location order by death.location,death.date) as	RollingPeopleVaccinated
From [Portfolio Project]..[Covid Deaths] Death
Join [Portfolio Project]..[Covid Vaccinations] Vacc
	on Death.location = Vacc.location
	and Death.date = Vacc.date
Where Death.continent is not null
--order by 2,3
)

Select *,(RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Temp Table

Drop Table if Exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255),
location nvarchar(255),
Date Datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
Select Death.continent, Death.location, Death.date, Death.population, Vacc.new_vaccinations,
SUM(Cast(vacc.new_vaccinations as bigint)) over (Partition by death.location order by death.location,death.date) as	RollingPeopleVaccinated
From [Portfolio Project]..[Covid Deaths] Death
Join [Portfolio Project]..[Covid Vaccinations] Vacc
	on Death.location = Vacc.location
	and Death.date = Vacc.date
Where Death.continent is not null

Select *,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
Select Death.continent, Death.location, Death.date, Death.population, Vacc.new_vaccinations,
SUM(Cast(vacc.new_vaccinations as bigint)) over (Partition by death.location order by death.location,death.date) as	RollingPeopleVaccinated
From [Portfolio Project]..[Covid Deaths] Death
Join [Portfolio Project]..[Covid Vaccinations] Vacc
	on Death.location = Vacc.location
	and Death.date = Vacc.date
Where Death.continent is not null



Select *
From PercentPopulationVaccinated


	
 

Select location, Max(cast(total_deaths as int))as DeathCount
From [Portfolio Project]..[Covid Deaths]
Where continent is null
Group by location
order by deathcount Desc