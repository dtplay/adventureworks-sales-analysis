-- DimSalesPerson
-- INNER JOINs are safe: every salesperson has a linked employee and person record in source.
-- TRIM + COALESCE handles NULLs in name parts (middlename is nullable in source).
-- Surrogate key=0 'Unassigned' row added for orders where salespersonid is NULL in fact.

CREATE OR REPLACE VIEW bi.dim_salesperson AS
SELECT 
    sp.businessentityid AS salesperson_key,
    TRIM(
          COALESCE(p.firstname || ' ', '')  -- empty string if firstname null 
          || COALESCE(p.middlename || ' ', '')  -- empty string if middlename null 
          || COALESCE(p.lastname, '') -- empty string is lastname null
         ) AS salesperson_name,
    sp.territoryid AS current_territory_key,
    sp.salesquota,
    sp.bonus,
    sp.commissionpct,
    sp.salesytd,
    sp.saleslastyear
FROM sales.salesperson sp
INNER JOIN humanresources.employee hr
    ON hr.businessentityid = sp.businessentityid
INNER JOIN person.person p
    ON p.businessentityid  = hr.businessentityid

-- Surrogate key=0 member: maps to fact rows where salespersonid IS NULL
UNION ALL

SELECT
  0, 'Unassigned', 0, 0, 0, 0, 0, 0;