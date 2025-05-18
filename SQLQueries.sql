use netflixDB

-- 1. Count the number of movies and TV shows
select type,count(*)
from netflix
group by type


-- 2. Find the Most Common Rating for Movies and TV Shows
WITH RatingCounts AS (
    SELECT type,rating, COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT type, rating, rating_count, RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT type, rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;


-- 3. List All Movies Released in a Specific Year (e.g., 2020)
select *
from netflix
where type='Movie' and release_year=2020


-- 4. Find the Top 5 Countries with the Most Content on Netflix
SELECT top 5
    TRIM(value) AS country,
    COUNT(show_id) AS total_content
FROM netflix
CROSS APPLY STRING_SPLIT(country, ',')
GROUP BY TRIM(value)
order by total_content desc

-- 5. Identify the tp 5 Longest Movies
SELECT top 5 type,title,country,duration
FROM netflix
WHERE type = 'Movie'
ORDER BY CAST(LEFT(duration, CHARINDEX(' ', duration + ' ') - 1) AS INT) DESC;


-- 6. Find Content Added in the Last 5 Years
SELECT type,title,country,format(date_added, 'MMMM dd, yyyy')
FROM netflix
WHERE date_added >= DATEADD(YEAR, -5, GETDATE())


-- 7. Find All Movies/TV Shows by Director 'Youssef Chahine'
SELECT type,title,country,release_year
FROM netflix
where director like '%Youssef Chahine%'

-- 8. List All TV Shows with More Than 5 Seasons
select title,country,director,release_year,duration
from netflix
where type='Tv Show' and
	CAST(LEFT(duration, CHARINDEX(' ', duration + ' ') - 1) AS INT)>5


-- 9. Count the Number of Content Items in Each Genre
SELECT TRIM(value) AS genre, COUNT(*) AS total_content
FROM netflix
CROSS APPLY STRING_SPLIT(listed_in, ',')
GROUP BY TRIM(value);


-- 10.Find each year and the total numbers of content release in Egypt on netflix.
SELECT country, release_year, COUNT(show_id) AS total_release
FROM netflix
WHERE country = 'Egypt'
GROUP BY country, release_year
ORDER BY total_release DESC;

-- 11. List All Movies that are Documentaries
select type,title,director,listed_in
from netflix
where listed_in like '%Documentaries%'


-- 12. Find All Content Without a Director
SELECT * 
FROM netflix
WHERE director IS NULL;

-- 13. Find How Many Movies Actor 'Denzel Washington' Appeared in the Last 10 Years
SELECT * 
FROM netflix
WHERE cast LIKE '%Denzel Washington%'
  AND release_year > YEAR(GETDATE()) - 10;


-- 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in Egypt
SELECT top 10 TRIM(value) AS actor, COUNT(*) AS shows
FROM netflix
CROSS APPLY STRING_SPLIT(cast, ',')
where country like '%Egypt%'
GROUP BY TRIM(value)
order by shows desc

-- 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
SELECT category,COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;