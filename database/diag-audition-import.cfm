<cfsilent>
<cfinclude template="/database/admin-guard.cfm">
<cfset datasource = application.dsn>
<!--- Optional: pass ?job_id=NN to inspect a specific job; otherwise uses the latest job. --->
<cfparam name="url.job_id" default="">
</cfsilent>
<!DOCTYPE html>
<html>
<head><title>Diag: Audition Import rows/facts</title></head>
<body style="font-family:monospace;padding:20px;">

<cfscript>
// 0) Resolve job_id (latest if not supplied)
if (len(trim(url.job_id)) and isNumeric(url.job_id)) {
    jobId = val(url.job_id);
} else {
    qLatest = queryExecute(
        "SELECT job_id FROM import_auditions_jobs ORDER BY job_id DESC LIMIT 1",
        {}, { datasource: datasource }
    );
    jobId = qLatest.recordCount ? qLatest.job_id : 0;
}

writeOutput("<h2>Audition Import diagnostic — job_id=" & jobId & " (DSN: " & datasource & ")</h2>");

if (jobId eq 0) {
    writeOutput("<p style='color:red;'>No import jobs found.</p></body></html>");
    abort;
}

// 1) Job summary
qJob = queryExecute(
    "SELECT job_id, source_filename, status, total_rows, parsed_rows
     FROM import_auditions_jobs WHERE job_id = :j",
    { j: { value: jobId, cfsqltype: "cf_sql_integer" } }, { datasource: datasource }
);
writeOutput("<h3>1. Job</h3><table border='1' cellpadding='4' cellspacing='0'>");
for (c in listToArray(qJob.columnList)) {
    v = isNull(qJob[c][1]) ? "<em style='color:orange;'>NULL</em>" : htmlEditFormat(toString(qJob[c][1]));
    writeOutput("<tr><td><strong>" & c & "</strong></td><td>" & v & "</td></tr>");
}
writeOutput("</table>");

// 2) Column mappings (this is what recompute uses to set field_name on facts)
qCols = queryExecute(
    "SELECT column_id, source_column_index, source_column_name, intent, target_key
     FROM import_auditions_columns WHERE job_id = :j ORDER BY source_column_index",
    { j: { value: jobId, cfsqltype: "cf_sql_integer" } }, { datasource: datasource }
);
writeOutput("<h3>2. Column mappings</h3><table border='1' cellpadding='4' cellspacing='0'><tr><th>column_id</th><th>idx</th><th>source_column_name</th><th>intent</th><th>target_key</th></tr>");
for (row in qCols) {
    tk = isNull(row.target_key) ? "<em style='color:orange;'>NULL</em>" : htmlEditFormat(row.target_key);
    bg = (isNull(row.target_key) or row.target_key eq "") ? "background:##fff3cd;" : "";
    writeOutput("<tr style='" & bg & "'><td>" & row.column_id & "</td><td>" & row.source_column_index & "</td><td>" & htmlEditFormat(toString(row.source_column_name)) & "</td><td>" & htmlEditFormat(toString(row.intent)) & "</td><td>" & tk & "</td></tr>");
}
writeOutput("</table>");

// 3) Rows
qRows = queryExecute(
    "SELECT row_id, row_num, status, error_count, warning_count
     FROM import_auditions_rows WHERE job_id = :j ORDER BY row_num",
    { j: { value: jobId, cfsqltype: "cf_sql_integer" } }, { datasource: datasource }
);
writeOutput("<h3>3. Rows (" & qRows.recordCount & ")</h3><table border='1' cellpadding='4' cellspacing='0'><tr><th>row_id</th><th>row_num</th><th>status</th><th>errors</th><th>warnings</th></tr>");
for (row in qRows) {
    writeOutput("<tr><td>" & row.row_id & "</td><td>" & row.row_num & "</td><td>" & htmlEditFormat(toString(row.status)) & "</td><td>" & row.error_count & "</td><td>" & row.warning_count & "</td></tr>");
}
writeOutput("</table>");

// 4) Facts per row — THE KEY DIAGNOSTIC
//    If field_name is still 'unmapped_N' and normalized_value is NULL -> recompute did not
//    process this row (recompute bug). If field_name is the target key (project_name, etc.)
//    with a normalized_value -> data is correct in DB and the blank row is a DISPLAY bug.
writeOutput("<h3>4. Facts per row (field_name / normalized_value / is_valid)</h3>");
for (row in qRows) {
    qFacts = queryExecute(
        "SELECT fact_id, column_id, field_name, LEFT(raw_value,40) AS raw_value,
                LEFT(normalized_value,40) AS normalized_value, CHAR_LENGTH(normalized_value) AS norm_len, is_valid
         FROM import_auditions_facts WHERE row_id = :rid ORDER BY field_name",
        { rid: { value: row.row_id, cfsqltype: "cf_sql_integer" } }, { datasource: datasource }
    );
    writeOutput("<h4>row_num=" & row.row_num & " (row_id=" & row.row_id & ", status=" & row.status & ")</h4>");
    writeOutput("<table border='1' cellpadding='4' cellspacing='0'><tr><th>fact_id</th><th>column_id</th><th>field_name</th><th>raw_value (40)</th><th>normalized_value (40)</th><th>norm_len</th><th>is_valid</th></tr>");
    for (f in qFacts) {
        unmapped = (left(toString(f.field_name), 9) eq "unmapped_");
        normNull = isNull(f.normalized_value) or f.normalized_value eq "";
        bg = (unmapped or normNull) ? "background:##fff3cd;" : "";
        nv = isNull(f.normalized_value) ? "<em style='color:orange;'>NULL</em>" : htmlEditFormat(toString(f.normalized_value));
        rv = isNull(f.raw_value) ? "<em style='color:orange;'>NULL</em>" : htmlEditFormat(toString(f.raw_value));
        writeOutput("<tr style='" & bg & "'><td>" & f.fact_id & "</td><td>" & f.column_id & "</td><td>" & htmlEditFormat(toString(f.field_name)) & "</td><td>" & rv & "</td><td>" & nv & "</td><td>" & (isNull(f.norm_len) ? "" : f.norm_len) & "</td><td>" & f.is_valid & "</td></tr>");
    }
    writeOutput("</table>");
}

writeOutput("<hr><p>Yellow cells = unmapped field_name or empty/NULL normalized_value. "
    & "If row 1's facts are yellow but later rows are not, recompute skipped row 1. "
    & "If row 1's facts look identical to other rows, the blank grid row is a display-layer bug.</p>");
</cfscript>

</body>
</html>
