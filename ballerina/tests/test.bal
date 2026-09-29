// Copyright (c) 2026, WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;
import ballerina/os;
import ballerina/test;

final boolean isLiveServer = os:getEnv("IS_LIVE_SERVER") == "true";
final string serviceUrl = isLiveServer ? "https://api.powerbi.com/v1.0/myorg" : "http://localhost:9090";
final string token = isLiveServer ? os:getEnv("POWERBI_TOKEN") : "test_token";

// Fixtures that must already exist in the live tenant. Every one lives in "My workspace",
// except where a test creates its own.
final string datasetId = isLiveServer ? os:getEnv("POWERBI_DATASET_ID") : "cfafbeb1-8037-4d0c-896e-a46fb27ff229";
final string pushDatasetId = isLiveServer ? os:getEnv("POWERBI_PUSH_DATASET_ID") : "cfafbeb1-8037-4d0c-896e-a46fb27ff229";
final string pushTableName = isLiveServer ? os:getEnv("POWERBI_PUSH_TABLE_NAME") : "Product";
final string reportId = isLiveServer ? os:getEnv("POWERBI_REPORT_ID") : "5b218778-e7a5-4d73-8187-f10824047715";
final string dashboardId = isLiveServer ? os:getEnv("POWERBI_DASHBOARD_ID") : "69ffaa6c-b36d-4d01-96f5-1ed67c64d4af";
final string userEmail = isLiveServer ? os:getEnv("POWERBI_USER_EMAIL") : "john@contoso.com";

final Client powerbi = check new ({
    auth: {token},
    // The mock is plain HTTP; HTTP/2 upgrade on a body-carrying PATCH times out against it.
    httpVersion: isLiveServer ? http:HTTP_2_0 : http:HTTP_1_1
}, serviceUrl);

