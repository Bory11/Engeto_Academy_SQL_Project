Engeto Discord: Marek B.

# Engeto Academy SQL Project

# Struktura projektu
README.md

Engeto_Academy_SQL_Project - Table1.SQL

Engeto_Academy_SQL_Project - Table2.SQL

Engeto_Academy_SQL_Project - Question1.SQL

Engeto_Academy_SQL_Project - Question2.SQL

Engeto_Academy_SQL_Project - Question3.SQL

Engeto_Academy_SQL_Project - Question4.SQL

Engeto_Academy_SQL_Project - Question5.SQL

Odpovědí na výzkumné otázky.docx

# Zadání
Vypracovat SQL podklady pro odpovědi na zadané výzkumné otázky týkající se mezd, cen a HDP v ČR ve sledovaném období.

# Poznatky z průběhu vypracování
Tabulka 1: Původně řešená tabulka značně neefektivní kvůli zbytečnému množství redundantních dat. Následná optimalizace.

Otázka 1: Původní řešení přes SELF JOIN, následná optimalizace přes fci lag().

Otázka 4: Původní řešení přes nepřehledné výpočty přes fci lag(), následná optimalizace přes Common table expression.

Otázka 5: Experimentální snaha o výpočet Spearmanova korelačního koeficientu přes vícero CTE.

# Informace o datech
Průměrné celkové mzdy nejsou váženým v průměrem, neboť v T1 chybí hodnoty pro počty zaměstnaných v jednotlivých oborech.