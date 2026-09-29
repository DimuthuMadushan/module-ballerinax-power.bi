# Change Log

This file contains all the notable changes done to the Ballerina Power BI connector through the releases.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- 96 operations that 1.5.1 did not cover, including scorecards and goals (preview), deployment pipelines, service
  principal profiles, dataset query scale-out, refresh execution details and cancellation, dataset users, dataflow
  transactions and storage accounts, available features, information protection labels, widely shared artifacts,
  unused artifacts, and further admin operations. The client now has 287 remote methods.
- Every method takes an optional `map<string|string[]> headers` argument for extra request headers.

### Changed

- **Breaking:** all 191 methods published in 1.5.1 are renamed. The group prefix is dropped.
- Optional query parameters moved from trailing positional arguments into an included `*<Method>Queries` record, so
  they are passed as named arguments. For example, `datasetsGetrefreshhistory(datasetId, 10)` is now
  `getRefreshHistory(datasetId, top = 10)`. This affects the 29 methods with optional query parameters.
- The 53 operations that return no body now return `error?` instead of `http:Response|error`.
- File downloads (`exportReport`, `getFileOfExportToFile`, `getDataflowById`,
  `exportDataflowAsAdmin` and their workspace variants) return `byte[]` instead of `string`.
- `getModifiedWorkspaces` (1.x `workspaceinfoGetmodifiedworkspaces`) returns `ModifiedWorkspace[]` instead of `ModifiedWorkspaces`.
- Admin list operations return admin-specific records (`AdminDatasets`, `AdminGroups`, `AdminReports`,
  `AdminDashboards`, `AdminTiles`, `AdminDataflows`) that carry the extra fields admins receive.
- The default `serviceUrl` is `https://api.powerbi.com/v1.0/myorg` (no trailing slash).
- `ConnectionConfig` exposes `http:ClientHttp1Settings` and `http:ProxyConfig` directly, adding `followRedirects`, `cookieConfig`, `socketConfig` and `laxDataBinding`.

### Removed

- The `ClientHttp1Settings`, `ProxyConfig`, `ModifiedWorkspaces`, `Object` and `Workbooks` types. Use
  `http:ClientHttp1Settings`, `http:ProxyConfig` and `ModifiedWorkspace[]`; the other two had no operation that returned them.
