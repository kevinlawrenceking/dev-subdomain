<cfscript>
  // Basic environment info
  serverInfo = {
    "Server OS": server.os.name,
    "CF Version": server.coldfusion.productVersion,
    "Java Version": server.coldfusion.java.version,
    "Template Path": GetTemplatePath(),
    "Web Root": ExpandPath("/"),
    "Date/Time": Now()
  };

  // Try DB connection
  dbResult = {};
  try {
    datasource = "abod"; 
    q = queryExecute("SELECT TOP 1 * FROM fusystems", {}, { datasource: datasource });
    dbResult.success = true;
    dbResult.recordCount = q.recordCount;
    dbResult.sampleSystem = q[1];
  } catch (any e) {
    dbResult.success = false;
    dbResult.error = e.message & ": " & e.detail;
  }

  // Output
  WriteOutput("<h2>ColdFusion Environment Diagnostic</h2><hr>");

  WriteOutput("<h3>Server Info</h3><ul>");
  for (key in serverInfo) {
    WriteOutput("<li><strong>#key#:</strong> #serverInfo[key]#</li>");
  }
  WriteOutput("</ul>");

  WriteOutput("<h3>Database Test</h3>");
  if (dbResult.success) {
    WriteOutput("<p><strong>Status:</strong>  Connected</p>");
    WriteOutput("<p><strong>Rows Returned:</strong> #dbResult.recordCount#</p>");
    WriteDump(var=dbResult.sampleSystem, label="Sample Record from fusystems", format="html");
  } else {
    WriteOutput("<p><strong>Status:</strong>  Failed to connect</p>");
    WriteOutput("<p><strong>Error:</strong> #dbResult.error#</p>");
  }
</cfscript>
