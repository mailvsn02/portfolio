Select *
From Portfolio_Project..Covid_Death$
Order by 3,4;


--Select *
--From Portfolio_Project..Covid_Vaccination$
--Order by 3,4;

Select location, date, total_cases, new_cases, total_deaths, population
From Portfolio_Project..Covid_Death$
Order by 1,2

-- Looking for Death Percentage 
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_per
From Portfolio_Project..Covid_Death$
WHere "location" = 'India'
order by 1, 2;

-- Looking for Total Case Vs population

select location, date, population, total_cases, (total_cases / population)*100 as Caseper
From Portfolio_Project..Covid_Death$
where "location" = 'India'
order by 1, 2
--- Looking for countries Highest Infection Rate compared to population 

select location, population, max(total_cases) as higest_infected_case, max((total_cases / population))*100 as Populationperceinfected
From Portfolio_Project..Covid_Death$
Group by location, population
order by Populationperceinfected desc

--- Looking for countries Highest Infection Rate compared to population 

select location, max(cast(total_deaths as int)) as total_death_count
From Portfolio_Project..Covid_Death$
where continent is null
Group by location
order by  total_death_count  desc

--Global Breakdown

select date, sum(new_cases) as total_new_case, SUM(cast(new_deaths as float)) as total_new_death, SUM(cast(new_deaths as float))/sum(new_cases)*100 as new_death_percentage
From Portfolio_Project..Covid_Death$
where continent is not null
--Group by date
order by  date, total_new_case
---- Total New Case, Death, Death percentage 
select date, sum(new_cases) as total_new_case, SUM(cast(new_deaths as float)) as total_new_death, SUM(cast(new_deaths as float))/sum(new_cases)*100 as new_death_percentage
From Portfolio_Project..Covid_Death$
where continent is not null
--Group by date
order by  date, total_new_case

--Joining 2 data sets Death and Vacinations 

select new_vaccinations
from Portfolio_Project..Covid_Vaccination$

select * 
From Portfolio_Project..Covid_Death$ dea
Join Portfolio_Project..Covid_Vaccination$ vac
on dea.location = vac.location 
and dea.date = vac.date

--Looking at total Population vs Vaccinations

Select dea.continent, dea.location, dea.date,  dea.population, vac.new_vaccinations, 
sum(convert(INT, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as cummuliative_vaccination_total
From Portfolio_Project..Covid_Death$ dea 
Join Portfolio_Project..Covid_Vaccination$ vac
on dea.location = vac.location 
and dea.date = vac.date
Where dea.continent is not null 
order by 1,2,3

--Create a new table 

WITH PopvsVac (Continent, Location, Date, Population, Vaccinations, cumuliative_Total_vaccination_Count)
as
(Select dea.continent, dea.location, dea.date,  dea.population, vac.new_vaccinations, 
sum(convert(INT, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as cumuliative_Total_vaccination_Count
From Portfolio_Project..Covid_Death$ dea 
Join Portfolio_Project..Covid_Vaccination$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null 
--order by 1,2,3
)
Select * 
FROM PopvsVac
order by 1,2,3

---Create a new table 
Create Table #VaccinatedPercentage 
(continent nvarchar(255),
Location nvarchar(255), 
Date datetime, 
Population numeric, 
new_vaccinations numeric, 
cumuliative_Total_vaccination_Count float)

Insert into #VaccinatedPercentage
Select dea.continent, dea.location, dea.date,  dea.population, vac.new_vaccinations, 
sum(convert(INT, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as cumuliative_Total_vaccination_Count
From Portfolio_Project..Covid_Death$ dea 
Join Portfolio_Project..Covid_Vaccination$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null 

Select *, (cumuliative_Total_vaccination_Count/Population)*100 as Vaccinated_percentage
FROM #VaccinatedPercentage
order by 1,2,3

