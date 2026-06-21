-- Netflix Project

CREATE TABLE Netflix(
show_id VARCHAR(500),
type VARCHAR(500),
title VARCHAR(500),
director VARCHAR(500),
"Cast" VARCHAR(1050),
country VARCHAR(500),
date_added VARCHAR(500),
release_year INT,
rating VARCHAR(500),
duration VARCHAR(500),
listed_in VARCHAR(500),
description VARCHAR(500)
)

SELECT * FROM Netflix


SELECT COUNT(*)
FROM Netflix

SELECT DISTINCT Type
FROM Netflix

--Q1. Count the number of Movies vs TV Shows

SELECT Type,
       COUNT(*)
FROM Netflix
GROUP BY type

--Q2. Find the most common rating for movies and TV shows
SELECT Type,
       Rating
FROM
(
SELECT Type,
       Rating,
	   Count(*),
	  RANK() OVER(PARTITION BY Type ORDER BY Count(*) DESC) AS Ranking
From Netflix
GROUP BY Type, Rating
) AS T1
WHERE Ranking = 1

--Q3. List all movies released in a specific year (e.g., 2020)

SELECT * FROM Netflix
WHERE Type = 'Movie' AND Release_Year = 2020

--Q4. Find the top 5 countries with the most content on Netflix

SELECT 
      UNNEST(STRING_TO_ARRAY(Country,',')) AS New_Country,
	  Count(Show_Id) AS Total_Count
FROM Netflix
GROUP BY New_Country
ORDER BY Total_Count DESC
LIMIT 5

--Q5. Identify the longest movie

SELECT * FROM Netflix
WHERE
     Type = 'Movie'
	 AND 
	 Duration = (SELECT MAX(Duration) FROM Netflix)


--Q6. Find content added in the last 5 years

SELECT 
      *
FROM Netflix
WHERE
      TO_DATE(Date_Added,'Month,DD,YYYY')>= CURRENT_DATE - INTERVAL '5 Years'

--Q7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT * FROM Netflix
WHERE Director ILIKE '%Rajiv Chilaka%'

--Q8. List all TV shows with more than 5 seasons

SELECT 
      *
FROM Netflix
WHERE 
     Type = 'TV Show'
	 AND
     SPLIT_PART(Duration,' ',1)::numeric > 5

--Q9. Count the number of content items in each genre

SELECT 
       UNNEST(STRING_TO_ARRAY(Listed_In,',')) AS Genre,
	  COUNT(Show_Id) AS Total_Content
FROM Netflix
GROUP BY Genre

/*Q10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!*/

SELECT 
     EXTRACT(YEAR FROM TO_DATE(Date_Added,'MONTH,DD,YYYY')) AS Date,
	  COUNT(*) AS Yearly_Content,
	  ROUND
	 (COUNT(*)::Numeric/(SELECT COUNT(*) FROM Netflix WHERE Country = 'India')::Numeric * 100 ,2) AS Avg_Content_per_year
FROM Netflix
WHERE Country = 'India'
GROUP BY Date

--Q11. List all movies that are documentaries

SELECT * FROM Netflix
WHERE Listed_In ILIKE '%Documentaries%'

--Q12. Find all content without a director

SELECT * FROM Netflix
Where Director IS NULL

--Q13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT * FROM Netflix
WHERE "Cast" ILIKE '%Salman Khan%'
AND
Release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10

--Q14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT 
	 UNNEST(STRING_TO_ARRAY("Cast",',')) AS Actor,
	 COUNT(*) AS Total_Count
FROM Netflix
WHERE Country ILIKE '%India'
GROUP BY Actor
ORDER BY Total_Count DESC
LIMIT 10

/*Q15.
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.*/
WITH New_Table
AS (
SELECT *,
       CASE
	   WHEN Description ILIKE '%Kill%'
	   OR
	   Description ILIKE '%Violence%' THEN 'Bad_Content'
	   ELSE 'Good_Content'
	   END Category
FROM Netflix
)
SELECT 
      Category,
	  COUNT(*) AS Total_Count
FROM New_Table
GROUP BY Category