-- Data Analysis of a Data Set containing over 55k entries on car sales

-- Creating new table for safety reasons

CREATE TABLE car_prices2
LIKE car_prices;

INSERT car_prices2
SELECT *
FROM car_prices;

-- Data cleaning

-- Renaming columns for specification reasons

ALTER TABLE car_prices2
RENAME COLUMN `condition` TO `car_condition`;

-- Creating row_num to show how often a row appears

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY year, make, trim, body, transmission, vin, state, car_condition, odometer, color, interior, seller, mmr, sellingprice, saledate) AS row_num
FROM car_prices2;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY year, make, trim, body, transmission, vin, state, car_condition, odometer, color, interior, seller, mmr, sellingprice, saledate) AS row_num
FROM car_prices2
)
SELECT *
FROM duplicate_cte
WHERE row_num >1;

-- There are no duplicates

-- Standardazing Data

-- Searching for BLANK or NULL values

SELECT * FROM car_prices2
WHERE year IS NULL
   OR make IS NULL
   OR trim IS NULL
   OR body IS NULL
   OR transmission IS NULL
   OR vin IS NULL
   OR state IS NULL
   OR car_condition IS NULL
   OR odometer IS NULL
   OR color IS NULL
   OR interior IS NULL
   OR seller IS NULL
   OR mmr IS NULL
   OR sellingprice IS NULL
   OR saledate IS NULL;
   
-- There are no NULL values, therefore we search for blank values
   
SELECT * 
FROM car_prices2
WHERE year = ''
   OR make = ''
   OR trim = ''
   OR body = ''
   OR transmission = ''
   OR vin = ''
   OR state = ''
   OR car_condition = ''
   OR odometer = ''
   OR color = ''
   OR interior = ''
   OR seller = ''
   OR mmr = ''
   OR sellingprice = ''
   OR saledate = '';

-- BMW 7-Series is a sedan, missing values need to be inserted

SELECT *
FROM car_prices2
WHERE make like 'bmw' and model like '7%';

UPDATE car_prices2
SET body = 'Sedan'
WHERE make like 'BMW' and model like '7%' and body like '';

-- BMW has different formats

SELECT *
FROM car_prices2
WHERE make like 'bmw';

UPDATE car_prices2
SET make = 'BMW'
WHERE make = 'bmw';

-- Now we update the value 'â€”' from various columns into 'n/a'  as we have no information to fill out these fields

SELECT*
FROM car_prices2
WHERE color like 'â€”' or interior like 'â€”';

UPDATE car_prices2
SET color = 'n/a'
WHERE color like 'â€”';

UPDATE car_prices2
SET interior = 'n/a'
WHERE interior like 'â€”';

-- Quick check if the value appears in any other column
 
SELECT * 
FROM car_prices2
WHERE year = 'â€”'
   OR make = 'â€”'
   OR trim = 'â€”'
   OR body = 'â€”'
   OR transmission = 'â€”'
   OR vin = 'â€”'
   OR state = 'â€”'
   OR car_condition = 'â€”'
   OR odometer = 'â€”'
   OR color = 'â€”'
   OR interior = 'â€”'
   OR seller = 'â€”'
   OR mmr = 'â€”'
   OR sellingprice = 'â€”'
   OR saledate = 'â€”';

-- no more 'â€”' values 

SELECT * 
FROM car_prices2
WHERE model = ''
   AND make = ''
   AND trim = ''
   AND body = '';
   
SELECT * 
FROM car_prices2
WHERE model = '' AND (make LIKE '%Mercedes%'
   OR make LIKE '%BMW%'
   OR make LIKE '%Audi%'
   OR make LIKE '%Jaguar%'
   OR make LIKE '%Volvo%'
   OR make LIKE '%Porsche%'
   OR make LIKE '%Lexus%');
   
-- BMW's are misssing the model description

UPDATE car_prices2
SET model = '7 Series'
WHERE trim LIKE '7%';


SELECT *
FROM car_prices2
WHERE trim like '7%';

