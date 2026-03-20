-- DimSalesTerritory 
-- INNER JOIN on countryregion is safe: every territory has a valid countryregioncode in source.
CREATE OR REPLACE VIEW bi.dim_sales_territory AS
SELECT 
    t.territoryid AS territory_key,
    t.countryregioncode,
    c.name AS country,
    t."group" AS territory_group, -- use of quotes because group is reserved keyword
    t.name AS territory_name
FROM sales.salesterritory t
INNER JOIN person.countryregion c
    ON c.countryregioncode = t.countryregioncode;