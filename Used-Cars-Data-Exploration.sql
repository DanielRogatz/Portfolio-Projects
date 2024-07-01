/* Just looking what i can find in this dataset with information about used cars*/

-- At first i want to change the numbers in selling_price to an european standard currency
ALTER TABLE usedcars ADD COLUMN formatted_price VARCHAR(50);
UPDATE usedcars
SET formatted_price = FORMAT(selling_price / 100, 2, 'de_DE');

-- Let´s check the outcome
SELECT *
FROM usedcars;

-- What are the most affordable cars ?

Select min(formatted_price)
from usedcars;

SELECT *
FROM usedcars
WHERE formatted_price = '1.000,00' ;

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

-- What is the average km driven in each year?

SELECT year, AVG(km_driven)
FROM usedcars
GROUP BY year
ORDER BY AVG(km_driven);




