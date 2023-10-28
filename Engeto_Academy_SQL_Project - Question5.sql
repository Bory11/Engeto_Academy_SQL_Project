/* Výzkumná otázka: * 
 * 4) Má výška HDP vliv na změny ve mzdách a cenách potravin? 
Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem? */


WITH rolling_GDP_wage_price AS (	
		SELECT
			tm1.payroll_year AS payroll_year,
			tm2.GDP AS GDP,
			round(lag(tm2.GDP) OVER (ORDER BY tm1.payroll_year), 2) AS GDP_prev_year,
			round(avg(tm1.payroll), 2) AS avg_wage,
			round(lag(avg(tm1.payroll)) OVER (ORDER BY tm1.payroll_year), 2) AS avg_wage_prev_year,
			round(avg(tm1.price), 2) AS avg_price,
			round(lag(avg(tm1.price)) OVER (ORDER BY tm1.payroll_year), 2) AS avg_price_prev_year
		FROM t_marek_borč_project_sql_primary_final AS tm1
		JOIN t_marek_borč_project_sql_secondary_final AS tm2 ON tm2.YEAR = tm1.payroll_year
		WHERE tm2.country = 'Czech Republic'
		GROUP BY tm1.payroll_year
	)
SELECT
	payroll_year,
	round((GDP - GDP_prev_year) / GDP_prev_year*100, 2) AS YoY_GDP_difference_percentual,
	round((avg_wage - avg_wage_prev_year) / avg_wage_prev_year*100, 2) AS YoY_wage_difference_percentual,
	round((avg_price - avg_price_prev_year) / avg_price_prev_year*100, 2) AS YoY_price_difference_percentual
FROM rolling_GDP_wage_price;
