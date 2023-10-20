SELECT *
FROM czechia_price AS cp
ORDER BY date_from ASC;

SELECT *
FROM czechia_price AS cp
ORDER BY date_from DESC;

-- Ceny v czechia_price od ledna 2006 do prosince 2018 --

SELECT *
FROM czechia_payroll AS cp 
ORDER BY payroll_year DESC;

SELECT *
FROM czechia_payroll AS cp 
ORDER BY payroll_year ASC, payroll_quarter ASC;

/* Ceny v czechia_payroll od prvního kvartálu 2000 do druhého kvartálu 2021 ->
 Prolíná se období leden 2006 - prosinec 2018  */

-- Alternativně ???--
SELECT 
str_to_date(payroll_year, '%Y') 
FROM czechia_payroll AS cp 
GROUP BY payroll_year
INTERSECT
SELECT 
str_to_date(date_from, '%Y')
FROM czechia_price AS cp
GROUP BY date_from ;

/* Pro data mezd a cen potravin za Českou republiku sjednocených na totožné porovnatelné období – společné roky.
 * Tedy průměrné mzdy a ceny potravin v jednotlivých letech 2006 až 2018
 */

CREATE OR REPLACE TABLE t_marek_borč_project_SQL_primary_final
SELECT
	cpc.name AS product,
	cp.value AS price,
	DATE_FORMAT(cp.date_from, '%Y-%m-%d') AS price_measured_from,
    DATE_FORMAT(cp.date_to, '%Y-%m-%d') AS price_measured_to,
	cpib.name AS industry,
	cpay.value AS payroll,
	cpay.payroll_year
FROM czechia_price AS cp 
JOIN czechia_payroll AS cpay 
	ON cpay.payroll_year = YEAR(cp.date_from)
	AND cpay.payroll_year BETWEEN 2006 AND 2018
	AND cpay.value_type_code = 5958
JOIN czechia_price_category AS cpc 
	ON cp.category_code = cpc.code 
LEFT JOIN czechia_payroll_industry_branch AS cpib 
	ON cpay.industry_branch_code = cpib.code 
;

/*
 * CREATE TABLE trvá deset minut bez ohledu sekvenci. Zřejmě normální při množství dat?
 */

-- Pomocné dotazy --
SELECT * FROM czechia_payroll AS cp 
WHERE value_type_code = 5958 AND value IS NULL;

/* Dodatečný materiál připravte i tabulku s HDP, GINI koeficientem 
 * a populací dalších evropských států ve stejném období, jako primární přehled pro ČR.
 * Economies obsahuje kombinaci států a regionů - nutná shoda jmen mezi countries a economies
 */

CREATE OR REPLACE TABLE t_marek_borč_project_SQL_secondary_final
AS SELECT 
	c.country,
	e.YEAR,
	e.population,
	e.GDP,
	e.gini	
FROM countries AS c
LEFT JOIN economies AS e ON c.country = e.country
WHERE YEAR >= 2006 AND YEAR <=2018 AND c.continent = 'Europe'
;

