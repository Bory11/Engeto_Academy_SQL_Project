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