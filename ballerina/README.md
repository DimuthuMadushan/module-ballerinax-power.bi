## Overview

[Power BI](https://www.microsoft.com/en-us/power-platform/products/power-bi) is Microsoft's business analytics service for building interactive reports and dashboards on top of shared datasets.

The Ballerina Power BI connector supports version 1.0 of the [Power BI REST API](https://learn.microsoft.com/en-us/rest/api/power-bi/). It lets Ballerina applications manage workspaces, datasets, reports, dashboards, dataflows, gateways, capacities, deployment pipelines and scorecards, push data into push datasets, run DAX queries, trigger and monitor refreshes, generate embed tokens, and use the tenant-wide admin operations.

### Key features

- Manage workspaces, their users and their capacity and dataflow storage assignments
- Create push datasets, push rows into them and query any dataset with DAX
- Trigger, schedule and monitor dataset and dataflow refreshes
- Import, clone, rebind and export reports, and manage dashboards and tiles
- Generate embed tokens for reports, dashboards, tiles and datasets
- Run deployment pipelines and administer the tenant, including activity events and workspace scans

## Setup guide

The connector authenticates with a Microsoft Entra ID access token for the Power BI service.

### Step 1: Register an application

1. Sign in to the [Microsoft Entra admin center](https://entra.microsoft.com) and go to **Identity** > **Applications** > **App registrations**.
2. Select **New registration**, enter a name, choose **Accounts in this organizational directory only**, and register the application.
3. Note the **Application (client) ID** and **Directory (tenant) ID** from the overview page.
4. Under **Certificates & secrets**, create a client secret and copy its value.

### Step 2: Grant Power BI permissions

1. Under **API permissions**, select **Add a permission** > **Power BI Service** > **Delegated permissions**.
2. Add the scopes the operations you call need, for example `Dataset.ReadWrite.All`, `Report.ReadWrite.All`, `Dashboard.ReadWrite.All` and `Workspace.ReadWrite.All`. Admin operations need `Tenant.Read.All` or `Tenant.ReadWrite.All`.
3. Grant admin consent for the tenant if your organization requires it.

To call the API as a service principal instead of a user, a Power BI administrator must also enable **Allow service principals to use Power BI APIs** in the Power BI admin portal, and the service principal must be added to each workspace it uses.

### Step 3: Obtain an access token

Request a token for the resource `https://analysis.windows.net/powerbi/api` from `https://login.microsoftonline.com/<tenant-id>/oauth2/v2.0/token`, for example with the authorization code flow and the scope `https://analysis.windows.net/powerbi/api/.default`. See [Register an app to embed Power BI content](https://learn.microsoft.com/en-us/power-bi/developer/embedded/register-app) for the details of each flow.

## Quickstart

To use the Power BI connector in your Ballerina application, update the `.bal` file as follows:

### Step 1: Import the module

Import the `power.bi` module.

```ballerina
import ballerinax/power.bi;
```

### Step 2: Instantiate a new connector

1. Create a `Config.toml` file and configure the access token obtained in the steps above:

```toml
token = "<Access Token>"
```

2. Create a `bi:ConnectionConfig` with the access token and initialize the connector with it.

```ballerina
configurable string token = ?;

final bi:Client powerbi = check new ({
    auth: {
        token
    }
});
```

### Step 3: Invoke the connector operation

Now, utilize the available connector operations.

#### List the datasets in My workspace

```ballerina
public function main() returns error? {
    bi:Datasets _ = check powerbi->getDatasets();
}
```

### Step 4: Run the Ballerina application

```bash
bal run
```

## Examples

The `Power BI` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-power.bi/tree/main/examples/), covering the following use cases:

1. [Push dataset sales feed](https://github.com/ballerina-platform/module-ballerinax-power.bi/tree/main/examples/push_dataset_sales_feed) - Create a push dataset in a workspace if it is missing, push sales rows into it and read per-region totals back with a DAX query.

2. [Dataset refresh monitoring](https://github.com/ballerina-platform/module-ballerinax-power.bi/tree/main/examples/dataset_refresh_monitoring) - Review the refresh schedule and recent refresh history of every refreshable dataset in a workspace, and optionally re-run refreshes that failed.
