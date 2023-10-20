Select *
from Portfolio..[Covid Deaths]
where continent is not null
order by 3,4


Select *
from Portfolio..[Covid Vaccination]
where continent is not null
order by 3,4
 

Select Location, date, total_cases, new_cases, total_deaths, population
from Portfolio..[Covid Deaths]
order by 1,2

ALTER TABLE [dbo].[Covid Deaths]
ALTER COLUMN total_cases NUMERIC;

ALTER TABLE [dbo].[Covid Deaths]
ALTER COLUMN total_deaths NUMERIC;

ALTER TABLE [dbo].[Covid Deaths]
ALTER COLUMN new_cases NUMERIC;

ALTER TABLE [dbo].[Covid Deaths]
ALTER COLUMN new_deaths NUMERIC;




--Total Cases vs total Deaths


Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from Portfolio..[Covid Deaths]
where location like '%indi%'
order by 1,2

-- Total Cases vs Total Population

Select Location, date, total_cases, population, (total_cases/population)*100 as infected_Percentage
from Portfolio..[Covid Deaths]
where location like '%indi%'
order by 1,2

--Highest Infection Rate compared to population

Select Location, population, Max (total_cases) as Hiighest_Infection_Count, Max ((total_cases/population))*100  as infected_Percentage
from Portfolio..[Covid Deaths]
--where location like '%indi%'
group by population, location
order by infected_Percentage desc

--Countries with Highest Death Count per population

Select Location, Max (total_deaths) as Total_Deaths
from Portfolio..[Covid Deaths]
--where location like '%indi%'
group by population, location
order by Total_Deaths desc


-- Continent with Highest Death Count per population

Select location, Max (total_deaths) as Total_Deaths
from Portfolio..[Covid Deaths]
--where location like '%indi%'
where continent is null
group by location
order by Total_Deaths desc
 

--Showing continents with the highest Deaths

Select continent, Max (cast(total_deaths as int)) as Total_Deaths
from Portfolio..[Covid Deaths]
--where location like '%indi%'
where continent is not null
group by continent
order by Total_Deaths desc
 

-- Global Numbers

Select Sum(new_cases) as Total_cases, Sum(cast(new_deaths As int)) as Total_Deaths, (Sum(cast(new_deaths as int))/Sum(new_cases))*100 as Death_Percentage
from Portfolio..[Covid Deaths]
--where location like '%indi%'
where continent is not null
--group by date
order by 1,2

UPDATE [dbo].[Covid Deaths] SET new_deaths = NULL WHERE new_deaths=0;
UPDATE [dbo].[Covid Deaths] SET new_cases = NULL WHERE new_cases=0;

-- Join both tables

Select * 
From Portfolio..[Covid Deaths] dea
Join Portfolio..[Covid Vaccination] vac
on dea.location = vac.location
and dea.date = vac.date

-- Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From Portfolio..[Covid Deaths] dea
Join Portfolio..[Covid Vaccination] vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null


ALTER TABLE [dbo].[Covid Vaccination]
ALTER COLUMN new_vaccinations NUMERIC;


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(vac.new_vaccinations) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated,
 (RollingPeopleVaccinated/population)*100

From Portfolio..[Covid Deaths] dea
Join Portfolio..[Covid Vaccination] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


--CTE

With PopvsVac (Continent, location,date, population, RollingPeopleVaccinated, new_vaccinations)
as
( 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 --,(RollingPeopleVaccinated/population)*100
From Portfolio..[Covid Deaths] dea
Join Portfolio..[Covid Vaccination] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
Select* , (RollingPeopleVaccinated/population)*100 as PercentPeopleVaccinated
From PopvsVac



--TEMP TABLE

Drop Table if exists #PercentPeopleVaccinated
Create table #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPeopleVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 --,(RollingPeopleVaccinated/population)*100
From Portfolio..[Covid Deaths] dea
Join Portfolio..[Covid Vaccination] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select* , (RollingPeopleVaccinated/population)*100 as PercentPeopleVaccinated
From #PercentPeopleVaccinated

-- Create View 

Create View PercentPeopleVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 --,(RollingPeopleVaccinated/population)*100
From Portfolio..[Covid Deaths] dea
Join Portfolio..[Covid Vaccination] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Create View HighestDeaths as
Select continent, Max (cast(total_deaths as int)) as Total_Deaths
from Portfolio..[Covid Deaths]
--where location like '%indi%'
where continent is not null
group by continent

