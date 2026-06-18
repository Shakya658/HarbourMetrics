# Event History Validation

`03_kpi_queries/07_event_history_validation.sql` is a read-only audit that compares the existing HarbourMetrics dashboard calculation with an event-based reconstruction of historical subscription states.

## Purpose

The current dashboard method reads the present subscription row for each historical month. After an upgrade, that row contains the customer's final plan and price.

The validation method instead reads the latest lifecycle event available on each monthly snapshot date. This identifies the plan held by the customer at that point in time.

## Outputs

The script returns two result grids:

1. A monthly comparison showing customer counts, MRR under both methods, variance and a `MATCH` or `REVIEW` status.
2. A customer-month detail view showing which records caused each variance and whether the difference came from plan history or activity status.

## How to run

After the HarbourMetrics schema, seed data and lifecycle events have been created, execute:

```text
03_kpi_queries/07_event_history_validation.sql
```

Run the complete file in DBeaver or pgAdmin. Each query opens a separate result grid.

## Safety and interpretation

The audit only reads existing tables. It does not modify the dataset, Power BI report, dashboard screenshots or existing KPI queries.

- `MATCH` means the monthly active-customer count and MRR agree.
- `REVIEW` means the approaches differ and the second result grid identifies the affected records.

A variance does not change the completed dashboard. It documents the effect of using a current-state subscription table for historical reporting and provides evidence for a future effective-dated design if the project is extended.

The audit uses the first day of each month because this matches the snapshot timing in the existing `01_mrr.sql` query.
