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

-- Ceny v czechia_payroll od prvního kvartálu 2000 do druhého kvartálu 2021 --
-- Prolíná se období leden 2006 - prosinec 2018 --