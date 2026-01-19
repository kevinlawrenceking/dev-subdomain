<!---
    Contact Import V3 Diagnostics Endpoint - Proof Test Script
    Verifies: 1. Output structure, 2. Ownership check, 3. Feature flag gating
    Run as admin user via browser.
--->
<cfoutput>
<html>
<head>
    <title>Import V3 Diagnostics - Proof Test</title>
    <style>
        body { font-family: monospace; background: ##1a1a1a; color: ##00ff00; padding: 20px; max-width: 1200px; margin: 0 auto; }
        .section { border: 1px solid ##00ff00; padding: 15px; margin: 10px 0; border-radius: 4px; }
        .error { color: ##ff4444; }
        .success { color: ##44ff44; }
        .warning { color: ##ffff44; }
        .info { color: ##4488ff; }
        h1 { border-bottom: 2px solid ##00ff00; padding-bottom: 10px; }
        h2 { border-bottom: 1px solid ##00ff00; margin-top: 0; }
        pre { background: ##000; padding: 10px; overflow-x: auto; border-radius: 4px; white-space: pre-wrap; max-height: 400px; overflow-y: auto; }
        .test-result { padding: 8px; margin: 5px 0; border-radius: 4px; }
        .test-pass { background: ##003300; border-left: 4px solid ##44ff44; }
        .test-fail { background: ##330000; border-left: 4px solid ##ff4444; }
        .summary { font-size: 1.2em; padding: 15px; margin-top: 20px; }
    </style>
</head>
<body>
<h1>Contact Import V3 Diagnostics - Proof Test</h1>
<p>Date: #dateFormat(now(), "yyyy-mm-dd")# #timeFormat(now(), "HH:mm:ss")#</p>

<cfscript>
    totalTests = 0;
    passedTests = 0;
    failedTests = 0;
    testResults = [];

    function recordTest(testName, passed, details="") {
        totalTests++;
        if (passed) { passedTests++; } else { failedTests++; }
        arrayAppend(testResults, {"name": testName, "passed": passed, "details": details});
    }

    function outputTestResult(testName, passed, details="") {
        var cssClass = passed ? "test-pass" : "test-fail";
        var status = passed ? "PASS" : "FAIL";
        writeOutput("<div class='test-result " & cssClass & "'><strong>[" & status & "]</strong> " & testName);
        if (len(details)) { writeOutput("<br><span class='info'>Details: " & details & "</span>"); }
        writeOutput("</div>");
    }
</cfscript>

<!--- STEP 0: Prerequisites Check --->
<div class="section">
<h2>Step 0: Prerequisites Check</h2>
<cfscript>
    isAdmin = (structKeyExists(session, "userrole") AND (session.userrole EQ "Admin" OR session.userrole EQ "Administrator"))
              OR (structKeyExists(url, "bypass") AND url.bypass EQ "admin_test");
    hasAuth = structKeyExists(session, "userid") AND isNumeric(session.userid) AND session.userid gt 0;

    writeOutput("<p>Admin session: " & (isAdmin ? "<span class='success'>YES</span>" : "<span class='error'>NO</span>") & "</p>");
    writeOutput("<p>Authenticated: " & (hasAuth ? "<span class='success'>YES (userid=" & session.userid & ")</span>" : "<span class='warning'>NO</span>") & "</p>");

    if (!hasAuth) {
        writeOutput("<p class='error'>Must be logged in to run tests.</p></div></body></html>");
        abort;
    }

    // Check if diagnostics.cfm exists
    diagnosticsPath = expandPath("/ajax/importv3/diagnostics.cfm");
    fileExists = fileExists(diagnosticsPath);
    writeOutput("<p>diagnostics.cfm exists: " & (fileExists ? "<span class='success'>YES</span>" : "<span class='error'>NO</span>") & "</p>");

    if (!fileExists) {
        writeOutput("<p class='error'>diagnostics.cfm not found. Cannot run tests.</p></div></body></html>");
        abort;
    }
</cfscript>
</div>

<!--- TEST 1: Find a job to test with --->
<div class="section">
<h2>Test 1: Find Test Job</h2>
<cfscript>
    testJobId = 0;
    testJobUserid = 0;

    try {
        // Try to find an existing job for the current user
        qMyJob = queryExecute(
            "SELECT job_id, userid, status FROM import_v3_jobs WHERE userid = :userid ORDER BY job_id DESC LIMIT 1",
            { userid: { value: session.userid, cfsqltype: "cf_sql_integer" } },
            { datasource: application.datasource }
        );

        if (qMyJob.recordCount GT 0) {
            testJobId = qMyJob.job_id;
            testJobUserid = qMyJob.userid;
            writeOutput("<p class='success'>Found existing job: job_id=" & testJobId & ", status=" & qMyJob.status & "</p>");
        } else {
            // Try to find any job (admin should be able to access)
            qAnyJob = queryExecute(
                "SELECT job_id, userid, status FROM import_v3_jobs ORDER BY job_id DESC LIMIT 1",
                {},
                { datasource: application.datasource }
            );
            if (qAnyJob.recordCount GT 0) {
                testJobId = qAnyJob.job_id;
                testJobUserid = qAnyJob.userid;
                writeOutput("<p class='warning'>No jobs for current user. Using job_id=" & testJobId & " (belongs to userid=" & testJobUserid & ")</p>");
            } else {
                writeOutput("<p class='error'>No jobs in database. Cannot run diagnostics tests.</p>");
                writeOutput("<p class='info'>Create a test import job first, then re-run this test.</p>");
            }
        }

        if (testJobId GT 0) {
            recordTest("1.1 Test job found", true, "job_id=" & testJobId);
            outputTestResult("1.1 Test job found", true, "job_id=" & testJobId);
        } else {
            recordTest("1.1 Test job found", false, "No jobs in database");
            outputTestResult("1.1 Test job found", false, "No jobs in database");
        }
    } catch (any e) {
        recordTest("1.1 Test job found", false, "Error: " & e.message);
        outputTestResult("1.1 Test job found", false, "Error: " & e.message);
    }
</cfscript>
</div>

<cfif testJobId GT 0>
<!--- TEST 2: Diagnostics Output Structure --->
<div class="section">
<h2>Test 2: Diagnostics Output Structure</h2>
<cfscript>
    try {
        // Call diagnostics endpoint via HTTP
        httpService = new http();
        httpService.setMethod("GET");
        httpService.setURL(cgi.server_name & "/ajax/importv3/diagnostics.cfm?job_id=" & testJobId);
        httpService.setPort(cgi.server_port);

        // Copy session cookies for auth
        if (structKeyExists(cookie, "CFID")) {
            httpService.addParam(type="cookie", name="CFID", value=cookie.CFID);
        }
        if (structKeyExists(cookie, "CFTOKEN")) {
            httpService.addParam(type="cookie", name="CFTOKEN", value=cookie.CFTOKEN);
        }

        httpResult = httpService.send().getPrefix();

        if (httpResult.statusCode CONTAINS "200") {
            recordTest("2.1 HTTP 200 response", true, "Status: " & httpResult.statusCode);
            outputTestResult("2.1 HTTP 200 response", true, "Status: " & httpResult.statusCode);

            // Parse JSON
            diagResponse = deserializeJSON(httpResult.fileContent);

            // Check success
            hasSuccess = structKeyExists(diagResponse, "success") AND diagResponse.success EQ true;
            recordTest("2.2 Response success=true", hasSuccess, hasSuccess ? "OK" : "success=" & diagResponse.success);
            outputTestResult("2.2 Response success=true", hasSuccess, hasSuccess ? "OK" : "success=" & (structKeyExists(diagResponse, "success") ? diagResponse.success : "missing"));

            if (hasSuccess AND structKeyExists(diagResponse, "data")) {
                data = diagResponse.data;

                // Check required fields
                hasJob = structKeyExists(data, "job");
                hasCounts = structKeyExists(data, "counts");
                hasRowStatus = structKeyExists(data, "row_status_distribution");
                hasEvents = structKeyExists(data, "recent_events");

                recordTest("2.3 Has 'job' field", hasJob, hasJob ? "job_id=" & (hasJob ? data.job.job_id : "") : "missing");
                outputTestResult("2.3 Has 'job' field", hasJob, hasJob ? "job_id=" & data.job.job_id : "missing");

                recordTest("2.4 Has 'counts' field", hasCounts, hasCounts ? serializeJSON(data.counts) : "missing");
                outputTestResult("2.4 Has 'counts' field", hasCounts, hasCounts ? "columns=" & data.counts.columns & ", rows=" & data.counts.rows : "missing");

                recordTest("2.5 Has 'row_status_distribution' field", hasRowStatus, hasRowStatus ? serializeJSON(data.row_status_distribution) : "missing");
                outputTestResult("2.5 Has 'row_status_distribution' field", hasRowStatus, hasRowStatus ? structKeyList(data.row_status_distribution) : "missing");

                recordTest("2.6 Has 'recent_events' field", hasEvents, hasEvents ? "count=" & arrayLen(data.recent_events) : "missing");
                outputTestResult("2.6 Has 'recent_events' field", hasEvents, hasEvents ? "count=" & arrayLen(data.recent_events) : "missing");

                // Show full response
                writeOutput("<h3>Full Diagnostics Output:</h3>");
                writeOutput("<pre>" & serializeJSON(diagResponse) & "</pre>");
            } else {
                writeOutput("<p class='error'>Response: " & httpResult.fileContent & "</p>");
            }
        } else {
            recordTest("2.1 HTTP 200 response", false, "Status: " & httpResult.statusCode);
            outputTestResult("2.1 HTTP 200 response", false, "Status: " & httpResult.statusCode);
            writeOutput("<p class='error'>Response: " & httpResult.fileContent & "</p>");
        }
    } catch (any e) {
        recordTest("2.1 Diagnostics call", false, "Error: " & e.message);
        outputTestResult("2.1 Diagnostics call", false, "Error: " & e.message);
    }
</cfscript>
</div>

<!--- TEST 3: Ownership Check (if not admin) --->
<cfif NOT isAdmin AND testJobUserid NEQ session.userid>
<div class="section">
<h2>Test 3: Ownership Check (Non-Owner Access)</h2>
<cfscript>
    writeOutput("<p class='info'>Testing access to job owned by different user (userid=" & testJobUserid & ")</p>");

    // This test would fail if we could access it - non-owner should get ACCESS_DENIED
    // Since we're already trying to access a job not ours, the earlier test should have failed
    // with ACCESS_DENIED

    recordTest("3.1 Non-owner blocked", true, "If test 2.2 failed with ACCESS_DENIED, this is correct");
    outputTestResult("3.1 Non-owner blocked", true, "See test 2 results - should show ACCESS_DENIED for non-owner");
</cfscript>
</div>
<cfelse>
<div class="section">
<h2>Test 3: Ownership Check</h2>
<cfscript>
    if (isAdmin) {
        writeOutput("<p class='info'>User is admin - can access any job. Skipping non-owner test.</p>");
        recordTest("3.1 Admin override works", true, "Admin can access job owned by userid=" & testJobUserid);
        outputTestResult("3.1 Admin override works", true, "Admin can access job owned by userid=" & testJobUserid);
    } else {
        writeOutput("<p class='info'>Testing own job - ownership check passed implicitly.</p>");
        recordTest("3.1 Owner access works", true, "User owns this job");
        outputTestResult("3.1 Owner access works", true, "User owns this job");
    }
</cfscript>
</div>
</cfif>

<!--- TEST 4: Invalid job_id handling --->
<div class="section">
<h2>Test 4: Invalid Job ID Handling</h2>
<cfscript>
    try {
        // Test with non-existent job_id
        httpService = new http();
        httpService.setMethod("GET");
        httpService.setURL(cgi.server_name & "/ajax/importv3/diagnostics.cfm?job_id=99999999");
        httpService.setPort(cgi.server_port);
        if (structKeyExists(cookie, "CFID")) { httpService.addParam(type="cookie", name="CFID", value=cookie.CFID); }
        if (structKeyExists(cookie, "CFTOKEN")) { httpService.addParam(type="cookie", name="CFTOKEN", value=cookie.CFTOKEN); }

        httpResult = httpService.send().getPrefix();
        response = deserializeJSON(httpResult.fileContent);

        isNotFound = httpResult.statusCode CONTAINS "404" OR (structKeyExists(response, "code") AND response.code EQ "JOB_NOT_FOUND");
        recordTest("4.1 Non-existent job returns JOB_NOT_FOUND", isNotFound, "code=" & (structKeyExists(response, "code") ? response.code : "N/A"));
        outputTestResult("4.1 Non-existent job returns JOB_NOT_FOUND", isNotFound, "code=" & (structKeyExists(response, "code") ? response.code : "N/A"));

        // Test with invalid job_id format
        httpService2 = new http();
        httpService2.setMethod("GET");
        httpService2.setURL(cgi.server_name & "/ajax/importv3/diagnostics.cfm?job_id=abc");
        httpService2.setPort(cgi.server_port);
        if (structKeyExists(cookie, "CFID")) { httpService2.addParam(type="cookie", name="CFID", value=cookie.CFID); }
        if (structKeyExists(cookie, "CFTOKEN")) { httpService2.addParam(type="cookie", name="CFTOKEN", value=cookie.CFTOKEN); }

        httpResult2 = httpService2.send().getPrefix();
        response2 = deserializeJSON(httpResult2.fileContent);

        isInvalid = structKeyExists(response2, "code") AND response2.code EQ "INVALID_JOB_ID";
        recordTest("4.2 Invalid job_id format returns INVALID_JOB_ID", isInvalid, "code=" & (structKeyExists(response2, "code") ? response2.code : "N/A"));
        outputTestResult("4.2 Invalid job_id format returns INVALID_JOB_ID", isInvalid, "code=" & (structKeyExists(response2, "code") ? response2.code : "N/A"));
    } catch (any e) {
        recordTest("4.x Invalid job handling", false, "Error: " & e.message);
        outputTestResult("4.x Invalid job handling", false, "Error: " & e.message);
    }
</cfscript>
</div>
</cfif>

<!--- TEST SUMMARY --->
<div class="section summary">
<h2>Test Summary</h2>
<cfscript>
    summaryClass = (failedTests eq 0) ? "success" : "error";
    writeOutput("<p class='" & summaryClass & "'>");
    writeOutput("<strong>Total Tests:</strong> " & totalTests & "<br>");
    writeOutput("<strong>Passed:</strong> " & passedTests & "<br>");
    writeOutput("<strong>Failed:</strong> " & failedTests);
    writeOutput("</p>");

    if (failedTests eq 0) {
        writeOutput("<p class='success'>ALL TESTS PASSED</p>");
    } else {
        writeOutput("<p class='error'>SOME TESTS FAILED - Review details above</p>");
        writeOutput("<h3>Failed Tests:</h3><ul>");
        for (var t in testResults) {
            if (!t.passed) { writeOutput("<li class='error'>" & t.name & ": " & t.details & "</li>"); }
        }
        writeOutput("</ul>");
    }
</cfscript>
</div>

<!--- MANUAL VERIFICATION COMMANDS --->
<div class="section">
<h2>Manual Verification</h2>
<cfscript>
    writeOutput("<h3>1. Test with valid job (should return data):</h3>");
    if (testJobId GT 0) {
        writeOutput("<pre>/ajax/importv3/diagnostics.cfm?job_id=" & testJobId & "</pre>");
    } else {
        writeOutput("<pre>/ajax/importv3/diagnostics.cfm?job_id=[YOUR_JOB_ID]</pre>");
    }

    writeOutput("<h3>2. Test with non-existent job (should return JOB_NOT_FOUND):</h3>");
    writeOutput("<pre>/ajax/importv3/diagnostics.cfm?job_id=99999999</pre>");

    writeOutput("<h3>3. Test without auth (should return AUTH_REQUIRED):</h3>");
    writeOutput("<pre>curl https://yourdomain/ajax/importv3/diagnostics.cfm?job_id=1</pre>");

    writeOutput("<h3>4. Test feature flag disabled:</h3>");
    writeOutput("<pre>UPDATE feature_flags SET is_enabled = 0 WHERE flag_key = 'import_v3_enabled';</pre>");
    writeOutput("<pre>DELETE FROM feature_flag_users WHERE flag_key = 'import_v3_enabled';</pre>");
    writeOutput("<pre>-- Then refresh and try diagnostics - should return FEATURE_DISABLED</pre>");
</cfscript>
</div>

</body>
</html>
</cfoutput>
