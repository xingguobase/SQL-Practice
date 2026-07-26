USE ev_database;
SELECT * FROM ev_database.ev_models;
SELECT *
FROM ev_models
ORDER BY range_km DESC;

CREATE TABLE city_country_sequence (
city VARCHAR(50) PRIMARY KEY,
correct_country VARCHAR(50)
);

INSERT IGNORE INTO city_country_sequence (city, correct_country) VALUES
('Beijing', 'China'),('Bangkok', 'Thailand'),('Chicago', 'USA'),
('Munich', 'Germany'),('Kuala Lumpur', 'Malaysia'),('Shanghai', 'China'),
('Tokyo', 'Japan'),('Los Angeles', 'USA'),('Seoul', 'South Korea'),('Berlin', 'Germany');

SET SQL_SAFE_UPDATES = 0;

UPDATE ev_charging_stations AS c
JOIN city_country_sequence AS s
ON TRIM(c.city) = TRIM(s.city)
SET c.country = s.correct_country
WHERE c.country IS NULL OR c.country <> s.correct_country;

SET SQL_SAFE_UPDATES = 1;

SELECT * FROM ev_database.ev_charging_stations;
SELECT *
FROM ev_charging_stations
WHERE country='Malaysia'
AND city='Kuala Lumpur'
AND fast_charging='Yes';

SELECT * FROM ev_database.ev_customers;
SELECT *
From ev_customers
WHERE satisfaction_score >= 9
ORDER BY satisfaction_score DESC;

SELECT ev_models.model_name, ev_manufacturers.name AS manufacturer_name, ev_manufacturers.country
FROM ev_models
JOIN ev_manufacturers
ON ev_models.manufacturer_id = ev_manufacturers.manufacturer_id;

SELECT * FROM ev_database.ev_manufacturers;
SELECT ev_customers.full_name, ev_models.model_name, ev_manufacturers.name AS manufacturer_name
FROM ev_models
JOIN ev_manufacturers
ON ev_models.manufacturer_id = ev_manufacturers.manufacturer_id
JOIN ev_customers
ON ev_models.model_id = ev_customers.car_model_id;

SELECT * FROM ev_database.ev_charging_records;
SELECT ev_charging_stations.city, ev_charging_stations.operator, ev_manufacturers.name AS manufacturer_name
FROM ev_charging_records
JOIN ev_models
ON ev_charging_records.model_id = ev_models.model_id
JOIN ev_manufacturers
ON ev_models.manufacturer_id = ev_manufacturers.manufacturer_id
JOIN ev_charging_stations
ON ev_charging_records.station_id = ev_charging_stations.station_id
WHERE ev_manufacturers.name = 'Tesla';

SELECT ev_manufacturers.name AS manufacturer_name,
ROUND(AVG(ev_models.range_km), 2) AS avg_range_km,
ROUND(AVG(ev_models.base_price_usd), 2) AS avg_base_price_used
FROM ev_database.ev_models
JOIN ev_manufacturers
ON ev_models.manufacturer_id = ev_manufacturers.manufacturer_id
GROUP BY ev_manufacturers.name;

SELECT ev_charging_records.station_id,
SUM(ev_charging_records.kwh_consumed) AS total_kwh
FROM ev_charging_records
GROUP BY station_id
ORDER BY total_kwh DESC;

SELECT ev_customers.country,
ROUND(AVG(ev_customers.satisfaction_score), 2) AS avg_satisfaction_score
FROM ev_customers
GROUP BY country;

SELECT ev_charging_records.station_id,
SUM(ev_charging_records.kwh_consumed) AS total_energy
FROM ev_charging_records
GROUP BY station_id
ORDER BY total_energy DESC
LIMIT 5;

SELECT ev_models.model_id, ev_models.launch_year, ev_models.range_km, ev_models.base_price_usd
FROM ev_models
WHERE launch_year > 2020
AND range_km > 500
AND base_price_usd < 60000;

SELECT ev_charging_records.station_id, ev_charging_records.duration_min
FROM ev_charging_records
WHERE duration_min > 100;

SELECT ev_manufacturers.name AS manufacturer_name, ev_manufacturers.founded_year,
COUNT(ev_models.model_name) AS model_count
FROM ev_manufacturers
JOIN ev_models
ON ev_manufacturers.manufacturer_id = ev_models.manufacturer_id
WHERE ev_manufacturers.founded_year > 2000
GROUP BY ev_manufacturers.name, ev_manufacturers.founded_year;

SELECT ev_models.model_name, ev_manufacturers.name AS manufacturer_name, ev_models.range_km,
DENSE_RANK() OVER(PARTITION BY ev_manufacturers.name ORDER BY ev_models.range_km DESC) AS range_rank
FROM ev_models
JOIN ev_manufacturers
ON ev_models.manufacturer_id = ev_manufacturers.manufacturer_id;

SELECT ev_charging_records.station_id,
COUNT(ev_charging_records.station_id) AS session_count
FROM ev_charging_records
GROUP BY station_id
ORDER BY session_count DESC
LIMIT 1;

SELECT ev_manufacturers.name AS manufacturer_name,
ROUND(AVG(ev_models.range_km), 2) AS avg_driving_range
FROM ev_manufacturers
JOIN ev_models
ON ev_manufacturers.manufacturer_id = ev_models.manufacturer_id
GROUP BY ev_manufacturers.name
ORDER BY avg_driving_range DESC
LIMIT 3;

