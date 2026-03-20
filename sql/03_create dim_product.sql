-- DimProduct
-- LEFT JOINs used because products without a subcategory (e.g. raw components) exist in source.
CREATE OR REPLACE VIEW bi.dim_product AS
SELECT 
    pdt.productid AS product_key,
    pdt.productnumber,
    pdt.name AS product_name,
    pdt.color, 
    pdt.size, 
    pdt.productline, 
    pdt.class, 
    pdt.style,
    pdt.listprice,
    pdt.standardcost,
    pdt.makeflag,
    pdt.productsubcategoryid,
    COALESCE(subcat.name, 'Unassigned') AS subcategory_name, -- NULL when product has no subcategory assigned in source
    subcat.productcategoryid,
    COALESCE(cat.name, 'Uncategorized') AS category_name -- NULL cascades from subcategory being NULL (unreachable)
FROM production.product pdt
LEFT JOIN production.productsubcategory subcat
    ON subcat.productsubcategoryid = pdt.productsubcategoryid
LEFT JOIN production.productcategory cat
    ON cat.productcategoryid = subcat.productcategoryid;