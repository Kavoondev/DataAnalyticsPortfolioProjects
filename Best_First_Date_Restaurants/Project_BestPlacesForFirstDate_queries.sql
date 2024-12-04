SELECT * FROM yelp_business LIMIT 5;

# Крок 1: Фільтрування ресторанів
SELECT business_id, name, city, state, latitude, longitude, stars, review_count, categories
FROM yelp_business
WHERE categories LIKE '%Restaurants%';

# Крок 3: Фільтрація за часом роботи
SELECT o.business_id
FROM yelp_opening_hours o
JOIN yelp_closing_hours c ON o.business_id = c.business_id
WHERE 
    (
    STR_TO_DATE(o.Monday_Open, '%h:%i %p') < '18:00:00' AND STR_TO_DATE(c.Monday_Close, '%h:%i %p') > '22:00:00'
    ) OR (
    STR_TO_DATE(o.Tuesday_Open, '%h:%i %p') < '18:00:00' AND STR_TO_DATE(c.Tuesday_Close, '%h:%i %p') > '22:00:00'
    ) OR (
    STR_TO_DATE(o.Wednesday_Open, '%h:%i %p') < '18:00:00' AND STR_TO_DATE(c.Wednesday_Close, '%h:%i %p') > '22:00:00'
    ) OR (
    STR_TO_DATE(o.Thursday_Open, '%h:%i %p') < '18:00:00' AND STR_TO_DATE(c.Thursday_Close, '%h:%i %p') > '22:00:00'
    ) OR (
    STR_TO_DATE(o.Friday_Open, '%h:%i %p') < '18:00:00' AND STR_TO_DATE(c.Friday_Close, '%h:%i %p') > '22:00:00'
    ) OR (
    STR_TO_DATE(o.Saturday_Open, '%h:%i %p') < '18:00:00' AND STR_TO_DATE(c.Saturday_Close, '%h:%i %p') > '22:00:00'
    ) OR (
    STR_TO_DATE(o.Sunday_Open, '%h:%i %p') < '18:00:00' AND STR_TO_DATE(c.Sunday_Close, '%h:%i %p') > '22:00:00'
    );

# Крок 4: Аналіз текстів відгуків
# Using Python SQLAlchemy
SELECT * FROM yelp_review_mentions LIMIT 10;

# Крок 5: Аналіз підказок (tips)
SELECT business_id, COUNT(CASE WHEN text LIKE '%romantic%' THEN 1 END) AS romantic_tips
FROM yelp_tips_combined
GROUP BY business_id;

# Крок 6: Об''єднання результатів
SELECT b.business_id, b.name, b.city, b.state, b.latitude, b.longitude, b.stars, b.review_count, b.categories
FROM yelp_business b
WHERE categories LIKE '%Restaurants%';

CREATE TEMPORARY TABLE open_close AS
SELECT
    o.business_id,
    CONCAT(
        'Monday: ', o.Monday_Open, '-', c.Monday_Close, '; ',
        'Tuesday: ', o.Tuesday_Open, '-', c.Tuesday_Close, '; ',
        'Wednesday: ', o.Wednesday_Open, '-', c.Wednesday_Close, '; ',
        'Thursday: ', o.Thursday_Open, '-', c.Thursday_Close, '; ',
        'Friday: ', o.Friday_Open, '-', c.Friday_Close, '; ',
        'Saturday: ', o.Saturday_Open, '-', c.Saturday_Close, '; ',
        'Sunday: ', o.Sunday_Open, '-', c.Sunday_Close
    ) AS schedule
FROM yelp_opening_hours o
JOIN yelp_closing_hours c ON o.business_id = c.business_id
WHERE
    (STR_TO_DATE(o.Monday_Open, '%h:%i %p') < '18:00:00' AND STR_TO_DATE(c.Monday_Close, '%h:%i %p') > '22:00:00')
    OR (STR_TO_DATE(o.Tuesday_Open, '%h:%i %p') < '18:00:00' AND STR_TO_DATE(c.Tuesday_Close, '%h:%i %p') > '22:00:00')
    OR (STR_TO_DATE(o.Wednesday_Open, '%h:%i %p') < '18:00:00' AND STR_TO_DATE(c.Wednesday_Close, '%h:%i %p') > '22:00:00')
    OR (STR_TO_DATE(o.Thursday_Open, '%h:%i %p') < '18:00:00' AND STR_TO_DATE(c.Thursday_Close, '%h:%i %p') > '22:00:00')
    OR (STR_TO_DATE(o.Friday_Open, '%h:%i %p') < '18:00:00' AND STR_TO_DATE(c.Friday_Close, '%h:%i %p') > '22:00:00')
    OR (STR_TO_DATE(o.Saturday_Open, '%h:%i %p') < '18:00:00' AND STR_TO_DATE(c.Saturday_Close, '%h:%i %p') > '22:00:00')
    OR (STR_TO_DATE(o.Sunday_Open, '%h:%i %p') < '18:00:00' AND STR_TO_DATE(c.Sunday_Close, '%h:%i %p') > '22:00:00');

DROP TABLE IF EXISTS filtered_business;

CREATE TEMPORARY TABLE filtered_business AS
SELECT business_id, name, city, state, latitude, longitude, stars, review_count, categories
FROM yelp_business
WHERE categories LIKE '%Restaurants%';

SELECT * FROM filtered_business LIMIT 5;
SELECT COUNT(*) FROM filtered_business WHERE review_count > 100 LIMIT 5;
-- Потім використовуйте `filtered_business` замість `yelp_business` у запиті.
DROP TABLE IF EXISTS final_table;

CREATE TABLE final_table AS
SELECT b.business_id, MAX(b.name) AS name, MAX(b.city) AS city, MAX(b.state) AS state, MAX(b.latitude) AS latitude, MAX(b.longitude) AS longitude, MAX(b.stars) AS stars, MAX(b.review_count) AS review_count, MAX(b.categories) AS categories,
	MAX(r.romantic_mentions) AS romantic_mentions, MAX(r.date_mentions) AS date_mentions, MAX(r.cozy_mentions) AS cozy_mentions, MAX(t.romantic_tips) AS romantic_tips,
    MAX(oc.schedule) AS schedule
FROM filtered_business b
LEFT JOIN open_close oc ON b.business_id = oc.business_id
LEFT JOIN yelp_review_mentions r ON b.business_id = r.business_id
LEFT JOIN aggregated_tips t ON b.business_id = t.business_id
GROUP BY b.business_id;

SELECT COUNT(*) FROM final_table LIMIT 5;
# business_id, name, city, state, latitude, longitude, stars, review_count, romance_score



CREATE TABLE aggregated_tips AS
SELECT business_id, COUNT(*) AS romantic_tips
FROM yelp_tips_combined
WHERE text LIKE '%romantic%'
GROUP BY business_id;





# Крок 7: Розрахунок фінального рейтингу
SELECT business_id,
	name, city, state, stars, review_count, 
       (romantic_mentions + date_mentions + cozy_mentions + romantic_tips) AS romance_score,
       stars * (romantic_mentions + romantic_tips) / (review_count + 1) AS final_score,
       schedule
FROM final_table
ORDER BY final_score DESC;


SELECT * FROM final_table LIMIT 10;
