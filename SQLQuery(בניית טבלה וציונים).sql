----------------------------------------------יצירת הטבלה------------------------------------
CREATE TABLE countries_scores (
    country NVARCHAR(100) PRIMARY KEY,
    accessibility_score FLOAT,
    unesco_score FLOAT,
    nature_score FLOAT,
    happiness_score FLOAT,
    safety_score FLOAT,
    cost_score FLOAT,
    weather_score FLOAT,
    authenticity_score FLOAT
);

select *
from countries_scores


----------------------------------------ציון אונסקו---------------------------------------
WITH base_data AS (
    SELECT 
        country_name,
        CAST(Number_of_international_airports AS FLOAT) AS airports_count,
        CAST(Number_of_international_airports AS FLOAT) / NULLIF(area, 0) AS airports_per_km2
    FROM countries
    WHERE Number_of_international_airports IS NOT NULL AND area IS NOT NULL
),
ranked AS (
    SELECT 
        country_name,
        PERCENT_RANK() OVER (ORDER BY airports_count) AS rank_airports,
        PERCENT_RANK() OVER (ORDER BY airports_per_km2) AS rank_density
    FROM base_data
),
final_scores AS (
    SELECT 
        country_name,
        ROUND(1 + 9.0 * (0.6 * rank_airports + 0.4 * rank_density), 3) AS accessibility_score
    FROM ranked
)
UPDATE countries_scores
SET accessibility_score = fs.accessibility_score
FROM countries_scores cs
JOIN final_scores fs ON cs.country_name = fs.country_name;


-----------------------------------------ציון נגישות------------------------------------------
WITH base_data AS (
    SELECT 
        country_name,
        CAST(Number_of_international_airports AS FLOAT) AS airports_count,
        CAST(Number_of_international_airports AS FLOAT) / NULLIF(area, 0) AS airports_per_km2
    FROM countries
    WHERE Number_of_international_airports IS NOT NULL AND area IS NOT NULL
),
ranked AS (
    SELECT 
        country_name,
        PERCENT_RANK() OVER (ORDER BY airports_count) AS rank_airports,
        PERCENT_RANK() OVER (ORDER BY airports_per_km2) AS rank_density
    FROM base_data
),
final_scores AS (
    SELECT 
        country_name,
        ROUND(1 + 9.0 * (0.6 * rank_airports + 0.4 * rank_density), 3) AS accessibility_score
    FROM ranked
)
UPDATE countries_scores
SET accessibility_score = fs.accessibility_score
FROM countries_scores cs
JOIN final_scores fs ON cs.country_name = fs.country_name;


------------------------------------------------------ציון אושר-----------------------------------------------
UPDATE cs
SET cs.happiness_score = h.score
FROM countries_scores cs
JOIN (
    SELECT Country_name, avg(score) as score
    FROM [Happiness_data(2011–2024)]
	group by Country_name
) h ON cs.country_name = h.Country_name;


-------------------------------------------------------ציון בטיחות/פשע----------------------------------------
UPDATE cs
SET cs.safety_score = ci.crimeratesafetyindex / 10.0
FROM countries_scores cs
JOIN [crime_index(2024)] ci ON cs.country_name = ci.country;


------------------------------------------------------ציון עלות מחיה------------------------------------------
WITH ranked AS (
    SELECT 
        country_name,
        cost_of_living_usd,
        PERCENT_RANK() OVER (ORDER BY cost_of_living_usd ASC) AS pr
    FROM [Cost_of_Living(2024)]
)
UPDATE cs
SET cs.cost_score = ROUND(1 + 9.0 * (1 - r.pr), 3) -- ככל שיותר זול, הציון גבוה
FROM countries_scores cs
JOIN ranked r ON cs.country_name = r.country_name;


