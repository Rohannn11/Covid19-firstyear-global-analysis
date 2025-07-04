CREATE PROCEDURE sp_GetCountryDeathRate
    @country VARCHAR(100)
AS
BEGIN
    SELECT 
        location,
        MAX(TRY_CAST(total_cases AS FLOAT)) AS TotalCases,
        MAX(TRY_CAST(total_deaths AS FLOAT)) AS TotalDeaths,
        MAX(TRY_CAST(total_deaths AS FLOAT)) * 100.0 / NULLIF(MAX(TRY_CAST(total_cases AS FLOAT)), 0) AS DeathRate
    FROM deaths
    WHERE location = @country
    GROUP BY location;
END;

CREATE PROCEDURE sp_GetCountryVaccinationRate
    @country VARCHAR(100)
AS
BEGIN
    SELECT 
        v.location,
        MAX(TRY_CAST(v.total_vaccinations AS FLOAT)) AS TotalVaccinations,
        MAX(TRY_CAST(d.population AS FLOAT)) AS Population,
        MAX(TRY_CAST(v.total_vaccinations AS FLOAT)) * 100.0 / NULLIF(MAX(TRY_CAST(d.population AS FLOAT)), 0) AS VaccinationRate
    FROM vaccination v
    JOIN deaths d ON v.location = d.location
    WHERE v.location = @country
    GROUP BY v.location;
END;

CREATE PROCEDURE sp_GetDailyCases
    @country VARCHAR(100)
AS
BEGIN
    SELECT 
        date,
        TRY_CAST(new_cases AS INT) AS NewCases
    FROM deaths
    WHERE location = @country
    ORDER BY date;
END;

CREATE PROCEDURE sp_GetDailyDeaths
    @country VARCHAR(100)
AS
BEGIN
    SELECT 
        date,
        TRY_CAST(new_deaths AS INT) AS NewDeaths
    FROM deaths
    WHERE location = @country
    ORDER BY date;
END;

CREATE PROCEDURE sp_GetContinentSummary
AS
BEGIN
    SELECT 
        continent,
        SUM(TRY_CAST(total_cases AS BIGINT)) AS TotalCases,
        SUM(TRY_CAST(total_deaths AS BIGINT)) AS TotalDeaths
    FROM deaths
    WHERE continent IS NOT NULL
    GROUP BY continent;
END;

CREATE PROCEDURE sp_GetCountryComparison
    @country1 VARCHAR(100),
    @country2 VARCHAR(100)
AS
BEGIN
    SELECT 
        location,
        MAX(TRY_CAST(total_cases AS BIGINT)) AS TotalCases,
        MAX(TRY_CAST(total_deaths AS BIGINT)) AS TotalDeaths
    FROM deaths
    WHERE location IN (@country1, @country2)
    GROUP BY location;
END;

CREATE PROCEDURE sp_GetVaccinationByDate
    @country VARCHAR(100),
    @target_date DATE
AS
BEGIN
    SELECT 
        location,
        date,
        TRY_CAST(total_vaccinations AS BIGINT) AS TotalVaccinations
    FROM vaccination
    WHERE location = @country AND date = @target_date;
END;

CREATE PROCEDURE sp_GetPeakCases
AS
BEGIN
    SELECT 
        location,
        MAX(TRY_CAST(new_cases AS INT)) AS PeakDailyCases
    FROM deaths
    WHERE continent IS NOT NULL
    GROUP BY location;
END;

CREATE PROCEDURE sp_GetFullyVaccinatedPercent
    @country VARCHAR(100)
AS
BEGIN
    SELECT 
        v.location,
        MAX(TRY_CAST(v.people_fully_vaccinated AS FLOAT)) AS FullyVaccinated,
        MAX(TRY_CAST(d.population AS FLOAT)) AS Population,
        MAX(TRY_CAST(v.people_fully_vaccinated AS FLOAT)) * 100.0 / NULLIF(MAX(TRY_CAST(d.population AS FLOAT)), 0) AS FullyVaccinatedPercent
    FROM vaccination v
    JOIN deaths d ON v.location = d.location
    WHERE v.location = @country
    GROUP BY v.location;
END;

CREATE PROCEDURE sp_GetTopInfectionRates
AS
BEGIN
    SELECT 
        location,
        MAX(TRY_CAST(total_cases AS FLOAT)) * 100.0 / NULLIF(MAX(TRY_CAST(population AS FLOAT)), 0) AS InfectionRate
    FROM deaths
    WHERE continent IS NOT NULL
    GROUP BY location
    ORDER BY InfectionRate DESC;
END;

