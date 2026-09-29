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

// Feeds sales figures into a Power BI push dataset and reads the totals back with DAX.
// The dataset is created in the workspace on first run and reused afterwards.

import ballerina/io;
import ballerinax/power.bi;

configurable string token = ?;
configurable string workspaceId = ?;
configurable string datasetName = ?;
configurable string saleDate = ?;

const TABLE_NAME = "Sales";

public function main() returns error? {
    bi:Client powerbi = check new ({auth: {token}});

    // Step 1: Reuse the push dataset if the workspace already has one with this name.
    bi:Datasets existing = check powerbi->getDatasetsInGroup(workspaceId);
    string? datasetId = ();
    foreach bi:Dataset dataset in existing.value ?: [] {
        if dataset.name == datasetName {
            datasetId = dataset.id;
            break;
        }
    }

    // Step 2: Otherwise create it, with one table describing a sale.
    if datasetId is () {
        bi:Dataset created = check powerbi->createDatasetInGroup(workspaceId, {
            name: datasetName,
            defaultMode: "Push",
            tables: [
                {
                    name: TABLE_NAME,
                    columns: [
                        {name: "Region", dataType: "string"},
                        {name: "Product", dataType: "string"},
                        {name: "Amount", dataType: "Double"},
                        {name: "SaleDate", dataType: "DateTime"}
                    ]
                }
            ]
        }, defaultRetentionPolicy = "basicFIFO");
        datasetId = created.id;
        io:println("Created push dataset ", datasetName, " (", created.id, ")");
    } else {
        io:println("Reusing push dataset ", datasetName, " (", datasetId, ")");
    }
    string id = <string>datasetId;

    // Step 3: Confirm the dataset exposes the table the rows are pushed into.
    bi:Tables tables = check powerbi->getTablesInGroup(workspaceId, id);
    boolean hasSalesTable = false;
    foreach bi:Table 'table in tables.value ?: [] {
        if 'table.name == TABLE_NAME {
            hasSalesTable = true;
        }
    }
    if !hasSalesTable {
        return error(string `Dataset ${datasetName} has no '${TABLE_NAME}' table`);
    }

    // Step 4: Push the day's sales rows, unless an earlier run already pushed that day. Push
    // datasets cannot delete individual rows, so a rerun for the same day must not append again.
    string dayFilter = check daxDate(saleDate);
    bi:DatasetExecuteQueriesRowResult[] existingRows = check query(powerbi, id, string
            `EVALUATE ROW("Rows", COUNTROWS(FILTER(${TABLE_NAME}, ${TABLE_NAME}[SaleDate] = ${dayFilter})))`);
    anydata existingCount = existingRows.length() > 0 ? existingRows[0]["[Rows]"] : ();
    if existingCount is int && existingCount > 0 {
        io:println("Sales for ", saleDate, " were already pushed; skipping the push");
    } else {
        string saleTime = saleDate + "T00:00:00Z";
        check powerbi->addRowsInGroup(workspaceId, id, TABLE_NAME, {
            rows: [
                {"Region": "West", "Product": "Road bike", "Amount": 1250.0, "SaleDate": saleTime},
                {"Region": "West", "Product": "Helmet", "Amount": 89.5, "SaleDate": saleTime},
                {"Region": "East", "Product": "Road bike", "Amount": 1180.0, "SaleDate": saleTime}
            ]
        });
        io:println("Pushed 3 rows to ", TABLE_NAME);
    }

    // Step 5: Read the day's totals per region back with a DAX query.
    bi:DatasetExecuteQueriesRowResult[] totals = check query(powerbi, id, string
            `EVALUATE SUMMARIZECOLUMNS(${TABLE_NAME}[Region], FILTER(ALL(${TABLE_NAME}[SaleDate]), ${TABLE_NAME}[SaleDate] = ${dayFilter}), "Total", SUM(${TABLE_NAME}[Amount]))`);
    foreach bi:DatasetExecuteQueriesRowResult row in totals {
        io:println(row);
    }
}

// Runs one DAX query against the dataset and returns the rows of its result tables.
function query(bi:Client powerbi, string datasetId, string dax) returns bi:DatasetExecuteQueriesRowResult[]|error {
    bi:DatasetExecuteQueriesResponse response = check powerbi->executeQueriesInGroup(workspaceId, datasetId, {
        queries: [{query: dax}]
    });
    bi:DatasetExecuteQueriesRowResult[] rows = [];
    foreach bi:DatasetExecuteQueriesQueryResult result in response.results ?: [] {
        foreach bi:DatasetExecuteQueriesTableResult resultTable in result.tables ?: [] {
            bi:DatasetExecuteQueriesRowResult[] tableRows = resultTable.rows ?: [];
            rows.push(...tableRows);
        }
    }
    return rows;
}

// Turns a `YYYY-MM-DD` date into a DAX `DATE(...)` expression.
function daxDate(string date) returns string|error {
    string[] parts = re `-`.split(date);
    if parts.length() != 3 {
        return error(string `saleDate must be YYYY-MM-DD, got '${date}'`);
    }
    int year = check int:fromString(parts[0]);
    int month = check int:fromString(parts[1]);
    int day = check int:fromString(parts[2]);
    return string `DATE(${year}, ${month}, ${day})`;
}
