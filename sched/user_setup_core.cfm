<!---
    PURPOSE: Core user setup for TAO (The Actor's Office) system
    AUTHOR: Updated by GitHub Copilot 
    DATE: 2025-07-22
    PARAMETERS: select_userid, select_contactid (optional), dbug (optional)
    DEPENDENCIES: Application.cfc with DSN configured
--->

<cfscript>
    // Use datasource from Application.cfc
    variables.dsn = application.dsn;
    
    // Parameters with validation
    param name="dbugz" default="N";
    param name="dbug" default="Y"; 
    param name="select_user" default="0";
    param name="select_contactid" default="0";
    param name="select_userid" default="0";
    
    // Debug helper function
    function debugLog(message, showCondition = variables.dbug == "Y") {
        if (showCondition) {
            writeOutput("<p style='color: ##666; font-size: 12px;'>" & message & "</p>");
        }
    }
    
    // Enhanced error logging function
    function logDatabaseError(operation, sql, params, error) {
        var errorDetails = "<div style='border: 1px solid red; padding: 10px; margin: 5px; background: ##ffe6e6;'>";
        errorDetails &= "<strong style='color: red;'>DATABASE ERROR IN: " & operation & "</strong><br>";
        errorDetails &= "<strong>Error Message:</strong> " & htmlEditFormat(error.message) & "<br>";
        if (structKeyExists(error, "detail") && len(error.detail)) {
            errorDetails &= "<strong>Error Detail:</strong> " & htmlEditFormat(error.detail) & "<br>";
        }
        if (structKeyExists(error, "errorCode") && len(error.errorCode)) {
            errorDetails &= "<strong>Error Code:</strong> " & error.errorCode & "<br>";
        }
        if (structKeyExists(error, "sqlState") && len(error.sqlState)) {
            errorDetails &= "<strong>SQL State:</strong> " & error.sqlState & "<br>";
        }
        errorDetails &= "<strong>SQL Query:</strong><br><pre style='background: ##f5f5f5; padding: 5px; overflow-x: auto;'>" & htmlEditFormat(sql) & "</pre>";
        if (isArray(params) && arrayLen(params) > 0) {
            errorDetails &= "<strong>Parameters:</strong> " & serializeJSON(params) & "<br>";
        }
        errorDetails &= "<strong>Datasource:</strong> " & variables.dsn & "<br>";
        errorDetails &= "</div>";
        debugLog(errorDetails, true); // Always show database errors
    }
    
    // Validation
    if (val(select_userid) == 0) {
        writeOutput("<p style='color: red;'>Error: No valid user ID provided</p>");
        abort;
    }
    
    // Scoped variables to avoid conflicts
    variables.userid = val(select_userid);
    variables.starttime = timeFormat(now(), 'HHMMSS');
    
    debugLog("Starting user setup for userID: " & variables.userid);
    
    // Test database connectivity and log details
    try {
        testQuery = queryExecute("SELECT COUNT(*) as recordCount FROM taousers WHERE userid = ?", 
            [variables.userid], {datasource: variables.dsn});
        debugLog("Database connection verified - User " & variables.userid & " exists: " & (testQuery.recordCount > 0 ? "YES" : "NO"));
        
        // Test a few critical tables for existence
        testTables = ["audopencalloptions", "eventtypes", "genderpronouns", "tags", "sitetypes_master"];
        for (tableName in testTables) {
            try {
                tableTest = queryExecute("SELECT COUNT(*) as recordCount FROM " & tableName, {}, {datasource: variables.dsn});
                debugLog("Table '" & tableName & "' accessible - " & tableTest.recordCount & " records");
            } catch (any tableError) {
                debugLog("<span style='color: red;'>Table '" & tableName & "' ERROR: " & tableError.message & "</span>");
            }
        }
    } catch (any e) {
        logDatabaseError("Database Connectivity Test", "SELECT COUNT(*) as recordCount FROM taousers WHERE userid = ?", [variables.userid], e);
    }
    
    // Media path configuration - Fixed application scope pollution
    variables.baseMediaPath = "C:\home\theactorsoffice.com\media-" & variables.dsn;
    variables.baseMediaUrl = "/media-" & variables.dsn;
    variables.imagesPath = variables.baseMediaPath & "\images";
    
    // Set application-level paths (corrected from nested application keys)
    application.imagesUrl = variables.baseMediaUrl & "/images";
    application.datesPath = variables.imagesPath & "\dates";
    application.datesUrl = application.imagesUrl & "/dates";
    application.defaultsPath = variables.imagesPath & "\defaults";
    application.defaultsUrl = application.imagesUrl & "/defaults";
    application.defaultAvatarPath = application.defaultsPath & "/avatar.jpg";
    application.defaultAvatarUrl = application.defaultsUrl & "/avatar.jpg";
    application.emailImagesPath = variables.imagesPath & "\email";
    application.emailImagesUrl = application.imagesUrl & "/email";
    application.filetypesPath = variables.imagesPath & "\filetypes";
    application.filetypesUrl = application.imagesUrl & "/filetypes";
    application.retinaIconsPath = variables.imagesPath & "\retina-circular-icons";
    application.retinaIconsUrl = application.imagesUrl & "/retina-circular-icons";
    application.retinaIcons14Path = application.retinaIconsPath & "\14";
    application.retinaIcons14Url = application.retinaIconsUrl & "/14";
    application.retinaIcons32Path = application.retinaIconsPath & "\32";
    application.retinaIcons32Url = application.retinaIconsUrl & "/32";
    
    // User-specific session paths
    session.userMediaPath = variables.baseMediaPath & "\users\" & variables.userid;
    session.userMediaUrl = variables.baseMediaUrl & "/users/" & variables.userid;
    session.userContactsPath = session.userMediaPath & "\contacts";
    session.userContactsUrl = session.userMediaUrl & "/contacts";
    session.userImportsPath = session.userMediaPath & "\imports";
    session.userImportsUrl = session.userMediaUrl & "/imports";
    session.userExportsPath = session.userMediaPath & "\exports";
    session.userExportsUrl = session.userMediaUrl & "/exports";
    session.userSharePath = session.userMediaPath & "\share";
    session.userShareUrl = session.userMediaUrl & "/share";
    session.userAvatarPath = session.userMediaPath & "\avatar.jpg";
    session.userAvatarUrl = session.userMediaUrl & "/avatar.jpg";
</cfscript>

<cfscript>
    // Directory creation helper function with error handling
    function ensureDirectoryExists(dirPath) {
        try {
            if (!directoryExists(dirPath)) {
                directoryCreate(dirPath);
                debugLog("Created directory: " & dirPath);
                return true;
            }
            return true;
        } catch (any e) {
            debugLog("Failed to create directory: " & dirPath & " - " & e.message);
            return false;
        }
    }
    
    // File copy helper function with error handling
    function ensureFileExists(sourcePath, destPath) {
        try {
            if (!fileExists(destPath) && fileExists(sourcePath)) {
                fileCopy(sourcePath, destPath);
                debugLog("Copied file: " & sourcePath & " to " & destPath);
                return true;
            }
            return fileExists(destPath);
        } catch (any e) {
            debugLog("Failed to copy file: " & sourcePath & " - " & e.message);
            return false;
        }
    }
    
    // Create user media directories
    debugLog("Creating user media directories...");
    ensureDirectoryExists(session.userMediaPath);
    ensureDirectoryExists(session.userContactsPath);
    ensureDirectoryExists(session.userImportsPath);
    ensureDirectoryExists(session.userExportsPath);
    ensureDirectoryExists(session.userSharePath);
    
    // Copy default avatar if needed
    ensureFileExists(application.defaultAvatarPath, session.userAvatarPath);
</cfscript>

<cfscript>
    // Contact directories setup with proper SQL security
    debugLog("Setting up contact directories...");
</cfscript>

<cfquery result="result" datasource="#variables.dsn#" name="contactQuery">
    SELECT contactid, recordname
    FROM contactdetails
    WHERE userid = <cfqueryparam value="#variables.userid#" cfsqltype="CF_SQL_INTEGER">
    <cfif val(select_contactid) neq 0>
        AND contactid = <cfqueryparam value="#val(select_contactid)#" cfsqltype="CF_SQL_INTEGER">
    </cfif>
    ORDER BY contactid
</cfquery>

<cfscript>
    // Process contact directories
    for (contact in contactQuery) {
        local.contactPath = session.userContactsPath & "\" & contact.contactid;
        ensureDirectoryExists(local.contactPath);
        
        local.contactAvatarPath = local.contactPath & "\avatar.jpg";
        if (!fileExists(local.contactAvatarPath) && isDefined("dir_missing_avatar_filename")) {
            ensureFileExists(dir_missing_avatar_filename, local.contactAvatarPath);
        }
    }
    
    debugLog("Processed " & contactQuery.recordCount & " contact directories");
    
    // Generic function to sync lookup tables from master to user tables
    function syncLookupTable(masterTable, userTable, keyField, valueField, additionalFields = "", whereClause = "isdeleted = 0") {
        var insertCount = 0;
        var debugTitle = arguments.userTable;
        var masterSQL = "";
        var checkSQL = "";
        var insertSQL = "";
        
        try {
            // Build SELECT fields list
            var selectFields = "";
            if (len(arguments.keyField)) {
                selectFields = arguments.keyField;
            }
            if (len(arguments.valueField)) {
                selectFields = listAppend(selectFields, arguments.valueField);
            }
            if (len(arguments.additionalFields)) {
                selectFields = listAppend(selectFields, arguments.additionalFields);
            }
            
            // Build and execute master query
            masterSQL = "SELECT " & selectFields & " FROM " & arguments.masterTable & 
                (len(arguments.whereClause) ? " WHERE " & arguments.whereClause : "");
            
            var masterQuery = queryExecute(masterSQL, {}, {datasource: variables.dsn});
            
            for (var row in masterQuery) {
                // Check if record exists for user
                checkSQL = "SELECT COUNT(*) as countValue 
                    FROM " & arguments.userTable & " 
                    WHERE " & arguments.valueField & " = ? AND userid = ?";
                var checkParams = [row[arguments.valueField], variables.userid];
                
                var checkQuery = queryExecute(checkSQL, checkParams, {datasource: variables.dsn});
                
                // Debug for audgenres_user specifically
                if (arguments.userTable == "audgenres_user") {
                    debugLog("Checking if '" & row[arguments.valueField] & "' exists for user " & variables.userid & " (audcatid: " & (structKeyExists(row, "audcatid") ? row.audcatid : "NULL") & ")");
                    debugLog("Check query result: actual count=" & checkQuery.countValue);
                }
                
                // Debug for audplatforms_user specifically
                if (arguments.userTable == "audplatforms_user") {
                    debugLog("Checking if '" & row[arguments.valueField] & "' exists for user " & variables.userid);
                    debugLog("Check query result: actual count=" & checkQuery.countValue);
                }
                
                if (checkQuery.countValue == 0) {
                    // Build insert statement dynamically
                    var insertFields = arguments.valueField & ", userid";
                    var insertValues = "?, ?";
                    var insertParams = [row[arguments.valueField], variables.userid];
                    
                    // Add additional fields if specified
                    if (len(arguments.additionalFields)) {
                        var additionalFieldList = listToArray(arguments.additionalFields);
                        for (var field in additionalFieldList) {
                            // Check if field exists in the row before trying to access it
                            if (structKeyExists(row, field)) {
                                insertFields = listAppend(insertFields, field);
                                insertValues = listAppend(insertValues, "?");
                                arrayAppend(insertParams, row[field]);
                            } else {
                                debugLog("Warning: Field '" & field & "' not found in " & arguments.masterTable & " record, skipping");
                            }
                        }
                    }
                    
                    // Execute insert
                    insertSQL = "INSERT INTO " & arguments.userTable & " (" & insertFields & ") 
                        VALUES (" & insertValues & ")";
                    
                    queryExecute(insertSQL, insertParams, {datasource: variables.dsn});
                    
                    insertCount++;
                    if (insertCount == 1) {
                        debugLog("<strong>" & debugTitle & "</strong>");
                    }
                    debugLog("Added: " & row[arguments.valueField]);
                }
            }
            
            if (insertCount > 0) {
                debugLog("Total " & debugTitle & " records added: " & insertCount);
            }
            
        } catch (any e) {
            // Determine which operation failed and log detailed error
            var failedSQL = "";
            var failedParams = [];
            
            if (len(masterSQL) && !isDefined("masterQuery")) {
                failedSQL = masterSQL;
                failedParams = [];
                logDatabaseError("syncLookupTable - Master Query (" & arguments.masterTable & ")", failedSQL, failedParams, e);
            } else if (len(checkSQL)) {
                failedSQL = checkSQL;
                failedParams = checkParams;
                logDatabaseError("syncLookupTable - Check Query (" & arguments.userTable & ")", failedSQL, failedParams, e);
            } else if (len(insertSQL)) {
                failedSQL = insertSQL;
                failedParams = insertParams;
                logDatabaseError("syncLookupTable - Insert Query (" & arguments.userTable & ")", failedSQL, failedParams, e);
            } else {
                logDatabaseError("syncLookupTable - Unknown (" & arguments.masterTable & " -> " & arguments.userTable & ")", "Unknown SQL", [], e);
            }
        }
        
        return insertCount;
    }
    
    // Specialized function for tables with category fields (like audgenres with audcatid)
    function syncLookupTableWithCategory(masterTable, userTable, keyField, valueField, categoryField, whereClause = "isdeleted = 0") {
        var insertCount = 0;
        var debugTitle = arguments.userTable;
        var masterSQL = "";
        var checkSQL = "";
        var insertSQL = "";
        
        try {
            // Build SELECT fields list
            var selectFields = arguments.valueField & ", " & arguments.categoryField;
            if (len(arguments.keyField)) {
                selectFields = arguments.keyField & ", " & selectFields;
            }
            
            // Build and execute master query
            masterSQL = "SELECT " & selectFields & " FROM " & arguments.masterTable & 
                (len(arguments.whereClause) ? " WHERE " & arguments.whereClause : "");
            
            var masterQuery = queryExecute(masterSQL, {}, {datasource: variables.dsn});
            
            for (var row in masterQuery) {
                // Check if record exists for user WITH CATEGORY
                checkSQL = "SELECT COUNT(*) as countValue 
                    FROM " & arguments.userTable & " 
                    WHERE " & arguments.valueField & " = ? AND " & arguments.categoryField & " = ? AND userid = ?";
                var checkParams = [row[arguments.valueField], row[arguments.categoryField], variables.userid];
                
                var checkQuery = queryExecute(checkSQL, checkParams, {datasource: variables.dsn});
                
                // Debug for audgenres_user specifically
                if (arguments.userTable == "audgenres_user") {
                    debugLog("Checking if '" & row[arguments.valueField] & "' with audcatid=" & row[arguments.categoryField] & " exists for user " & variables.userid);
                    debugLog("Check query result: actual count=" & checkQuery.countValue);
                }
                
                if (checkQuery.countValue == 0) {
                    // Execute insert
                    insertSQL = "INSERT INTO " & arguments.userTable & " (" & arguments.valueField & ", " & arguments.categoryField & ", userid) 
                        VALUES (?, ?, ?)";
                    var insertParams = [row[arguments.valueField], row[arguments.categoryField], variables.userid];
                    
                    queryExecute(insertSQL, insertParams, {datasource: variables.dsn});
                    
                    insertCount++;
                    if (insertCount == 1) {
                        debugLog("<strong>" & debugTitle & " (with category consideration)</strong>");
                    }
                    debugLog("Added: " & row[arguments.valueField] & " (audcatid: " & row[arguments.categoryField] & ")");
                }
            }
            
            if (insertCount > 0) {
                debugLog("Total " & debugTitle & " records added: " & insertCount);
            }
            
        } catch (any e) {
            // Determine which operation failed and log detailed error
            var failedSQL = "";
            var failedParams = [];
            
            if (len(masterSQL) && !isDefined("masterQuery")) {
                failedSQL = masterSQL;
                failedParams = [];
                logDatabaseError("syncLookupTableWithCategory - Master Query (" & arguments.masterTable & ")", failedSQL, failedParams, e);
            } else if (len(checkSQL)) {
                failedSQL = checkSQL;
                failedParams = checkParams;
                logDatabaseError("syncLookupTableWithCategory - Check Query (" & arguments.userTable & ")", failedSQL, failedParams, e);
            } else if (len(insertSQL)) {
                failedSQL = insertSQL;
                failedParams = insertParams;
                logDatabaseError("syncLookupTableWithCategory - Insert Query (" & arguments.userTable & ")", failedSQL, failedParams, e);
            } else {
                logDatabaseError("syncLookupTableWithCategory - Unknown (" & arguments.masterTable & " -> " & arguments.userTable & ")", "Unknown SQL", [], e);
            }
        }
        
        return insertCount;
    }
    
    // Specialized function for cross-reference tables (like itemcatxref with typeid/catid pairs)
    function syncCrossReferenceTable(masterQuery, userTable, field1, field2, debugTitle) {
        var insertCount = 0;
        var checkSQL = "";
        var insertSQL = "";
        
        try {
            debugLog("Starting cross-reference sync for " & arguments.debugTitle & " with " & arguments.masterQuery.recordCount & " pairs");
            
            for (var row in arguments.masterQuery) {
                // Check if this combination already exists for user
                checkSQL = "SELECT COUNT(*) as countValue 
                    FROM " & arguments.userTable & " 
                    WHERE userid = ? AND " & arguments.field1 & " = ? AND " & arguments.field2 & " = ?";
                var checkParams = [variables.userid, row[arguments.field1], row[arguments.field2]];
                
                var checkQuery = queryExecute(checkSQL, checkParams, {datasource: variables.dsn});
                
                debugLog("Checking pair: " & arguments.field1 & "=" & row[arguments.field1] & ", " & arguments.field2 & "=" & row[arguments.field2] & " -> exists: " & (checkQuery.countValue > 0 ? "YES" : "NO"));
                
                if (checkQuery.countValue == 0) {
                    insertSQL = "INSERT INTO " & arguments.userTable & " (" & arguments.field1 & ", " & arguments.field2 & ", userid) 
                        VALUES (?, ?, ?)";
                    var insertParams = [row[arguments.field1], row[arguments.field2], variables.userid];
                    
                    queryExecute(insertSQL, insertParams, {datasource: variables.dsn});
                    
                    insertCount++;
                    if (insertCount == 1) {
                        debugLog("<strong>" & arguments.debugTitle & " (cross-reference pairs)</strong>");
                    }
                    debugLog("Added xref: " & arguments.field1 & "=" & row[arguments.field1] & ", " & arguments.field2 & "=" & row[arguments.field2]);
                }
            }
            
            if (insertCount > 0) {
                debugLog("Total " & arguments.debugTitle & " records added: " & insertCount);
            } else {
                debugLog("No new " & arguments.debugTitle & " records needed");
            }
            
        } catch (any e) {
            var failedSQL = "";
            var failedParams = [];
            
            if (len(checkSQL)) {
                failedSQL = checkSQL;
                failedParams = checkParams;
                logDatabaseError("syncCrossReferenceTable - Check Query (" & arguments.userTable & ")", failedSQL, failedParams, e);
            } else if (len(insertSQL)) {
                failedSQL = insertSQL;
                failedParams = insertParams;
                logDatabaseError("syncCrossReferenceTable - Insert Query (" & arguments.userTable & ")", failedSQL, failedParams, e);
            } else {
                logDatabaseError("syncCrossReferenceTable - Unknown (" & arguments.userTable & ")", "Unknown SQL", [], e);
            }
        }
        
        return insertCount;
    }
</cfscript>

<cfscript>
    // Update team tags first
    try {
        teamTagsSQL = "UPDATE tags_user 
            SET IsTeam = ? 
            WHERE userid = ? AND tagname IN (
                SELECT tagname FROM tags WHERE IsTeam = 1
            )";
        
        teamTagsParams = [
            {value: 1, cfsqltype: "CF_SQL_BIT"},
            {value: variables.userid, cfsqltype: "CF_SQL_INTEGER"}
        ];
        
        queryExecute(teamTagsSQL, teamTagsParams, {datasource: variables.dsn});
        
        debugLog("Updated team tags for user");
    } catch (any e) {
        logDatabaseError("Update Team Tags", teamTagsSQL, teamTagsParams, e);
    }
    
    // Sync all lookup tables using the generic function
    debugLog("<h3>Syncing Lookup Tables</h3>");
    
    // Audition-related tables with category consideration
    debugLog("<h5>auddialects → auddialects_user</h5>");
    syncLookupTableWithCategory("auddialects", "auddialects_user", "auddialectid", "auddialect", "audcatid");
    
    debugLog("<h5>audgenres → audgenres_user</h5>");
    try {
        // Add debugging for audgenres like we did for audplatforms
        debugLog("Checking audgenres sync...");
        
        // Count master records with and without isdeleted filter
        allMasterQuery = queryExecute("SELECT COUNT(*) as countValue FROM audgenres", {}, {datasource: variables.dsn});
        activeMasterQuery = queryExecute("SELECT COUNT(*) as countValue FROM audgenres WHERE isdeleted = 0", {}, {datasource: variables.dsn});
        
        debugLog("Total audgenres records (all): " & allMasterQuery.countValue);
        debugLog("Active audgenres records (isdeleted=0): " & activeMasterQuery.countValue);
        
        // Count existing user records
        userCountQuery = queryExecute("SELECT COUNT(*) as countValue FROM audgenres_user WHERE userid = ?", [variables.userid], {datasource: variables.dsn});
        debugLog("Existing audgenres_user records for user " & variables.userid & ": " & userCountQuery.countValue);
        
        // Check if there are records with missing audcatid
        missingCatQuery = queryExecute("SELECT COUNT(*) as countValue FROM audgenres WHERE isdeleted = 0 AND (audcatid IS NULL OR audcatid = '')", {}, {datasource: variables.dsn});
        debugLog("Master audgenres with missing audcatid: " & missingCatQuery.countValue);
        
        // Run the sync with proper audcatid consideration
        insertedCount = syncLookupTableWithCategory("audgenres", "audgenres_user", "audgenreid", "audgenre", "audcatid");
        debugLog("Records inserted: " & insertedCount);
        
        // Count user records after sync
        userCountAfterQuery = queryExecute("SELECT COUNT(*) as countValue FROM audgenres_user WHERE userid = ?", [variables.userid], {datasource: variables.dsn});
        debugLog("Final audgenres_user records for user " & variables.userid & ": " & userCountAfterQuery.countValue);
        
    } catch (any e) {
        debugLog("Error debugging audgenres: " & e.message);
        // Fallback to regular sync
        syncLookupTable("audgenres", "audgenres_user", "audgenreid", "audgenre", "audcatid");
    }
    
    debugLog("<h5>audnetworks → audnetworks_user</h5>");
    syncLookupTableWithCategory("audnetworks", "audnetworks_user", "networkid", "network", "audcatid");
    
    debugLog("<h5>audopencalloptions → audopencalloptions_user</h5>");
    syncLookupTable("audopencalloptions", "audopencalloptions_user", "", "opencallname", "", "1=1");
    
    // Special debugging for audplatforms_user
    try {
        debugLog("<h5>audplatforms → audplatforms_user (with debugging)</h5>");
        debugLog("<strong>DEBUGGING audplatforms_user</strong>");
        
        // Count master records
        masterCountQuery = queryExecute("SELECT COUNT(*) as countValue FROM audplatforms WHERE isdeleted = 0", {}, {datasource: variables.dsn});
        masterCount = masterCountQuery.countValue;
        debugLog("Master audplatforms records: " & masterCount);
        
        // Count existing user records
        userCountQuery = queryExecute("SELECT COUNT(*) as countValue FROM audplatforms_user WHERE userid = ?", [variables.userid], {datasource: variables.dsn});
        userCount = userCountQuery.countValue;
        debugLog("Existing audplatforms_user records for user " & variables.userid & ": " & userCount);
        
        // Let's check what's actually in the master table
        debugMasterQuery = queryExecute("SELECT audplatformid, audplatform FROM audplatforms WHERE isdeleted = 0", {}, {datasource: variables.dsn});
        debugLog("Master audplatforms records found:");
        for (platform in debugMasterQuery) {
            debugLog("- ID: " & platform.audplatformid & ", Name: " & platform.audplatform);
        }
        
        // Now run the sync and capture result
        insertedCount = syncLookupTable("audplatforms", "audplatforms_user", "audplatformid", "audplatform");
        debugLog("Records inserted: " & insertedCount);
        
        // Count user records after sync
        userCountAfterQuery = queryExecute("SELECT COUNT(*) as countValue FROM audplatforms_user WHERE userid = ?", [variables.userid], {datasource: variables.dsn});
        userCountAfter = userCountAfterQuery.countValue;
        debugLog("Final audplatforms_user records for user " & variables.userid & ": " & userCountAfter);
        
    } catch (any e) {
        debugLog("Error debugging audplatforms_user: " & e.message);
    }
    
    debugLog("<h5>audtones → audtones_user</h5>");
    syncLookupTableWithCategory("audtones", "audtones_user", "toneid", "tone", "audcatid");
    
    // Event and gender tables
    debugLog("<h5>eventtypes → eventtypes_user</h5>");
    try {
        // Check what fields actually exist in eventtypes table first
        debugLog("Checking eventtypes table structure...");
        eventTypesTestQuery = queryExecute("SELECT * FROM eventtypes LIMIT 1", {}, {datasource: variables.dsn});
        debugLog("Available eventtypes fields: " & arrayToList(eventTypesTestQuery.getColumnNames()));
        
        // Sync with only the fields we know exist
        syncLookupTable("eventtypes", "eventtypes_user", "", "eventTypeName", "eventtypedescription", "1=1");
    } catch (any e) {
        debugLog("Error with eventtypes sync: " & e.message);
        // Fallback: try with just the basic field
        syncLookupTable("eventtypes", "eventtypes_user", "", "eventTypeName", "", "1=1");
    }
    
    debugLog("<h5>genderpronouns → genderpronouns_users</h5>");
    syncLookupTable("genderpronouns", "genderpronouns_users", "", "genderpronoun", "genderpronounplural", "1=1");
    
    // Item and site tables
    debugLog("<h5>itemtypes → itemtypes_user</h5>");
    syncLookupTable("itemtypes", "itemtypes_user", "typeid", "valuetype", "typeicon");
    
    debugLog("<h5>tags → tags_user</h5>");
    syncLookupTable("tags", "tags_user", "", "tagname", "", "1=1");
    
    debugLog("<h5>sitetypes_master → sitetypes_user</h5>");
    syncLookupTable("sitetypes_master", "sitetypes_user", "", "sitetypename", "sitetypedescription");
</cfscript>

<cfscript>
    // Special handling for audquestions (needs qorder field checking)
    try {
        debugLog("<h5>audquestions_default → audquestions_user (special handling)</h5>");
        debugLog("<strong>audquestions_user</strong>");
        questionsSQL = "SELECT qtypeid, qtext, qorder 
            FROM audquestions_default 
            WHERE isdeleted = 0";
        
        questionsQuery = queryExecute(questionsSQL, {}, {datasource: variables.dsn});
        
        questionsAdded = 0;
        for (question in questionsQuery) {
            existsSQL = "SELECT COUNT(*) as countValue 
                FROM audquestions_user 
                WHERE isdeleted = 0 AND qorder = ? AND userid = ?";
            existsParams = [question.qorder, variables.userid];
            
            existsQuery = queryExecute(existsSQL, existsParams, {datasource: variables.dsn});
            
            if (existsQuery.countValue == 0) {
                insertSQL = "INSERT INTO audquestions_user (qtypeid, qtext, qorder, userid) 
                    VALUES (?, ?, ?, ?)";
                insertParams = [question.qtypeid, question.qtext, question.qorder, variables.userid];
                
                queryExecute(insertSQL, insertParams, {datasource: variables.dsn});
                questionsAdded++;
                debugLog("Added question: " & question.qtext);
            }
        }
        if (questionsAdded > 0) {
            debugLog("Total audquestions_user records added: " & questionsAdded);
        }
    } catch (any e) {
        failedSQL = "";
        failedParams = [];
        if (isDefined("questionsSQL") && !isDefined("questionsQuery")) {
            failedSQL = questionsSQL;
            failedParams = [];
        } else if (isDefined("existsSQL")) {
            failedSQL = existsSQL;
            failedParams = existsParams;
        } else if (isDefined("insertSQL")) {
            failedSQL = insertSQL;
            failedParams = insertParams;
        }
        logDatabaseError("Special Handling - audquestions", failedSQL, failedParams, e);
    }
    
    // Special handling for audsubmitsites (has catlist field)
    try {
        debugLog("<h5>audsubmitsites → audsubmitsites_user (special handling)</h5>");
        debugLog("<strong>audsubmitsites_user</strong>");
        submitsitesQuery = queryExecute("
            SELECT submitsitename, catlist 
            FROM audsubmitsites",
            {},
            {datasource: variables.dsn}
        );
        
        submitsitesAdded = 0;
        for (site in submitsitesQuery) {
            existsQuery = queryExecute("
                SELECT COUNT(*) as countValue 
                FROM audsubmitsites_user 
                WHERE submitsitename = ? AND userid = ?",
                [site.submitsitename, variables.userid],
                {datasource: variables.dsn}
            );
            
            if (existsQuery.countValue == 0) {
                queryExecute("
                    INSERT INTO audsubmitsites_user (submitsitename, catlist, userid) 
                    VALUES (?, ?, ?)",
                    [site.submitsitename, site.catlist, variables.userid],
                    {datasource: variables.dsn}
                );
                submitsitesAdded++;
                debugLog("Added submitsite: " & site.submitsitename);
            }
        }
        if (submitsitesAdded > 0) {
            debugLog("Total audsubmitsites_user records added: " & submitsitesAdded);
        }
    } catch (any e) {
        debugLog("Error syncing audsubmitsites: " & e.message);
    }
    
    // Special handling for itemcatxref (complex join logic with unique typeid/catid pairs)
    try {
        debugLog("<h5>itemcategory + itemcatxref → itemcatxref_user (complex join)</h5>");
        debugLog("<strong>itemcatxref_user</strong>");
        
        // First, let's see what we're working with
        debugLog("Debugging itemcatxref sync process...");
        
        // Count existing user records
        existingUserRecords = queryExecute("SELECT COUNT(*) as countValue FROM itemcatxref_user WHERE userid = ?", [variables.userid], {datasource: variables.dsn});
        debugLog("Existing itemcatxref_user records for user " & variables.userid & ": " & existingUserRecords.countValue);
        
        categoryQuery = queryExecute("
            SELECT DISTINCT c.catid, i.valuetype, i.typeid as master_typeid
            FROM itemcategory c
            INNER JOIN itemcatxref x ON x.catid = c.catid
            INNER JOIN itemtypes i ON i.typeid = x.typeid
            WHERE c.isdeleted = 0 AND i.isdeleted = 0
            ORDER BY c.catid, i.valuetype",
            {},
            {datasource: variables.dsn}
        );
        
        debugLog("Master itemcatxref combinations found: " & categoryQuery.recordCount);
        
        // Build a query result with user typeid/catid pairs for the cross-reference sync
        userCategoryPairs = queryNew("typeid,catid", "integer,integer");
        categoryAdded = 0;
        pairsFound = 0;
        
        for (category in categoryQuery) {
            // Get user's typeid for this valuetype
            userTypeQuery = queryExecute("
                SELECT typeid 
                FROM itemtypes_user 
                WHERE valuetype = ? AND userid = ?",
                [category.valuetype, variables.userid],
                {datasource: variables.dsn}
            );
            
            if (userTypeQuery.recordCount > 0) {
                userTypeId = userTypeQuery.typeid;
                pairsFound++;
                
                debugLog("Found pair: valuetype='" & category.valuetype & "' -> user_typeid=" & userTypeId & ", catid=" & category.catid);
                
                // Add this pair to our query result for batch processing
                queryAddRow(userCategoryPairs);
                querySetCell(userCategoryPairs, "typeid", userTypeId);
                querySetCell(userCategoryPairs, "catid", category.catid);
            } else {
                debugLog("No user typeid found for valuetype: " & category.valuetype & " (master_typeid: " & category.master_typeid & ")");
            }
        }
        
        debugLog("Total valid pairs found for user: " & pairsFound);
        debugLog("User category pairs to sync: " & userCategoryPairs.recordCount);
        
        // Now use the cross-reference sync function
        if (userCategoryPairs.recordCount > 0) {
            categoryAdded = syncCrossReferenceTable(userCategoryPairs, "itemcatxref_user", "typeid", "catid", "itemcatxref_user");
        }
        
        // Count final user records
        finalUserRecords = queryExecute("SELECT COUNT(*) as countValue FROM itemcatxref_user WHERE userid = ?", [variables.userid], {datasource: variables.dsn});
        debugLog("Final itemcatxref_user records for user " & variables.userid & ": " & finalUserRecords.countValue);
        
    } catch (any e) {
        debugLog("Error syncing itemcatxref: " & e.message);
    }
    
    // Sync panels from master
    debugLog("<h5>pgpanels_master → pgpanels_user</h5>");
    try {
        // Check what fields actually exist in pgpanels_master table first
        debugLog("Checking pgpanels_master table structure...");
        pgpanelsTestQuery = queryExecute("SELECT * FROM pgpanels_master LIMIT 1", {}, {datasource: variables.dsn});
        
        if (pgpanelsTestQuery.recordCount > 0) {
            availableFields = arrayToList(pgpanelsTestQuery.getColumnNames());
            debugLog("Available pgpanels_master fields: " & availableFields);
            
            // Build additional fields list based on what actually exists
            additionalFields = "";
            if (listFindNoCase(availableFields, "pnTitle")) {
                additionalFields = listAppend(additionalFields, "pnTitle");
            }
            if (listFindNoCase(availableFields, "pnDescription")) {
                additionalFields = listAppend(additionalFields, "pnDescription");
            }
            
            debugLog("Using additional fields: " & additionalFields);
            syncLookupTable("pgpanels_master", "pgpanels_user", "", "pnFilename", additionalFields, "1=1");
        } else {
            debugLog("No records found in pgpanels_master table");
        }
    } catch (any e) {
        debugLog("Error with pgpanels sync: " & e.message);
        // Fallback: try with just the basic field
        syncLookupTable("pgpanels_master", "pgpanels_user", "", "pnFilename", "", "1=1");
    }
    
    // Update tag properties after syncing
    try {
        tagUpdateSQL = "SELECT tagname, IsTeam, IsCasting, tagtype 
            FROM tags";
        
        tagUpdateQuery = queryExecute(tagUpdateSQL, {}, {datasource: variables.dsn});
        
        debugLog("Updating " & tagUpdateQuery.recordCount & " tag properties...");
        
        for (tag in tagUpdateQuery) {
            // Debug the source values
            debugLog("Processing tag '" & tag.tagname & "': IsTeam=" & tag.IsTeam & " IsCasting=" & tag.IsCasting & " tagtype=" & tag.tagtype);
            
            updateSQL = "UPDATE tags_user 
                SET IsTeam = ?, IsCasting = ?, tagtype = ? 
                WHERE tagname = ? AND userid = ?";
            
            updateParams = [
                {value: (tag.IsTeam ? 1 : 0), cfsqltype: "CF_SQL_BIT"},
                {value: (tag.IsCasting ? 1 : 0), cfsqltype: "CF_SQL_BIT"},
                {value: tag.tagtype, cfsqltype: "CF_SQL_VARCHAR"},
                {value: tag.tagname, cfsqltype: "CF_SQL_VARCHAR"},
                {value: variables.userid, cfsqltype: "CF_SQL_INTEGER"}
            ];
            
            queryExecute(updateSQL, updateParams, {datasource: variables.dsn});
        }
        debugLog("Updated tag properties for " & tagUpdateQuery.recordCount & " tags");
    } catch (any e) {
        failedSQL = "";
        failedParams = [];
        if (isDefined("tagUpdateSQL") && !isDefined("tagUpdateQuery")) {
            failedSQL = tagUpdateSQL;
            failedParams = [];
        } else if (isDefined("updateSQL")) {
            failedSQL = updateSQL;
            failedParams = updateParams;
        }
        logDatabaseError("Update Tag Properties", failedSQL, failedParams, e);
    }
</cfscript>

<cfscript>
    // Handle sitelinks with proper relationship to sitetypes
    try {
        debugLog("<h5>sitelinks_master → sitelinks_user (with sitetypes relationship)</h5>");
        debugLog("<strong>sitelinks_user</strong>");
        sitelinksSQL = "SELECT s.id, s.sitename, s.siteURL, s.siteicon, s.sitetypeid, t.sitetypename
            FROM sitelinks_master s
            INNER JOIN sitetypes_master t ON t.sitetypeid = s.siteTypeid
            ORDER BY s.sitename";
        
        sitelinksQuery = queryExecute(sitelinksSQL, {}, {datasource: variables.dsn});
        
        sitelinksAdded = 0;
        for (sitelink in sitelinksQuery) {
            // Get user's sitetypeid for this sitetypename
            userSiteTypeSQL = "SELECT sitetypeid 
                FROM sitetypes_user 
                WHERE sitetypename = ? AND userid = ?";
            userSiteTypeParams = [sitelink.sitetypename, variables.userid];
            
            userSiteTypeQuery = queryExecute(userSiteTypeSQL, userSiteTypeParams, {datasource: variables.dsn});
            
            if (userSiteTypeQuery.recordCount == 1) {
                userSiteTypeId = userSiteTypeQuery.sitetypeid;
                
                // Check if this sitelink already exists for user
                existsSQL = "SELECT COUNT(*) as countValue 
                    FROM sitelinks_user_tbl 
                    WHERE sitename = ? AND userid = ?";
                existsParams = [sitelink.sitename, variables.userid];
                
                existsQuery = queryExecute(existsSQL, existsParams, {datasource: variables.dsn});
                
                if (existsQuery.countValue == 0) {
                    insertSQL = "INSERT INTO sitelinks_user_tbl (siteName, siteURL, siteicon, siteTypeid, userid) 
                        VALUES (?, ?, ?, ?, ?)";
                    insertParams = [sitelink.sitename, sitelink.siteURL, sitelink.siteicon, userSiteTypeId, variables.userid];
                    
                    queryExecute(insertSQL, insertParams, {datasource: variables.dsn});
                    sitelinksAdded++;
                    debugLog("Added sitelink: " & sitelink.sitename);
                }
            }
        }
        if (sitelinksAdded > 0) {
            debugLog("Total sitelinks_user records added: " & sitelinksAdded);
        }
    } catch (any e) {
        failedSQL = "";
        failedParams = [];
        if (isDefined("sitelinksSQL") && !isDefined("sitelinksQuery")) {
            failedSQL = sitelinksSQL;
            failedParams = [];
        } else if (isDefined("userSiteTypeSQL")) {
            failedSQL = userSiteTypeSQL;
            failedParams = userSiteTypeParams;
        } else if (isDefined("existsSQL")) {
            failedSQL = existsSQL;
            failedParams = existsParams;
        } else if (isDefined("insertSQL")) {
            failedSQL = insertSQL;
            failedParams = insertParams;
        }
        logDatabaseError("Handle Sitelinks", failedSQL, failedParams, e);
    }
    
    // Create panels for each sitetype
    try {
        debugLog("<strong>Creating sitetype panels</strong>");
        siteTypesQuery = queryExecute("
            SELECT sitetypeid, sitetypename, sitetypedescription, pnid
            FROM sitetypes_user 
            WHERE userid = ?",
            [variables.userid],
            {datasource: variables.dsn}
        );
        
        panelsCreated = 0;
        for (siteType in siteTypesQuery) {
            panelTitle = siteType.sitetypename & " Links";
            
            // Check if this sitetype already has a panel assigned
            if (len(trim(siteType.pnid)) == 0 || val(siteType.pnid) == 0) {
                // Check if a panel with this title already exists for this user
                existingPanelQuery = queryExecute("
                    SELECT pnid 
                    FROM pgpanels_user 
                    WHERE pnTitle = ? AND userid = ? AND IsDeleted = 0",
                    [panelTitle, variables.userid],
                    {datasource: variables.dsn}
                );
                
                if (existingPanelQuery.recordCount > 0) {
                    // Use existing panel
                    existingPanelId = existingPanelQuery.pnid;
                    queryExecute("
                        UPDATE sitetypes_user 
                        SET pnid = ? 
                        WHERE sitetypeid = ? AND userid = ?",
                        [existingPanelId, siteType.sitetypeid, variables.userid],
                        {datasource: variables.dsn}
                    );
                    debugLog("Linked existing panel: " & panelTitle & " (ID: " & existingPanelId & ")");
                } else {
                    // Create new panel
                    // Get next panel order number
                    maxOrderQuery = queryExecute("
                        SELECT COALESCE(MAX(pnOrderno), 0) + 1 as nextOrderNo
                        FROM pgpanels_user 
                        WHERE userid = ?",
                        [variables.userid],
                        {datasource: variables.dsn}
                    );
                    
                    nextOrderNo = maxOrderQuery.nextOrderNo;
                    
                    // Insert new panel
                    panelResult = queryExecute("
                        INSERT INTO pgpanels_user (pnTitle, pnFilename, pnorderno, pncolxl, pncolMd, pnDescription, IsDeleted, IsVisible, userid) 
                        VALUES (?, 'mylinks_user.cfm', ?, 3, 3, '', 0, 1, ?)",
                        [panelTitle, nextOrderNo, variables.userid],
                        {datasource: variables.dsn, result: "panelInsert"}
                    );
                    
                    newPanelId = panelInsert.generatedKey;
                    
                    // Update sitetype with panel ID
                    queryExecute("
                        UPDATE sitetypes_user 
                        SET pnid = ? 
                        WHERE sitetypeid = ? AND userid = ?",
                        [newPanelId, siteType.sitetypeid, variables.userid],
                        {datasource: variables.dsn}
                    );
                    
                    panelsCreated++;
                    debugLog("Created panel: " & panelTitle & " (ID: " & newPanelId & ")");
                }
            } else {
                debugLog("Panel already exists for " & siteType.sitetypename & " (ID: " & siteType.pnid & ")");
            }
        }
        
        if (panelsCreated > 0) {
            debugLog("Total new panels created: " & panelsCreated);
        }
    } catch (any e) {
        debugLog("Error creating sitetype panels: " & e.message);
    }
    
    // Handle users without contactid (create contact records)
    try {
        debugLog("<strong>Creating missing contact records</strong>");
        usersQuery = queryExecute("
            SELECT userid, userfirstname, userlastname, contactid
            FROM taousers 
            WHERE contactid IS NULL OR contactid = ''",
            {},
            {datasource: variables.dsn}
        );
        
        contactsCreated = 0;
        for (user in usersQuery) {
            if (!len(trim(user.contactid))) {
                // Create contact record
                contactResult = queryExecute("
                    INSERT INTO contactdetails (contactfullname, userid, user_yn) 
                    VALUES (?, ?, 'Y')",
                    [user.userfirstname & " " & user.userlastname, user.userid],
                    {datasource: variables.dsn, result: "contactInsert"}
                );
                
                newContactId = contactInsert.generatedKey;
                
                // Update user with contact ID
                queryExecute("
                    UPDATE taousers 
                    SET contactid = ? 
                    WHERE userid = ?",
                    [newContactId, user.userid],
                    {datasource: variables.dsn}
                );
                
                contactsCreated++;
                debugLog("Created contact for user " & user.userid & ": " & user.userfirstname & " " & user.userlastname);
            }
        }
        if (contactsCreated > 0) {
            debugLog("Total contact records created: " & contactsCreated);
        }
    } catch (any e) {
        debugLog("Error creating contact records: " & e.message);
    }
    
    // Final completion message
    endTime = timeFormat(now(), 'HHMMSS');
    timeDiff = timeFormat(dateAdd("s", timeFormat(endTime, "H")*3600 + timeFormat(endTime, "m")*60 + timeFormat(endTime, "s") - (timeFormat(variables.starttime, "H")*3600 + timeFormat(variables.starttime, "m")*60 + timeFormat(variables.starttime, "s")), createDate(1970,1,1)), 'HHMMSS');
    
    debugLog("<hr><strong>User setup completed for userID " & variables.userid & "</strong>");
    debugLog("Total execution time: " & timeDiff);
</cfscript>