-- Audi is missing one model descripton as well

SELECT *
FROM car_prices2
WHERE make LIKE 'AUDI' AND trim LIKE '2.0 TFSI Premium quattro';

-- There is not enough data to make a comparable input

UPDATE car_prices2
SET model = 'n/a'
WHERE make like 'Audi' AND trim LIKE '2.0 TFSI Premium quattro';

   
-- There are a lot of rows with missing make, model, trim and body information. We can't derive values from other columns. Therefore we insert 'n/a'. 

UPDATE car_prices2
SET make = 'n/a' 
WHERE make = '' and  model = '' and trim = '' and body = '';

UPDATE car_prices2
SET model = 'n/a' 
WHERE make = 'n/a' and  model = '' and trim = '' and body = '';

UPDATE car_prices2
SET trim = 'n/a' 
WHERE make = 'n/a' and  model = 'n/a' and trim = '' and body = '';

UPDATE car_prices2
SET body = 'n/a'
WHERE make = 'n/a' and  model = 'n/a' and trim = 'n/a' and body = '';

-- The saldedate needs to be standardized as well because it's in a text format.

ALTER TABLE car_prices2
ADD COLUMN formatted_date DATE;

UPDATE car_prices2
SET formatted_date = STR_TO_DATE(SUBSTRING(saledate, 5, 11), '%b %d %Y');

SELECT * 
FROM car_prices2;

-- Until this point 8818 rows are still having blank values. As we focus on the premium segment with brands like Mercedes, BMW, Audi etc. we take a closer look at these car makers.

SELECT distinct(make)
FROM car_prices2;

-- Mercedes has two diffrent 'make' values, Mercedes-Bent and Mercedes. 

-- In the next step we standardize the expression to Mercedes-Benz

SELECT *
FROM car_prices2
Where make like 'mercedes%';

UPDATE car_prices2
SET make = 'Mercedes-Benz'
Where make = 'mercedes';

SELECT *
FROM car_prices2
WHERE make LIKE '%BMW%';

-- Saldedates are terminated before certain model years. This is impossible and needs to be changed to 0. 

ALTER TABLE car_prices2
ADD COLUMN vehicle_age INT;

UPDATE car_prices2
SET vehicle_age = YEAR(formatted_date) - YEAR;

UPDATE car_prices2
SET vehicle_age = 0
WHERE vehicle_age = -1;




-- Now we can start with the EDA




-- At first we look at the number of sold cars of the core brands

SELECT make, count(make) as number_sold_cars
FROM car_prices2
WHERE make LIKE '%Mercedes%'
   OR make LIKE '%BMW%'
   OR make LIKE '%Audi%'
   OR make LIKE '%Jaguar%'
   OR make LIKE '%Volvo%'
   OR make LIKE '%Porsche%'
   OR make LIKE '%Lexus%'
GROUP BY make
ORDER BY number_sold_cars DESC;

/* We receive the number of sold cars per car maker:
'BMW', '2533'
'Mercedes-Benz', '2125'
'Lexus', '1318'
'Audi', '626'
'Volvo', '426'
'Jaguar', '188'
'Porsche', '158'
*/

-- What is the average age of a vehicle as it is being sold ?

SELECT make, AVG(vehicle_age)
FROM car_prices2
WHERE make LIKE '%Mercedes%'
   OR make LIKE '%BMW%'
   OR make LIKE '%Audi%'
   OR make LIKE '%Jaguar%'
   OR make LIKE '%Volvo%'
   OR make LIKE '%Porsche%'
   OR make LIKE '%Lexus%'
   GROUP BY make
ORDER BY AVG(vehicle_AGE) DESC;
   
/*make, AVG(vehicle_age)
Jaguar, 6.6755
Volvo, 6.4038
Porsche, 6.3987
Lexus, 5.6616
Audi, 5.3722
Mercedes-Benz, 5.0988
BMW, 5.0825

*/
   
-- What is the average price of each manufacturer?

