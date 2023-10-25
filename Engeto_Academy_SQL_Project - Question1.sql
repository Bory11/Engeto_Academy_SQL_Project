/* Výzkumná otázka:
 * 1) Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
  */
-- a) View průměrných mezd v odvětvích během let --

CREATE OR REPLACE VIEW v_average_sector_wage_by_year 
AS SELECT 
	round(avg(payroll)) AS avg_wage,	
	payroll_year,
	industry
FROM t_marek_borč_project_sql_primary_final
GROUP BY industry, payroll_year
;

-- b) View meziročních srovnání v rámci odvětví --

CREATE OR REPLACE VIEW v_interannual_changes
AS SELECT
	prevyear.industry,
	prevyear.payroll_year AS previous_year,
	prevyear.avg_wage AS previous_year_wage,
	nxtyear.payroll_year AS next_year,
	nxtyear.avg_wage AS next_year_wage,
	(nxtyear.avg_wage - prevyear.avg_wage) AS YoY,
	round(((nxtyear.avg_wage - prevyear.avg_wage)/prevyear.avg_wage*100), 2) AS 'YoY_percentage',
	CASE 
		WHEN nxtyear.avg_wage > prevyear.avg_wage > 0 THEN 'Growth'
		WHEN nxtyear.avg_wage = prevyear.avg_wage THEN 'No change'
		ELSE 'Decline'
	END AS 'YoY_status'
FROM v_average_sector_wage_by_year AS prevyear
JOIN v_average_sector_wage_by_year AS nxtyear
	ON nxtyear.payroll_year = prevyear.payroll_year + 1
	-- jednoroční posun --
	AND prevyear.industry = nxtyear.industry
	-- podmínka pro smysluplné kombinace --
	;

-- alternativně přes LAG místo SELF JOIN, zhruba dvakrát rychlejší --

CREATE OR REPLACE VIEW v_interannual_changes_alt
AS SELECT 
	industry,
	payroll_year,
	avg_wage,
	LAG(avg_wage) OVER (PARTITION BY industry ORDER BY payroll_year) AS avg_wage_previous_year,
	avg_wage - LAG(avg_wage) OVER (PARTITION BY industry ORDER BY payroll_year) AS YoY_difference,
	round((avg_wage - LAG(avg_wage) OVER (PARTITION BY industry ORDER BY payroll_year)) / (LAG(avg_wage) OVER (PARTITION BY industry ORDER BY payroll_year))*100, 2) AS YoY_difference_percentual,
	CASE 
		WHEN avg_wage > LAG(avg_wage) OVER (PARTITION BY industry ORDER BY payroll_year) > 0 THEN 'Growth'
		WHEN avg_wage = LAG(avg_wage) OVER (PARTITION BY industry ORDER BY payroll_year) THEN 'No change'
		ELSE 'Decline'
	END AS 'YoY_status'
FROM v_average_sector_wage_by_year AS vaswby
;

-- Selecty pro zodpovězení otázky, z v_interannual_changes --

SELECT 
	industry,
	CASE WHEN next_year_wage > previous_year_wage THEN TRUE
	ELSE FALSE
	END AS 'growth'
FROM v_interannual_changes AS vic
GROUP BY industry ;

SELECT 
	YoY_status AS YoY_within_industry,
	count(YoY_status) AS 'count'
FROM v_interannual_changes AS vic 
GROUP BY YoY_status
ORDER BY YoY_status desc;

SELECT 
	industry,
	YoY_status AS YoY_within_industry,
	count(YoY_status) AS 'count'
FROM v_interannual_changes AS vic 
GROUP BY industry, YoY_status
ORDER BY industry asc, YoY_status desc;

/* V průběhu celého období rostly mzdy ve všech odvětvích.
   Mzdy meziročně rostly v rámci průmyslových odvětví v 205 z 228 instancí. 
   Mzdy meziročně vždy rostly v rámci tří odvětví - Doprava a skladování, Ostatní činnosti a Zdravotní a sociální péče. 
   Nejvícekrát - 4x - poklesly meziročně mzdy v rámci odvětví Těžba a dobývání. */