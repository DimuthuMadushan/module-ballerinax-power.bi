_Author_:  @DimuthuMadushan \
_Created_: 29-09-2026 \
_Updated_: 29-09-2026 \
_Edition_: Swan Lake

# Sanitation for OpenAPI specification

This document records the sanitation done on top of the official OpenAPI specification from Power BI.
The OpenAPI specification is obtained from [wso2/api-specs](https://github.com/wso2/api-specs/blob/main/openapi/powerbi/powerbi/v1.0/openapi.json).
These changes are done in order to improve the overall usability, and as workarounds for some known language limitations.

`docs/spec/openapi.json` is kept byte-identical to the upstream document. Items 1-11 are applied to `docs/spec/aligned_ballerina_openapi.json` after `bal openapi flatten` and `bal openapi align`, and must be re-applied after every re-alignment.

1. Fix the server URL
- **Original**: `align` folds the `/v1.0/myorg` path prefix into the Swagger 2.0 `host` and produces `https://api.powerbi.com//v1.0/myorg` (double slash).
- **Updated**: `https://api.powerbi.com/v1.0/myorg`.
- **Reason**: The double slash produces an invalid request path on every call.

2. Add the security scheme
- **Original**: The source spec has no `securityDefinitions` and an empty top-level `security`.
- **Updated**: Added `components.securitySchemes.azure_auth` (OAuth 2.0 implicit flow, `https://login.microsoftonline.com/common/oauth2/authorize`, scope `user_impersonation`) and a top-level `security: [{azure_auth: [user_impersonation]}]`, as in the specification of the published 1.x connector.
- **Reason**: Without a scheme the generated `ConnectionConfig` has no `auth` field. The API requires a Microsoft Entra ID bearer token, so the client takes `http:BearerTokenConfig`.

3. Set the request body media type to `application/json`
- **Original**: The source spec declares `consumes: []` globally and on 164 operations, so 19 request bodies converted to `*/*`.
- **Updated**: Those 19 request bodies use `application/json`.
- **Reason**: The Power BI REST API accepts JSON bodies; `*/*` gives an untyped payload.

4. Make `Role.members` and `Role.tablePermissions` arrays
- **Original**: Each declares `type: array` with a sibling `$ref` and no `items`, so the conversion kept only the `$ref` (a single `RoleMember` / `RoleTablePermission`).
- **Updated**: `type: array` with `items: {$ref: ...}`.
- **Reason**: The API returns arrays for both fields.

5. Move sibling `properties` into `allOf`
- **Original**: 13 schemas (`AdminApp`, `AdminServicePrincipalProfile`, `GroupUser`, `CapacityUser`, `ReportUser`, `DatamartUser`, `DashboardUser`, `DatasetUser`, `PostDatasetUserAccess`, `DatasetUserAccess`, `DataflowUser`, `SelectiveDeployRequest`, `PipelineUser`) declare `properties`/`required` beside `allOf`.
- **Updated**: The sibling `properties` and `required` are moved into a second `allOf` member `{type: object, properties, required}`.
- **Reason**: The generator ignores properties declared beside `allOf`, which dropped fields such as `groupUserAccessRight`.

6. Narrow file downloads to `application/octet-stream`
- **Original**: The six `type: file` responses (report `Export`, export-to-file `file`, dataflow get and admin export, each with its workspace variant) list several binary media types (`application/zip`, `image/*`, `text/csv`, `multipart/related`, ...).
- **Updated**: A single `application/octet-stream` binary response.
- **Reason**: Several binary media types generate an unbindable record return; a single binary type returns `byte[]`.

7. Remove a duplicate field from `WorkspaceInfoDataset`
- **Original**: Both `DatasetBaseProperties` and `WorkspaceInfoDataflowProperties` declare `upstreamDataflows`, and `WorkspaceInfoDataset` includes both through `allOf`.
- **Updated**: `WorkspaceInfoDataset` includes the other three `WorkspaceInfoDataflowProperties` fields inline instead of the `$ref`.
- **Reason**: The duplicate fails compilation with `redeclared symbol 'upstreamDataflows'`. The two declarations are identical.

8. Restore the OData query parameter names
- **Original**: `align` names the `$top`, `$skip`, `$filter`, `$expand` and `$select` parameters `dollarTop`, `dollarSkip`, ... (`x-ballerina-name`, 82 parameters).
- **Updated**: `top`, `skip`, `filter`, `expand`, `select`.
- **Reason**: Keeps the parameter names of the published 1.x connector. The wire names are unchanged.

9. Name the operations in camelCase, without the group prefix
- **Original**: Vendor operationIds of the form `<Group>_<Operation>`, e.g. `Datasets_GetDatasets`, `Groups_CreateGroup` and `GoalValues_(Preview)_PatchByID`.
- **Updated**: `_(Preview)` removed, the `<Group>_` prefix dropped, and the rest camelCased from the vendor PascalCase, keeping its word boundaries and acronyms (`Datasets_GetDatasets` → `getDatasets`, `Groups_CreateGroup` → `createGroup`, `Admin_AddPowerBIEncryptionKey` → `addPowerBIEncryptionKey`). Four further rules, applied in this order; each table's "previous" column is the name the earlier rules produced:
  - **Name clashes.** Where dropping the prefix would make two operations share a name, the Datasets operation and the group's primary resource keep the plain name, and the other gets a disambiguating noun (37 names, first table).
  - **Single-item gets.** Where a single-item get would differ from its list operation only by the plural `s`, `By<Key>` is appended right after the noun and before any scope suffix (`InGroup`, `AsAdmin`, `ForCapacity`): `ById` for ID-keyed items, `ByName` for pages and workloads, `ByTimestamp` for goal values (`getDataset` → `getDatasetById`, `getDatasetInGroup` → `getDatasetByIdInGroup`, `getRefreshableForCapacity` → `getRefreshableByIdForCapacity`). The exceptions are the gateway data-source pair, which instead becomes `getDatasourceInGateway` and `updateDatasourceInGateway`, so it does not read as the dataset `getDatasources`/`updateDatasources`. These 30 names are in the second table.

  - **Verbs from the summary.** HTTP-method verbs are replaced with the verb of the operation summary: `post`/`put`/`patch` become `create`, `add`, `update` or `request` (`postDataset` → `createDataset`, `postRows` → `addRows`, `putTable` → `updateTable`, `patchWorkload` → `updateWorkload`, `postWorkspaceInfo` → `requestWorkspaceInfo`). Operations that grant a user access use `add…User` (`addDatasetUser`, `addPipelineUser`, `addPipelineUserAsAdmin`). No method name starts with `post`, `put` or `patch`. These 17 names are in the third table.
  - **Consistency fixes.** 9 names are aligned with their siblings: a scope noun where the plain name was ambiguous (`addGroupUserAsAdmin`, `deleteGroupUser`, `deleteGoalStatusRules`), `ById` for `getGatewayById`, a `get` verb for the status and admin reports (`getCapacityAssignmentStatus`, `getLinksSharedToWholeOrganizationAsAdmin`, `getPublishedToWebAsAdmin`), and `Datasources` spelled as elsewhere (`getDataflowDatasources`). They are in the fourth table.

  List operations keep their plural names. All 287 names are recorded in `docs/spec/ai-mappings.json`.
- **Reason**: Readable camelCase method names consistent with the other connectors. The group prefix restates what the operation name already says, and a single-item get should not be one letter away from its list operation. This renames every method of the published 1.x connector (see `changelog.md`).

Name-clash overrides:

| Vendor operationId | Plain name (clashes) | Method name |
|---|---|---|
| `Admin_GetRefreshables` | `getRefreshables` | `getRefreshablesAsAdmin` |
| `Admin_GetRefreshablesForCapacity` | `getRefreshablesForCapacity` | `getRefreshablesForCapacityAsAdmin` |
| `Apps_GetDashboards` | `getDashboards` | `getAppDashboards` |
| `Apps_GetReports` | `getReports` | `getAppReports` |
| `Apps_GetTiles` | `getTiles` | `getAppTiles` |
| `Dashboards_GenerateTokenInGroup` | `generateTokenInGroup` | `generateDashboardTokenInGroup` |
| `Dataflows_UpdateRefreshSchedule` | `updateRefreshSchedule` | `updateDataflowRefreshSchedule` |
| `Gateways_GetDatasources` | `getDatasources` | `getDatasourcesInGateway` |
| `GoalNotes_(Preview)_DeleteByID` | `deleteByID` | `deleteGoalNote` |
| `GoalNotes_(Preview)_PatchByID` | `patchByID` | `updateGoalNote` |
| `GoalNotes_(Preview)_Post` | `post` | `createGoalNote` |
| `GoalValues_(Preview)_DeleteByID` | `deleteByID` | `deleteGoalValue` |
| `GoalValues_(Preview)_Get` | `get` | `getGoalValues` |
| `GoalValues_(Preview)_PatchByID` | `patchByID` | `updateGoalValue` |
| `GoalValues_(Preview)_Post` | `post` | `createGoalValue` |
| `GoalsStatusRules_(Preview)_Get` | `get` | `getGoalStatusRules` |
| `GoalsStatusRules_(Preview)_Post` | `post` | `createGoalStatusRules` |
| `Goals_(Preview)_DeleteByID` | `deleteByID` | `deleteGoal` |
| `Goals_(Preview)_Get` | `get` | `getGoals` |
| `Goals_(Preview)_GetRefreshHistory` | `getRefreshHistory` | `getGoalRefreshHistory` |
| `Goals_(Preview)_PatchByID` | `patchByID` | `updateGoal` |
| `Goals_(Preview)_Post` | `post` | `createGoal` |
| `Groups_DeleteUserAsAdmin` | `deleteUserAsAdmin` | `deleteGroupUserAsAdmin` |
| `Pipelines_DeleteUserAsAdmin` | `deleteUserAsAdmin` | `deletePipelineUserAsAdmin` |
| `Reports_BindToGateway` | `bindToGateway` | `bindReportToGateway` |
| `Reports_BindToGatewayInGroup` | `bindToGatewayInGroup` | `bindReportToGatewayInGroup` |
| `Reports_GenerateTokenInGroup` | `generateTokenInGroup` | `generateReportTokenInGroup` |
| `Reports_GetDatasources` | `getDatasources` | `getReportDatasources` |
| `Reports_GetDatasourcesInGroup` | `getDatasourcesInGroup` | `getReportDatasourcesInGroup` |
| `Reports_TakeOverInGroup` | `takeOverInGroup` | `takeOverReportInGroup` |
| `Reports_UpdateDatasources` | `updateDatasources` | `updateReportDatasources` |
| `Reports_UpdateDatasourcesInGroup` | `updateDatasourcesInGroup` | `updateReportDatasourcesInGroup` |
| `Scorecards_(Preview)_DeleteByID` | `deleteByID` | `deleteScorecard` |
| `Scorecards_(Preview)_Get` | `get` | `getScorecards` |
| `Scorecards_(Preview)_PatchByID` | `patchByID` | `updateScorecard` |
| `Scorecards_(Preview)_Post` | `post` | `createScorecard` |
| `Tiles_GenerateTokenInGroup` | `generateTokenInGroup` | `generateTileTokenInGroup` |

Single-item gets:

| Vendor operationId | Plain name | Method name |
|---|---|---|
| `Admin_GetRefreshableForCapacity` | `getRefreshableForCapacity` | `getRefreshableByIdForCapacityAsAdmin` |
| `Apps_GetApp` | `getApp` | `getAppById` |
| `Apps_GetDashboard` | `getDashboard` | `getAppDashboardById` |
| `Apps_GetReport` | `getReport` | `getAppReportById` |
| `Apps_GetTile` | `getTile` | `getAppTileById` |
| `Capacities_GetRefreshableForCapacity` | `getRefreshableForCapacity` | `getRefreshableByIdForCapacity` |
| `Capacities_GetWorkload` | `getWorkload` | `getWorkloadByName` |
| `Dashboards_GetDashboard` | `getDashboard` | `getDashboardById` |
| `Dashboards_GetDashboardInGroup` | `getDashboardInGroup` | `getDashboardByIdInGroup` |
| `Dashboards_GetTile` | `getTile` | `getTileById` |
| `Dashboards_GetTileInGroup` | `getTileInGroup` | `getTileByIdInGroup` |
| `Dataflows_GetDataflow` | `getDataflow` | `getDataflowById` |
| `Datasets_GetDataset` | `getDataset` | `getDatasetById` |
| `Datasets_GetDatasetInGroup` | `getDatasetInGroup` | `getDatasetByIdInGroup` |
| `Gateways_GetDatasource` | `getDatasource` | `getDatasourceInGateway` |
| `Gateways_UpdateDatasource` | `updateDatasource` | `updateDatasourceInGateway` |
| `GoalValues_(Preview)_GetByID` | `getByID` | `getGoalValueByTimestamp` |
| `Goals_(Preview)_GetByID` | `getByID` | `getGoalById` |
| `Groups_GetGroup` | `getGroup` | `getGroupById` |
| `Groups_GetGroupAsAdmin` | `getGroupAsAdmin` | `getGroupByIdAsAdmin` |
| `Imports_GetImport` | `getImport` | `getImportById` |
| `Imports_GetImportInGroup` | `getImportInGroup` | `getImportByIdInGroup` |
| `Pipelines_GetPipeline` | `getPipeline` | `getPipelineById` |
| `Pipelines_GetPipelineOperation` | `getPipelineOperation` | `getPipelineOperationById` |
| `Profiles_GetProfile` | `getProfile` | `getProfileById` |
| `Reports_GetPage` | `getPage` | `getPageByName` |
| `Reports_GetPageInGroup` | `getPageInGroup` | `getPageByNameInGroup` |
| `Reports_GetReport` | `getReport` | `getReportById` |
| `Reports_GetReportInGroup` | `getReportInGroup` | `getReportByIdInGroup` |
| `Scorecards_(Preview)_GetByID` | `getByID` | `getScorecardById` |

Summary verbs:

| Vendor operationId | Previous name | Method name |
|---|---|---|
| `Admin_PatchCapacityAsAdmin` | `patchCapacityAsAdmin` | `updateCapacityAsAdmin` |
| `Capacities_PatchWorkload` | `patchWorkload` | `updateWorkload` |
| `Datasets_PostDataset` | `postDataset` | `createDataset` |
| `Datasets_PostDatasetInGroup` | `postDatasetInGroup` | `createDatasetInGroup` |
| `Datasets_PostDatasetUser` | `postDatasetUser` | `addDatasetUser` |
| `Datasets_PostDatasetUserInGroup` | `postDatasetUserInGroup` | `addDatasetUserInGroup` |
| `Datasets_PostRows` | `postRows` | `addRows` |
| `Datasets_PostRowsInGroup` | `postRowsInGroup` | `addRowsInGroup` |
| `Datasets_PutDatasetUser` | `putDatasetUser` | `updateDatasetUser` |
| `Datasets_PutDatasetUserInGroup` | `putDatasetUserInGroup` | `updateDatasetUserInGroup` |
| `Datasets_PutTable` | `putTable` | `updateTable` |
| `Datasets_PutTableInGroup` | `putTableInGroup` | `updateTableInGroup` |
| `Imports_PostImport` | `postImport` | `createImport` |
| `Imports_PostImportInGroup` | `postImportInGroup` | `createImportInGroup` |
| `Pipelines_UpdatePipelineUser` | `updatePipelineUser` | `addPipelineUser` |
| `Pipelines_UpdateUserAsAdmin` | `updateUserAsAdmin` | `addPipelineUserAsAdmin` |
| `WorkspaceInfo_PostWorkspaceInfo` | `postWorkspaceInfo` | `requestWorkspaceInfo` |

Consistency fixes:

| Vendor operationId | Previous name | Method name |
|---|---|---|
| `Dataflows_GetDataflowDataSources` | `getDataflowDataSources` | `getDataflowDatasources` |
| `Gateways_GetGateway` | `getGateway` | `getGatewayById` |
| `GoalsStatusRules_(Preview)_Delete` | `delete` | `deleteGoalStatusRules` |
| `Groups_AddUserAsAdmin` | `addUserAsAdmin` | `addGroupUserAsAdmin` |
| `Groups_CapacityAssignmentStatus` | `capacityAssignmentStatus` | `getCapacityAssignmentStatus` |
| `Groups_CapacityAssignmentStatusMyWorkspace` | `capacityAssignmentStatusMyWorkspace` | `getCapacityAssignmentStatusMyWorkspace` |
| `Groups_DeleteUserInGroup` | `deleteUserInGroup` | `deleteGroupUser` |
| `WidelySharedArtifacts_LinksSharedToWholeOrganization` | `linksSharedToWholeOrganization` | `getLinksSharedToWholeOrganizationAsAdmin` |
| `WidelySharedArtifacts_PublishedToWeb` | `publishedToWeb` | `getPublishedToWebAsAdmin` |

10. Rename a generic schema
- **Original**: `GoalsRulesRule1OfInt32` (a .NET generic type name).
- **Updated**: `GoalsRulesStatusRule`. All other 342 schema names are unchanged, keeping the published type names.
- **Reason**: Readable public type name.

11. Fill missing documentation
- **Original**: 110 fields, 34 schemas, 6 path parameters and 11 request bodies had no description; 182 typed 2xx responses said only `OK`, `Created` or `Accepted`; 14 groups of operations shared a summary, and the capacity-users admin operation (`GET /admin/capacities/{capacityId}/users`) described workspace users.
- **Updated**: Descriptions taken from the referenced schema or written from the field name; responses described from the operation summary; duplicate summaries qualified with "in My workspace", "in the specified workspace" or "(as an administrator)"; the capacity-users summary corrected.
- **Reason**: Generated doc comments and distinct operation descriptions.

12. Update the API Paths
- **Original**: Paths included common prefix `/v1.0/myorg` in each endpoint.
- **Updated**: Common prefix removed from endpoints as it is now in the base URL.
- **Reason**: Simplifies API paths and avoids duplication.
<!-- auto-generated -->

## OpenAPI cli command

The following command was used to generate the Ballerina client from the OpenAPI specification. The command should be executed from the repository root directory.

```bash
bal openapi -i docs/spec/aligned_ballerina_openapi.json -o ballerina --mode client --license docs/license.txt --client-methods remote
```

Note: The license year is hardcoded to 2026, change if necessary.
