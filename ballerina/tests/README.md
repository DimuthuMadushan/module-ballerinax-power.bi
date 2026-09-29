# Tests

The suite covers 30 of the connector's operations across datasets, reports, dashboards, workspaces, imports, gateways, capacities, apps and deployment pipelines. Each test runs against a local mock of the Power BI REST API (`tests/mock_service.bal`, port 9090) by default, or against the live service when `IS_LIVE_SERVER` is `true`.

Tests that delete something create it first in the same test and delete that item, so no shared fixture is destroyed. Tests that create a workspace, dashboard, dataset or report clone remove it again when running live. `testRefreshDataset` and `testUpdateRefreshSchedule` are in `mock_tests` only and return before calling the API when `IS_LIVE_SERVER` is `true`, even without a group filter: a live refresh counts against the tenant's refresh quota, and changing a refresh schedule would modify a shared dataset.

## Running Tests

```bash
bal test
```

The test suite uses a mock server (`tests/mock_service.bal`) that intercepts HTTP calls so no real credentials are required.

## Running against the live service

Set the following environment variables, then run `bal test --groups live_tests`.

| Variable | Description |
|---|---|
| `IS_LIVE_SERVER` | Set to `true` to run against `https://api.powerbi.com/v1.0/myorg` |
| `POWERBI_TOKEN` | A Microsoft Entra ID access token for the Power BI service (`https://analysis.windows.net/powerbi/api`) |
| `POWERBI_DATASET_ID` | A refreshable dataset in **My workspace** that supports DAX queries |
| `POWERBI_PUSH_DATASET_ID` | A push dataset in **My workspace** with at least one table (read only; `testAddRows` pushes into a dataset it creates) |
| `POWERBI_REPORT_ID` | A report in **My workspace** with at least one page |
| `POWERBI_DASHBOARD_ID` | A dashboard in **My workspace** |
| `POWERBI_USER_EMAIL` | The email address of a user in the tenant to grant workspace access to |
