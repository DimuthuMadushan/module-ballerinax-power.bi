# Push dataset sales feed

This example feeds sales figures into a Power BI push dataset and reads them back. It looks for a push dataset with the configured name in the workspace and creates it on first run, with a `Sales` table of region, product, amount and sale date. It then confirms the table exists, pushes three sales rows for the configured day unless that day was already pushed, and runs a DAX query that totals the day's amounts per region.

## Prerequisites

### 1. Obtain an access token

Follow the [Setup guide](https://github.com/ballerina-platform/module-ballerinax-power.bi/blob/main/ballerina/README.md#setup-guide) to register an application and obtain an access token for the Power BI service. The token needs the `Dataset.ReadWrite.All` scope, and the workspace must allow the signed-in user to create datasets.

Reading the totals back uses the Execute Queries API, which also needs:

- the tenant setting **Dataset Execute Queries REST API** (under **Integration settings** in the Power BI admin portal) enabled, and
- read and build permissions on the dataset for the caller.

### 2. Configuration

Create a `Config.toml` file in this example's directory with the following content:

```toml
token = "<access-token>"
workspaceId = "<workspace-id>"
datasetName = "<push-dataset-name, e.g. Sales feed>"
saleDate = "<sale-date (YYYY-MM-DD), e.g. 2026-09-28>"
```

Rows are pushed once per `saleDate`: rerunning the example for a day that is already in the dataset skips the push, and the totals cover only that day.

## Run the example

Execute the following command to run the example:

```bash
bal run
```
