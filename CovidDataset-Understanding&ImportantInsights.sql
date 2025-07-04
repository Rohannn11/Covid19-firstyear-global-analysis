--use PortfolioProjectCovid1

select location, date, total_cases, new_cases, total_deaths, population
from deaths 
where continent is not null
order by 1,2


-- Looking at total cases vs total deaths
-- Shows the likelihood of dying if you catch covid in this country.
select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from deaths
where location like 'India'

CREATE PROCEDURE chancesofdeath
    @country VARCHAR(100)
AS
BEGIN
    SELECT 
        location,
        date,
        total_cases,
        total_deaths,
        -- Ensure decimal division and avoid divide-by-zero
        (CAST(total_deaths AS FLOAT) / NULLIF(CAST(total_cases AS FLOAT), 0)) * 100 
            AS DeathPercentage
    FROM deaths
    WHERE location LIKE @country;
END;

exec chancesofdeath 'India'

-- Looking at total cases vs Population
-- Shows percentage of population having covid.
select location,date, total_cases, population, (total_cases/population)*100 as PercentageHavingCovid
from deaths
where location like 'India'
order by 1,2

-- Looking at the rate at which population is being affected,
select location, total_cases, population,round(cast(population as float)/nullif (cast(total_cases as float),0),3) as CasesbyPopulation
from deaths
where location like 'India'
order by 1,2

-- Looking at countries with highest infection rate compared to population
select location,population, max(total_cases) as HighestInfectionCount, round(Max((total_cases/population)),6)*100 as Populationinfected
from PortfolioProjectCovid1.dbo.deaths
group by location,population
order by Populationinfected desc

-- Looking at the countries with the highest death count per population
select location,population, max(cast(total_deaths as int)) as TotalDeaths, round(Max((total_deaths/population)),6)*100 as PopulationDead
from PortfolioProjectCovid1.dbo.deaths
where continent is not null
group by location,population
order by TotalDeaths desc

-- Find 
select * from Deaths where location='World';

-- Looking into data and understanding w.r.t continents

-- Population death rates according to continents
select continent,max(cast(total_cases as int)) as TotalCases ,max(cast(total_deaths as int)) as TotalDeaths, round(Max((total_deaths/population)),6)*100 as PopulationDead
from PortfolioProjectCovid1.dbo.deaths
where continent is not null
group by continent
order by TotalDeaths desc

-- Understanding the continents with the highest death count per population
select continent,max(cast(total_deaths as int)) as TotalDeaths, round(Max((total_deaths/population)),6)*100 as PopulationDead
from PortfolioProjectCovid1.dbo.deaths
where continent is not null
group by continent
order by TotalDeaths desc

-- Looking at continents with highest infection rate compared to population
select continent, max(total_cases) as HighestInfectionCount, round(Max((total_cases/population)),6)*100 as Populationinfected
from PortfolioProjectCovid1.dbo.deaths
where continent is not null
group by continent
order by Populationinfected desc

-- GLOBAL NUMBERS
Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths,
SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
from Deaths
where continent is not null
group by date
order by 1,2
-- A statistical report
Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths,
SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
from Deaths
where continent is not null
--group by date
order by 1,2

-- Vaccination table
select * from Vaccination

-- Looking at total population vs vaccinations
select d.continent, d.location,d.date, d.population, cast(v.new_vaccinations as int) as Newvaccinations,
SUM(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location,d.date ) as RecordPeopleVaccinated
from deaths d
join Vaccination v
on d.location=v.location
and d.date = v.date
where d.continent is not null
order by 2,3

-- Enhancing the query to add VaccinationPercent by using CTEs.
with PopVsVaccination ( continent, location, date, population,new_vaccinations, RecordPeopleVaccinated)
as 
(
select d.continent, d.location,d.date, d.population, cast(v.new_vaccinations as int) as Newvaccinations,
SUM(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location,d.date ) as RecordPeopleVaccinated
from deaths d
join Vaccination v
on d.location=v.location
and d.date = v.date
where d.continent is not null
)
--order by 2,3)
select *, round((RecordPeopleVaccinated/population * 100),7) from PopVsVaccination

-- Enhancing the query to add VaccinationPercent by using Temp Tables.

