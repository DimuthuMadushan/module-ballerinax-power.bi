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

listener http:Listener ep0 = new (9090);

service / on ep0 {
    # Deletes the specified dashboard from **My workspace**.
    #
    # + dashboardId - The dashboard ID
    # + return - OK 
    resource function delete dashboards/[string dashboardId]() returns http:Ok {
        return http:OK;
    }

    # Deletes the specified dataset from **My workspace**.
    #
    # + datasetId - The dataset ID
    # + return - OK 
    resource function delete datasets/[string datasetId]() returns http:Ok {
        return http:OK;
    }

    # Deletes the specified workspace.
    #
    # + groupId - The workspace ID
    # + return - OK 
    resource function delete groups/[string groupId]() returns http:Ok {
        return http:OK;
    }

    # Deletes the specified report from **My workspace**.
    #
    # + reportId - The report ID
    # + return - OK 
    resource function delete reports/[string reportId]() returns http:Ok {
        return http:OK;
    }

    # Returns a list of installed apps.
    #
    # + return - The result of the request that returns a list of installed apps 
    resource function get apps() returns Apps {
        return {
            atOdataContext: "https://api.powerbi.com/v1.0/myorg/$metadata#apps",
            value: [
                {
                    id: "f089354e-8366-4e18-aea3-4cb4a3a50b48",
                    name: "Sales Insights",
                    description: "Quarterly sales performance app",
                    publishedBy: "Bill",
                    lastUpdate: "2025-11-12T08:41:22.35Z"
                }
            ]
        };
    }

    # Returns a list of capacities that the user has access to.
    #
    # + return - The result of the request that returns a list of capacities that the user has access to 
    resource function get capacities() returns Capacities {
        return {
            atOdataContext: "https://api.powerbi.com/v1.0/myorg/$metadata#capacities",
            value: [
                {
                    id: "0f084df7-c13d-451b-af5f-ed0c466403b2",
                    displayName: "MyCapacity",
                    admins: ["john@contoso.com"],
                    sku: "A1",
                    state: "Active",
                    region: "West Central US",
                    capacityUserAccessRight: "Admin"
                }
            ]
        };
    }

    # Returns a list of dashboards from **My workspace**.
    #
    # + return - The result of the request that returns a list of dashboards from My workspace 
    resource function get dashboards() returns Dashboards {
        return {
            atOdataContext: "https://api.powerbi.com/v1.0/myorg/$metadata#dashboards",
            value: [
                {
                    id: "69ffaa6c-b36d-4d01-96f5-1ed67c64d4af",
                    displayName: "SalesMarketing",
                    isReadOnly: false,
                    embedUrl: "https://app.powerbi.com/dashboardEmbed?dashboardId=69ffaa6c-b36d-4d01-96f5-1ed67c64d4af"
                }
            ]
        };
    }

    # Returns a list of tiles within the specified dashboard from **My workspace**.
    #
    # + dashboardId - The dashboard ID
    # + return - The result of the request that returns a list of tiles within the specified dashboard from My workspace 
    resource function get dashboards/[string dashboardId]/tiles() returns Tiles {
        return {
            atOdataContext: "https://api.powerbi.com/v1.0/myorg/$metadata#tiles",
            value: [
                {
                    id: "312fbfe9-2eda-44e0-9ed0-ab5dc571bb4b",
                    title: "SalesMarketingTile",
                    embedUrl: string `https://app.powerbi.com/embed?dashboardId=${dashboardId}&tileId=312fbfe9-2eda-44e0-9ed0-ab5dc571bb4b`,
                    rowSpan: 0,
                    colSpan: 0,
                    reportId: "5b218778-e7a5-4d73-8187-f10824047715",
                    datasetId: "cfafbeb1-8037-4d0c-896e-a46fb27ff229"
                }
            ]
        };
    }

    # Returns a list of datasets from **My workspace**.
    #
    # + return - The result of the request that returns a list of datasets from My workspace 
    resource function get datasets() returns Datasets {
        return {
            atOdataContext: "https://api.powerbi.com/v1.0/myorg/$metadata#datasets",
            value: [mockDataset("cfafbeb1-8037-4d0c-896e-a46fb27ff229", "SalesMarketing")]
        };
    }

    # Returns the specified dataset from **My workspace**.
    #
    # + datasetId - The dataset ID
    # + return - The result of the request that returns the specified dataset from My workspace 
    resource function get datasets/[string datasetId]() returns Dataset {
        return mockDataset(datasetId, "SalesMarketing");
    }

    # Returns the refresh schedule for the specified dataset from **My workspace**.
    #
    # + datasetId - The dataset ID
    # + return - The result of the request that returns the refresh schedule for the specified dataset from My workspace 
    resource function get datasets/[string datasetId]/refreshSchedule() returns RefreshSchedule {
        return {
            days: ["Sunday", "Friday", "Saturday"],
            times: ["05:00", "11:30", "17:30", "23:00"],
            enabled: true,
            localTimeZoneId: "UTC",
            notifyOption: "MailOnFailure"
        };
    }

    # Returns the refresh history for the specified dataset from **My workspace**.
    #
    # + datasetId - The dataset ID
    # + dollarTop - The requested number of entries in the refresh history. If not provided, the default is the last available 60 entries
    # + return - The result of the request that returns the refresh history for the specified dataset from My workspace 
    resource function get datasets/[string datasetId]/refreshes(@http:Query {name: "$top"} int? dollarTop) returns Refreshes {
        return {
            atOdataContext: "https://api.powerbi.com/v1.0/myorg/$metadata#refreshes",
            value: [
                {
                    requestId: "9399bb89-25d1-44f8-8576-136d7e9014b1",
                    refreshType: "ViaApi",
                    startTime: "2025-06-13T09:25:43.153Z",
                    endTime: "2025-06-13T09:31:43.153Z",
                    status: "Completed"
                }
            ]
        };
    }

    # Returns a list of tables within the specified dataset from **My workspace**.
    #
    # + datasetId - The dataset ID
    # + return - The result of the request that returns a list of tables within the specified dataset from My workspace 
    resource function get datasets/[string datasetId]/tables() returns Tables {
        return {
            atOdataContext: "https://api.powerbi.com/v1.0/myorg/$metadata#tables",
            value: [
                {
                    name: "Product",
                    columns: [
                        {name: "ProductID", dataType: "Int64"},
                        {name: "Name", dataType: "string"}
                    ]
                }
            ]
        };
    }

    # Returns a list of gateways for which the user is an admin.
    #
    # + return - The result of the request that returns a list of gateways for which the user is an admin 
    resource function get gateways() returns Gateways {
        return {
            atOdataContext: "https://api.powerbi.com/v1.0/myorg/$metadata#gateways",
            value: [
                {
                    id: "1f69e798-5852-4fdd-ab01-33bb14b6e934",
                    name: "Contoso Gateway",
                    'type: "Resource",
                    gatewayStatus: "Live",
                    publicKey: {exponent: "AQAB", modulus: "o6j2....cLk="}
                }
            ]
        };
    }

    # Returns a list of workspaces the user has access to.
    #
    # + dollarFilter - Returns a subset of a results based on [Odata](https://docs.oasis-open.org/odata/odata/v4.01/odata-v4.01-part2-url-conventions.html#sec_SystemQueryOptions) filter query parameter condition
    # + dollarTop - Returns only the first n results
    # + dollarSkip - Skips the first n results
    # + return - The result of the request that returns a list of workspaces the user has access to 
    resource function get groups(@http:Query {name: "$filter"} string? dollarFilter, @http:Query {name: "$top"} int:Signed32? dollarTop, @http:Query {name: "$skip"} int:Signed32? dollarSkip) returns Groups {
        return {
            atOdataContext: "https://api.powerbi.com/v1.0/myorg/$metadata#groups",
            value: [
                {
                    id: "f089354e-8366-4e18-aea3-4cb4a3a50b48",
                    name: "Sales Team",
                    isReadOnly: false,
                    isOnDedicatedCapacity: false
                }
            ]
        };
    }

    # Returns a list of users that have access to the specified workspace.
    #
    # + groupId - The workspace ID
    # + dollarTop - Returns only the first n results
    # + dollarSkip - Skips the first n results
    # + return - The result of the request that returns a list of users that have access to the specified workspace 
    resource function get groups/[string groupId]/users(@http:Query {name: "$top"} int:Signed32? dollarTop, @http:Query {name: "$skip"} int:Signed32? dollarSkip) returns GroupUsers {
        return {
            atOdataContext: "https://api.powerbi.com/v1.0/myorg/$metadata#groupUsers",
            value: [
                {
                    identifier: "john@contoso.com",
                    displayName: "John Nick",
                    emailAddress: "john@contoso.com",
                    groupUserAccessRight: "Admin",
                    principalType: "User"
                }
            ]
        };
    }

    # Returns a list of imports from **My workspace**.
    #
    # + return - The result of the request that returns a list of imports from My workspace 
    resource function get imports() returns Imports {
        return {
            atOdataContext: "https://api.powerbi.com/v1.0/myorg/$metadata#imports",
            value: [
                {
                    id: "82d9a37a-2b45-4221-b012-cb109b8e30c7",
                    name: "SalesMarketing",
                    importState: "Succeeded",
                    createdDateTime: "2025-05-08T13:28:25.99Z",
                    updatedDateTime: "2025-05-08T13:28:36.293Z"
                }
            ]
        };
    }

    # Returns a list of deployment pipelines that the user has access to.
    #
    # + return - The result of the request that returns a list of deployment pipelines that the user has access to 
    resource function get pipelines() returns Pipelines {
        return {
            atOdataContext: "https://api.powerbi.com/v1.0/myorg/$metadata#pipelines",
            value: [
                {
                    id: "a5ded933-57b7-41f4-b072-ed4c1f9d5824",
                    displayName: "Marketing Deployment Pipeline",
                    description: "Power BI deployment pipeline to manage marketing reports"
                }
            ]
        };
    }

    # Returns a list of reports from **My workspace**.
    #
    # + return - The result of the request that returns a list of reports from My workspace 
    resource function get reports() returns Reports {
        return {
            atOdataContext: "https://api.powerbi.com/v1.0/myorg/$metadata#reports",
            value: [mockReport("5b218778-e7a5-4d73-8187-f10824047715", "SalesMarketing")]
        };
    }

    # Returns the specified report from **My workspace**.
    #
    # + reportId - The report ID
    # + return - The result of the request that returns the specified report from My workspace 
    resource function get reports/[string reportId]() returns Report {
        return mockReport(reportId, "SalesMarketing");
    }

    # Returns a list of pages within the specified report from **My workspace**.
    #
    # + reportId - The report ID
    # + return - The result of the request that returns a list of pages within the specified report from My workspace 
    resource function get reports/[string reportId]/pages() returns Pages {
        return {
            atOdataContext: "https://api.powerbi.com/v1.0/myorg/$metadata#pages",
            value: [
                {name: "ReportSection", displayName: "Regional Sales Analysis", 'order: 0},
                {name: "ReportSection600dd9293d71ade01765", displayName: "Geographic Analysis", 'order: 1}
            ]
        };
    }

    # Updates the refresh schedule for the specified dataset from **My workspace**.
    #
    # + datasetId - The dataset ID
    # + payload - Update Refresh Schedule parameters, by specifying all or some of the parameters 
    # + return - OK 
    resource function patch datasets/[string datasetId]/refreshSchedule(@http:Payload RefreshScheduleRequest payload) returns http:Ok {
        return http:OK;
    }

    # Creates a new empty dashboard in **My workspace**.
    #
    # + payload - Add dashboard parameters 
    # + return - The result of the request that creates a new empty dashboard in My workspace 
    resource function post dashboards(@http:Payload AddDashboardRequest payload) returns DashboardOk {
        Dashboard dashboard = {
            id: "a4b2f2f1-9e4c-4d8a-8b6f-2f6a3c1d9e70",
            displayName: payload.name,
            isReadOnly: false,
            embedUrl: "https://app.powerbi.com/dashboardEmbed?dashboardId=a4b2f2f1-9e4c-4d8a-8b6f-2f6a3c1d9e70"
        };
        return {body: dashboard};
    }

    # Creates a new dataset on **My workspace**.
    #
    # + defaultRetentionPolicy - The default retention policy
    # + payload - Dataset definition to create 
    # + return - returns can be any of following types 
    # http:Created (The result of the request that creates a new dataset on My workspace)
    # http:Accepted (The result of the request that creates a new dataset on My workspace)
    resource function post datasets("None"|"basicFIFO"? defaultRetentionPolicy, @http:Payload CreateDatasetRequest payload) returns Dataset|DatasetAccepted {
        Dataset dataset = mockDataset("7a2b9f41-3e8d-4c5a-9a61-0d2e4f6b8c13", payload.name);
        return dataset;
    }

    # Executes Data Analysis Expressions (DAX) queries against the provided dataset. The dataset must reside in **My workspace** or another workspace.
    #
    # + datasetId - The dataset ID
    # + payload - The request message 
    # + return - The result of the request that executes Data Analysis Expressions (DAX) queries against the provided dataset. The dataset must reside in My workspace or another workspace 
    resource function post datasets/[string datasetId]/executeQueries(@http:Payload DatasetExecuteQueriesRequest payload) returns DatasetExecuteQueriesResponseOk {
        DatasetExecuteQueriesResponse result = {
            results: [
                {
                    tables: [
                        {
                            rows: [
                                {"MyTable[Year]": 2010, "MyTable[Quarter]": "Q1"},
                                {"MyTable[Year]": 2010, "MyTable[Quarter]": "Q2"}
                            ]
                        }
                    ]
                }
            ]
        };
        return {body: result};
    }

    # Triggers a refresh for the specified dataset from **My workspace**. An [enhanced refresh](/power-bi/connect-data/asynchronous-refresh) is triggered only if a request payload other than `notifyOption` is set.
    #
    # + datasetId - The dataset ID
    # + payload - Refresh options: notification option and, for an enhanced refresh, the objects and refresh type 
    # + return - Accepted 
    resource function post datasets/[string datasetId]/refreshes(@http:Payload DatasetRefreshRequest payload) returns http:Accepted {
        return http:ACCEPTED;
    }

    # Adds new data rows to the specified table within the specified dataset from **My workspace**.
    #
    # + datasetId - The dataset ID
    # + tableName - The table name
    # + payload - The request message 
    # + return - OK 
    resource function post datasets/[string datasetId]/tables/[string tableName]/rows(@http:Payload PostRowsRequest payload) returns http:Ok {
        return http:OK;
    }

    # Creates a new workspace.
    #
    # + workspaceV2 - (Preview feature) Whether to create a workspace. The only supported value is `true`
    # + payload - Create group request parameters 
    # + return - The result of the request that creates a new workspace 
    resource function post groups(boolean? workspaceV2, @http:Payload GroupCreationRequest payload) returns GroupOk {
        Group group = {
            id: "e2284830-c8dc-416b-b19a-8cdcd2729332",
            name: payload.name,
            isReadOnly: false,
            isOnDedicatedCapacity: false
        };
        return {body: group};
    }

    # Grants the specified user the specified permissions to the specified workspace.
    #
    # + groupId - The workspace ID
    # + payload - Details of user access right 
    # + return - OK 
    resource function post groups/[string groupId]/users(@http:Payload GroupUser payload) returns http:Ok {
        return http:OK;
    }

    # Clones the specified report from **My workspace**.
    #
    # + reportId - The report ID
    # + payload - Clone report parameters 
    # + return - The result of the request that clones the specified report from My workspace 
    resource function post reports/[string reportId]/Clone(@http:Payload CloneReportRequest payload) returns ReportOk {
        Report report = mockReport("c1a8e4d2-6b3f-4a9e-8d17-5f2b0c9e4a61", payload.name);
        return {body: report};
    }
}

isolated function mockDataset(string id, string name) returns Dataset => {
    id,
    name,
    configuredBy: "john@contoso.com",
    isRefreshable: true,
    isEffectiveIdentityRequired: false,
    isEffectiveIdentityRolesRequired: false,
    isOnPremGatewayRequired: false,
    createdDate: "2025-04-11T12:37:38.33Z"
};

isolated function mockReport(string id, string name) returns Report => {
    id,
    name,
    datasetId: "cfafbeb1-8037-4d0c-896e-a46fb27ff229",
    reportType: "PowerBIReport",
    webUrl: string `https://app.powerbi.com/reports/${id}`,
    embedUrl: string `https://app.powerbi.com/reportEmbed?reportId=${id}`
};

// Service-mode response types. `bal openapi --mode client` collapses 4XX/5XX
// to `error` and never emits these, so they are defined here for the mock only.
public type DashboardOk record {|
    *http:Ok;
    Dashboard body;
|};

public type DatasetAccepted record {|
    *http:Accepted;
    Dataset body;
|};

public type DatasetExecuteQueriesResponseOk record {|
    *http:Ok;
    DatasetExecuteQueriesResponse body;
|};

public type GroupOk record {|
    *http:Ok;
    Group body;
|};

public type ReportOk record {|
    *http:Ok;
    Report body;
|};
