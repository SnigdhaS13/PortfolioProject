Create database Myportfolio;
select * from Myportfolio.coviddeaths
order by 3,4;

select * from Myportfolio.covidvaccinations
order by 3,4;
#selectingdata

select Location,date,total_cases_per_million,new_cases,new_Deaths,total_deaths,population
from Myportfolio.coviddeaths
order by 3,4;
#looking at new_cases vs new_Deaths to fimd out deathpercentage on that location , make new column as deathpercentage

select Location,date,total_cases_per_million,new_cases,new_Deaths,total_deaths, (new_Deaths/new_cases)*100 as DeathPercentage
from Myportfolio.coviddeaths
where Location like '%States%'
order by 1, 2;

#Selecting location and calculating total count
select location, SUM(cast(new_deaths as signed)) as TotalDeathCount
from Myportfolio.coviddeaths
where continent not in ('Europe','Africa','Oceania','Asia','North America','South America')
and location not in ('World','European Union','International')
group by location
order by TotalDeathCount desc;

#looking total cases vs Population
#shows what percent of population got covid
select Location,date,total_cases_per_million,Population,(total_cases_per_million/population)*100 as PercetPopulationInfected
from Myportfolio.coviddeaths
where Location like '%Canada%'
order by 1,2;
#Finding countries that has highest infection rate compared to Population
select Location,Population,MAX(total_cases_per_million) as HighestInfectionrate , MAX(total_cases_per_million/population)*100 as PercetPopulationInfected
from Myportfolio.coviddeaths
Group by Location, Population
order by PercetPopulationInfected desc;
#Showing countries with highest deth count per pop
select location,MAX(cast(total_deaths_per_million as signed)) as Totaldeathcount
from Myportfolio.coviddeaths
where continent is null
Group by location
order by Totaldeathcount desc;

#Globalized numbers
select SUM(new_cases) as total_Cases , SUM(cast(new_Deaths as signed)) as total_Deaths,SUM(cast(new_Deaths as signed))/SUM(new_Cases)*100 as Deathpercentage
from Myportfolio.coviddeaths
where continent is not null
group by date
order by 1,2;
#Join two tables
#lets look at total pop who are vaccinated 


select dea.continent , dea.location, dea.date , dea.population, vac.new_vaccinations
FROM Myportfolio.coviddeaths dea
Join Myportfolio.covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3 ; 


#adding together
#with CTE

With PopsVacc (Continent,Location, Date, Population, New_Vaccinations,CommingVaccinated)
as
(
select dea.continent , dea.location, dea.date , dea.population, vac.new_vaccinations
, SUM(convert(vac.new_vaccinations,signed)) OVER (Partition by dea.location order by dea.location,dea.date) as CommingVacinated
FROM Myportfolio.coviddeaths dea
Join Myportfolio.covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null)
#order by 2,3 );
Select * , (CommingVaccinated/population)*100
from PopsVacc ;

#Finding Sum of total cases,total death and death percentage
select SUM(new_cases) as total_Cases, SUM(cast(new_deaths as signed )) as total_deaths, SUM(cast(new_deaths as signed)) as total_Deaths, SUM(cast(new_deaths as signed))/SUM(New_Cases)*100 as DeathPercentage
from Myportfolio.coviddeaths
where continent is not null
#group by date
order  by 1,2


#temp table

select dea.continent , dea.location, dea.date , dea.population, vac.new_vaccinations
, SUM(convert(vac.new_vaccinations,signed)) OVER (Partition by dea.location order by dea.location,dea.date) as CommingVacinated
FROM Myportfolio.coviddeaths dea
Join Myportfolio.covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null;
#order by 2,3 );
Select * , (CommingVaccinated/population)*100
from PopsVacc ;


Drop table if exists PercentPopulationVaccinated;
Create table PercentPopulationVaccinated
(
Continent char(255),
Location char(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
CommingVaccinated numeric);

insert into PercentPopulationVaccinated
select dea.continent , dea.location, dea.date , dea.population, vac.new_vaccinations
, SUM(convert(vac.new_vaccinations, signed)) OVER (Partition by dea.location order by dea.location,dea.date) as CommingVacinated
FROM Myportfolio.coviddeaths dea
Join Myportfolio.covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null;
Select * ,(CommingVaccinated/population)*100
from PercentPopulationVaccinated ;

#create view
Create view PercentPopVaccinated as
select dea.continent , dea.location, dea.date , dea.population, vac.new_vaccinations
, SUM(convert(vac.new_vaccinations, signed)) OVER (Partition by dea.location order by dea.location,dea.date) as CommingVacinated
FROM Myportfolio.coviddeaths dea
Join Myportfolio.covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null;
#order by 2,3 ;