SELECT make, AVG(sellingprice)
FROM car_prices2
WHERE make LIKE '%Mercedes%'
   OR make LIKE '%BMW%'
   OR make LIKE '%Audi%'
   OR make LIKE '%Jaguar%'
   OR make LIKE '%Volvo%'
   OR make LIKE '%Porsche%'
   OR make LIKE '%Lexus%'
   GROUP BY make
ORDER BY AVG(sellingprice) DESC;
   
/* make, AVG(sellingprice)
Porsche, 31935.4430
Mercedes-Benz, 21545.4908
BMW, 21532.5132
Jaguar, 19626.0638
Lexus, 19376.9651
Audi, 18571.6853
Volvo, 11740.2582
*/

-- what is the difference between the mmr and the final sellingprice in % ?

WITH pricedifference AS (
SELECT ((ABS(mmr - sellingprice))/ mmr*100) as perc_price_diff
FROM car_prices2)
SELECT AVG(perc_price_diff)
FROM pricedifference;

/* The average price difference in percent is 13.99% */


-- What is the avg price difference between mmr and final selingprice per carmaker?

WITH pricedifference AS (
SELECT make, ((ABS(mmr - sellingprice))/ mmr*100) as perc_price_diff
FROM car_prices2)
SELECT make, AVG(perc_price_diff) as avg_price_diff
FROM pricedifference
WHERE make LIKE '%Mercedes%'
   OR make LIKE '%BMW%'
   OR make LIKE '%Audi%'
   OR make LIKE '%Jaguar%'
   OR make LIKE '%Volvo%'
   OR make LIKE '%Porsche%'
   OR make LIKE '%Lexus%'
GROUP BY make 
ORDER BY avg_price_diff DESC;

/* make, avg_price_diff
Jaguar, 23.46375691
Volvo, 18.23079554
Audi, 14.97404936
Mercedes-Benz, 11.45140616
BMW, 10.79340758
Porsche, 9.38383101
Lexus, 9.31849143
*/

SELECT *
FROM car_prices2;

-- what is the average of the odometer ?

SELECT make, AVG(odometer)
FROM car_prices2
WHERE make LIKE '%Mercedes%'
   OR make LIKE '%BMW%'
   OR make LIKE '%Audi%'
   OR make LIKE '%Jaguar%'
   OR make LIKE '%Volvo%'
   OR make LIKE '%Porsche%'
   OR make LIKE '%Lexus%'
   GROUP BY make
ORDER BY AVG(odometer) DESC;

/*make, AVG(odometer)
Volvo, 81949.8779
Lexus, 76578.2215
Jaguar, 71599.6702
Audi, 71090.6230
BMW, 63632.3983
Mercedes-Benz, 62975.3280
Porsche, 60948.4747
*/

-- Which cars offer the best car condition
SELECT * 
FROM car_prices2;

SELECT * 
FROM car_prices2
WHERE make LIKE '%Mercedes%'
   OR make LIKE '%BMW%'
   OR make LIKE '%Audi%'
   OR make LIKE '%Jaguar%'
   OR make LIKE '%Volvo%'
   OR make LIKE '%Porsche%'
   OR make LIKE '%Lexus%';

SELECT make, AVG(car_condition)
FROM car_prices2
WHERE make LIKE '%Mercedes%'
   OR make LIKE '%BMW%'
   OR make LIKE '%Audi%'
   OR make LIKE '%Jaguar%'
   OR make LIKE '%Volvo%'
   OR make LIKE '%Porsche%'
   OR make LIKE '%Lexus%'
GROUP BY make
ORDER BY AVG(car_condition) DESC
LIMIT 10 ;

/* # make, AVG(car_condition)
Porsche, 33.4684
BMW, 32.6463
Mercedes-Benz, 31.4955
Lexus, 31.3414
Audi, 29.8882
Volvo, 28.3803
Jaguar, 27.8351
*/

-- Which car offers the best value considering car_condition, sellingprice, odometer and age in this exact order?

