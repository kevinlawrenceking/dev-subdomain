<cfscript>
  // Get Java version via system call
  javaVersion = CreateObject("java", "java.lang.System").getProperty("java.version");

  serverInfo = {
    "Server OS": server.os.name,
    "ColdFusion Version": server.coldfusion.productVersion,
    "Java Version": javaVersion,
    "Template Path": GetTemplatePath(),
    "Web Root": ExpandPath("/"),
    "Date/Time": Now()
  };

  // Test database connection
  dbResult = {};
  try {
    datasource = "abod"; 
    q = queryExecute("SELECT * FROM fusystems", {}, { datasource: datasource });
    dbResult.success = true;
    dbResult.recordCount = q.recordCount;
    dbResult.sampleSystem = q[1];
  } catch (any e) {
    dbResult.success = false;
    dbResult.error = e.message & ": " & e.detail;
  }

  // Output diagnostics
  WriteOutput("<h2>ColdFusion Environment Diagnostic</h2><hr>");

  WriteOutput("<h3>Server Info</h3><ul>");
  for (key in serverInfo) {
    WriteOutput("<li><strong>#key#:</strong> #serverInfo[key]#</li>");
  }
  WriteOutput("</ul>");

  WriteOutput("<h3>Database Test</h3>");
  if (dbResult.success) {
    WriteOutput("<p>Status: Connected</p>");
    WriteOutput("<p>Rows Returned: #dbResult.recordCount#</p>");
    WriteDump(var=dbResult.sampleSystem, label="Sample Record from fusystems", format="html");
  } else {
    WriteOutput("<p>Status: Failed to connect</p>");
    WriteOutput("<p>Error: #dbResult.error#</p>");
  }
</cfscript>
