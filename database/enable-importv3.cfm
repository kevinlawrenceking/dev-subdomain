<cfsilent>
<!--- One-time script to enable Contact Import V3 globally --->
<cfset datasource = "reach">
</cfsilent>
<!DOCTYPE html>
<html>
<head><title>Enable Import V3</title></head>
<body style="font-family: Arial, sans-serif; padding: 20px;">
<h2>Enable Contact Import V3</h2>

<cfscript>
try {
    // Check current status
    qCheck = queryExecute(
        "SELECT * FROM feature_flags WHERE flag_key = 'import_v3_enabled'",
        {},
        { datasource: datasource }
    );

    writeOutput("<h3>Current Status:</h3>");
    if (qCheck.recordCount eq 0) {
        writeOutput("<p style='color:orange;'>Flag row does not exist. Creating...</p>");
        queryExecute(
            "INSERT INTO feature_flags (flag_key, is_enabled, description, created_at)
             VALUES ('import_v3_enabled', 1, 'Contact Import V3 Feature', NOW())",
            {},
            { datasource: datasource }
        );
        writeOutput("<p style='color:green;'>Created and ENABLED.</p>");
    } else if (qCheck.is_enabled eq 0) {
        writeOutput("<p style='color:orange;'>Flag exists but is DISABLED. Enabling...</p>");
        queryExecute(
            "UPDATE feature_flags SET is_enabled = 1 WHERE flag_key = 'import_v3_enabled'",
            {},
            { datasource: datasource }
        );
        writeOutput("<p style='color:green;'>ENABLED.</p>");
    } else {
        writeOutput("<p style='color:green;'>Already ENABLED.</p>");
    }

    // Refresh application scope
    writeOutput("<h3>Refreshing Application Scope...</h3>");

    // Call the refresh function if it exists
    if (structKeyExists(application, "loadFeatureFlags") && isCustomFunction(application.loadFeatureFlags)) {
        application.loadFeatureFlags();
        writeOutput("<p style='color:green;'>Called application.loadFeatureFlags()</p>");
    } else {
        // Manually set the flag
        if (!structKeyExists(application, "features")) {
            application.features = {};
        }
        application.features.importV3Enabled = true;
        writeOutput("<p style='color:green;'>Manually set application.features.importV3Enabled = true</p>");
    }

    // Verify
    writeOutput("<h3>Verification:</h3>");
    writeOutput("<p>application.features.importV3Enabled = <strong>" &
        (structKeyExists(application, "features") && structKeyExists(application.features, "importV3Enabled")
            ? application.features.importV3Enabled : "undefined") & "</strong></p>");

    writeOutput("<h3>Done!</h3>");
    writeOutput("<p><a href='/app/contacts-import-v3/'>Go to Contact Import V3</a></p>");

} catch (any e) {
    writeOutput("<p style='color:red;'>Error: " & e.message & "</p>");
    writeOutput("<pre>" & e.detail & "</pre>");
}
</cfscript>

</body>
</html>