CREATE PROCEDURE sp_GetTopDeathRates
AS
BEGIN
    SELECT 
        location,
        MAX(TRY_CAST(total_deaths AS FLOAT)) * 100.0 / NULLIF(MAX(TRY_CAST(total_cases AS FLOAT)), 0) AS DeathRate
    FROM deaths
    WHERE continent IS NOT NULL
    GROUP BY location
    ORDER BY DeathRate DESC;
END;

CREATE PROCEDURE sp_GetGlobalDailySummary
AS
BEGIN
    SELECT 
        date,
        SUM(TRY_CAST(new_cases AS INT)) AS TotalNewCases,
        SUM(TRY_CAST(new_deaths AS INT)) AS TotalNewDeaths
    FROM deaths
    WHERE continent IS NOT NULL
    GROUP BY date
    ORDER BY date;
END;

CREATE PROCEDURE sp_GetMonthlyCaseSummary
AS
BEGIN
    SELECT 
        location,
        FORMAT(date, 'yyyy-MM') AS Month,
        SUM(TRY_CAST(new_cases AS INT)) AS MonthlyCases
    FROM deaths
    WHERE continent IS NOT NULL
    GROUP BY location, FORMAT(date, 'yyyy-MM');
END;

CREATE PROCEDURE sp_GetVaccinationStartDates
AS
BEGIN
    SELECT 
        location,
        MIN(date) AS VaccinationStartDate
    FROM vaccination
    WHERE TRY_CAST(total_vaccinations AS INT) > 0
    GROUP BY location;
END;

CREATE PROCEDURE sp_GetDailyCaseDeathRatio
AS
BEGIN
    SELECT 
        location,
        date,
        TRY_CAST(new_cases AS FLOAT) AS NewCases,
        TRY_CAST(new_deaths AS FLOAT) AS NewDeaths,
        TRY_CAST(new_deaths AS FLOAT) / NULLIF(TRY_CAST(new_cases AS FLOAT), 0) AS DeathToCaseRatio
    FROM deaths
    WHERE continent IS NOT NULL;
END;

CREATE PROCEDURE sp_GetCountryMonthlyVaccination
    @country VARCHAR(100)
AS
BEGIN
    SELECT 
        FORMAT(date, 'yyyy-MM') AS Month,
        SUM(TRY_CAST(new_vaccinations AS INT)) AS MonthlyVaccinations
    FROM vaccination
    WHERE location = @country
    GROUP BY FORMAT(date, 'yyyy-MM');
END;

CREATE PROCEDURE sp_GetCasesBeforeDate
    @country VARCHAR(100),
    @end_date DATE
AS
BEGIN
    SELECT 
        location,
        date,
        TRY_CAST(total_cases AS INT) AS TotalCases
    FROM deaths
    WHERE location = @country AND date <= @end_date
    ORDER BY date DESC;
END;

CREATE PROCEDURE sp_GetVaccinationProgressOverTime
    @country VARCHAR(100)
AS
BEGIN
    SELECT 
        date,
        TRY_CAST(total_vaccinations AS BIGINT) AS TotalVaccinations,
        TRY_CAST(people_vaccinated AS BIGINT) AS PeopleVaccinated,
        TRY_CAST(people_fully_vaccinated AS BIGINT) AS FullyVaccinated
    FROM vaccination
    WHERE location = @country
    ORDER BY date;
END;

CREATE PROCEDURE sp_GetContinentVaccinationCoverage
AS
BEGIN
    SELECT 
        v.continent,
        SUM(TRY_CAST(v.total_vaccinations AS FLOAT)) AS TotalVaccinations,
        SUM(TRY_CAST(d.population AS FLOAT)) AS Population,
        SUM(TRY_CAST(v.total_vaccinations AS FLOAT)) * 100.0 / NULLIF(SUM(TRY_CAST(d.population AS FLOAT)), 0) AS CoveragePercent
    FROM vaccination v
    JOIN deaths d ON v.location = d.location AND v.date = d.date
    WHERE v.continent IS NOT NULL
    GROUP BY v.continent;
END;

CREATE PROCEDURE sp_GetNewVaccinationsTrend
    @country VARCHAR(100)
AS
BEGIN
    SELECT 
        date,
        TRY_CAST(new_vaccinations AS INT) AS NewVaccinations,
        LAG(TRY_CAST(new_vaccinations AS INT)) OVER (ORDER BY date) AS PrevDay,
        TRY_CAST(new_vaccinations AS INT) - LAG(TRY_CAST(new_vaccinations AS INT)) OVER (ORDER BY date) AS DailyChange
    FROM vaccination
    WHERE location = @country;
END;