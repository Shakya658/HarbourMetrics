# HarbourMetrics: SaaS Revenue & Retention Analytics System

## 🚀 Project Overview & Progress
This repository houses the full end-to-end development of the **HarbourMetrics** business intelligence platform. The project spans relational database architecture, analytical data simulation, complex KPI engineering, and executive-level analytics reporting.

*   [x] **Module 1:** Database Architecture & Relational DDL Setup
*   [x] **Module 2:** Data Simulation Engine (2,000 Customers, 24-Month History)
*   [x] **Module 3:** Analytical SQL KPI Development (MRR, Churn, Cohorts)
*   [x] **Module 4:** Power BI Semantic Modeling & DAX Formulation
*   [x] **Module 5:** Dashboard Design & Executive Storytelling

---

## 📊 Dashboard Preview
![SaaS Executive Dashboard](./assets/Dashboard.png)

---

## 📐 Database Architecture (ERD)
The following Entity Relationship Diagram illustrates the relational Star Schema structure optimized for analytical processing (OLAP). It maps operational events, customer tiers, and historical timelines back to core plan dimensions.

```mermaid
erDiagram
    harbourmetrics_plans {
        int plan_id PK
        varchar plan_name
        decimal base_price
        varchar billing_cycle
        varchar feature_tier
    }
    harbourmetrics_customers {
        varchar customer_id PK
        varchar company_name
        varchar company_size
        varchar industry
        varchar region
        date signup_date
        date churn_date
    }
    harbourmetrics_custom_events {
        varchar event_id PK
        varchar customer_id FK
        int plan_id FK
        date event_date
        varchar event_type
    }
    calendar {
        date date_id PK
        int calendar_year
        int calendar_quarter
        int calendar_month
        varchar month_short_name
        varchar day_name
        int day_of_week
        boolean is_weekend
        int week_of_year
    }

    harbourmetrics_customers }|--|| calendar : "signup_date / churn_date"
    harbourmetrics_custom_events }|--|| harbourmetrics_customers : "tracks"
    harbourmetrics_custom_events }|--|| harbourmetrics_plans : "subscribes_to"
    harbourmetrics_custom_events }|--|| calendar : "event_date"