SELECT ev_customers.country,
COUNT(ev_customers.customer_id) AS customer_count
FROM ev_customers
GROUP BY country
ORDER BY customer_count DESC
LIMIT 1;

SELECT manufacturer_name, model_name, price_rank
FROM(SELECT ev_models.model_name, ev_manufacturers.name AS manufacturer_name,
ROW_NUMBER() OVER(PARTITION BY ev_manufacturers.name ORDER BY ev_models.base_price_usd DESC) AS price_rank
FROM ev_models
JOIN ev_manufacturers
ON ev_models.manufacturer_id = ev_manufacturers.manufacturer_id) AS ranked_models
WHERE price_rank = 1;

SELECT ev_manufacturers.name AS manufacturer_name,
COUNT(ev_charging_records.record_id) AS total_charging_sessions
FROM ev_charging_records
JOIN ev_models
ON ev_charging_records.model_id = ev_models.model_id
JOIN ev_manufacturers
ON ev_models.manufacturer_id = ev_manufacturers.manufacturer_id
GROUP BY manufacturer_name
ORDER BY total_charging_sessions DESC;

SELECT ev_manufacturers.name AS manufacturer_name,
ROUND(AVG(ev_customers.satisfaction_score),2) AS avg_satisfaction_score
FROM ev_models
JOIN ev_customers
ON ev_models.model_id = ev_customers.car_model_id 
JOIN ev_manufacturers
ON ev_models.manufacturer_id = ev_manufacturers.manufacturer_id
GROUP BY manufacturer_name
ORDER BY avg_satisfaction_score DESC;

SELECT ev_charging_stations.station_id,
ROUND(SUM(ev_charging_records.cost_usd), 2) AS total_cost_used
FROM ev_charging_stations
JOIN ev_charging_records
ON ev_charging_stations.station_id = ev_charging_records.station_id
GROUP BY station_id
ORDER BY total_cost_used DESC
LIMIT 5;

SELECT ev_customers.full_name, ev_models.model_name, ev_models.base_price_usd
FROM ev_models
JOIN ev_customers
ON ev_models.model_id = ev_customers.car_model_id
WHERE ev_models.base_price_usd > (SELECT AVG(ev_models.base_price_usd)
FROM ev_models)
ORDER BY base_price_usd DESC;

SELECT ev_manufacturers.name AS manufacturer_name,
MIN(ev_models.launch_year) AS earliest_launch_year,
MAX(ev_models.launch_year) AS latest_launch_year
FROM ev_models
JOIN ev_manufacturers
ON ev_models.manufacturer_id = ev_manufacturers.manufacturer_id
GROUP BY manufacturer_name
ORDER BY earliest_launch_year AND latest_launch_year;

SELECT ev_charging_stations.operator,
ROUND(AVG(ev_charging_records.cost_usd/ev_charging_records.kwh_consumed), 2) AS avg_cost_per_kwh
FROM ev_charging_records
JOIN ev_charging_stations
ON ev_charging_records.station_id = ev_charging_stations.station_id
GROUP BY operator
ORDER BY avg_cost_per_kwh DESC;

SELECT ev_manufacturers.name AS manufacturer_name,
SUM(ev_charging_records.kwh_consumed) AS total_kwh_consumed
FROM ev_charging_records
JOIN ev_models
ON ev_charging_records.model_id = ev_models.model_id
JOIN ev_manufacturers
ON ev_models.manufacturer_id = ev_manufacturers.manufacturer_id
GROUP BY manufacturer_name
ORDER BY total_kwh_consumed DESC
LIMIT 1;

SELECT ev_models.model_name,
ROUND(AVG(ev_charging_records.duration_min), 2) AS avg_charging_duration
FROM ev_models
JOIN ev_charging_records
ON ev_models.model_id = ev_charging_records.model_id
GROUP BY model_name
ORDER BY avg_charging_duration DESC
LIMIT 1;

SELECT sub.country,
CONCAT(ROUND(sub.fast_charging_percentage, 2), '%') AS fast_charging_percentage
FROM(SELECT ev_charging_stations.country,
SUM(CASE WHEN fast_charging = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(ev_charging_stations.fast_charging) AS fast_charging_percentage
FROM ev_charging_stations
GROUP BY country
)AS sub
ORDER BY sub.fast_charging_percentage DESC;

SELECT ev_customers.country,
COUNT(ev_models.model_name) AS total_models
FROM ev_customers
JOIN ev_models
ON ev_customers.car_model_id = ev_models.model_id
GROUP BY country
ORDER BY total_models DESC
LIMIT 3;

SELECT ev_customers.country, ev_customers.full_name, ev_customers.satisfaction_score, 
SUM(ev_charging_records.kwh_consumed) AS total_kwh_consumed
FROM ev_customers
JOIN ev_charging_records
ON ev_customers.car_model_id = ev_charging_records.model_id
GROUP BY country, full_name, satisfaction_score
ORDER BY total_kwh_consumed DESC;

SELECT ev_charging_records.charge_date, ev_charging_records.cost_usd,
ROUND(SUM(ev_charging_records.cost_usd) OVER (ORDER BY charge_date), 2) AS running_total_charging_cost
FROM ev_charging_records
ORDER BY running_total_charging_cost;