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

// Reviews the refresh health of every refreshable dataset in a workspace: its schedule and
// its most recent refreshes. Optionally triggers an on-demand refresh of the datasets whose
// latest refresh failed.

import ballerina/io;
import ballerinax/power.bi;

configurable string token = ?;
configurable string workspaceId = ?;
configurable int historyDepth = 5;
configurable boolean refreshFailed = false;

public function main() returns error? {
    bi:Client powerbi = check new ({auth: {token}});

    // Step 1: List the workspace's datasets and keep the refreshable ones.
    bi:Datasets datasets = check powerbi->getDatasetsInGroup(workspaceId);
    foreach bi:Dataset dataset in datasets.value ?: [] {
        if dataset.isRefreshable != true {
            continue;
        }
        io:println(string `${dataset.name ?: dataset.id} (${dataset.id})`);

        // Step 2: Show the scheduled refresh configuration.
        bi:RefreshSchedule schedule = check powerbi->getRefreshScheduleInGroup(workspaceId, dataset.id);
        if schedule.enabled == true {
            string[] days = from string day in schedule.days ?: [] select day;
            io:println("  schedule: ", string:'join(", ", ...days), " at ",
                    string:'join(", ", ...(schedule.times ?: [])), " (", schedule.localTimeZoneId ?: "UTC", ")");
        } else {
            io:println("  schedule: disabled");
        }

        // Step 3: Show the most recent refreshes, newest first.
        bi:Refreshes history = check powerbi->getRefreshHistoryInGroup(workspaceId, dataset.id,
                top = historyDepth);
        bi:Refresh[] refreshes = history.value ?: [];
        foreach bi:Refresh refresh in refreshes {
            string status = refresh.status ?: "Unknown";
            string refreshType = refresh.refreshType ?: "Unknown";
            io:println("  ", refresh.startTime ?: "-", "  ", refreshType, "  ", status);
        }

        // Step 4: Optionally re-run a refresh whose latest attempt failed. MailOnFailure emails the
        // owner only when the token belongs to a user; with a service principal token no email is sent.
        if refreshes.length() > 0 && refreshes[0].status == "Failed" {
            if refreshFailed {
                check powerbi->refreshDatasetInGroup(workspaceId, dataset.id,
                        {notifyOption: "MailOnFailure"});
                io:println("  latest refresh failed; triggered an on-demand refresh");
            } else {
                io:println("  latest refresh failed; set refreshFailed = true to re-run it");
            }
        }
    }
}
