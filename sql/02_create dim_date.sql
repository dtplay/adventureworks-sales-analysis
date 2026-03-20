-- DimDate
-- Note: iso_week_num and iso_year_num follow ISO-8601 (weeks run Mon–Sun).
-- Always pair iso_year_num with iso_week_num when grouping by week, as
-- Week 1 is the week containing the first Thursday — meaning early Jan dates
-- can belong to the previous ISO year.

DROP TABLE IF EXISTS bi.dim_date;

CREATE TABLE bi.dim_date (
    date_key INT PRIMARY KEY, --YYYYMMDD
    full_date DATE UNIQUE,
    year_num SMALLINT NOT NULL,
    quarter_num SMALLINT NOT NULL,
    month_num SMALLINT NOT NULL,
    month_name TEXT NOT NULL,
    day_of_month SMALLINT NOT NULL,
    iso_day_of_week SMALLINT NOT NULL, -- 1=Mon ... 7=Sun
    day_name TEXT NOT NULL,
    iso_week_num SMALLINT NOT NULL,
    iso_year_num SMALLINT NOT NULL,
    is_weekend BOOLEAN NOT NULL,
    first_day_month DATE NOT NULL,
    last_day_month DATE NOT NULL
);

-- Populate DimDate using generated series from specified range 
INSERT INTO bi.dim_date(
  date_key, full_date,
  year_num, quarter_num, month_num, month_name,
  day_of_month, iso_day_of_week, day_name,
  iso_week_num, iso_year_num,
  is_weekend, first_day_month, last_day_month
    )
SELECT
    TO_CHAR(d, 'YYYYMMDD')::INT     AS date_key, 
    d::DATE                         AS full_date,
    EXTRACT(YEAR FROM d)::INT       AS year_num, 
    EXTRACT(QUARTER FROM d)::INT    AS quarter_num, 
    EXTRACT(MONTH FROM d)::INT      AS month_num, 
    TO_CHAR(d, 'FMMonth')           AS month_name,
    EXTRACT(DAY FROM d)::INT        AS day_of_month, 
    EXTRACT(ISODOW FROM d)::INT     AS iso_day_of_week, -- 1=Mon ... 7=Sun
    TO_CHAR(d, 'FMDay')             AS day_name,
    EXTRACT(WEEK FROM d)::INT       AS iso_week_num, -- ISO-8601 week number
    EXTRACT(ISOYEAR FROM d)::INT    AS iso_year_num,
    (EXTRACT(ISODOW FROM d)::INT IN (6, 7)) AS is_weekend, 
    DATE_TRUNC('month', d)::DATE    AS first_day_month,
    (DATE_TRUNC('month', d) + INTERVAL '1 month - 1 day')::DATE AS last_day_month    
FROM generate_series(DATE '2006-01-01', DATE '2014-12-31', INTERVAL '1 day') AS date_series(d);

-- Insert 'Unknown' member to handle Nulls or Orphaned records in Fact tables
INSERT INTO bi.dim_date (
  date_key, full_date, year_num, quarter_num, month_num, month_name,
  day_of_month, iso_day_of_week, day_name, iso_week_num, iso_year_num,
  is_weekend, first_day_month, last_day_month
)
VALUES
  (0, '1900-01-01'::DATE, 0, 0, 0, 'Unknown', 0, 0, 'Unknown', 0, 0, FALSE, '1900-01-01'::DATE, '1900-01-01'::DATE);
  
    
-- ============================================================
-- VERIFICATION QUERIES (not part of schema build)
-- ============================================================
-- Check date range across all date-bearing tables to determine
-- generate_series bounds. Run manually before regenerating dim_date.
-- Output: start_range = 2006-06-30, end_range = 2014-09-22
 
SELECT MIN(earliest_date) AS start_range, 
       MAX(latest_date) AS end_range 
FROM (
    SELECT MIN(orderdate) as earliest_date, MAX(orderdate) AS latest_date from sales.salesorderheader
    UNION ALL
    SELECT MIN(orderdate) as earliest_date, MAX(orderdate) AS latest_date from purchasing.purchaseorderheader
    UNION ALL
    SELECT MIN(hiredate) as earliest_date, MAX(hiredate) AS latest_date from humanresources.employee
) AS date_range;