/* Exploratory Data Analysis of a small data set of used cars with a focus on car ownership, transmisson, fueltype and sellertype */

-- At first i want to change the numbers in selling_price to a standard format
UPDATE usedcars
SET selling_price = selling_price / 100;

-- Let´s check the outcome
SELECT *
FROM usedcars;

-- What are the most affordable cars ?

Select min(selling_price)
from usedcars;

-- We don´t have any information about the currency. The most affordable car is priced at 200

SELECT *
FROM usedcars
WHERE selling_price = '200' ;

-- What is the average of the selling prices ?

SELECT ROUND(AVG(selling_price),2)
FROM usedcars;
-- The AVG is 5.041,27. 

-- Let´s look at the difference of the avg dealer/individual prices

SELECT ROUND(AVG(selling_price),2)
FROM usedcars
WHERE seller_type like 'dealer'; 
-- 7.218,23


SELECT ROUND(AVG(selling_price),2)
FROM usedcars
WHERE seller_type like 'ind%'; 
-- 4.245,05

-- Which cars do car dealerships sell depending on the fuel?

SELECT fuel, COUNT(fuel)
FROM usedcars
GROUP BY fuel;

-- Let´s compare diesel cars to petrol cars

SELECT ROUND(AVG(selling_price),2)
FROM usedcars
WHERE fuel like 'diesel'; 
-- 6.690,94 

SELECT ROUND(AVG(selling_price),2)
FROM usedcars
WHERE fuel like 'petrol'; 
-- 3.448,40

-- What are the top 10 most offered cars categorized by brand name?

SELECT COUNT(name), name
FROM usedcars
GROUP BY name
ORDER BY COUNT(name) DESC limit 10;

-- What is the average price in each year?

SELECT year, AVG(selling_price)
FROM usedcars
GROUP BY year
ORDER BY AVG(selling_price);

-- The average price of a car from 1996 is quite high. Let´s check out all cars from 1996

SELECT *
FROM usedcars
Where year = 1996;
-- There are only 2 cars available


-- What are the top 3 cars considering value for least amount of money

SELECT *
FROM usedcars
WHERE selling_price < 5000 AND owner LIKE "First Owner" 
ORDER BY km_driven, year DESC limit 3;

/* 1. Tata 2. Maruti 3. Datsun */
