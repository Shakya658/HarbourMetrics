HarbourMetrics: SaaS Revenue & Retention Analytics System

🚀 Project Overview & Progress

This repository houses the full end-to-end development of the HarbourMetrics business intelligence platform. The project spans relational database architecture, analytical data simulation, complex KPI engineering, and executive-level analytics reporting.

[x] Module 1: Database Architecture & Relational DDL Setup

[x] Module 2: Data Simulation Engine (2,000 Customers, 24-Month History)

[x] Module 3: Analytical SQL KPI Development (MRR, Churn, Cohorts)

[x] Module 4: Power BI Semantic Modeling & DAX Formulation

[x] Module 5: Dashboard Design & Executive Storytelling

📊 Dashboard Preview

📐 Database Architecture (ERD)

The following Entity Relationship Diagram illustrates the relational Star Schema structure optimized for analytical processing (OLAP). It maps operational events, customer tiers, and historical timelines back to core plan dimensions.
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

    harbourmetrics_customers }|--|| calendar : "signup_date"
    harbourmetrics_custom_events }|--|| harbourmetrics_customers : "tracks"
    harbourmetrics_custom_events }|--|| harbourmetrics_plans : "subscribes"
    harbourmetrics_custom_events }|--|| calendar : "event_date"
💻 Technical Code Showcase

1. SQL Optimization: Monthly Recurring Revenue (MRR) Calculation

This optimized PostgreSQL query aggregates operational subscriber signups, cancellations, and tier upgrades to calculate chronological monthly revenue performance.
WITH MonthlyEvents AS (
    SELECT 
        DATE_TRUNC('month', event_date) AS reporting_month,
        plan_id,
        COUNT(CASE WHEN event_type = 'signup' THEN 1 END) AS new_signups,
        COUNT(CASE WHEN event_type = 'churn' THEN 1 END) AS cancellations
    FROM harbourmetrics_custom_events
    GROUP BY 1, 2
)
SELECT 
    me.reporting_month,
    p.plan_name,
    p.base_price,
    (me.new_signups * p.base_price) AS Gross_New_MRR,
    (me.cancellations * p.base_price) AS Churned_MRR,
    SUM(me.new_signups - me.cancellations) OVER (
        PARTITION BY p.plan_id 
        ORDER BY me.reporting_month
    ) * p.base_price AS Cumulative_Total_MRR
FROM MonthlyEvents me
JOIN harbourmetrics_plans p ON me.plan_id = p.plan_id
ORDER BY me.reporting_month ASC, Cumulative_Total_MRR DESC;

2. DAX Formulation: Dynamic Active Subscribers
Active Subscribers = 
CALCULATE(
    COUNT(harbourmetrics_customers[customer_id]),
    FILTER(
        harbourmetrics_customers,
        harbourmetrics_customers[signup_date] <= MAX('calendar'[date_id]) &&
        (ISBLANK(harbourmetrics_customers[churn_date]) || harbourmetrics_customers[churn_date] > MAX('calendar'[date_id]))
    )
)

🛠️ Key Technical Implementations (Power BI & UX Layer)

Data-Driven Storytelling: Embedded an Executive Insights panel directly onto the canvas to present clear, scannable takeaways alongside raw visualizations.

Chronological Sorting Logic: Resolved standard chronological layout issues by leveraging hidden numerical priority keys (month_number) to align textual calendar timelines dynamically.

Premium UX Grid: Customized canvas borders, container cards with subtle drop shadows (#FFFFFF tiles over #F4F6F9 canvas), and adjusted typography colors (#1A2530 / #5A6A7A) to achieve a high-end, minimalist corporate aesthetic.

💡 Core Business Insights Delivered

Enterprise Dominance: The Enterprise tier acts as the primary revenue engine for the business, significantly outpacing basic and pro tiers despite maintaining a lower overall subscriber footprint.

Retention Alert: The organization experienced a major Net MRR contraction in February, marking a vital churn area for predictive analysis.

Q4 Recovery: The fiscal year closed out incredibly strong, culminating in a massive December revenue spike that successfully matched our annual performance peaks.

⚙️ How to Run & Local Setup

Prerequisites

Database: PostgreSQL (v14 or higher)

BI Software: Power BI Desktop

Step 1: Database Initialization

Clone this repository and execute your schema initialization query script inside your database manager client to construct the structural layout and load the simulated datasets.

git clone [https://github.com/Shakya658/HarbourMetrics.git](https://github.com/Shakya658/HarbourMetrics.git)
cd HarbourMetrics


Step 2: Open Report & Refresh Data Link

Open the file HarbourMetrics_SaaS_Analytics.pbix in Power BI Desktop.

In the top ribbon, click Transform Data $\rightarrow$ Data source settings.

Select the local PostgreSQL entry, click Change Source, and enter your local server credentials to re-link your relational database tables.

Click Refresh to populate the charts dynamically.

🧰 Tech Stack

Database Engine: PostgreSQL (Relational Architecture & Window Functions)

Analytics Layer: Power BI Desktop (Power Query Engine, Data Modeling, DAX, UX Layout)