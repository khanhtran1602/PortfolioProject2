--Here's the link to the project Dataset in case you want to flick though:
--https://ourworldindata.org/covid-deaths


--Hello, welcome to my first portfolio project!

--Taking a look at our data:
select * from PortfolioProject..CovidDeaths$
select * from PortfolioProject..CovidVaccinations$


--Showing the data regarding the situation in Vietnam:
select distinct continent, location, cast(date as date) Date, population, total_cases, total_deaths, 
		total_deaths/total_cases*100 as Death_rate,
		total_cases/population*100 as pct_infected
from PortfolioProject..CovidDeaths$
where location = 'Vietnam'  
order by 3


--Showing countries with highest infection rate: (For any day)
Select location, population, Max(total_cases) HighestInfectionCount, max((total_cases/population)*100)as Population_Infected_Rate
from PortfolioProject..CovidDeaths$
where continent is not null
group by location, population
order by Population_Infected_Rate desc


--Showing Countries with Highest Death Count per Population:
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null 
Group by Location
order by TotalDeathCount desc


--Showing GLOBAL numbers
;with data_world as (
select continent, location, max(total_cases) as total_cases, max(cast(total_deaths as int)) total_deaths
from PortfolioProject..CovidDeaths$
where continent is not null
group by continent, location
)
select format(sum(total_cases),'##,##0') world_total_cases , format(sum(total_deaths),'##,##0') world_total_deaths, 
		sum(total_deaths)/sum(total_cases)*100 as  world_death_rate
from data_world


--Showing the number of vaccinated people by date per country:
Select dea.continent, dea.location, cast(dea.date as date) Date, dea.population, vac.new_vaccinations,
format(sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.date),'##,##0') as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.continent is not null and new_vaccinations is not null
--and dea.location = 'Vietnam'
order by 2,3


-- Creating View to store data for later visualizations:
execute ('Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null')
