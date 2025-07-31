----------------------------------------------שאילתות הקשר-----------------------------------------------

---------------------------------------------- מה מביא יותר תיירים - טבע או מורשת? ---------------------
SELECT 
    c.country_name AS Country,

    -- ממוצע תיירים לאורך השנים
    t.Tourists_Avg / 1000000 as tourists,

    -- צפיפות אתרי אונסק"ו לפי שטח
    u.UNESCO_sites_number,

    -- ממוצע אחוז שמורות טבע
    n.Avg_Nature_Reserves_Percent / 100  * c.area as  nature_area

FROM Countries c

-- ממוצע תיירים לפי מדינה
JOIN (
    SELECT country_name, AVG(Arrivals) AS Tourists_Avg
    FROM [Tourists_number(1995-2020)]
    GROUP BY Country_Name
) t ON c.country_name = t.Country_Name

-- כמות אתרי אונסק"ו
JOIN (
    SELECT Country_name, COUNT(Site_Name) AS UNESCO_sites_number
    FROM UNESCO_sites
    GROUP BY Country_name
) u ON c.country_name = u.Country_name

-- ממוצע שמורות טבע לאורך השנים
JOIN (
    SELECT Country_Name, AVG(percentage) AS Avg_Nature_Reserves_Percent
    FROM [Nature_reserves_precentage(2013-2024)]
    GROUP BY Country_Name
) n ON c.country_name = n.Country_Name


----------------------כמה משפיע יוקר המחיה על תיירים-----------------------------

select c.Country_name , AVG(t.arrivals) as tourists  , AVG(Cost_Of_Living_USD) AS COST
from [Tourists_number(1995-2020)] t join
[Cost_of_Living(2024)] c on t.Country_Name = c.Country_name
group by c.Country_name

----------------------כמה משפיע מדד האושר על תיירים--------------------------------
select h.Country_Name , AVG(h.score) as happiness , avg(t.arrivals) as tourists
from [Happiness_data(2011–2024)] h join
[Tourists_number(1995-2020)] t on t.Country_Name = h.Country_name
group by h.Country_Name


--------------------------כמה משפיע גשם על תיירות---------------------------------
select w.Country_Name , AVG(w.precipitation) as mm_rain , avg(t.arrivals) as tourists
from [Weather_data(1990-2020)] w join
[Tourists_number(1995-2020)] t on t.Country_Name = w.Country_name
group by w.Country_Name


----------------------------כמה משפיע נגישות על תיירות-----------------------------
select c.Country_Name , c.Number_of_international_airports, avg(t.arrivals) as tourists
from countries c join
[Tourists_number(1995-2020)] t on t.Country_Name = c.Country_name
group by c.Country_Name , c.Number_of_international_airports



-----------------------------------------------שאילתות פילוחים--------------------------------------------

--1 המדינות עם הכי הרבה אתרי אונסקו לשטח
SELECT c.country_name, COUNT(u.Site_Name) AS unesco_count, c.area,
       COUNT(u.Site_Name) / c.area AS unesco_per_1000km2
FROM countries c
JOIN Unesco_sites u
  ON u.Country_name = c.country_name
GROUP BY c.country_name, c.area
having COUNT(u.Site_Name) > 5
ORDER BY unesco_per_1000km2 DESC;

--2 המדינה עם הכי הרבה אתרי אונסקו
select Country_name , COUNT(site_name) as unesco_counter
from Unesco_sites
group by Country_name
order by COUNT(site_name) desc

--3 המדינות הכי יציבות ונעימות בטמפרטורה
SELECT Country_Name, 
       AVG(Temperature) AS avg_temp,
       AVG(Air_pollution) AS avg_pollution,
	   STDEV(Temperature) as temp_stability
FROM [Weather_data(1990-2020)]
WHERE Year BETWEEN 1995 AND 2020
GROUP BY Country_Name
HAVING AVG(Temperature) BETWEEN 17 AND 25 AND AVG(Air_pollution) < 20  and STDEV(Temperature) < 0.5
ORDER BY avg_temp;

--4 מדינות מאושרות עם פשיעה גבוהה
SELECT h.Country_name, 
       AVG(h.score) AS avg_happiness,
       ci.crimeIndex
FROM [Happiness_data(2011–2024)] h
JOIN [crime_index(2024)] ci 
     ON h.Country_name = ci.country
WHERE h.Year >= 2018
GROUP BY h.Country_name, ci.crimeIndex
HAVING AVG(h.score) > 6 AND ci.crimeIndex > 50
ORDER BY avg_happiness DESC;

