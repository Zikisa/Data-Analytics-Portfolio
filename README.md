# Cloud Infrastructure Performance & Cost Optimization
**Modern Data Stack Project: Data Centre Operator to Analytics Engineering**

## Project Overview
This project simulates a production-grade Analytics Engineering pipeline designed to solve a classic enterprise problem: cloud waste. Leveraging my background in **System Administration**, I built an end-to-end data pipeline that ingests raw server performance infrastructure logs, transforms them into dimensional models, and surface actionable insights to eliminate underutilized infrastructure ("zombie servers").

The goal of this project is to provide executive and engineering teams with continuous visibility into system performance metrics mapped directly to financial cloud expenditures.

---

## The Business Challenge
A fast-growing enterprise lacks granular visibility into its multi-department cloud infrastructure spend. Infrastructure metrics and cloud billing records are trapped in disparate silos, preventing leadership from answering key questions:
* Which departments are over-provisioning servers?
* How much capital is being wasted on unutilized or idling computing power?
* Where can we immediately downsize infrastructure to reduce monthly overhead?

---

## Tech Stack & Architecture
* **Ingestion:** Python (Pandas & NumPy data simulation engine)
* **Data Warehouse:** Google BigQuery (Cloud storage and computation)
* **Data Transformation:** dbt Cloud (Data modeling, modularity, and software engineering practices)
* **Languages:** SQL (BigQuery Dialect), Python 3.11
* **BI & Visualization:** Tableau

---

## Data Pipeline Architecture

```text
[ Raw CSV Files ] ──(Python Ingestion)──> [ Google BigQuery (Raw Schema) ]
                                                       │
                                            (dbt Staging Views)
                                                       │
                                            (dbt Core Fact Tables)
                                                       │
                                                       ▼
[ BI Dashboard ] <──────────────────────── [ BigQuery (Analytics Marts) ]
```

---

## Repository Structure
```text
├── data_generation/
│   └── generate_infra_logs.py      # Python script generating 30 days of hourly server metrics
├── dbt_project/
│   ├── dbt_project.yml             # Global dbt configuration
│   └── models/
│       ├── schema.yml              # Source and documentation configurations
│       ├── staging/
│       │   ├── stg_servers.sql     # Cleans and casts raw server dimensions
│       │   └── stg_hourly_logs.sql # Casts types and metrics for hourly telemetry logs
│       └── marts/
│           └── fct_infrastructure_efficiency.sql  # Core logic identifying "zombie" servers
├── dashboards/
|    ├── infra_optimization.png     # Completed BI dashboard file
└── images
    └── dbt_model.png               # Completed dbt model

```

---

## Core Analytics Engineering Logic (dbt Layer)

The foundational business logic separates servers into distinct efficiency statuses. A server is systematically classified as a **"Zombie Server"** if its average daily CPU utilization falls below 5%. This metric explicitly captures financial bleeding on idling infrastructure.

Here is a snippet of the transformational logic inside `fct_infrastructure_efficiency.sql`:

```sql
SELECT
    al.log_date,
    al.server_id,
    s.server_name,
    s.department_name,
    s.operating_system,
    al.avg_daily_cpu,
    al.avg_daily_ram,
    al.total_daily_cost,
    -- Business logic to identify wasted resources
    CASE 
        WHEN al.avg_daily_cpu < 5.0 THEN 'Zombie Server (Underutilized)'
        WHEN al.avg_daily_cpu > 85.0 THEN 'Overloaded Over-provision'
        ELSE 'Optimized'
    END AS efficiency_status,
    -- Calculate explicit capital wasted
    CASE 
        WHEN al.avg_daily_cpu < 5.0 THEN al.total_daily_cost
        ELSE 0.0
    END AS wasted_spend_usd
FROM aggregated_logs al
LEFT JOIN servers s ON al.server_id = s.server_id
```

---

## Key Data & Business Insights
By implementing this modern data stack configuration, the pipeline isolates the following critical inefficiencies:
1. **Total Wasted Capital Identified:** Successfully isolated systematic "zombie" infrastructure accounts, identifying an immediate potential cost reduction of **15% of monthly spend**.
2. **Department Breakdown:** The data layer surfaces exactly which business units (e.g., *Marketing-App* vs *Data-Team*) are deploying oversized computing environments relative to their operational loads.
3. **Capacity Management:** Identified seasonal and business-hour compute spikes to transition fixed infrastructure toward dynamic automated scaling schedules.

---

## How to Run This Project Locally

### 1. Requirements
* Python 3.x
* A free Google Cloud Sandbox Account (BigQuery)
* A free dbt Cloud account

### 2. Generate the Source Data
Navigate to the data folder and run the simulation engine to generate the source log data files:
```bash
python data_generation/generate_infra_logs.py
```

### 3. Execution via dbt Cloud
Connect your dbt instance to your BigQuery project and run the complete analytical model graph:
```bash
dbt run
```
```bash
dbt test
```

---
---

## Project 2: E-Commerce Sales & Customer Insights Pipeline
 **Modern Data Stack Project: Multi-Source Dimensional Modeling**

### Project Overview
This project simulates an enterprise-grade commercial analytics pipeline for a fast-growing South African e-commerce store. The goal was to break down silos between customer profiles, product catalogs, and transactional order ledgers to surface core business growth metrics like Gross vs. Net Revenue and Customer Lifetime Value (CLV).

### Tech Stack & Architecture
* **Ingestion:** Python (Pandas transactional simulation data layer)
* **Data Warehouse:** Google BigQuery (US Multi-Region storage)
* **Data Transformation:** dbt Cloud (Dimensional modeling, table materialization, and modular architectures)
* **BI & Visualization:** Tableau Public

### Analytics Engineering Logic (dbt Layer)
This pipeline isolates successful transactional values from returns and cancellations to calculate accurate operational metrics. Here is a snippet from `fct_ecommerce_sales.sql`:

```sql
SELECT
    o.order_id,
    o.order_timestamp,
    DATE(o.order_timestamp) as order_date,
    o.customer_id,
    c.region as customer_region,
    p.product_category,
    -- Financial Modeling Engine
    (o.quantity * p.unit_price_zar) as gross_revenue_zar,
    CASE 
        WHEN o.order_status = 'Completed' THEN (o.quantity * p.unit_price_zar)
        ELSE 0.0
    END as net_revenue_zar
FROM orders o
LEFT JOIN products p ON o.product_id = p.product_id
LEFT JOIN customers c ON o.customer_id = c.customer_id
```

### Key Business Insights Surfaced
1. **Financial Precision:** Built a robust data modeling separation that filters out cancelled and returned orders, giving executives absolute visibility into true **Net Revenue** versus top-line sales figures.
2. **Provincial Demographics:** Visualized spending concentrations across South African provinces to optimize targeted marketing budgets for high-performing nodes (e.g., Gauteng and Western Cape).
3. **Product Growth:** Isolated product categories driving the highest transactional volume to guide warehouse inventory turnover tracking.

---
*Connect with me on **www.linkedin/in/zikisakwinana** to discuss how I can bring this unique combination of infrastructure management and analytics engineering into your data team.*
