# Olist Data Warehouse: Slowly Changing Dimensions (SCD) and ELT Pipeline

# Table of Contents
1. [Overview](#overview)
2. [Requirements Gathering](#requirements-gathering)
3. [Slowly Changing Dimension (SCD)](#slowly-changing-dimension-scd)
   1. [Strategy](#strategy)
4. [ELT with Python & SQL](#elt-with-python--sql)
   1. [Workflow Description](#workflow-description)
   2. [Setup and Execution](#setup-and-execution)
   3. [Code Highlights](#code-highlights)
5. [Orchestrate ELT with Luigi](#orchestrate-elt-with-luigi)
   1. [Setup Instructions](#setup-instructions)
6. [Requirements](#requirements)

---

## Overview
This project implements a Data Warehouse (DWH) for Olist, leveraging Slowly Changing Dimensions (SCD) strategies and an ELT pipeline using Python, SQL, and Luigi for orchestration.

## Requirements Gathering
Below are some of the most critical questions and answers gathered during the requirements phase:

1. **Which tables need historical tracking?**
   - **Answer:** Customers, Sellers, Orders.
2. **What SCD type should be applied for customers?**
   - **Answer:** SCD Type 2, to track changes in details like address or state.
3. **Should product information be versioned?**
   - **Answer:** No, corrections are sufficient (SCD Type 1).
4. **What attributes of sellers should be tracked?**
   - **Answer:** Seller location changes (SCD Type 2).
5. **Are order statuses subject to historical tracking?**
   - **Answer:** Yes, statuses like "approved" or "delivered" will be tracked (SCD Type 2).
6. **Is payment data immutable?**
   - **Answer:** Yes, corrections only (SCD Type 1).
7. **Do order reviews require versioning?**
   - **Answer:** No, reviews are fixed once submitted (SCD Type 1).
8. **Should order items be tracked historically?**
   - **Answer:** No, these are static once recorded (SCD Type 1).
9. **Do we need to simplify geolocation data?**
   - **Answer:** Yes, use city and state instead of raw geolocation.
10. **Should timestamps include time components?**
    - **Answer:** Only dates are needed, except for statuses.

## Slowly Changing Dimension (SCD)
### Strategy
Based on the gathered requirements, the following SCD strategies will be applied:

| Dimension Table      | SCD Type | Explanation                                                                 |
|----------------------|----------|-----------------------------------------------------------------------------|
| dim_customers        | Type 2   | Customer details change over time. Use `created_at`, `expired_at`, and `current_flag`. |
| dim_products         | Type 1   | Product attributes require corrections rather than versioning. Use `created_at` and `updated_at`. |
| dim_sellers          | Type 2   | Seller details, such as location, may change. Use `created_at`, `expired_at`, and `current_flag`. |
| dim_order_payments   | Type 1   | Payment information doesn’t need historical tracking; corrections can be applied directly. Use `created_at` and `updated_at`. |
| dim_order_reviews    | Type 1   | Reviews are fixed once submitted. Use `created_at` and `updated_at`.       |
| dim_orders           | Type 2   | Order statuses (e.g., approved, delivered) change over time. Use `created_at`, `expired_at`, and `current_flag`. |
| dim_order_items      | Type 1   | Order items remain static once recorded. Use `created_at` and `updated_at`. |

## ELT with Python & SQL
### Workflow Description
The ELT pipeline consists of three main steps:
1. **Extract:** Fetch data from the source PostgreSQL database.
2. **Transform:** Apply transformations, including SCD handling.
3. **Load:** Load transformed data into the DWH PostgreSQL database.

### Setup and Execution
1. Clone the repository (using git lfs clone).
2. Create a `.env` file with the following variables:

```env
# Source
SRC_POSTGRES_DB=olist-src
SRC_POSTGRES_HOST=localhost
SRC_POSTGRES_USER=[YOUR USERNAME]
SRC_POSTGRES_PASSWORD=[YOUR PASSWORD]
SRC_POSTGRES_PORT=[YOUR PORT]

# DWH
DWH_POSTGRES_DB=olist-dwh
DWH_POSTGRES_HOST=localhost
DWH_POSTGRES_USER=[YOUR USERNAME]
DWH_POSTGRES_PASSWORD=[YOUR PASSWORD]
DWH_POSTGRES_PORT=[YOUR PORT]
```

3. Ensure the `/helper/source/init.sql` script has the data preloaded.
4. Run `elt_main.py` to execute the pipeline.
5. Monitor logs in the `/logs/pipeline/` directory for any errors.

### Code Highlights
- **Scripts:** Clean and modularized for easy maintenance.
- **Error Handling:** Alerts for pipeline errors.
- **Logging:** Comprehensive logs for each pipeline step.

## Orchestrate ELT with Luigi
Luigi is used for orchestration and scheduling:
- **Tasks:** 
  - Extract data.
  - Transform data with SCD logic.
  - Load data into the DWH.
- **Scheduling:** Configure tasks to run at desired intervals (e.g., using `cron`).

### Setup Instructions
1. Install Luigi via `pip install luigi`.
2. Run the Luigi scheduler: `luigid`.
3. Execute tasks: `python elt_main.py`.

## Requirements
Install dependencies with:
```bash
pip install -r requirements.txt
```