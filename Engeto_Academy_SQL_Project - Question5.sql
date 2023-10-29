/* Výzkumná otázka: * 
 * 4) Má výška HDP vliv na změny ve mzdách a cenách potravin? 
Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem? */

-- Skrze nahrubo naroubovanou Spearmanovu korelaci přes multiple CTE vycházející z předchozích otázek??? (MariaDB korelace neumí) --

WITH spearman_d AS (
	WITH rolling_GDP_wage_price_percentual AS (
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
			round((GDP - GDP_prev_year) / GDP_prev_year*100, 2) AS YoY_GDP_growth_percentual,
			round((avg_wage - avg_wage_prev_year) / avg_wage_prev_year*100, 2) AS YoY_wage_growth_percentual,
			round((avg_price - avg_price_prev_year) / avg_price_prev_year*100, 2) AS YoY_price_growth_percentual
		FROM rolling_GDP_wage_price
	)
	SELECT
		payroll_year,
		YoY_GDP_growth_percentual,
		ROW_NUMBER () OVER (ORDER BY YoY_GDP_growth_percentual) AS GDP_rank,
		YoY_wage_growth_percentual,
		ROW_NUMBER () OVER (ORDER BY YoY_wage_growth_percentual) AS wage_rank,
		ROW_NUMBER () OVER (ORDER BY YoY_GDP_growth_percentual) - ROW_NUMBER () OVER (ORDER BY YoY_wage_growth_percentual) AS d_wage,
		pow((ROW_NUMBER () OVER (ORDER BY YoY_GDP_growth_percentual) - ROW_NUMBER () OVER (ORDER BY YoY_wage_growth_percentual)), 2) AS d_wage_squared,
		YoY_price_growth_percentual,
		ROW_NUMBER () OVER (ORDER BY YoY_price_growth_percentual) AS price_rank,
		ROW_NUMBER () OVER (ORDER BY YoY_GDP_growth_percentual) - ROW_NUMBER () OVER (ORDER BY YoY_price_growth_percentual) AS d_price,
		pow((ROW_NUMBER () OVER (ORDER BY YoY_GDP_growth_percentual) - ROW_NUMBER () OVER (ORDER BY YoY_price_growth_percentual)), 2) AS d_price_squared
	FROM rolling_GDP_wage_price_percentual
	WHERE YoY_GDP_growth_percentual IS NOT null
	ORDER BY payroll_year
	)
SELECT
	round(1-((6*sum(d_wage_squared)) / (12*(pow(12, 2)-1))), 5) AS GDP_wages_Spearman,
	round(1-((6*sum(d_price_squared)) / (12*(pow(12, 2)-1))), 5) AS GDP_prices_Spearman
FROM spearman_d
;

/* r(s) pro vztah HDP a mzdy = 0.48252, což značí slabou až střední pozitivní korelaci. p-hodnota není dostupná.
 * r(s) pro vztah HDP a cen = 0.28671, což značí slabou pozitivní korelaci. p-hodnota není dostupná.
 */