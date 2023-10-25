/* Výzkumná otázka:
3) Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
(de facto stejný princip jako u otázky 1)
*/

CREATE OR REPLACE VIEW v_average_product_price_by_year
AS SELECT 
	product,
	round(avg(price), 2) AS avg_price,
	payroll_year
FROM t_marek_borč_project_sql_primary_final AS tmbpspf 
GROUP BY product, payroll_year;

CREATE OR REPLACE VIEW v_interannual_changes_products
AS SELECT
	prevyear.product,
	prevyear.payroll_year AS previous_year,
	prevyear.avg_price AS previous_year_price,
	nxtyear.payroll_year AS next_year,
	nxtyear.avg_price AS next_year_price,
	(nxtyear.avg_price - prevyear.avg_price) AS YoY,
	round(((nxtyear.avg_price - prevyear.avg_price)/prevyear.avg_price*100), 2) AS 'YoY_percentage',
	CASE 
		WHEN nxtyear.avg_price > prevyear.avg_price > 0 THEN 'Growth'
		WHEN nxtyear.avg_price = prevyear.avg_price THEN 'No change'
		ELSE 'Decline'
	END AS 'YoY_status'
FROM v_average_product_price_by_year AS prevyear
JOIN v_average_product_price_by_year AS nxtyear
	ON nxtyear.payroll_year = prevyear.payroll_year + 1
	-- jednoroční posun --
	AND prevyear.product = nxtyear.product
	-- podmínka pro smysluplné kombinace --
	;
	
SELECT 
	product,
	round(sum(percentage), 2) AS cumulative_percentual_growth,
	round(avg(percentage), 2) AS average_percentual_growth
FROM v_interannual_changes_products AS vicp
GROUP BY product
ORDER BY cumulative_percentual_growth ASC;

/* 
 * Cukr krystalový je komoditou, která meziročně zdražovala nejméně - naopak dokonce zlevňovala a to v průměru o 1,92 procenta ročně.
*/