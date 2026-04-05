<cfsilent>
<!---
    verify-pending-fixes.cfm
    Checks whether critical database fixes from the April 2026 QA cycle
    have been applied. Safe to run repeatedly (read-only queries).

    Covers:
      - #2191: Relationship filter views (contacts_ss_target/followup/maint)
      - #2161: charDescription column type (VARCHAR -> TEXT)
      - ThriveCart address backfill status
      - #2191/#2192/#1615/#1646 ticket status check
--->
<cfinclude template="/database/admin-guard.cfm">
<cfset datasource = application.dsn>
</cfsilent>
<!DOCTYPE html>
<html>
<head>
    <title>Verify Pending Fixes | TAO Admin</title>
    <link href="/app/assets/css/bootstrap.css" rel="stylesheet" />
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; background: #f8f9fa; }
        .check-card { background: white; border-radius: 8px; padding: 20px; margin-bottom: 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
        .status-pass { color: #28a745; font-weight: bold; }
        .status-fail { color: #dc3545; font-weight: bold; }
        .status-warn { color: #ffc107; font-weight: bold; }
        .fix-btn { margin-top: 10px; }
        pre { background: #f5f5f5; padding: 10px; border-radius: 4px; font-size: 0.85rem; overflow-x: auto; }
        h1 { color: #406E8E; }
        .summary-bar { padding: 15px 20px; border-radius: 8px; margin-bottom: 20px; color: white; font-size: 1.1rem; }
        .summary-pass { background: #28a745; }
        .summary-fail { background: #dc3545; }
        .summary-partial { background: #ffc107; color: #333; }
    </style>
</head>
<body>
<div class="container-fluid" style="max-width: 1000px;">

<h1>Pending Fix Verification</h1>
<p class="text-muted">
    Datasource: <strong><cfoutput>#datasource#</cfoutput></strong> |
    Checked: <cfoutput>#DateTimeFormat(Now(), "yyyy-mm-dd HH:nn:ss")#</cfoutput>
</p>

<cfscript>
checks = [];
passCount = 0;
failCount = 0;

// ============================================================
// CHECK 1: charDescription column type (#2161)
// ============================================================
try {
    qColType = queryExecute("
        SELECT TABLE_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE COLUMN_NAME = 'charDescription'
        AND TABLE_NAME IN ('audroles', 'auditionsimport')
        AND TABLE_SCHEMA = DATABASE()
        ORDER BY TABLE_NAME
    ", {}, { datasource: datasource });

    allText = true;
    detail = "";
    for (row in qColType) {
        detail &= row.TABLE_NAME & ": " & row.DATA_TYPE;
        if (row.DATA_TYPE neq "text") {
            detail &= " (NEEDS FIX - should be TEXT)";
            allText = false;
        } else {
            detail &= " (OK)";
        }
        detail &= "<br>";
    }
    if (qColType.recordCount eq 0) {
        detail = "Columns not found - tables may not exist";
        allText = false;
    }

    arrayAppend(checks, {
        ticket: "##2161",
        title: "charDescription Column Type",
        description: "audroles.charDescription and auditionsimport.charDescription should be TEXT, not VARCHAR(500)",
        status: allText ? "PASS" : "FAIL",
        detail: detail,
        fixScript: allText ? "" : "ALTER TABLE audroles MODIFY COLUMN charDescription TEXT NULL;<br>ALTER TABLE auditionsimport MODIFY COLUMN charDescription TEXT NULL;"
    });
    if (allText) passCount++; else failCount++;
} catch (any e) {
    arrayAppend(checks, { ticket: "##2161", title: "charDescription Column Type", description: "", status: "ERROR", detail: e.message, fixScript: "" });
    failCount++;
}

// ============================================================
// CHECK 2: Relationship filter views (#2191)
// ============================================================
try {
    viewChecks = [
        { view: "contacts_ss_target", expected: "Targeted List" },
        { view: "contacts_ss_followup", expected: "Follow Up" },
        { view: "contacts_ss_maint", expected: "Maintenance List" }
    ];
    allViewsOk = true;
    viewDetail = "";

    for (vc in viewChecks) {
        // Check view exists
        qView = queryExecute("
            SELECT COUNT(*) AS cnt
            FROM INFORMATION_SCHEMA.VIEWS
            WHERE TABLE_NAME = :viewName
            AND TABLE_SCHEMA = DATABASE()
        ", { viewName: { value: vc.view, cfsqltype: "cf_sql_varchar" } },
        { datasource: datasource });

        if (qView.cnt eq 0) {
            viewDetail &= vc.view & ": <span class='status-fail'>VIEW MISSING</span><br>";
            allViewsOk = false;
        } else {
            // Check view definition contains correct systemtype
            qDef = queryExecute("
                SELECT VIEW_DEFINITION
                FROM INFORMATION_SCHEMA.VIEWS
                WHERE TABLE_NAME = :viewName
                AND TABLE_SCHEMA = DATABASE()
            ", { viewName: { value: vc.view, cfsqltype: "cf_sql_varchar" } },
            { datasource: datasource });

            if (findNoCase(vc.expected, qDef.VIEW_DEFINITION)) {
                // Count rows
                qCount = queryExecute("SELECT COUNT(*) AS cnt FROM #vc.view#", {}, { datasource: datasource });
                viewDetail &= vc.view & ": <span class='status-pass'>OK</span> (filters on '" & vc.expected & "', " & qCount.cnt & " rows)<br>";
            } else {
                viewDetail &= vc.view & ": <span class='status-fail'>WRONG FILTER</span> (expected '" & vc.expected & "' not found in definition)<br>";
                allViewsOk = false;
            }
        }
    }

    arrayAppend(checks, {
        ticket: "##2191",
        title: "Relationship Filter Views",
        description: "contacts_ss_target, contacts_ss_followup, contacts_ss_maint should filter on correct systemtype values",
        status: allViewsOk ? "PASS" : "FAIL",
        detail: viewDetail,
        fixScript: allViewsOk ? "" : "Run: <a href='/database/run-tested-bug-fixes-2026-04-02.cfm'>/database/run-tested-bug-fixes-2026-04-02.cfm</a>"
    });
    if (allViewsOk) passCount++; else failCount++;
} catch (any e) {
    arrayAppend(checks, { ticket: "##2191", title: "Relationship Filter Views", description: "", status: "ERROR", detail: e.message, fixScript: "" });
    failCount++;
}

// ============================================================
// CHECK 3: ThriveCart address backfill
// ============================================================
try {
    qBackfill = queryExecute("
        SELECT
            COUNT(*) AS total_users,
            SUM(CASE WHEN t.billing_address IS NOT NULL AND t.billing_address != '' THEN 1 ELSE 0 END) AS has_billing,
            SUM(CASE WHEN u.address IS NOT NULL AND u.address != '' THEN 1 ELSE 0 END) AS has_address
        FROM taousers u
        INNER JOIN thrivecart_tbl t ON t.email = u.email
        WHERE t.billing_address IS NOT NULL AND t.billing_address != ''
    ", {}, { datasource: datasource });

    backfillNeeded = (qBackfill.has_billing gt 0 and qBackfill.has_address lt qBackfill.has_billing);
    bDetail = "Users with ThriveCart billing data: " & qBackfill.has_billing & "<br>";
    bDetail &= "Users with address populated: " & qBackfill.has_address & "<br>";
    if (backfillNeeded) {
        bDetail &= "<span class='status-warn'>" & (qBackfill.has_billing - qBackfill.has_address) & " users missing address data that could be backfilled</span>";
    } else {
        bDetail &= "All matched users have address data.";
    }

    arrayAppend(checks, {
        ticket: "Backfill",
        title: "ThriveCart Address Backfill",
        description: "User address fields should be populated from ThriveCart billing data",
        status: backfillNeeded ? "WARN" : "PASS",
        detail: bDetail,
        fixScript: backfillNeeded ? "Run: <code>database/2026-03-31_backfill_taousers_address_from_thrivecart.sql</code>" : ""
    });
    if (!backfillNeeded) passCount++; else failCount++;
} catch (any e) {
    // thrivecart_tbl may not have billing_address column yet - handle gracefully
    arrayAppend(checks, { ticket: "Backfill", title: "ThriveCart Address Backfill", description: "", status: "SKIP", detail: "Could not verify: " & e.message, fixScript: "" });
}

// ============================================================
// CHECK 4: Ticket statuses (#2191, #2192, #2161, #1615, #1646)
// ============================================================
try {
    qTickets = queryExecute("
        SELECT ticketid, ticketStatus
        FROM tickets
        WHERE ticketid IN (2191, 2192, 2161, 1615, 1646)
        ORDER BY ticketid
    ", {}, { datasource: datasource });

    tDetail = "<table class='table table-sm'><tr><th>Ticket</th><th>Status</th><th>Expected</th></tr>";
    allImpl = true;
    for (row in qTickets) {
        isImpl = (row.ticketStatus eq "Implemented");
        color = isImpl ? "status-pass" : "status-fail";
        tDetail &= "<tr><td>##" & row.ticketid & "</td><td class='" & color & "'>" & row.ticketStatus & "</td><td>Implemented</td></tr>";
        if (!isImpl) allImpl = false;
    }
    tDetail &= "</table>";

    arrayAppend(checks, {
        ticket: "QA Cycle",
        title: "Bug Fix Ticket Statuses",
        description: "All fixed tickets from April 2 QA cycle should be marked Implemented",
        status: allImpl ? "PASS" : "WARN",
        detail: tDetail,
        fixScript: allImpl ? "" : "Run: <a href='/database/run-ticket-updates-2026-04-02.cfm'>/database/run-ticket-updates-2026-04-02.cfm</a>"
    });
    if (allImpl) passCount++;  else failCount++;
} catch (any e) {
    arrayAppend(checks, { ticket: "QA Cycle", title: "Bug Fix Ticket Statuses", description: "", status: "ERROR", detail: e.message, fixScript: "" });
    failCount++;
}

// ============================================================
// CHECK 5: error_tickets table exists (TAO-SPEC-2026-005)
// ============================================================
try {
    qErrTable = queryExecute("
        SELECT COUNT(*) AS cnt
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = 'error_tickets'
        AND TABLE_SCHEMA = DATABASE()
    ", {}, { datasource: datasource });

    errExists = (qErrTable.cnt gt 0);
    errDetail = errExists ? "Table exists." : "Table NOT FOUND.";
    if (errExists) {
        qErrCount = queryExecute("SELECT COUNT(*) AS cnt, SUM(CASE WHEN resolved = 0 THEN 1 ELSE 0 END) AS unresolved FROM error_tickets", {}, { datasource: datasource });
        errDetail &= " Total tickets: " & qErrCount.cnt & ", Unresolved: " & qErrCount.unresolved;
    }

    arrayAppend(checks, {
        ticket: "SPEC-005",
        title: "Error Tickets Table",
        description: "error_tickets table from TAO-SPEC-2026-005 should exist",
        status: errExists ? "PASS" : "FAIL",
        detail: errDetail,
        fixScript: errExists ? "" : "Run: <code>database/migrations/2026-04-04_error_tickets.sql</code>"
    });
    if (errExists) passCount++; else failCount++;
} catch (any e) {
    arrayAppend(checks, { ticket: "SPEC-005", title: "Error Tickets Table", description: "", status: "ERROR", detail: e.message, fixScript: "" });
    failCount++;
}

// ============================================================
// CHECK 6: Performance indexes (TAO-PLAN-2026-004)
// ============================================================
try {
    // Check for a known composite index from the optimization
    qIdx = queryExecute("
        SELECT COUNT(*) AS cnt
        FROM INFORMATION_SCHEMA.STATISTICS
        WHERE TABLE_SCHEMA = DATABASE()
        AND INDEX_NAME = 'idx_funot_user_status_start'
    ", {}, { datasource: datasource });

    idxExists = (qIdx.cnt gt 0);
    arrayAppend(checks, {
        ticket: "PLAN-004",
        title: "Performance Indexes",
        description: "Composite indexes from TAO-PLAN-2026-004 should be applied",
        status: idxExists ? "PASS" : "FAIL",
        detail: idxExists ? "Key index idx_funot_user_status_start found." : "Key index idx_funot_user_status_start NOT FOUND.",
        fixScript: idxExists ? "" : "Run: <code>database/migrations/2026-03-20_add_performance_indexes.sql</code>"
    });
    if (idxExists) passCount++; else failCount++;
} catch (any e) {
    arrayAppend(checks, { ticket: "PLAN-004", title: "Performance Indexes", description: "", status: "ERROR", detail: e.message, fixScript: "" });
    failCount++;
}

// ============================================================
// CHECK 7: admin_enums table exists
// ============================================================
try {
    qAE = queryExecute("
        SELECT COUNT(*) AS cnt
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = 'admin_enums'
        AND TABLE_SCHEMA = DATABASE()
    ", {}, { datasource: datasource });

    aeExists = (qAE.cnt gt 0);
    aeDetail = aeExists ? "Table exists." : "Table NOT FOUND.";
    if (aeExists) {
        qAECount = queryExecute("SELECT COUNT(*) AS cnt FROM admin_enums", {}, { datasource: datasource });
        aeDetail &= " Seed rows: " & qAECount.cnt;
    }

    arrayAppend(checks, {
        ticket: "Enums",
        title: "Admin Enums Registry Table",
        description: "admin_enums table should exist with seed data for the Admin Enum Dashboard",
        status: aeExists ? "PASS" : "FAIL",
        detail: aeDetail,
        fixScript: aeExists ? "" : "Run: <code>sql/admin_enums_create.sql</code>"
    });
    if (aeExists) passCount++; else failCount++;
} catch (any e) {
    arrayAppend(checks, { ticket: "Enums", title: "Admin Enums Registry Table", description: "", status: "ERROR", detail: e.message, fixScript: "" });
    failCount++;
}

// Summary
totalChecks = passCount + failCount;
</cfscript>

<!--- Summary bar --->
<cfoutput>
<div class="summary-bar <cfif failCount eq 0>summary-pass<cfelseif passCount eq 0>summary-fail<cfelse>summary-partial</cfif>">
    <strong>#passCount# / #totalChecks#</strong> checks passed
    <cfif failCount gt 0> | <strong>#failCount#</strong> need attention</cfif>
</div>
</cfoutput>

<!--- Individual check cards --->
<cfloop array="#checks#" index="chk">
<div class="check-card">
    <div class="d-flex justify-content-between align-items-start">
        <div>
            <h5>
                <cfoutput>
                <cfif chk.status eq "PASS"><span class="status-pass">PASS</span>
                <cfelseif chk.status eq "FAIL"><span class="status-fail">FAIL</span>
                <cfelseif chk.status eq "WARN"><span class="status-warn">WARN</span>
                <cfelseif chk.status eq "SKIP"><span class="status-warn">SKIP</span>
                <cfelse><span class="status-fail">ERROR</span>
                </cfif>
                &nbsp; #chk.title#
                </cfoutput>
            </h5>
            <cfoutput>
            <cfif chk.description neq ""><p class="text-muted mb-2">#chk.description#</p></cfif>
            <div>#chk.detail#</div>
            <cfif chk.fixScript neq "">
                <div class="fix-btn">
                    <strong>Fix:</strong> #chk.fixScript#
                </div>
            </cfif>
            </cfoutput>
        </div>
        <span class="badge bg-secondary"><cfoutput>#chk.ticket#</cfoutput></span>
    </div>
</div>
</cfloop>

<p class="text-muted mt-4">
    <a href="/database/">Back to Database Admin</a>
</p>

</div>
<script src="/app/assets/js/bootstrap.bundle.js"></script>
</body>
</html>
