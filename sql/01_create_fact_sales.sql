-- Create a BI schema to store export-friendly views/tables
CREATE SCHEMA IF NOT EXISTS bi;

-- Recreate view that computes LineTotal in sales.salesorderdetail (not ported into Postgresql)
DROP VIEW IF EXISTS sales.v_salesorderdetail;

CREATE OR REPLACE VIEW sales.v_salesorderdetail AS
    SELECT sod.*,
           sod.unitprice * (1 - sod.unitpricediscount) * sod.orderqty AS linetotal
    FROM sales.salesorderdetail sod;

-- Fact view at SalesOrderDetail grain (one row per order line)
CREATE OR REPLACE VIEW bi.fact_salesorder AS
SELECT 
    ROW_NUMBER() OVER(ORDER BY soh.salesorderid, sod.salesorderid) AS fact_key,
    sod.salesorderid,
    sod.salesorderdetailid,
    soh.customerid                                   AS customer_key,
    sod.productid                                    AS product_key,
    COALESCE(soh.salespersonid, 0)                   AS salesperson_key,
    soh.territoryid                                  AS order_territory_key,
    COALESCE(TO_CHAR(orderdate, 'YYYYMMDD')::INT, 0) AS order_date_key,
    soh.onlineorderflag,
    sod.orderqty,
    sod.unitprice,
    sod.unitpricediscount,
    sod.linetotal,
    soh.orderdate,
    soh.shipdate,
    soh.duedate
FROM sales.v_salesorderdetail sod
INNER JOIN sales.salesorderheader soh
    ON soh.salesorderid = sod.salesorderid;