-- View: Death Percentage by Location
CREATE VIEW vw_DeathPercentageByLocation AS
SELECT location, date, total_cases, total_deaths,
       (total_deaths * 100.0 / NULLIF(total_cases, 0)) AS DeathPercentage
FROM deaths
WHERE continent IS NOT NULL;

-- View: Cases vs Vaccinations
CREATE VIEW vw_CasesVsVaccinations AS
SELECT d.location, d.date, d.total_cases, v.total_vaccinations,
       (v.total_vaccinations * 100.0 / NULLIF(d.population, 0)) AS VaccinationRate
FROM deaths d
JOIN vaccination v ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL;

-- View: Daily Growth Rates
CREATE VIEW vw_DailyGrowthRates AS
SELECT d.location, d.date, d.new_cases, d.new_deaths, v.new_vaccinations,
       (new_cases - LAG(new_cases) OVER (PARTITION BY d.location ORDER BY d.date)) AS DailyCaseGrowth
FROM deaths d
JOIN vaccination v ON d.location = v.location AND d.date = v.date;

-- View: Vaccination Progress Over Time
CREATE VIEW vw_VaccinationProgress AS
SELECT 
    location, 
    date, 
    people_vaccinated,
    people_fully_vaccinated,
    total_vaccinations
FROM vaccination
WHERE continent IS NOT NULL;

-- View: Daily New Cases and Deaths by Country
CREATE VIEW vw_DailyNewCasesDeaths AS
SELECT 
    location,
    date,
    new_cases,
    new_deaths
FROM deaths
WHERE continent IS NOT NULL;

-- View: Population vs Vaccination Coverage
CREATE VIEW vw_VaccinationCoverage AS
SELECT 
    v.location,
    v.date,
    d.population,
    v.total_vaccinations,
    (v.total_vaccinations * 100.0 / NULLIF(d.population, 0)) AS VaccinationCoveragePercent
FROM vaccination v
JOIN deaths d ON v.location = d.location AND v.date = d.date
WHERE d.continent IS NOT NULL;

-- View: Infection Penetration by Population
CREATE VIEW vw_CasePenetration AS
SELECT 
    location,
    date,
    total_cases,
    population,
    (total_cases * 100.0 / NULLIF(population, 0)) AS CasePenetrationPercent
FROM deaths
WHERE continent IS NOT NULL;

-- View: Continent-Level Summary
CREATE VIEW vw_ContinentSummary AS
SELECT 
    continent,
    MAX(date) AS LatestDate,
    SUM(cast(total_cases as float)) AS TotalCases,
    SUM(cast(total_deaths as float)) AS TotalDeaths,
    SUM(cast(total_deaths as float) * 100.0 / NULLIF(SUM(total_cases), 0)) AS DeathRatePercent
FROM deaths
WHERE continent IS NOT NULL
GROUP BY continent;

-- View: Daily Global Totals
CREATE VIEW vw_GlobalDailyTotals AS
SELECT 
    date,
    SUM(cast(new_cases as int)) AS TotalNewCases,
    SUM(cast(new_deaths as int)) AS TotalNewDeaths
FROM deaths
WHERE continent IS NOT NULL
GROUP BY date

-- View: Countries with Most Vaccinated People
CREATE VIEW vw_TopVaccinatedCountries AS
SELECT 
    location,
    MAX(people_vaccinated) AS PeopleVaccinated,
    MAX(people_fully_vaccinated) AS PeopleFullyVaccinated
FROM vaccination
WHERE continent IS NOT NULL
GROUP BY location

-- View: Lagged Case Growth Rate
CREATE VIEW vw_GrowthRate AS
SELECT 
    location,
    date,
    new_cases,
    LAG(new_cases) OVER (PARTITION BY location ORDER BY date) AS PreviousDayCases,
    CASE 
        WHEN LAG(new_cases) OVER (PARTITION BY location ORDER BY date) = 0 THEN NULL
        ELSE (new_cases * 1.0 / NULLIF(LAG(new_cases) OVER (PARTITION BY location ORDER BY date), 0))
    END AS GrowthRate
FROM deaths
WHERE continent IS NOT NULL;

-- View: Total Vaccinations by Countr
CREATE VIEW vw_TotalVaccinationsByCountry AS
SELECT 
    location,
    MAX(TRY_CAST(total_vaccinations AS BIGINT)) AS TotalVaccinations
