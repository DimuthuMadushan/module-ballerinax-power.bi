# Dataset refresh monitoring

This example reviews the refresh health of a Power BI workspace. For every refreshable dataset it prints the scheduled refresh configuration and the most recent refresh attempts, newest first. When a dataset's latest refresh failed, it reports it, and if `refreshFailed` is set to `true` it triggers an on-demand refresh that emails the owner on failure.

## Prerequisites

### 1. Obtain an access token

Follow the [Setup guide](https://github.com/ballerina-platform/module-ballerinax-power.bi/blob/main/ballerina/README.md#setup-guide) to register an application and obtain an access token for the Power BI service. Reading schedules and history needs `Dataset.Read.All`, and the caller must also have Write permission on each dataset to read its refresh history (`getRefreshHistoryInGroup`). Triggering a refresh needs `Dataset.ReadWrite.All`.

The on-demand refresh asks for an email on failure (`MailOnFailure`). Power BI sends that email only for user tokens; with a service principal token no notification is sent.

### 2. Configuration

Create a `Config.toml` file in this example's directory with the following content:

```toml
token = "<access-token>"
workspaceId = "<workspace-id>"
historyDepth = 5
refreshFailed = false
```

Triggering a refresh counts against the workspace's daily refresh limit, which is why `refreshFailed` defaults to `false`.

## Run the example

Execute the following command to run the example:

```bash
bal run
```
