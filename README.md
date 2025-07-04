# COVID-19: First Year Global Impact Analysis

This project analyzes the global impact of COVID-19 during the first year of the pandemic, using publicly available data on infections, deaths, population, and vaccinations. The goal is to uncover trends, assess country-level impact, and provide structured insights using SQL.

## Project Objective

To explore and understand the rise of COVID-19 in its initial phase and how different countries were affected in the first year. This analysis uses SQL queries to extract insights, and builds views and procedures to make the data reusable and easier to explore dynamically.

## Data Sources

- **COVID-19 Deaths**: Cleaned version of the dataset from [Our World in Data](https://ourworldindata.org/covid-deaths)
- **Vaccination Data**: Sourced from [Our World in Data](https://ourworldindata.org/covid-vaccinations)

These datasets were trimmed and structured to focus only on the first year of the pandemic (approximately up to early 2021).

## Files in This Repository

| File                                  | Description |
|---------------------------------------|-------------|
| `CovidDataset-Understanding&ImportantInsights.sql` | Main analytical queries and exploratory analysis around death rates, cases, and population impact. |
| `Views.sql`                           | Reusable views that summarize key metrics like death percentages and vaccination rates across countries. |
| `Procedures.sql`                      | Stored procedures to dynamically extract summaries and perform comparisons across countries. |

## Key Insights

- Trends in total cases and deaths by location
- Death percentage per country
- Countries with the highest infection rates
- Correlation between vaccinations and reduced impact

## Technologies Used

- **Microsoft SQL Server Management Studio (SSMS)**
- SQL (T-SQL)
- Microsoft Excel (for preprocessing and review)

## About the Datasets

| Table         | Description                                                                          |
|---------------|--------------------------------------------------------------------------------------|
| `Covid-19 deaths`      | Includes country-level daily COVID-19 data such as total cases, deaths, and population. |
| `Vaccination` | Contains daily vaccination records by country including totals and people vaccinated. |

**Note:** Certain numeric fields (like `total_cases`, `new_deaths`) were originally stored as `nvarchar` and are converted to appropriate numeric types (`FLOAT`, `BIGINT`) using `TRY_CAST`.

## How to Use

1. Import the `deaths` and `vaccination` datasets into your SQL Server environment.
2. Run the scripts in this order:
   - `views.sql` (to create reusable views)
   - `procedures.sql` (to define stored procedures)
   - `CovidDataset-Understanding&ImportantInsights.sql` (to explore the data)
3. Use stored procedures for country-level comparisons and summaries.

## Future Improvements

- Integrate more recent pandemic data to extend the trend beyond the first year  
- Add visualizations using tools like Power BI or Tableau  
- Include automated tests or validation procedures for critical calculations  
- Create a dashboard UI to consume views and procedures interactively  
- Optimize performance using indexes or filtered queries for large-scale datasets  

## Author

This project was developed as part of a personal learning initiative to apply and showcase SQL skills through real-world public health data.  
It demonstrates a practical understanding of database querying, trend analysis, and procedural logic in Microsoft SQL Server Management Studio.
