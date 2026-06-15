# **HarbourMetrics: SaaS Revenue & Retention Analytics System**

## **🚀 Project Overview & Progress**

This repository houses the full end-to-end development of the **HarbourMetrics** business intelligence platform. The project spans relational database architecture, analytical data simulation, complex KPI engineering, and executive-level analytics reporting.

* \[x\] **Module 1:** Database Architecture & Relational DDL Setup  
* \[x\] **Module 2:** Data Simulation Engine (2,000 Customers, 24-Month History)  
* \[x\] **Module 3:** Analytical SQL KPI Development (MRR, Churn, Cohorts)  
* \[x\] **Module 4:** Power BI Semantic Modeling & DAX Formulation  
* \[x\] **Module 5:** Dashboard Design & Executive Storytelling

## **📊 Dashboard Preview**

## **📐 Database Architecture (ERD)**

The following Entity Relationship Diagram illustrates the relational Star Schema structure optimized for analytical processing (OLAP). It maps operational events, customer tiers, and historical timelines back to core plan dimensions.

erDiagram  
    harbourmetrics\_plans {  
        int plan\_id PK  
        varchar plan\_name  
        decimal base\_price  
        varchar billing\_cycle  
        varchar feature\_tier  
    }  
    harbourmetrics\_customers {  
        varchar customer\_id PK  
        varchar company\_name  
        varchar company\_size  
        varchar industry  
        varchar region  
        date signup\_date  
        date churn\_date  
    }  
    harbourmetrics\_custom\_events {  
        varchar event\_id PK  
        varchar customer\_id FK  
        int plan\_id FK  
        date event\_date  
        varchar event\_type  
    }  
    calendar {  
        date date\_id PK  
        int calendar\_year  
        int calendar\_quarter  
        int calendar\_month  
        varchar month\_short\_name  
        varchar day\_name  
        int day\_of\_week  
        boolean is\_weekend  
        int week\_of\_year  
    }

    harbourmetrics\_customers }|--|| calendar : "signup\_date"  
    harbourmetrics\_custom\_events }|--|| harbourmetrics\_customers : "tracks"  
    harbourmetrics\_custom\_events }|--|| harbourmetrics\_plans : "subscribes"  
    harbourmetrics\_custom\_events }|--|| calendar : "event\_date"

## **💻 Technical Code Showcase**

### **1\. SQL Optimization: Monthly Recurring Revenue (MRR) Calculation**

This optimized PostgreSQL query aggregates operational subscriber signups, cancellations, and tier upgrades to calculate chronological monthly revenue performance.

WITH MonthlyEvents AS (  
    SELECT   
        DATE\_TRUNC('month', event\_date) AS reporting\_month,  
        plan\_id,  
        COUNT(CASE WHEN event\_type \= 'signup' THEN 1 END) AS new\_signups,  
        COUNT(CASE WHEN event\_type \= 'churn' THEN 1 END) AS cancellations  
    FROM harbourmetrics\_custom\_events  
    GROUP BY 1, 2  
)  
SELECT   
    me.reporting\_month,  
    p.plan\_name,  
    p.base\_price,  
    (me.new\_signups \* p.base\_price) AS Gross\_New\_MRR,  
    (me.cancellations \* p.base\_price) AS Churned\_MRR,  
    SUM(me.new\_signups \- me.cancellations) OVER (  
        PARTITION BY p.plan\_id   
        ORDER BY me.reporting\_month  
    ) \* p.base\_price AS Cumulative\_Total\_MRR  
FROM MonthlyEvents me  
JOIN harbourmetrics\_plans p ON me.plan\_id \= p.plan\_id  
ORDER BY me.reporting\_month ASC, Cumulative\_Total\_MRR DESC;

### **2\. DAX Formulation: Dynamic Active Subscribers**

Active Subscribers \=   
CALCULATE(  
    COUNT(harbourmetrics\_customers\[customer\_id\]),  
    FILTER(  
        harbourmetrics\_customers,  
        harbourmetrics\_customers\[signup\_date\] \<= MAX('calendar'\[date\_id\]) &&  
        (ISBLANK(harbourmetrics\_customers\[churn\_date\]) || harbourmetrics\_customers\[churn\_date\] \> MAX('calendar'\[date\_id\]))  
    )  
)

## **🛠️ Key Technical Implementations (Power BI & UX Layer)**

* **Data-Driven Storytelling:** Embedded an Executive Insights panel directly onto the canvas to present clear, scannable takeaways alongside raw visualizations.  
* **Chronological Sorting Logic:** Resolved standard chronological layout issues by leveraging hidden numerical priority keys (month\_number) to align textual calendar timelines dynamically.  
* **Premium UX Grid:** Customized canvas borders, container cards with subtle drop shadows (\#FFFFFF tiles over \#F4F6F9 canvas), and adjusted typography colors (\#1A2530 / \#5A6A7A) to achieve a high-end, minimalist corporate aesthetic.

## **💡 Core Business Insights Delivered**

* **Enterprise Dominance:** The Enterprise tier acts as the primary revenue engine for the business, significantly outpacing basic and pro tiers despite maintaining a lower overall subscriber footprint.  
* **Retention Alert:** The organization experienced a major Net MRR contraction in February, marking a vital churn area for predictive analysis.  
* **Q4 Recovery:** The fiscal year closed out incredibly strong, culminating in a massive December revenue spike that successfully matched our annual performance peaks.

## **⚙️ How to Run & Local Setup**

### **Prerequisites**

* **Database:** PostgreSQL (v14 or higher)  
* **BI Software:** Power BI Desktop

### **Step 1: Database Initialization**

Clone this repository and execute your schema initialization query script inside your database manager client to construct the structural layout and load the simulated datasets.

git clone \[https://github.com/Shakya658/HarbourMetrics.git\](https://github.com/Shakya658/HarbourMetrics.git)  
cd HarbourMetrics

### **Step 2: Open Report & Refresh Data Link**

1. Open the file HarbourMetrics\_SaaS\_Analytics.pbix in Power BI Desktop.  
2. In the top ribbon, click **Transform Data** ![][image1] **Data source settings**.  
3. Select the local PostgreSQL entry, click **Change Source**, and enter your local server credentials to re-link your relational database tables.  
4. Click **Refresh** to populate the charts dynamically.

## **🧰 Tech Stack**

* **Database Engine:** PostgreSQL (Relational Architecture & Window Functions)  
* **Analytics Layer:** Power BI Desktop (Power Query Engine, Data Modeling, DAX, UX Layout)

[image1]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABUAAAAlCAYAAACtbaI7AAAArUlEQVR4XmNYcfzXf2pjBnQBauBRQzEFKcWjhmIKUooHj6EJ+R0YYsiYLEObZuz5v2DvWwxxGCbLUBA2t3X7P2PzAwxxECbb0LCksv/O3pEY4iAMNjQ8pRKsiFQcFFvwX1FJ+X90ZgOdDCUHgwx19YvFEAdhsg01s3GhbkSBklPNxC0Y4jBMlqE0SfzTN93HEEPGZBlKCI8aiilIKR41FFOQUjxqKKYgpXjoGAoAKAAexnoqmrcAAAAASUVORK5CYII=>