// Datasets

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetDatasets() returns error? {
    Datasets response = check powerbi->getDatasets();
    test:assertTrue(response.value is Dataset[]);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetDataset() returns error? {
    Dataset response = check powerbi->getDatasetById(datasetId);
    test:assertEquals(response.id, datasetId);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testCreateDataset() returns error? {
    Dataset response = check powerbi->createDataset(pushDatasetDefinition("Ballerina test dataset"));
    test:assertTrue(response.id.length() > 0);
    if isLiveServer {
        check powerbi->deleteDataset(response.id);
    }
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testDeleteDataset() returns error? {
    Dataset created = check powerbi->createDataset(pushDatasetDefinition("Ballerina test dataset to delete"));
    test:assertTrue(created.id.length() > 0);
    check powerbi->deleteDataset(created.id);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetTables() returns error? {
    Tables response = check powerbi->getTables(pushDatasetId);
    Table[] tables = response.value ?: [];
    test:assertTrue(tables.length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testAddRows() returns error? {
    check powerbi->addRows(pushDatasetId, pushTableName, {
        rows: [
            {"ProductID": 1, "Name": "Adjustable Race"},
            {"ProductID": 2, "Name": "LL Crankarm"}
        ]
    });
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetRefreshHistory() returns error? {
    Refreshes response = check powerbi->getRefreshHistory(datasetId, top = 5);
    test:assertTrue(response.value is Refresh[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function testRefreshDataset() returns error? {
    // Mock-only: a live refresh depends on the dataset's data-source credentials and
    // counts against the tenant's daily refresh quota.
    check powerbi->refreshDataset(datasetId, {notifyOption: "NoNotification"});
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetRefreshSchedule() returns error? {
    RefreshSchedule response = check powerbi->getRefreshSchedule(datasetId);
    test:assertTrue(response.enabled is boolean);
}

@test:Config {groups: ["mock_tests"]}
isolated function testUpdateRefreshSchedule() returns error? {
    // Mock-only: changing a live refresh schedule alters a shared tenant fixture.
    check powerbi->updateRefreshSchedule(datasetId, {
        value: {
            days: ["Sunday", "Friday"],
            times: ["07:00", "16:30"],
            localTimeZoneId: "UTC",
            enabled: true
        }
    });
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testExecuteQueries() returns error? {
    DatasetExecuteQueriesResponse response = check powerbi->executeQueries(datasetId, {
        queries: [{query: "EVALUATE VALUES(Product)"}],
        serializerSettings: {includeNulls: true}
    });
    DatasetExecuteQueriesQueryResult[] results = response.results ?: [];
    test:assertEquals(results.length(), 1);
}

// Reports

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetReports() returns error? {
    Reports response = check powerbi->getReports();
    test:assertTrue(response.value is Report[]);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetReport() returns error? {
    Report response = check powerbi->getReportById(reportId);
    test:assertEquals(response.id, reportId);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetPages() returns error? {
    Pages response = check powerbi->getPages(reportId);
    Page[] pages = response.value ?: [];
    test:assertTrue(pages.length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testCloneReport() returns error? {
    Report response = check powerbi->cloneReport(reportId, {name: "Ballerina test report clone"});
    test:assertTrue(response.id.length() > 0);
    if isLiveServer {
        check powerbi->deleteReport(response.id);
    }
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testDeleteReport() returns error? {
    Report created = check powerbi->cloneReport(reportId, {name: "Ballerina test report to delete"});
    test:assertTrue(created.id.length() > 0);
    check powerbi->deleteReport(created.id);
}

// Dashboards

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetDashboards() returns error? {
    Dashboards response = check powerbi->getDashboards();
    test:assertTrue(response.value is Dashboard[]);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testAddDashboard() returns error? {
    Dashboard response = check powerbi->addDashboard({name: "Ballerina test dashboard"});
    test:assertEquals(response.displayName, "Ballerina test dashboard");
    if isLiveServer {
        check powerbi->deleteDashboard(response.id);
    }
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testDeleteDashboard() returns error? {
    Dashboard created = check powerbi->addDashboard({name: "Ballerina test dashboard to delete"});
    test:assertTrue(created.id.length() > 0);
    check powerbi->deleteDashboard(created.id);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetTiles() returns error? {
    Tiles response = check powerbi->getTiles(dashboardId);
    test:assertTrue(response.value is Tile[]);
}

// Workspaces

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetGroups() returns error? {
    Groups response = check powerbi->getGroups(top = 10);
    test:assertTrue(response.value is Group[]);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testCreateGroup() returns error? {
    Group response = check powerbi->createGroup({name: "Ballerina test workspace"}, workspaceV2 = true);
    test:assertEquals(response.name, "Ballerina test workspace");
    if isLiveServer {
        check powerbi->deleteGroup(response.id);
    }
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testDeleteGroup() returns error? {
    Group created = check powerbi->createGroup({name: "Ballerina test workspace to delete"}, workspaceV2 = true);
    test:assertTrue(created.id.length() > 0);
    check powerbi->deleteGroup(created.id);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetGroupUsers() returns error? {
    Group created = check powerbi->createGroup({name: "Ballerina test workspace users"}, workspaceV2 = true);
    GroupUsers response = check powerbi->getGroupUsers(created.id);
    GroupUser[] users = response.value ?: [];
    test:assertTrue(users.length() > 0);
    if isLiveServer {
        check powerbi->deleteGroup(created.id);
    }
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testAddGroupUser() returns error? {
    Group created = check powerbi->createGroup({name: "Ballerina test workspace access"}, workspaceV2 = true);
    check powerbi->addGroupUser(created.id, {
        identifier: userEmail,
        emailAddress: userEmail,
        principalType: "User",
        groupUserAccessRight: "Viewer"
    });
    if isLiveServer {
        check powerbi->deleteGroup(created.id);
    }
}

// Other collections

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetImports() returns error? {
    Imports response = check powerbi->getImports();
    test:assertTrue(response.value is Import[]);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetGateways() returns error? {
    Gateways response = check powerbi->getGateways();
    test:assertTrue(response.value is Gateway[]);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetCapacities() returns error? {
    Capacities response = check powerbi->getCapacities();
    test:assertTrue(response.value is Capacity[]);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetApps() returns error? {
    Apps response = check powerbi->getApps();
    test:assertTrue(response.value is App[]);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetPipelines() returns error? {
    Pipelines response = check powerbi->getPipelines();
    test:assertTrue(response.value is Pipeline[]);
}

// A push dataset definition: one table, two columns.
isolated function pushDatasetDefinition(string name) returns CreateDatasetRequest => {
    name,
    defaultMode: "Push",
    tables: [
        {
            name: "Product",
            columns: [
                {name: "ProductID", dataType: "Int64"},
                {name: "Name", dataType: "string"}
            ]
        }
    ]
};
