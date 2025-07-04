<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Debug Log Viewer</title>
    <!--- Include Bootstrap CSS --->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!--- Include DataTables CSS --->
    <link href="https://cdn.datatables.net/1.13.6/css/jquery.dataTables.min.css" rel="stylesheet">
</head>
<body>
    <div class="container my-5">
        <h1 class="mb-4">Debug Log Viewer</h1>
        <table id="debugLogTable" class="table table-striped table-bordered">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Filename/Path</th>
                    <th>Debug Details</th>
                    <th>Timestamp</th>
                </tr>
            </thead>
            <tbody>
                <!--- Fetch debug log entries --->
                <cfquery name="debugLogs" >
                    SELECT 
                        id,
                        filename,
                        debugDetails,
                        timestamp
                    FROM debugLog
                    ORDER BY `timestamp` DESC
                </cfquery>

                <cfoutput query="debugLogs">
                    <tr>
                        <td>#id#</td>
                        <td>#filename#</td>
                        <td>
                            <button class="btn btn-link btn-sm" type="button" data-bs-toggle="collapse" data-bs-target="##details-#id#" aria-expanded="false" aria-controls="details-#id#">
                                View Details
                            </button>
                            <div class="collapse" id="details-#id#">
                                <div class="card card-body debug-details">
                                    <cfoutput>#htmlEditFormat(debugLogs.debugDetails)#</cfoutput>
                                </div>
                            </div>
                        </td>
                        <td>#Dateformat(timestamp, "mm/dd/yyyy")# #timeFormat(timestamp, "hh:mm:ss tt")#</td>
                    </tr>
                </cfoutput>
            </tbody>
        </table>
    </div>

    <!--- Include Bootstrap Bundle JS --->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <!--- Include jQuery --->
    <script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
    <!--- Include DataTables JS --->
    <script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>

    <!--- Initialize DataTable --->
    
</body>
</html>
