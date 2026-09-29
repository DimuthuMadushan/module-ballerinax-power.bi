# Examples

The `ballerinax/power.bi` connector provides practical examples illustrating usage in various scenarios.

1. **[Push dataset sales feed](https://github.com/ballerina-platform/module-ballerinax-power.bi/tree/main/examples/push_dataset_sales_feed)** - Create a push dataset in a workspace if it is missing, push sales rows into it and read per-region totals back with a DAX query.

2. **[Dataset refresh monitoring](https://github.com/ballerina-platform/module-ballerinax-power.bi/tree/main/examples/dataset_refresh_monitoring)** - Review the refresh schedule and recent refresh history of every refreshable dataset in a workspace, and optionally re-run refreshes that failed.

## Prerequisites

1. Obtain an access token for the Power BI service as described in the [Setup guide](https://central.ballerina.io/ballerinax/power.bi/latest#setup-guide).

2. For each example, create a `Config.toml` file with the related configuration. Here's an example of how your Config.toml file should look:

```toml
token = "<access-token>"
workspaceId = "<workspace-id>"
```

Each example lists the additional values it needs in its own README.

## Running an example

Execute the following commands to build an example from the source:

* To build an example:

    ```bash
    bal build
    ```

* To run an example:

    ```bash
    bal run
    ```

## Building the examples with the local module

**Warning**: Due to the absence of support for reading local repositories for single Ballerina files, the Bala of the module is manually written to the central repository as a workaround. Consequently, the bash script may modify your local Ballerina repositories.

Execute the following commands to build all the examples against the changes you have made to the module locally:

* To build all the examples:

    ```bash
    ./build.sh build
    ```

* To run all the examples:

    ```bash
    ./build.sh run
    ```
