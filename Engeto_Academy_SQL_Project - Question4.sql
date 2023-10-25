/* Výzkumná otázka:
4) Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
Pozn.: Průměrné procentuální meziroční změny mezi všemi obory dohromady a potravinami dohromady.
	   Nelze jen zprůměrovat procentuální změny z finálních pohledů z otázek 1 a 3, neboť průměr != průměr z průměrů.
Pozn2.: Nejedná se o skutečnou průměrnou mzdu, neboť neznáme počet zaměstnaných v jednotlivých oborech.
*/

-- pomocné pohledy pro využití fce LAG --

CREATE OR REPLACE VIEW v_help_wages
AS SELECT 
	round(avg(avg_wage), 2) AS avg_wage,	
	payroll_year
FROM v_average_sector_wage_by_year AS vaswby 
GROUP BY payroll_year;

CREATE OR REPLACE VIEW v_help_prices
AS SELECT
	round(avg(avg_price), 2) AS avg_price,
	payroll_year
FROM v_average_product_price_by_year AS vappby 
GROUP BY payroll_year;

SELECT 
	vhw.payroll_year,
	vhw.avg_wage,
	lag(vhw.avg_wage) OVER (ORDER BY vhw.payroll_year) AS avg_wage_prev_year,
	vhw.avg_wage - lag(vhw.avg_wage) OVER (ORDER BY vhw.payroll_year) AS YoY_wage_difference,
	round((vhw.avg_wage - lag(vhw.avg_wage) OVER (ORDER BY vhw.payroll_year)) / (lag(vhw.avg_wage) OVER (ORDER BY vhw.payroll_year))*100, 2) AS YoY_wage_difference_percentual,
	vhp.avg_price,
	lag(vhp.avg_price) OVER (ORDER BY vhw.payroll_year) AS avg_price_prev_year,
	vhp.avg_price - lag(vhp.avg_price) OVER (ORDER BY vhw.payroll_year) AS YoY_price_difference,
	round((vhp.avg_price - lag(vhp.avg_price) OVER (ORDER BY vhw.payroll_year)) / (lag(vhp.avg_price) OVER (ORDER BY vhw.payroll_year))*100, 2) AS YoY_price_difference_percentual,
	round((vhp.avg_price - lag(vhp.avg_price) OVER (ORDER BY vhw.payroll_year)) / (lag(vhp.avg_price) OVER (ORDER BY vhw.payroll_year))*100, 2) - round((vhw.avg_wage - lag(vhw.avg_wage) OVER (ORDER BY vhw.payroll_year)) / (lag(vhw.avg_wage) OVER (ORDER BY vhw.payroll_year))*100, 2) AS YoY_price_wage_difference_perc
FROM v_help_wages AS vhw
JOIN v_help_prices AS vhp 
ON vhp.payroll_year = vhw.payroll_year ;

/* Odpověď: Neexistuje žádný rok, ve kterém by byl meziroční růst cen potravin o deset procentních bodů vyšší než meziroční růst mezd.
Nejvyšší rozdíl (6,59 procentního bodu) byl zaznamenán v roce 2013.
*/