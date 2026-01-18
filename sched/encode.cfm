<cfscript>
    // Database configuration
    datasource = "abod";
    dbName = "new_development";

    // Step 1: Get a list of all tables in the database
    queryTables = "
        SELECT TABLE_NAME
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_SCHEMA = :dbName AND TABLE_TYPE = 'BASE TABLE'
    ";

    // Execute the query to get all table names
    tables = queryExecute(queryTables, {dbName: dbName}, {datasource: datasource});

    // Step 2: Loop through each table and alter the encoding
    if (tables.recordCount > 0) {
        for (table in tables) {
            // Dynamically build the ALTER TABLE SQL
            alterSQL = "ALTER TABLE " & table.TABLE_NAME & 
                       " CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci";

            try {
                // Execute the ALTER TABLE command
                queryExecute(alterSQL, {}, {datasource: datasource});
                writeOutput("Updated table: " & table.TABLE_NAME & "<br>");
            } catch (any e) {
                // Log errors if any table fails to update
                writeOutput("Error updating table: " & table.TABLE_NAME & " - " & e.message & "<br>");
            }
        }
    } else {
        writeOutput("No tables found in the database.");
    }
</cfscript>