--5--מדינות מאושרות וזולות
SELECT h.[Country_name], 
       col.[Cost_Of_Living_USD], 
       AVG(h.[score]) AS avg_happiness
FROM [Happiness_data(2011–2024)] h
JOIN [Cost_of_Living(2024)] col 
     ON h.[Country_name] = col.[Country_name]
WHERE h.Year >= 2010
GROUP BY h.[Country_name], col.[Cost_Of_Living_USD]
HAVING AVG(h.[score]) > 6
ORDER BY col.[Cost_Of_Living_USD] ASC;

--6 מדינות ירוקות עם פשיעה גבוהה
SELECT c.country_name, 
       AVG(n.Percentage) AS avg_nature_reserves,
       ci.crimeIndex
FROM countries c
JOIN [Nature_reserves_precentage(2013-2024)] n 
     ON c.country_name = n.[Country_Name]
JOIN [crime_index(2024)] ci 
     ON ci.country = c.country_name
WHERE n.Year BETWEEN 2015 AND 2020
GROUP BY c.country_name, ci.crimeIndex
HAVING AVG(n.Percentage) > 20 AND ci.crimeIndex > 60
ORDER BY avg_nature_reserves DESC;

--
--7 מדינות ירוקות,בטוחות ועם תיירות נמוכה
SELECT c.country_name, 
       AVG(n.Percentage) AS avg_nature_reserves,
       ci.crimeIndex,
       AVG(t.Arrivals) AS avg_tourists,
	   c.area
FROM countries c
JOIN [Nature_reserves_precentage(2013-2024)] n 
  ON c.country_name = n.[Country_Name]
JOIN [Tourists_number(1995-2020)] t 
  ON c.country_name = t.[Country_Name] AND n.Year = t.Year
JOIN [crime_index(2024)] ci 
  ON ci.country = c.country_name
WHERE n.Year BETWEEN 2015 AND 2020
GROUP BY c.country_name, ci.crimeIndex , c.area
HAVING 
     AVG(n.Percentage) > 20         -- ירוקות: מעל 20% שטח מוגן
 AND ci.crimeIndex < 45          -- בטוחות: פשיעה יחסית נמוכה
 AND AVG(t.Arrivals) < 3000000  -- לא מתוירות: פחות מ 3מיליון תיירים בשנה
 and c.area > 10000 -- שטח מספיק גדול
ORDER BY avg_nature_reserves desc;

----8 המדינות הכי צפופות בתיירים לעומת אזרחים
SELECT c.country_name, 
       AVG(t.Arrivals) AS avg_tourists,
       c.area,
       AVG(t.Arrivals) / c.area AS tourist_density_per_km2
FROM countries c
JOIN [Tourists_number(1995-2020)] t 
     ON c.country_name = t.[Country_Name]
WHERE t.Year BETWEEN 2015 AND 2019
      AND c.area IS NOT NULL AND c.area > 0
GROUP BY c.country_name, c.area
ORDER BY tourist_density_per_km2 DESC;

--9 המדינות הכי פחות צפופות בתיירים (מדד האותנטיות)
SELECT c.country_name, 
       AVG(t.Arrivals) AS avg_tourists,
       c.population,
       AVG(t.Arrivals) / c.population AS tourists_per_capita
FROM countries c
JOIN [Tourists_number(1995-2020)] t 
     ON c.country_name = t.[Country_Name]
WHERE t.Year BETWEEN 2015 AND 2019
      AND c.population IS NOT NULL AND c.population > 0
GROUP BY c.country_name, c.population
ORDER BY tourists_per_capita asc;

--מדינות מאושרות עם הרבה טבע ומעט תיירים10 
SELECT h.Country_name, 
       AVG(h.score) AS avg_happiness,
       AVG(n.Percentage) AS avg_nature, 
       AVG(t.Arrivals) AS avg_tourists
FROM [Happiness_data(2011–2024)] h
JOIN [Nature_reserves_precentage(2013-2024)] n 
  ON h.Country_name = n.[Country_Name] AND h.Year = n.Year
JOIN [Tourists_number(1995-2020)] t 
  ON t.[Country_Name] = h.[Country_name] AND t.Year = h.Year
WHERE h.Year BETWEEN 2015 AND 2020
GROUP BY h.[Country_name]
HAVING AVG(h.score) > 6 AND AVG(n.Percentage) > 10 AND AVG(t.Arrivals) < 6000000
ORDER BY avg_happiness DESC;