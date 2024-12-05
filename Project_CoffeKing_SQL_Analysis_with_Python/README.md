# SQL Analysis Project with Python: Unlocking Insights for CoffeeKing

## Вступ

CoffeeKing, a pioneering startup in the coffee industry, is committed to delivering an unparalleled customer experience. To achieve this, they seek actionable insights from Yelp reviews and user data. These insights will guide strategic decision-making, including optimal location selection, optimized operating hours, business enhancements, and targeted loyalty programs.

With a keen interest in data analysis and a desire to contribute to the success of local businesses, I decided to analyze Yelp data for CoffeeKing. While I am currently working my way through the Coursera course "Learn SQL Basics for Data Science Specialization," I have already been able to put my SQL skills to the test. By uncovering valuable insights from Yelp reviews, I hope to assist CoffeeKing in achieving its business objectives.

## Dataset info
- COUNT(name) FROM yelp_business - **150,346**
- COUNT(review_id) FROM yelp_review = **6,990,280**
- **22241** places where you can drink alcohol in **1269** cities in **27** states.
- Over 1.2 million business attributes such as hours of operation, parking options, availability, and ambiance.

## Key Achievement:
Despite challenges such as converting 10GB of JSON data to CSV and importing it into a SQL database on limited hardware, I successfully identified a promising location for a new CoffeeKing and uncovered a correlation between coffee price and business rating.

# Process
## Part 1
1. Using modules
import os
import json
import pandas as pd
import numpy as np
import dask.dataframe as dd
from dask import delayed
from multiprocessing import Pool
import ijson

2. Importing the JSON files
3. Extract business_id, attributes and hours into a new data frame
4 .Remove the attributes and hours dataframes from the business data frame
## Part 2 - Cleaning
4. Remove "attributes" from column names in attributes_df
5. Cleaning attributes Wifi and Alcohol
## Part 3 - Preparing Hours table
6. Remove "hours" from column names in hours_df
7. Split opening and closing hours into separate columns
8. Define a function to convert time format and handle null values
9. Apply the function to all columns with opening and closing hours
10. Create a dataframes for opening and for closing hours
11. Exporting dataframes into CSV files
yelp_business.csv
yelp_checkin.csv
yelp_review.csv
yelp_tip.csv
yelp_user.csv
yelp_attributes.csv
yelp_opening_hours.csv
yelp_closing_hours.csv
## Part 4 - CSV to MySQL
12. Imporint Large CSV into SQL code is in file Import CSV to SQL.ipynb.
## ERD of our SQL Database is here


## Part 5 - Analysis
13. To identify optimal locations for new CoffeeKing stores, I leveraged MySQL to analyze Yelp data. By examining cities based on store density, review volume, and star ratings, I was able to pinpoint areas with high coffee shop interest and engagement.
<pre>
SELECT 
       state,
       city,
       COUNT(name) AS Stores,
       ROUND(AVG(review_count), 1) AS AvgReviews,
       ROUND(AVG(stars), 1) AS AvgStarRating
FROM 
       yelp_business
WHERE 
       stars BETWEEN 3 AND 4 
       AND categories LIKE '%Coffee & Tea%' 
GROUP BY 
       state, city
ORDER BY 
       Stores DESC
LIMIT 5;
</pre>
### Business Closure Rates by City
14. This query evaluates the percentage of closed businesses in various cities to assess market dynamics and competitive challenges.
<pre>
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
</pre>
### Key Insights
- New Orleans, LA stands out as an ideal location for our new coffee shop for several reasons:
- The city's average star rating of 3.7 suggests potential for differentiation and improvement in the market.
- CoffeeKing is prepared to offer a unique product that can excel against the competition.
- An average of 1844 reviews per coffee and tea establishment highlights strong customer engagement.
- Additional factors like population trends and the broader business landscape will also guide our decision.

**15. Analysis of Opening Hours Range**
<pre>
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
</pre>
**16. Analysis of Closing Hours Range**
<pre>
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
</pre>
**17. Analyzing the Relationship: Price Range vs. Star Rating**
<pre>
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
</pre>
![Опис зображення](https://github.com/Kavoondev/YelpDataset_CoffeeKing/blob/main/yelp_plot.png)


**18. Star Rating vs Sum of Reviews**
<pre>
SELECT
	stars AS StarRating,
    SUM(review_count) AS NumReviews
FROM yelp_business
GROUP BY stars
ORDER BY stars DESC;
</pre>
![Опис зображення](https://github.com/Kavoondev/YelpDataset_CoffeeKing/blob/main/yelp_plot_2.png)
