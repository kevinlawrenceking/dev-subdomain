<cfsetting requestTimeout="9000">
<!DOCTYPE html>
<html>
<head>
    <title>Completion Percentage</title>
    <meta http-equiv="refresh" content="10"> <!--- Refresh the page every 30 seconds --->
    <style>
        /* CSS styles to center the percentage and make it large */
        body, html {
            height: 100%;
            margin: 0;
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            background-color: #f0f0f0;
        }

        .percentage-container {
            text-align: center;
            font-size: 5em;
            color: #333;
        }

        .percentage-text {
            font-weight: bold;
            color: #1a73e8; /* Blue color for the percentage */
        }

        .description {
            margin-top: 20px;
            font-size: 1.5em;
            color: #555;
        }
    </style>
</head>
<body>
 
    <!--- Query to get the total number of records --->
    <cfquery result="result" name="totalRecords" datasource="abod">
        SELECT COUNT(*) AS totalCount
   FROM  functions f
    INNER JOIN components c ON c.id = f.component_id
    INNER JOIN qry_types q on f.qry_type = q.name

    </cfquery>

    <!--- Query to get the number of completed records --->
    <cfquery result="result" name="completedRecords" datasource="abod">
        SELECT COUNT(*) AS completedCount
   FROM  functions f
    INNER JOIN components c ON c.id = f.component_id
    INNER JOIN qry_types q on f.qry_type = q.name
    WHERE f.function_code IS not NULL 
    </cfquery>

<cfoutput>
    <!--- Calculate the completion percentage --->
    <cfset percentageComplete = 0>
    <cfif totalRecords.totalCount GT 0>
        <cfset percentageComplete = (completedRecords.completedCount / totalRecords.totalCount) * 100>
    </cfif>

    <div class="percentage-container">
        <span class="percentage-text">#numberFormat(percentageComplete, "0.00")#%</span>
        <div class="description">Completion Percentage</div>
    </div>
</cfoutput>
</body>
</html>
