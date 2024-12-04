SHOW TABLE STATUS WHERE Name = 'yelp_review';
ALTER TABLE yelp_opening_hours ENGINE = InnoDB;

-- Citywise Store Analysis: Average Reviews and Ratings
SELECT 
       state,
       city,
       COUNT(name) AS Stores,
       ROUND(AVG(review_count), 1) AS AvgReviews,
       ROUND(AVG(stars), 1) AS AvgStarRating
FROM yelp_business
WHERE stars BETWEEN 3 AND 4 AND categories LIKE '%Coffee & Tea%' 
GROUP BY state, city
ORDER BY Stores DESC
LIMIT 5;

-- 5. List the cities with the most reviews in descending order:
select
	city, sum(review_count) as reviews
from yelp_business
where state like 'LA'
group by state, city
order by reviews desc;

-- 2222222222222222222222222222
SELECT 
    SUM(CASE WHEN is_open = 0 THEN 1 ELSE 0 END) AS ClosedBusinesses,
    COUNT(*) AS TotalCount,
    ROUND((SUM(CASE WHEN is_open = 0 THEN 1 ELSE 0 END) * 100.00 / COUNT(*)), 2) AS PercentageClosed,
    state
FROM yelp_business
WHERE categories LIKE '%Coffee & Tea%'
GROUP BY state
ORDER BY TotalCount DESC
LIMIT 5;

-- 333333333333333333333333333333333333333333333
-- Business Closure Rates by City
SELECT
    SUM(CASE WHEN is_open = 0 THEN 1 ELSE 0 END) AS Closed_businesses,
    COUNT(*) AS TotalCount,
    ROUND((SUM(CASE WHEN is_open = 0 THEN 1 ELSE 0 END) * 100.00/ COUNT(*)),2) AS Percentage_closed,
    state,
    city
FROM yelp_business
WHERE state = 'LA' AND categories  LIKE '%Coffee & Tea%'
GROUP BY city
ORDER BY TotalCount DESC
LIMIT 5;

-- Key Insights
-- New Orleans, LA stands out as an ideal location for our new coffee shop for several reasons:
-- The city's average star rating of 3.7 suggests potential for differentiation and improvement in the market.
-- CoffeeKing is prepared to offer a unique product that can excel against the competition.
-- An average of 1844 reviews per coffee and tea establishment highlights strong customer engagement.
-- Additional factors like population trends and the broader business landscape will also guide our decision.

-- 444444444444444444444444444444444444444444444444
SELECT name, address, city, state, stars, review_count, is_open, categories  FROM `yelp_business`
WHERE is_open = "1";

-- *****************************************************
-- Count how many businesses are in each category
WITH split_categories AS (
    SELECT business_id, TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(categories, ',', numbers.n), ',', -1)) AS category
    FROM yelp_business
    INNER JOIN (
        SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
        UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
    ) numbers ON CHAR_LENGTH(categories)
       - CHAR_LENGTH(REPLACE(categories, ',', '')) >= numbers.n - 1
)
SELECT category, COUNT(*) AS count
FROM split_categories
GROUP BY category
ORDER BY count DESC;

-- ********************************** 
-- Counting how many businesses are in each category by state
WITH split_categories AS (
    SELECT 
        business_id, 
        state,
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(categories, ',', numbers.n), ',', -1)) AS category
    FROM yelp_business
    INNER JOIN (
        SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
        UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
    ) numbers ON CHAR_LENGTH(categories) - CHAR_LENGTH(REPLACE(categories, ',', '')) >= numbers.n - 1
)
SELECT 
    state,
    category, 
    COUNT(*) AS count
FROM split_categories
GROUP BY state, category
ORDER BY state, count DESC;

-- ******************* PART 2
-- Exploring Strategic Differentiation: Attributes vs. Star Ratings

SELECT
    b.stars AS StarRating,
    COUNT(*) AS NumOfStores,
    ROUND(SUM(CASE WHEN a.OutdoorSeating = 'True' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS PercentageOutdoorSeating,
    ROUND(SUM(CASE WHEN a.DogsAllowed = 'True' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS PercentageAllowedDogs,
    ROUND(SUM(CASE WHEN a.BikeParking = 'True' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS PercentageBikeParking,
    ROUND(SUM(CASE WHEN a.Alcohol = 'Full_Bar' OR a.Alcohol = 'Beer_and_Wine' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS PercentageAlcohol,
    ROUND(SUM(CASE WHEN a.RestaurantsDelivery = 'True' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS PercentageRestaurantDelivery,
    ROUND(SUM(CASE WHEN a.RestaurantsTableService = 'True' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS PercentageTableService
FROM
    yelp_attributes a
INNER JOIN
    yelp_business b ON a.business_id = b.business_id
WHERE
    state = 'LA'
    AND city = 'New Orleans'
    AND categories LIKE '%Coffee & Tea%'
    AND b.stars >= 3.5
GROUP BY
    b.stars
ORDER BY
    b.stars DESC;

-- 555555555555555555555555555
-- Analysis of Opening Hours Range
SELECT
	b.stars AS StarRating,
    ROUND(AVG(o.Monday_Open + o.Tuesday_Open + o.Wednesday_Open + o.Thursday_Open + o.Friday_Open) / 5, 2) AS AvgOpeningHour,
    SUM(b.review_count)as Num_Reviews
FROM yelp_opening_hours o
INNER JOIN yelp_business b
ON o.business_id = b.business_id
WHERE 
	state = 'La' AND city = 'New Orleans' AND categories LIKE '%Coffee & Tea%'
GROUP BY b.stars
ORDER BY StarRating DESC
LIMIT 5;

-- 666666666666666666666666
-- Analysis of Closing Hours Range
SELECT
	b.stars AS StarRating,
    ROUND(AVG(c.Monday_Close + c.Tuesday_Close + c.Wednesday_Close + c.Thursday_Close + c.Friday_Close) / 5, 2) AS AvgClosingHour,
    SUM(b.review_count)as Num_Reviews
FROM yelp_closing_hours c
INNER JOIN yelp_business b
ON c.business_id = b.business_id
WHERE
	state = 'FL' AND city = 'Tampa' AND categories LIKE '%Coffee & Tea%'
GROUP BY b.stars
ORDER BY StarRating DESC
LIMIT 5;

-- 777777777777777777777777777777777
-- Analyzing the Relationship: Price Range vs. Star Rating
CREATE TEMPORARY TABLE coffee_shop_ratings AS
SELECT
    b.stars AS StarRating,
    ROUND(AVG(a.RestaurantsPriceRange2),1) AS PriceRange
FROM yelp_business b
INNER JOIN yelp_attributes a
ON b.business_id = a.business_id
WHERE state = 'LA' AND city = 'New Orleans' AND categories LIKE '%Coffee & Tea%'
GROUP BY b.stars
ORDER BY b.stars DESC;

SELECT * FROM coffee_shop_ratings;


-- Star Rating vs Sum of Reviews
SELECT
	stars AS StarRating,
    SUM(review_count) AS NumReviews
FROM yelp_business
GROUP BY stars
ORDER BY stars DESC;


-- Star Rating vs "Cool" Votes
SELECT
    b.stars AS StarRating,
    COUNT(r.cool) AS CountCoolVotes
FROM yelp_business b
INNER JOIN yelp_review r ON b.business_id = r.business_id
WHERE 
    b.state = 'LA' AND 
    b.city = 'New Orleans' AND 
    b.categories LIKE '%Coffee & Tea%'
GROUP BY b.stars
ORDER BY b.stars DESC
LIMIT 1000;

