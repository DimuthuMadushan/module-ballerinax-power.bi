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

    // Step 4: Push the day's sales rows.
    check powerbi->addRowsInGroup(workspaceId, id, TABLE_NAME, {
        rows: [
            {"Region": "West", "Product": "Road bike", "Amount": 1250.0, "SaleDate": saleDate},
            {"Region": "West", "Product": "Helmet", "Amount": 89.5, "SaleDate": saleDate},
            {"Region": "East", "Product": "Road bike", "Amount": 1180.0, "SaleDate": saleDate}
        ]
    });
    io:println("Pushed 3 rows to ", TABLE_NAME);

    // Step 5: Read the totals per region back with a DAX query.
    bi:DatasetExecuteQueriesResponse response = check powerbi->executeQueriesInGroup(workspaceId, id, {
        queries: [
            {query: string `EVALUATE SUMMARIZECOLUMNS(${TABLE_NAME}[Region], "Total", SUM(${TABLE_NAME}[Amount]))`}
        ]
    });
    foreach bi:DatasetExecuteQueriesQueryResult result in response.results ?: [] {
        foreach bi:DatasetExecuteQueriesTableResult resultTable in result.tables ?: [] {
            foreach bi:DatasetExecuteQueriesRowResult row in resultTable.rows ?: [] {
                io:println(row);
            }
        }
    }
}
