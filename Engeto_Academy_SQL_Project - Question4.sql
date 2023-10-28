/* Výzkumná otázka:
4) Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
Pozn.: Průměrné procentuální meziroční změny mezi všemi obory dohromady a potravinami dohromady.
	   Nelze jen zprůměrovat procentuální změny z finálních pohledů z otázek 1 a 3, neboť průměr != průměr z průměrů.
Pozn2.: Nejedná se o skutečnou průměrnou mzdu, neboť neznáme počet zaměstnaných v jednotlivých oborech.
*/

-- Prostřednictvím funkce LAG s využitím pohledů z Q 1 a 3. --

SELECT 
	vas.payroll_year,
	round(avg(vas.avg_wage), 2) AS avg_wage,
	round(lag(avg(vas.avg_wage)) OVER (ORDER BY vas.payroll_year), 2) AS avg_wage_prev_year,
	round(avg(vas.avg_wage) - lag(avg(vas.avg_wage)) OVER (ORDER BY vas.payroll_year), 2) AS YoY_wage_growth,
	round((avg(vas.avg_wage) - lag(avg(vas.avg_wage)) OVER (ORDER BY vas.payroll_year)) / (lag(avg(vas.avg_wage)) OVER (ORDER BY vas.payroll_year))*100, 2) AS YoY_wage_growth_percentual,
	round(avg(vap.avg_price), 2) AS avg_price,
	round(lag(avg(vap.avg_price)) OVER (ORDER BY vas.payroll_year), 2) AS avg_price_prev_year,
	round(avg(vap.avg_price), 2) - round(lag(avg(vap.avg_price)) OVER (ORDER BY vas.payroll_year), 2) AS YoY_price_growth,
	round((avg(vap.avg_price) - lag(avg(vap.avg_price)) OVER (ORDER BY vas.payroll_year)) / (lag(avg(vap.avg_price)) OVER (ORDER BY vas.payroll_year))*100, 2) AS YoY_price_growth_percentual,
	round((avg(vap.avg_price) - lag(avg(vap.avg_price)) OVER (ORDER BY vas.payroll_year)) / (lag(avg(vap.avg_price)) OVER (ORDER BY vas.payroll_year))*100, 2) - round((avg(vas.avg_wage) - lag(avg(vas.avg_wage)) OVER (ORDER BY vas.payroll_year)) / (lag(avg(vas.avg_wage)) OVER (ORDER BY vas.payroll_year))*100, 2) AS YoY_price_wage_difference_perc
FROM v_average_sector_wage_by_year AS vas
JOIN v_average_product_price_by_year AS vap 
ON vap.payroll_year = vas.payroll_year
GROUP BY vas.payroll_year;

/* Odpověď: Neexistuje žádný rok, ve kterém by byl meziroční růst cen potravin o deset procentních bodů vyšší než meziroční růst mezd.
Nejvyšší rozdíl (6,59 procentního bodu) byl zaznamenán v roce 2013.
*/

-- "Přehlednější" výpočty přes CTE, mírné odchylky v zaokrouhlených hodnotách --

WITH rolling_wages_and_price as (
	SELECT 
	vas.payroll_year,
	round(avg(vas.avg_wage), 2) AS avg_wage,
	round(lag(avg(vas.avg_wage)) OVER (ORDER BY vas.payroll_year), 2) AS avg_wage_prev_year,
	round(avg(vap.avg_price), 2) AS avg_price,
	round(lag(avg(vap.avg_price)) OVER (ORDER BY vas.payroll_year), 2) AS avg_price_prev_year
FROM v_average_sector_wage_by_year AS vas
JOIN v_average_product_price_by_year AS vap 
ON vap.payroll_year = vas.payroll_year
GROUP BY vas.payroll_year
)
SELECT
	payroll_year,
	avg_wage,
	avg_wage_prev_year,
	avg_wage - avg_wage_prev_year AS YoY_wage_growth,
	round((avg_wage - avg_wage_prev_year) / avg_wage_prev_year*100, 2) AS YoY_wage_growth_percentual,
	avg_price,
	avg_price_prev_year,
	avg_price - avg_price_prev_year AS YoY_price_growth,
	round((avg_price - avg_price_prev_year) / avg_price_prev_year*100, 2) AS YoY_price_growth_percentual,
	round((avg_price - avg_price_prev_year) / avg_price_prev_year*100,2) - round((avg_wage - avg_wage_prev_year) / avg_wage_prev_year*100, 2) AS YoY_price_wage_difference_perc
FROM rolling_wages_and_price;
	