------------------------------------------------------ציון שמורות טבע------------------------------------------
WITH avg_nature AS (
    SELECT 
        nr.country_name,
        AVG(nr.percentage) AS avg_percentage
    FROM [Nature_reserves_precentage(2013-2024)] nr
    WHERE nr.percentage IS NOT NULL
    GROUP BY nr.Country_Name
),
combined AS (
    SELECT 
        c.country_name,
        a.avg_percentage,
        (a.avg_percentage / 100.0) * c.area AS avg_area_reserved  -- חישוב שטח שמורות טבע בפועל
    FROM avg_nature a
    JOIN countries c ON a.Country_Name = c.country_name
    WHERE c.area IS NOT NULL
),
ranked AS (
    SELECT 
        country_name,
        avg_percentage,
        avg_area_reserved,
        -- דירוג לפי ציון משולב: 70% אחוז, 30% שטח בפועל
        0.7 * PERCENT_RANK() OVER (ORDER BY avg_percentage ASC) +
        0.3 * PERCENT_RANK() OVER (ORDER BY avg_area_reserved ASC) AS combined_score
    FROM combined
)
UPDATE cs
SET cs.nature_score = ROUND(1 + 9.0 * r.combined_score, 3)
FROM countries_scores cs
JOIN ranked r ON cs.country_name = r.country_name;


-------------------------------------------------ציון אותנטיות-----------------------------------------------
WITH avg_tourism AS (
    SELECT 
        country_name,
        AVG(arrivals) AS avg_tourists
    FROM [Tourists_number(1995-2020)]
    WHERE Arrivals IS NOT NULL
    GROUP BY Country_Name
),
tourists_per_capita AS (
    SELECT 
        c.country_name,
        a.avg_tourists,
        c.[population],
        CAST(a.avg_tourists AS FLOAT) / NULLIF(c.population, 0) AS tourists_per_capita
    FROM avg_tourism a
    JOIN countries c ON a.Country_Name = c.country_name
    WHERE c.population IS NOT NULL
),
ranked AS (
    SELECT 
        country_name,
        tourists_per_capita,
        1- PERCENT_RANK() OVER (ORDER BY tourists_per_capita ASC) AS pr -- פחות תיירים = יותר אותנטי
    FROM tourists_per_capita
)
UPDATE cs
SET cs.authenticity_score = ROUND(1 + 9.0 * r.pr, 3)
FROM countries_scores cs
JOIN ranked r ON cs.country_name = r.country_name;


---------------------------------------------------ציון מזג אויר--------------------------------------------
WITH yearly_avg AS (
    SELECT 
        country_name,
        AVG(temperature) AS avg_temp,
        AVG(precipitation) AS avg_precip,
        AVG(air_pollution) AS avg_pollution
    FROM [Weather_data(1990-2020)]
    WHERE temperature IS NOT NULL AND precipitation IS NOT NULL AND air_pollution IS NOT NULL
    GROUP BY Country_Name
),
normalized AS (
    SELECT 
        Country_Name,

        -- טמפרטורה אידיאלית סביב 21 מעלות
        1 - ABS(avg_temp - 21) / 15.0 AS temp_score,

        -- משקעים אידיאליים סביב 1000 מ"מ
        1 - ABS(avg_precip - 1000) / 1000.0 AS precip_score,

        -- זיהום אוויר – פחות = טוב
        1 - avg_pollution / 100.0 AS pollution_score

    FROM yearly_avg
),
weighted_score AS (
    SELECT 
        Country_Name,
        temp_score,
        precip_score,
        pollution_score,
        0.5 * temp_score + 0.35 * pollution_score + 0.15 * precip_score AS combined_score
    FROM normalized
),
final_score AS (
    SELECT 
        Country_Name,
        PERCENT_RANK() OVER (ORDER BY combined_score ASC) AS pr
    FROM weighted_score
)
UPDATE cs
SET cs.weather_score = ROUND(1 + 9.0 * fs.pr, 3)
FROM countries_scores cs
JOIN final_score fs ON cs.country_name = fs.Country_Name;


------------------------------------------------------טבלה סופית-----------------------------------------
select *
from countries_scores