# AdventureWorks Sales Dashboard — PostgreSQL → Power BI

Transforms AdventureWorks sales data (PostgreSQL port) into a star schema and delivers a 4-page Power BI dashboard covering $109.85M in sales across 31K orders from 2011–2014.

**Tools:** PostgreSQL • SQL • Power BI

>✨ **Live Interactive Report:** [Interact with the Power BI dashboard here](https://dtplay.github.io/adventureworks-sales-analysis/) 🔗 (Right-click to open in a new tab)

## Business Questions Answered

- Which product **categories and subcategories** generate the most revenue?
- How do **monthly sales, units sold, and average order value** trend over time?
- Which **salesperson** drives the highest revenue, and how does discount behaviour vary across reps?
- Which **countries and territories** (North America, Europe, Pacific) contribute most to total sales?

## Methodology & Project Structure

SQL `CREATE VIEW` statements extract and denormalise OLTP tables from PostgreSQL into flat, export-ready CSVs that form the star schema. These are loaded into Power BI where relationships are defined between the central fact table and surrounding dimension tables. DAX measures are built for KPIs such as total revenue, order count, and month-over-month growth.

## Repository Structure

- `sql/`
  - `01_create_fact_sales.sql`
  - `02_create_dim_date.sql`
  - `03_create_dim_product.sql`
  - `04_create_dim_sales_territory.sql`
  - `05_create_dim_salesperson.sql`
- `exports/` – star schema CSVs loaded into Power BI
- `powerbi/`
  - `adventureworks.pbix` – star schema model + DAX measures
  - `adventureworks.pdf` – 4-page dashboard export

If you mainly care about the results, open the **[Live Interactive Dashboard](https://dtplay.github.io/adventureworks-sales-analysis/)** 🔗 (Right-click to open in a new tab), or view `powerbi/adventureworks.pdf` for a static overview.

**Database setup not included.** Uses AdventureWorks PostgreSQL port by [NorfolkDataSci](https://github.com/NorfolkDataSci/adventure-works-postgres). Follow their instructions first.

## Star Schema

| Table                 | Type      | Key columns                                                                                                        |
| --------------------- | --------- | ------------------------------------------------------------------------------------------------------------------ |
| `fact_salesorder`     | Fact      | `order_date_key`, `customer_key`, `product_key`, `salesperson_key`, `order_territory_key`, `linetotal`, `orderqty` |
| `dim_date`            | Dimension | `date_key` (YYYYMMDD), year, quarter, month, ISO week, `is_weekend`                                                |
| `dim_product`         | Dimension | `product_key`, product name, category, subcategory, list price, standard cost                                      |
| `dim_salesperson`     | Dimension | `salesperson_key`, salesperson name, territory, quota, commission %, YTD sales                                     |
| `dim_sales_territory` | Dimension | `territory_key`, country, territory group (North America / Europe / Pacific)                                       |

`fact_salesorder` is at **sales order detail grain** — one row per order line.

**Surrogate key 0**: Maps NULLs to "Unassigned" members. INNER JOINs work cleanly + data quality visible as named buckets.

## Key Findings

- **Bikes** dominate at ~$95M (87%) of total revenue; **Components** ~$12M
- **Linda Mitchell** ($10.4M) and **Jillian Carson** ($10.1M) lead sales; Syed Abbas highest discount (3.24%)
- **United States** $63M; Canada $16M; Australia $11M
- **Mountain-200 Black, 38** top product ($4.4M revenue, 15.3% margin)

## How to Run the Project

1. **Load source DB**: Clone NorfolkDataSci repo for AdventureWorks
2. **Build star schema**: Run SQL files in numbered order → export CSVs to `exports/`
3. **Power BI**: Open `powerbi/adventureworks.pbix` → refresh data sources
