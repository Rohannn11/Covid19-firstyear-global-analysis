# COVID-19: First Year Global Impact Analysis

This project analyzes the global impact of COVID-19 during the first year of the pandemic, using publicly available data on infections, deaths, population, and vaccinations. The goal is to uncover trends, assess country-level impact, and provide structured insights using SQL.

## Project Objective

To explore and understand the rise of COVID-19 in its initial phase and how different countries were affected in the first year. This analysis uses SQL queries to extract insights, and builds views and procedures to make the data reusable and easier to explore dynamically.

## Data Sources

- **COVID-19 Deaths**: Cleaned version of the dataset from [Our World in Data](https://ourworldindata.org/covid-deaths)
- **Vaccination Data**: Sourced from [Our World in Data](https://ourworldindata.org/covid-vaccinations)

These datasets were trimmed and structured to focus only on the first year of the pandemic (approximately up to early 2021).

## Files in This Repository

| File              | Description |
|-------------------|-------------|
| `insights.sql`    | Main analytical queries and exploratory analysis around death rates, cases, and population impact. |
| `views.sql`       | Reusable views that summarize key metrics like death percentages and vaccination rates across countries. |
| `procedures.sql`  | Stored procedures to dynamically extract summaries and perform comparisons across countries. |

## Key Insights

- Trends in total cases and deaths by location
- Death percentage per country
- Countries with the highest infection rates
- Correlation between vaccinations and reduced impact

## Technologies Used

- SQL (T-SQL / MS SQL Server syntax)
- Microsoft Excel (for preprocessing and review)

## How to Use

1. Import the `deaths` and `vaccinations` datasets into your SQL environment.
2. Run the scripts in this order:
   - `views.sql` (to create reusable views)
   - `procedures.sql` (to define stored procedures)
   - `insights.sql` (to explore the data)
3. Use stored procedures for country-level comparisons and summaries.

## Author

This project was created as part of a personal portfolio focused on SQL-based data analysis.
