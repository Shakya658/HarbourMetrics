Parse error on line 43:
...1. SQL Optimization: Monthly Recurring
----------------------^
Expecting 'EOF', 'SPACE', 'NEWLINE', 'STYLE_SEPARATOR', 'BLOCK_START', 'SQS', 'title', 'acc_title', 'acc_descr', 'acc_descr_multiline_value', 'direction_tb', 'direction_bt', 'direction_rl', 'direction_lr', 'CLASSDEF', 'UNICODE_TEXT', 'CLASS', 'STYLE', 'NUM', 'ENTITY_NAME', 'DECIMAL_NUM', 'ENTITY_ONE', 'ZERO_OR_ONE', 'ZERO_OR_MORE', 'ONE_OR_MORE', 'ONLY_ONE', 'MD_PARENT', got 'COLON'

For more information, see https://docs.github.com/get-started/writing-on-github/working-with-advanced-formatting/creating-diagrams#creating-mermaid-diagrams
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

Step 2: Open Report & Refresh Data LinkOpen the file HarbourMetrics_SaaS_Analytics.pbix in Power BI Desktop.In the top ribbon, click Transform Data $\rightarrow$ Data source settings.Select the local PostgreSQL entry, click Change Source, and enter your local server credentials to re-link your relational database tables.Click Refresh to populate the charts dynamically.🧰 Tech StackDatabase Engine: PostgreSQL (Relational Architecture & Window Functions)Analytics Layer: Power BI Desktop (Power Query Engine, Data Modeling, DAX, UX Layout)