FROM vaccination
WHERE continent IS NOT NULL
GROUP BY location;
select * from vw_TotalVaccinationsByCountry

-- View: Daily Vaccination Progress
CREATE VIEW vw_DailyVaccinationProgress AS
SELECT 
    location,
    date,
    TRY_CAST(new_vaccinations AS INT) AS NewVaccinations,
    TRY_CAST(total_vaccinations AS BIGINT) AS TotalVaccinations
FROM vaccination
WHERE continent IS NOT NULL;

-- View: Vaccination Rate vs Population
CREATE VIEW vw_VaccinationRate AS
SELECT 
    v.location,
    v.date,
    TRY_CAST(v.total_vaccinations AS FLOAT) AS TotalVaccinations,
    TRY_CAST(d.population AS FLOAT) AS Population,
    (TRY_CAST(v.total_vaccinations AS FLOAT) * 100.0 / NULLIF(TRY_CAST(d.population AS FLOAT), 0)) AS VaccinationRate
FROM vaccination v
JOIN deaths d ON v.location = d.location AND v.date = d.date
WHERE d.continent IS NOT NULL;

-- View: Top Countries by Vaccination Coverage
CREATE VIEW vw_TopVaccinatedCoverage AS
SELECT 
    v.location,
    MAX(TRY_CAST(v.total_vaccinations AS FLOAT)) AS TotalVaccinations,
    MAX(TRY_CAST(d.population AS FLOAT)) AS Population,
    MAX(TRY_CAST(v.total_vaccinations AS FLOAT)) * 100.0 / NULLIF(MAX(TRY_CAST(d.population AS FLOAT)), 0) AS VaccinationCoverage
FROM vaccination v
JOIN deaths d ON v.location = d.location AND v.date = d.date
WHERE d.continent IS NOT NULL
GROUP BY v.location
--ORDER BY VaccinationCoverage DESC;

-- View: Cumulative Vaccinations by Continent
CREATE VIEW vw_ContinentVaccinationTotals AS
SELECT 
    continent,
    SUM(TRY_CAST(total_vaccinations AS BIGINT)) AS TotalVaccinations
FROM vaccination
WHERE continent IS NOT NULL
GROUP BY continent;

-- View: First Day of Vaccination by Country
CREATE VIEW vw_FirstVaccinationDate AS
SELECT 
    location,
    MIN(date) AS FirstVaccinationDate
FROM vaccination
WHERE TRY_CAST(total_vaccinations AS INT) > 0
GROUP BY location;

-- View: Daily New Cases and Vaccinations
CREATE VIEW vw_DailyCasesVaccinations AS
SELECT 
    d.location,
    d.date,
    TRY_CAST(d.new_cases AS INT) AS NewCases,
    TRY_CAST(v.new_vaccinations AS INT) AS NewVaccinations
FROM deaths d
JOIN vaccination v ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL;

-- View: Countries with High Case-to-Vaccination Ratio
CREATE VIEW vw_CaseToVaxRatio AS
SELECT 
    d.location,
    MAX(TRY_CAST(d.total_cases AS FLOAT)) AS TotalCases,
    MAX(TRY_CAST(v.total_vaccinations AS FLOAT)) AS TotalVaccinations,
    MAX(TRY_CAST(d.total_cases AS FLOAT)) / NULLIF(MAX(TRY_CAST(v.total_vaccinations AS FLOAT)), 0) AS CaseToVaccinationRatio
FROM deaths d
JOIN vaccination v ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
GROUP BY d.location
ORDER BY CaseToVaccinationRatio DESC;

--View: Continent-Level Summary of Cases, Deaths & Vaccinations
CREATE VIEW vw_ContinentSummaryCovid AS
SELECT 
    d.continent,
    MAX(d.date) AS LatestDate,
    SUM(TRY_CAST(d.total_cases AS BIGINT)) AS TotalCases,
    SUM(TRY_CAST(d.total_deaths AS BIGINT)) AS TotalDeaths,
    SUM(TRY_CAST(v.total_vaccinations AS BIGINT)) AS TotalVaccinations
FROM deaths d
JOIN vaccination v ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
GROUP BY d.continent;