WITH aggregated_data AS (
    SELECT make, model, 
        AVG(car_condition) AS avg_car_con,
        AVG(sellingprice) AS avg_sellingprice,
        AVG(odometer) AS avg_odo,
        AVG(vehicle_age) AS avg_vehicle_age
    FROM car_prices2
    WHERE make LIKE '%Mercedes%'
       OR make LIKE '%BMW%'
       OR make LIKE '%Audi%'
       OR make LIKE '%Jaguar%'
       OR make LIKE '%Volvo%'
       OR make LIKE '%Porsche%'
       OR make LIKE '%Lexus%'
    GROUP BY make, model
)
SELECT make, model, avg_car_con, avg_sellingprice, avg_odo, avg_vehicle_age
FROM aggregated_data
ORDER BY 
    avg_car_con DESC,      -- best car condition
    avg_sellingprice ASC,  -- lowest price
    avg_odo ASC,           -- shortest range
    avg_vehicle_age ASC		-- latest vehicle
LIMIT 10;   

/*
# make, model, avg_car_con, avg_sellingprice, avg_odo, avg_vehicle_age
Audi, RS 5, 49.0000, 57250.0000, 28238.0000, 1.0000
BMW, 323i, 45.0000, 10400.0000, 94729.0000, 5.0000
Audi, n/a, 45.0000, 27500.0000, 3954.0000, 0.0000
Audi, S8, 44.6667, 43033.3333, 46588.3333, 4.3333
BMW, 1, 44.0000, 54400.0000, 19205.0000, 4.0000
Audi, R8, 44.0000, 80166.6667, 29480.6667, 5.0000
BMW, 2 Series, 43.5000, 34562.5000, 4900.2500, 0.5000
BMW, 4 Series, 42.8667, 39831.6667, 6357.6000, 0.2000
Porsche, Cayman S, 42.3333, 21000.0000, 80871.6667, 8.0000
Lexus, IS F, 42.0000, 34000.0000, 56854.2000, 4.0000
*/

-- Lets look at the cheapest car with the best car con and reasonable odometer and age, the car shouldn't be older than 7 years 

WITH aggregated_data AS (
    SELECT make, model, 
        AVG(car_condition) AS avg_car_con,
        AVG(sellingprice) AS avg_sellingprice,
        AVG(odometer) AS avg_odo,
        AVG(vehicle_age) AS avg_vehicle_age 
    FROM car_prices2
    WHERE make LIKE '%Mercedes%'
       OR make LIKE '%BMW%'
       OR make LIKE '%Audi%'
       OR make LIKE '%Jaguar%'
       OR make LIKE '%Volvo%'
       OR make LIKE '%Porsche%'
       OR make LIKE '%Lexus%'
    GROUP BY make, model
    HAVING avg_vehicle_age < 7
)
SELECT make, model, avg_car_con, avg_sellingprice, avg_odo, avg_vehicle_age
FROM aggregated_data
ORDER BY 
    avg_sellingprice ASC,  -- lowest price
    avg_car_con DESC,      -- best car condition
    avg_odo ASC,           -- shortest range
    avg_vehicle_age ASC		-- latest vehicle
LIMIT 10; 

/*
# make, model, avg_car_con, avg_sellingprice, avg_odo, avg_vehicle_age
Volvo, V50, 36.3333, 7766.6667, 87598.3333, 6.1667
Volvo, C30, 32.0000, 9900.0000, 70168.2500, 5.5000
BMW, 323i, 45.0000, 10400.0000, 94729.0000, 5.0000
Audi, A4, 27.3718, 10454.9145, 87053.7692, 6.6197
Mercedes-Benz, R-Class, 28.9070, 10629.0698, 91317.4884, 6.6977
Volvo, C70, 29.7500, 10881.2500, 72480.6250, 6.4375
Volvo, S60, 29.3440, 12191.8000, 69876.7040, 5.0400
Audi, A3, 25.6786, 14219.6429, 63902.1071, 3.5714
Lexus, IS 350, 35.9545, 15520.4545, 97370.5000, 5.9545
BMW, 3 Series, 31.8594, 16638.1529, 63872.6733, 5.2840
*/
