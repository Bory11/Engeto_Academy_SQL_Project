/* Výzkumná otázka:
   2) Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
*/

SELECT
	product,
	round(avg(price * price_value), 2) AS 'avg_yearly_product_price',
	payroll_year AS 'year',
	industry,
	round(avg(payroll), 2) AS avg_monthly_payroll_in_a_year,
	round(avg(payroll) / avg(price * price_value)) AS 'product_amount_per_payroll'
FROM t_marek_borč_project_sql_primary_final AS tmbpspf
WHERE (payroll_year = 2006 OR payroll_year = 2018) AND (product = 'Mléko polotučné pasterované' OR product = 'Chléb konzumní kmínový')
GROUP BY product, industry, payroll_year
ORDER BY product, YEAR asc, product_amount_per_payroll desc
;

/* V roce 2006 bylo možné si za průměrnou mzdu v rámci jednotlivých odvětví koupit za průměrnou cenu produktů mezi 2 462 a 706 kilogramy chleba (průměrná cena 16,12 Kč)
  a mezi 2 749 a 789 litry mléka (průměrná cena 14,44 Kč). Nejvíce chleba si mohl dovolit obor Peněžnictví a pojišťovnictví, nejméně pak obor Ubytování, stravování a pohostinství.
   V roce 2018 bylo možné si za průměrnou mzdu v rámci jednotlivých odvětví koupit za průměrnou cenu produktů mezi 2 315 a 774 kilogramy chleba (průměrná cena 24,44 Kč)
  a mezi 2 831 a 947 litry mléka (průměrná cena 19,82 Kč). Nejvíce mléka si mohl dovolit obor Informační a komunikační činnosti, nejméně pak obor Ubytování, stravování a pohostinství.
*/