Create table #PercentPopulationVaccinated
( 
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RecordPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
select d.continent, d.location,d.date, d.population, cast(v.new_vaccinations as int) as Newvaccinations,
SUM(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location,d.date ) as RecordPeopleVaccinated
from deaths d
join Vaccination v
on d.location=v.location
and d.date = v.date
where d.continent is not null

select *, round((RecordPeopleVaccinated/population * 100),7) 
from #PercentPopulationVaccinated

-- Top N countries by death rate
SELECT TOP 10 location, MAX(total_deaths) as Deaths
FROM deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Deaths DESC;

-- Deaths per population (%) per continent:
SELECT continent, 
       SUM(cast(total_deaths as float)) * 100.0 / SUM(population) AS DeathRatePerPopulation
FROM deaths
WHERE continent IS NOT NULL
GROUP BY continent;

-- Monthly new cases and deaths (globally or per country):
SELECT 
  FORMAT(date, 'yyyy-MM') AS Month,
  SUM(new_cases) AS MonthlyNewCases,
  SUM(cast(new_deaths as int)) AS MonthlyNewDeaths
FROM deaths
WHERE location = 'India'
GROUP BY FORMAT(date, 'yyyy-MM')
ORDER BY Month;

-- Running total of cases:
SELECT location, date,
       SUM(new_cases) OVER (PARTITION BY location ORDER BY date) AS RunningTotal
FROM deaths;

-- Rolling 7-day average of new cases
SELECT location, date,
       AVG(new_cases) OVER (
         PARTITION BY location 
         ORDER BY date 
         ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
       ) AS WeeklyAvgCases
FROM deaths;

-- Day with highest new cases per country
SELECT d.location, d.date, d.new_cases
FROM deaths d
JOIN (
    SELECT location, MAX(new_cases) AS max_cases
    FROM deaths
    GROUP BY location
) AS max_cases_per_location
ON d.location = max_cases_per_location.location
AND d.new_cases = max_cases_per_location.max_cases
WHERE d.continent IS NOT NULL
ORDER BY d.new_cases DESC;

-- Countries with Highest Cases per Million Population
select location, max(total_cases_per_million) as CasesPerMillion
from Deaths
where continent is not null
and total_cases_per_million is not null
group by location
order by CasesPerMillion desc

-- Day Each Country Reported Its First Case
SELECT location, MIN(date) AS FirstCaseDate
FROM deaths
WHERE total_cases > 0 AND continent IS NOT NULL
GROUP BY location
ORDER BY FirstCaseDate;

-- Countries with Highest Deaths per Million
SELECT location, MAX(total_deaths_per_million) AS DeathsPerMillion
FROM deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY DeathsPerMillion DESC;

-- Monthly Trend of Cases Globally
SELECT FORMAT(date, 'yyyy-MM') AS Month, SUM(new_cases) AS GlobalMonthlyCases
FROM deaths
WHERE continent IS NOT NULL
GROUP BY FORMAT(date, 'yyyy-MM')
ORDER BY Month;

-- Countries with Highest Spike in a Single Day (New Cases)
SELECT location, date, new_cases
FROM deaths d
WHERE new_cases = (
    SELECT MAX(new_cases)
    FROM deaths
    WHERE continent IS NOT NULL
)
AND continent IS NOT NULL;

--  Comparing Continents by Total Cases
SELECT continent, SUM(new_cases) AS TotalCases
FROM deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalCases DESC;

-- Average Daily Cases per Country (Top 10)
SELECT TOP 10 location, AVG(new_cases) AS AvgDailyCases
FROM deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY AvgDailyCases DESC;

-- Case Fatality Rate (CFR) > 5%
SELECT location,
       MAX(CAST(total_cases AS FLOAT)) AS Cases,
       MAX(CAST(total_deaths AS FLOAT)) AS Deaths,
       (MAX(CAST(total_deaths AS FLOAT)) * 100.0 / NULLIF(MAX(CAST(total_cases AS FLOAT)), 0)) AS DeathRate
FROM deaths
WHERE continent IS NOT NULL
GROUP BY location
HAVING (MAX(CAST(total_deaths AS FLOAT)) * 100.0 / NULLIF(MAX(CAST(total_cases AS FLOAT)), 0)) > 5
ORDER BY DeathRate DESC;


-- Rolling 7-Day Average of New Cases (for a Country)
SELECT location, date,
       AVG(new_cases) OVER (
           PARTITION BY location
           ORDER BY date
           ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
       ) AS RollingAvg7Days
FROM deaths
WHERE location = 'India';

-- Countries With Consistent Reporting (0 NULL days in total_cases)
SELECT location, COUNT(*) AS TotalDays, 
       COUNT(total_cases) AS ReportedDays,
       (COUNT(total_cases) * 100.0 / COUNT(*)) AS ReportingCompleteness
FROM deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY ReportingCompleteness DESC;

-- Countries Where New Cases Peaked in December 2020
SELECT location, MAX(new_cases) AS PeakCases, MAX(date) AS PeakDate
FROM deaths
WHERE FORMAT(date, 'yyyy-MM') = '2020-12'
AND continent IS NOT NULL
GROUP BY location
HAVING MAX(new_cases) > 10000  -- Optional filter
ORDER BY PeakCases DESC;

-- Top 3 Deadliest Days by Country
WITH RankedDeaths AS (
  SELECT location, date, new_deaths,
         RANK() OVER (PARTITION BY location ORDER BY new_deaths DESC) AS Rank
  FROM deaths
  WHERE continent IS NOT NULL AND new_deaths IS NOT NULL
)
SELECT *
FROM RankedDeaths
WHERE Rank <= 3
ORDER BY location, Rank;

-- Month-over-Month Growth in Cases (World)
WITH MonthlyCases AS (
  SELECT FORMAT(date, 'yyyy-MM') AS Month,
         SUM(new_cases) AS MonthlyCases
  FROM deaths
  WHERE continent IS NOT NULL
  GROUP BY FORMAT(date, 'yyyy-MM')
)
SELECT Month, MonthlyCases,
       MonthlyCases - LAG(MonthlyCases) OVER (ORDER BY Month) AS Growth
FROM MonthlyCases;

-- Countries Where Deaths Lagged Cases by >30 Days
WITH FirstCase AS (
  SELECT location, MIN(date) AS FirstCaseDate
  FROM deaths
  WHERE total_cases > 0
  GROUP BY location
),
FirstDeath AS (
  SELECT location, MIN(date) AS FirstDeathDate
  FROM deaths
  WHERE total_deaths > 0
  GROUP BY location
)
SELECT c.location, 
       c.FirstCaseDate, 
       d.FirstDeathDate,
       DATEDIFF(DAY, c.FirstCaseDate, d.FirstDeathDate) AS LagInDays
FROM FirstCase c
JOIN FirstDeath d ON c.location = d.location
WHERE DATEDIFF(DAY, c.FirstCaseDate, d.FirstDeathDate) > 30;

-- Total Hospital Admissions 
SELECT location, SUM(CAST(weekly_hosp_admissions AS FLOAT)) AS TotalAdmissions
FROM deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalAdmissions DESC;

-- Average Weekly Growth Rate in Cases (Year 1 Only)
WITH WeeklyCases AS (
  SELECT location,
         DATEPART(WEEK, date) AS Week,
         YEAR(date) AS Year,
         SUM(new_cases) AS WeeklyCases
  FROM deaths
  WHERE continent IS NOT NULL AND YEAR(date) = 2020
  GROUP BY location, DATEPART(WEEK, date), YEAR(date)
),
GrowthRate AS (
  SELECT location, Week, Year, WeeklyCases,
         WeeklyCases - LAG(WeeklyCases) OVER (PARTITION BY location ORDER BY Week) AS Growth
  FROM WeeklyCases
)
SELECT location, AVG(Growth) AS AvgWeeklyGrowth
FROM GrowthRate
GROUP BY location
ORDER BY AvgWeeklyGrowth DESC;

--  Daily Percentage Change in Total Cases (for a country)
SELECT date, location, total_cases,
       LAG(total_cases) OVER (PARTITION BY location ORDER BY date) AS PreviousTotal,
       ((total_cases - LAG(total_cases) OVER (PARTITION BY location ORDER BY date)) 
         * 100.0 / NULLIF(LAG(total_cases) OVER (PARTITION BY location ORDER BY date), 0)) 
         AS PercentChange
FROM deaths
WHERE location = 'India'
ORDER BY date;

-- Rank Countries by Total Deaths Within Each Continent
SELECT location, continent, total_deaths,
       RANK() OVER (PARTITION BY continent ORDER BY total_deaths DESC) AS DeathRank
FROM (
  SELECT location, continent, MAX(CAST(total_deaths AS FLOAT)) AS total_deaths
  FROM deaths
  WHERE continent IS NOT NULL
  GROUP BY location, continent
) AS Ranked
ORDER BY continent, DeathRank;





