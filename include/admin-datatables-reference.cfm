<!---
    TAO DataTables Reference Sandbox
    Canonical patterns for all DataTables initializations in TAO.
    Loads identical asset stack to production admin pages via pgpagespluginsxref
    rows for pluginid 1 (datatable bundle) and 4 (global infrastructure).
    Section 10 is the regression canary for column-compression bugs (TAO-DT-03 / TAO-DT-04).
    MIGRATE: in Go/Flutter rebuild, sections become Flutter widget acceptance tests.

    Single source of truth for each section's init JS lives in the initJsByID
    struct below. Each section renders that string twice:
      1. Inside a [script] block (executed by the browser).
      2. Inside a [pre][code] block (HTML-escaped via htmlEditFormat for display).
    DO NOT define separate snippet strings - if display and execution diverge,
    the sandbox lies.
--->
<cfinclude template="/app/admin-users/admin-guard.cfm">

<style>
    /* TECH-DEBT: .status-badge defined in 4 places with 3 variations - consolidate.
       Sites: share/share.cfm:309, app/admin-import-v3/index.cfm:38,
       include/import-auditions.cfm:135, include/import-contacts.cfm:112.
       This sandbox copies the share/share.cfm definition (the only one with
       TAO-DT-04 white-space:nowrap regression protection). */
    .status-badge {
        padding: 0.375rem 0.85rem;
        border-radius: 999px;
        font-size: 0.82rem;
        font-weight: 600;
        display: inline-flex;
        align-items: center;
        gap: 0.5rem;
        white-space: nowrap;
    }
    .status-callback { background: rgba(161,217,236,0.35); color: #246078; }
    .status-redirect { background: rgba(116,192,252,0.35); color: #134d7c; }
    .status-audition { background: rgba(64,110,142,0.2);  color: #2a4f6c; }
    .status-booking  { background: rgba(40,167,69,0.18);  color: #1b5e34; }

    .sandbox-toc { columns: 2; column-gap: 2rem; padding-left: 0; }
    .sandbox-toc li { break-inside: avoid; padding: 2px 0; list-style: none; }
    .sandbox-section { scroll-margin-top: 80px; }
    .sandbox-snippet pre { background: #f8f9fa; border: 1px solid #e9ecef; padding: 12px; border-radius: 4px; font-size: 12px; }
    .sandbox-when { font-size: 0.875rem; color: #5a6c7d; margin-bottom: 12px; }

    /* Section 10: deliberately narrow status column for the stress test */
    #dt-badge-stress th.badge-status-col,
    #dt-badge-stress td.badge-status-col { width: 80px; max-width: 80px; }
</style>

<!--- ============================================================
      SHARED INIT JS REGISTRY
      ============================================================ --->

<cfsavecontent variable="initWideStatic">// Pattern 1: Wide static (10+ cols)
// Use when: server-rendered admin list, fixed columns, no user-side AJAX.
// Inherits scrollX/responsive/pageLength from tao-datatables-defaults.js.
$('#dt-wide-static').DataTable({
    language: {
        paginate: {
            previous: "<i class='mdi mdi-chevron-left'></i>",
            next:     "<i class='mdi mdi-chevron-right'></i>"
        }
    },
    drawCallback: function () {
        $('.dataTables_paginate > .pagination').addClass('pagination-rounded');
    }
});</cfsavecontent>

<cfsavecontent variable="initMediumStatic">// Pattern 2: Medium static (5-9 cols)
// Identical init to wide static; difference is column count, not configuration.
$('#dt-medium-static').DataTable({
    language: {
        paginate: {
            previous: "<i class='mdi mdi-chevron-left'></i>",
            next:     "<i class='mdi mdi-chevron-right'></i>"
        }
    },
    drawCallback: function () {
        $('.dataTables_paginate > .pagination').addClass('pagination-rounded');
    }
});</cfsavecontent>

<cfsavecontent variable="initFormDriven">// Pattern 3: Form-driven (no built-in search)
// Use when: surrounding form controls drive filtering. DataTables search box redundant.
// dom 'rtip' = (r)processing, (t)table, (i)info, (p)paging. Drops length-menu and search.
$('#dt-form-driven').DataTable({
    bFilter: false,
    dom: 'rtip',
    pageLength: 100,
    language: {
        paginate: {
            previous: "<i class='mdi mdi-chevron-left'></i>",
            next:     "<i class='mdi mdi-chevron-right'></i>"
        }
    },
    drawCallback: function () {
        $('.dataTables_paginate > .pagination').addClass('pagination-rounded');
    }
});</cfsavecontent>

<cfsavecontent variable="initButtonsExport">// Pattern 4: Buttons-only export
// Use when: table primarily exists to be exported. Buttons module is bundled
// in /app/assets/js/datatables.min.js (no separate plugin needed).
$('#dt-buttons-export').DataTable({
    lengthChange: false,
    buttons: [
        { extend: 'copy',  className: 'btn-light' },
        { extend: 'print', className: 'btn-light' },
        { extend: 'pdf',   className: 'btn-light' }
    ],
    language: {
        paginate: {
            previous: "<i class='mdi mdi-chevron-left'></i>",
            next:     "<i class='mdi mdi-chevron-right'></i>"
        }
    },
    drawCallback: function () {
        $('.dataTables_paginate > .pagination').addClass('pagination-rounded');
    }
});</cfsavecontent>

<cfsavecontent variable="initAjaxClient">// Pattern 5: Client-side AJAX with dataSrc callback
// Use when: data fetched once from JSON, then sort/page/filter run client-side.
// dataSrc is the hook to shape, log, or augment the response before rendering.
$('#dt-ajax-client').DataTable({
    ajax: {
        url: '/app/admin-datatables-reference/ajax-client.cfm',
        dataSrc: function (json) {
            return json.data || [];
        }
    },
    columns: [
        { data: 'verid',         title: 'ID' },
        { data: 'vername',       title: 'Version' },
        { data: 'versiontype',   title: 'Type' },
        { data: 'versionstatus', title: 'Status' },
        { data: 'releasedate',   title: 'Released' }
    ],
    language: { emptyTable: 'No rows returned' }
});</cfsavecontent>

<cfsavecontent variable="initServerSide">// Pattern 6: Server-side processing
// Use when: dataset is too large for client-side (10k+ rows) or row-level
// auth/scoping must happen server-side. Endpoint speaks the DataTables SSP wire format.
// Production gold-standard is /include/contacts_ss.cfm (user-scoped, CSRF, joined-table search).
// This sandbox endpoint is the minimum-viable shape against the system-scoped pgpages list.
$('#dt-server-side').DataTable({
    serverSide: true,
    processing: true,
    ajax: {
        url: '/app/admin-datatables-reference/ajax-server.cfm',
        type: 'POST'
    },
    columns: [
        { data: 'pgID',       title: 'pgID' },
        { data: 'pgDir',      title: 'Slug' },
        { data: 'pgName',     title: 'Name' },
        { data: 'pgTitle',    title: 'Title' },
        { data: 'pgFilename', title: 'Filename' },
        { data: 'compID',     title: 'compID' }
    ]
});</cfsavecontent>

<cfsavecontent variable="initModal">// Pattern 7: Modal-hosted
// Use when: a table lives inside a Bootstrap modal that opens on demand.
// Init eagerly on dom-ready; the global tao-datatables-defaults.js shown.bs.modal
// handler will call columns.adjust() when the modal becomes visible.
// No per-init shown.bs.modal handler needed.
$('#dt-modal').DataTable({
    language: {
        paginate: {
            previous: "<i class='mdi mdi-chevron-left'></i>",
            next:     "<i class='mdi mdi-chevron-right'></i>"
        }
    },
    drawCallback: function () {
        $('.dataTables_paginate > .pagination').addClass('pagination-rounded');
    }
});</cfsavecontent>

<cfsavecontent variable="initScrollYX">// Pattern 8: scrollY + scrollX combo
// Use when: many rows AND many columns. scrollY caps height; scrollX (from defaults)
// scrolls horizontally for wide tables. tao-datatables.css strips the margin-bottom
// that Bootstrap adds to .table - without that fix, scroll-head and scroll-body misalign.
$('#dt-scroll-yx').DataTable({
    scrollY: '350px',
    scrollCollapse: true,
    paging: false,
    language: {
        paginate: {
            previous: "<i class='mdi mdi-chevron-left'></i>",
            next:     "<i class='mdi mdi-chevron-right'></i>"
        }
    }
});</cfsavecontent>

<cfsavecontent variable="initResponsiveInline">// Pattern 9: Inline-details responsive (gold-standard)
// Use when: contact-list-style page that must collapse gracefully on narrow viewports.
// THIS is the only pattern where the green '+' icon is intentional.
// Overrides global responsive:false to opt in.
$('#dt-responsive-inline').DataTable({
    responsive: {
        details: {
            type: 'inline',
            renderer: function (api, rowIdx, columns) {
                var rows = $.map(columns, function (col) {
                    if (!col.hidden) return '';
                    var v = col.data;
                    if (v == null || String(v).trim() === '') return '';
                    return '<tr><td class="pr-2"><strong>' +
                           $('<div></div>').text(col.title).html() +
                           ':</strong></td><td>' +
                           $('<div></div>').text(String(v)).html() +
                           '</td></tr>';
                }).join('');
                return rows ? $('<table class="table table-sm mb-0"></table>').append(rows) : false;
            }
        }
    },
    columnDefs: [
        { targets: 0, responsivePriority: 1 },
        { targets: 1, responsivePriority: 2 },
        { targets: 2, responsivePriority: 3 },
        { targets: 3, responsivePriority: 5 },
        { targets: 4, responsivePriority: 4 },
        { targets: 5, responsivePriority: 6, orderable: false }
    ],
    language: {
        paginate: {
            previous: "<i class='mdi mdi-chevron-left'></i>",
            next:     "<i class='mdi mdi-chevron-right'></i>"
        }
    },
    drawCallback: function () {
        $('.dataTables_paginate > .pagination').addClass('pagination-rounded');
    }
});</cfsavecontent>

<cfsavecontent variable="initBadgeStress">// Pattern 10: Status-badge stress test
// REGRESSION CANARY for TAO-DT-03 (badge wrapping under autoWidth:false + scrollX:true)
// and TAO-DT-04 (.status-badge compressing under table-layout:auto).
// Status column is deliberately constrained to ~80px. Badges must:
//   - render on ONE line (white-space: nowrap on .status-badge)
//   - not compress mid-character (display: inline-flex, not inline-block)
//   - not vertically squish under autoWidth=true table-layout:auto
// If badges wrap or compress here, defaults regressed. Report; do NOT fix from this work order.
$('#dt-badge-stress').DataTable({
    pageLength: 50,
    language: {
        paginate: {
            previous: "<i class='mdi mdi-chevron-left'></i>",
            next:     "<i class='mdi mdi-chevron-right'></i>"
        }
    },
    drawCallback: function () {
        $('.dataTables_paginate > .pagination').addClass('pagination-rounded');
    }
});</cfsavecontent>

<cfset initJsByID = {
    "dt-wide-static"        = trim(initWideStatic),
    "dt-medium-static"      = trim(initMediumStatic),
    "dt-form-driven"        = trim(initFormDriven),
    "dt-buttons-export"     = trim(initButtonsExport),
    "dt-ajax-client"        = trim(initAjaxClient),
    "dt-server-side"        = trim(initServerSide),
    "dt-modal"              = trim(initModal),
    "dt-scroll-yx"          = trim(initScrollYX),
    "dt-responsive-inline"  = trim(initResponsiveInline),
    "dt-badge-stress"       = trim(initBadgeStress)
}>

<!--- ============================================================
      DATA QUERIES (all inline, system-scoped, parameterized)
      ============================================================ --->

<cfquery name="qWide" datasource="#application.dsn#">
    SELECT
        t.ticketID, t.ticketName, t.tickettype, t.ticketstatus,
        t.ticketpriority, t.esthours,
        CONCAT(IFNULL(v.major,0), '.', IFNULL(v.minor,0), '.', IFNULL(v.patch,0)) AS releaseVer,
        IFNULL(u.recordname, '') AS userName,
        DATE_FORMAT(t.ticketCreatedDate, '%Y-%m-%d') AS createdDate,
        IFNULL(p.pgname, '') AS pageName
    FROM tickets t
    LEFT JOIN taousers_tbl u ON u.userid = t.userid
    LEFT JOIN taoversions v ON v.verid = t.verid
    LEFT JOIN pgpages p ON p.pgid = t.pgid
    WHERE t.ticketActive = <cfqueryparam value="Y" cfsqltype="cf_sql_varchar">
    ORDER BY t.ticketCreatedDate DESC
    LIMIT 100
</cfquery>

<cfquery name="qMedium" datasource="#application.dsn#">
    SELECT
        ap.audprojectid,
        IFNULL(ap.projname, '')         AS projname,
        DATE_FORMAT(ap.projdate, '%Y-%m-%d') AS projdate,
        IFNULL(ap.projdescription, '')  AS projdescription,
        ap.isDirect,
        ap.contactid,
        ap.userid
    FROM audprojects ap
    WHERE ap.isDeleted = <cfqueryparam value="0" cfsqltype="cf_sql_bit">
    ORDER BY ap.audprojectid DESC
    LIMIT 100
</cfquery>

<cfquery name="qButtons" datasource="#application.dsn#">
    SELECT pgID, pgDir, pgName, pgTitle, pgFilename, compID
    FROM pgpages_tbl
    WHERE IsDeleted = <cfqueryparam value="0" cfsqltype="cf_sql_bit">
    ORDER BY pgID
    LIMIT 200
</cfquery>

<cfquery name="qVersions" datasource="#application.dsn#">
    SELECT
        verid,
        CONCAT(IFNULL(major,0), '.', IFNULL(minor,0), '.', IFNULL(patch,0)) AS vername,
        IFNULL(versiontype, '')   AS versiontype,
        IFNULL(versionstatus, '') AS versionstatus,
        DATE_FORMAT(releasedate, '%Y-%m-%d') AS releasedate
    FROM taoversions
    ORDER BY verid DESC
    LIMIT 50
</cfquery>

<cfquery name="qScroll" datasource="#application.dsn#">
    SELECT
        t.ticketID, t.ticketName, t.tickettype, t.ticketstatus,
        t.ticketpriority, t.esthours,
        DATE_FORMAT(t.ticketCreatedDate, '%Y-%m-%d') AS createdDate,
        IFNULL(u.recordname, '') AS userName,
        IFNULL(v.major, 0)       AS verMajor,
        IFNULL(v.minor, 0)       AS verMinor,
        IFNULL(p.pgname, '')     AS pageName
    FROM tickets t
    LEFT JOIN taousers_tbl u ON u.userid = t.userid
    LEFT JOIN taoversions v ON v.verid = t.verid
    LEFT JOIN pgpages p ON p.pgid = t.pgid
    ORDER BY t.ticketID DESC
    LIMIT 100
</cfquery>

<cfquery name="qResponsive" datasource="#application.dsn#">
    SELECT pgID, pgDir, pgName, pgTitle, pgFilename, compID
    FROM pgpages_tbl
    WHERE IsDeleted = <cfqueryparam value="0" cfsqltype="cf_sql_bit">
    ORDER BY pgID
    LIMIT 100
</cfquery>

<!--- §10 stress: hand-crafted demo rows so all four .status-badge classes appear --->
<cfset badgeStressRows = []>
<cfset stressStatuses = ["callback", "redirect", "audition", "booking"]>
<cfloop from="1" to="20" index="i">
    <cfset arrayAppend(badgeStressRows, {
        "id"     = i,
        "name"   = "Demo Project " & i,
        "status" = stressStatuses[((i - 1) MOD 4) + 1],
        "date"   = dateFormat(dateAdd("d", -i, now()), "yyyy-mm-dd")
    })>
</cfloop>

<!--- ============================================================
      PAGE BODY
      ============================================================ --->

<div class="row">
  <div class="col-12">

    <!--- Top-of-page TOC --->
    <div class="card mb-3">
      <div class="card-body">
        <p class="text-muted font-13 mb-3">
          Canonical patterns for every TAO DataTables init. Loads identical asset
          stack to production admin pages. Each section shows the live table, the
          exact init JS that produces it, and when (and when NOT) to use it.
          <strong>Section 10 is the regression canary</strong> for column-compression
          and badge-wrapping bugs - if it breaks, defaults regressed.
        </p>
        <ul class="sandbox-toc">
          <li><a href="#sec-wide-static">1. Wide static (10+ cols)</a></li>
          <li><a href="#sec-medium-static">2. Medium static (5-9 cols)</a></li>
          <li><a href="#sec-form-driven">3. Form-driven (no built-in search)</a></li>
          <li><a href="#sec-buttons-export">4. Buttons-only export</a></li>
          <li><a href="#sec-ajax-client">5. Client-side AJAX (dataSrc)</a></li>
          <li><a href="#sec-server-side">6. Server-side processing</a></li>
          <li><a href="#sec-modal">7. Modal-hosted</a></li>
          <li><a href="#sec-scroll-yx">8. scrollY + scrollX combo</a></li>
          <li><a href="#sec-responsive-inline">9. Inline-details responsive (gold-standard)</a></li>
          <li><a href="#sec-badge-stress">10. Status-badge stress test (canary)</a></li>
        </ul>
      </div>
    </div>

    <!--- ===================== §1 Wide static ===================== --->
    <div class="card mb-3 sandbox-section" id="sec-wide-static">
      <div class="card-body">
        <h4 class="header-title">1. Wide static (10+ cols)</h4>
        <p class="sandbox-when">
          <strong>Use when:</strong> server-rendered admin list, fixed columns,
          no user-side AJAX. <strong>Don't use when:</strong> the data set is
          large (10k+ rows) - server-side processing scales better.
          Inherits scrollX/responsive/pageLength from tao-datatables-defaults.js.
        </p>
        <table id="dt-wide-static" class="table dt-responsive nowrap w-100 table-striped">
          <thead>
            <tr>
              <th>ID</th><th>Title</th><th>Type</th><th>Status</th><th>Priority</th>
              <th>Hours</th><th>Release</th><th>User</th><th>Created</th><th>Page</th>
            </tr>
          </thead>
          <tbody>
            <cfoutput query="qWide">
              <tr>
                <td>#qWide.ticketID#</td>
                <td>#left(qWide.ticketName, 60)#</td>
                <td>#qWide.tickettype#</td>
                <td>#qWide.ticketstatus#</td>
                <td>#qWide.ticketpriority#</td>
                <td>#qWide.esthours#</td>
                <td>#qWide.releaseVer#</td>
                <td>#qWide.userName#</td>
                <td>#qWide.createdDate#</td>
                <td>#qWide.pageName#</td>
              </tr>
            </cfoutput>
          </tbody>
        </table>
        <script>
          $(document).ready(function () {
            <cfoutput>#initJsByID["dt-wide-static"]#</cfoutput>
          });
        </script>
        <details class="sandbox-snippet mt-3">
          <summary class="text-muted small">Show init code</summary>
          <pre><code class="language-js"><cfoutput>#htmlEditFormat(initJsByID["dt-wide-static"])#</cfoutput></code></pre>
        </details>
      </div>
    </div>

    <!--- ===================== §2 Medium static ===================== --->
    <div class="card mb-3 sandbox-section" id="sec-medium-static">
      <div class="card-body">
        <h4 class="header-title">2. Medium static (5-9 cols)</h4>
        <p class="sandbox-when">
          <strong>Use when:</strong> mid-sized admin list. <strong>Don't use when:</strong>
          the page already has filter controls - jump to §3 to drop the redundant
          DataTables search. Same init as §1; only column count differs.
        </p>
        <table id="dt-medium-static" class="table dt-responsive nowrap w-100 table-striped">
          <thead>
            <tr>
              <th>ID</th><th>Project</th><th>Date</th><th>Description</th>
              <th>Direct?</th><th>Contact ID</th><th>User</th>
            </tr>
          </thead>
          <tbody>
            <cfoutput query="qMedium">
              <tr>
                <td>#qMedium.audprojectid#</td>
                <td>#left(qMedium.projname, 50)#</td>
                <td>#qMedium.projdate#</td>
                <td>#left(qMedium.projdescription, 60)#</td>
                <td>#qMedium.isDirect#</td>
                <td>#qMedium.contactid#</td>
                <td>#qMedium.userid#</td>
              </tr>
            </cfoutput>
          </tbody>
        </table>
        <script>
          $(document).ready(function () {
            <cfoutput>#initJsByID["dt-medium-static"]#</cfoutput>
          });
        </script>
        <details class="sandbox-snippet mt-3">
          <summary class="text-muted small">Show init code</summary>
          <pre><code class="language-js"><cfoutput>#htmlEditFormat(initJsByID["dt-medium-static"])#</cfoutput></code></pre>
        </details>
      </div>
    </div>

    <!--- ===================== §3 Form-driven ===================== --->
    <div class="card mb-3 sandbox-section" id="sec-form-driven">
      <div class="card-body">
        <h4 class="header-title">3. Form-driven (no built-in search)</h4>
        <p class="sandbox-when">
          <strong>Use when:</strong> surrounding form controls drive filtering -
          DataTables search box is redundant noise. <strong>Don't use when:</strong>
          there's no surrounding filter UI - users will be stuck without search.
          Same data as §2; init drops the search/length controls.
        </p>
        <table id="dt-form-driven" class="table dt-responsive nowrap w-100 table-striped">
          <thead>
            <tr>
              <th>ID</th><th>Project</th><th>Date</th><th>Description</th>
              <th>Direct?</th><th>Contact ID</th><th>User</th>
            </tr>
          </thead>
          <tbody>
            <cfoutput query="qMedium">
              <tr>
                <td>#qMedium.audprojectid#</td>
                <td>#left(qMedium.projname, 50)#</td>
                <td>#qMedium.projdate#</td>
                <td>#left(qMedium.projdescription, 60)#</td>
                <td>#qMedium.isDirect#</td>
                <td>#qMedium.contactid#</td>
                <td>#qMedium.userid#</td>
              </tr>
            </cfoutput>
          </tbody>
        </table>
        <script>
          $(document).ready(function () {
            <cfoutput>#initJsByID["dt-form-driven"]#</cfoutput>
          });
        </script>
        <details class="sandbox-snippet mt-3">
          <summary class="text-muted small">Show init code</summary>
          <pre><code class="language-js"><cfoutput>#htmlEditFormat(initJsByID["dt-form-driven"])#</cfoutput></code></pre>
        </details>
      </div>
    </div>

    <!--- ===================== §4 Buttons-only export ===================== --->
    <div class="card mb-3 sandbox-section" id="sec-buttons-export">
      <div class="card-body">
        <h4 class="header-title">4. Buttons-only export</h4>
        <p class="sandbox-when">
          <strong>Use when:</strong> table primarily exists to be exported (CSV,
          PDF, copy-to-clipboard). <strong>Don't use when:</strong> editing is
          the primary interaction - export buttons add noise. Buttons module is
          bundled in <code>/app/assets/js/datatables.min.js</code>.
        </p>
        <table id="dt-buttons-export" class="table dt-responsive nowrap w-100 table-striped">
          <thead>
            <tr>
              <th>pgID</th><th>Slug</th><th>Name</th><th>Title</th>
              <th>Filename</th><th>compID</th>
            </tr>
          </thead>
          <tbody>
            <cfoutput query="qButtons">
              <tr>
                <td>#qButtons.pgID#</td>
                <td>#qButtons.pgDir#</td>
                <td>#qButtons.pgName#</td>
                <td>#qButtons.pgTitle#</td>
                <td>#qButtons.pgFilename#</td>
                <td>#qButtons.compID#</td>
              </tr>
            </cfoutput>
          </tbody>
        </table>
        <script>
          $(document).ready(function () {
            <cfoutput>#initJsByID["dt-buttons-export"]#</cfoutput>
          });
        </script>
        <details class="sandbox-snippet mt-3">
          <summary class="text-muted small">Show init code</summary>
          <pre><code class="language-js"><cfoutput>#htmlEditFormat(initJsByID["dt-buttons-export"])#</cfoutput></code></pre>
        </details>
      </div>
    </div>

    <!--- ===================== §5 Client-side AJAX ===================== --->
    <div class="card mb-3 sandbox-section" id="sec-ajax-client">
      <div class="card-body">
        <h4 class="header-title">5. Client-side AJAX (dataSrc)</h4>
        <p class="sandbox-when">
          <strong>Use when:</strong> data fetched once from a JSON endpoint, then
          sort/page/filter run client-side. <strong>Don't use when:</strong> the
          data set is too large to ship in one response - jump to §6.
          <code>dataSrc</code> is the hook to shape, log, or augment the response.
          Endpoint: <code>/app/admin-datatables-reference/ajax-client.cfm</code>.
        </p>
        <table id="dt-ajax-client" class="table dt-responsive nowrap w-100 table-striped">
          <thead>
            <tr>
              <th>ID</th><th>Version</th><th>Type</th><th>Status</th><th>Released</th>
            </tr>
          </thead>
          <tbody></tbody>
        </table>
        <script>
          $(document).ready(function () {
            <cfoutput>#initJsByID["dt-ajax-client"]#</cfoutput>
          });
        </script>
        <details class="sandbox-snippet mt-3">
          <summary class="text-muted small">Show init code</summary>
          <pre><code class="language-js"><cfoutput>#htmlEditFormat(initJsByID["dt-ajax-client"])#</cfoutput></code></pre>
        </details>
      </div>
    </div>

    <!--- ===================== §6 Server-side processing ===================== --->
    <div class="card mb-3 sandbox-section" id="sec-server-side">
      <div class="card-body">
        <h4 class="header-title">6. Server-side processing</h4>
        <p class="sandbox-when">
          <strong>Use when:</strong> data set is too large for client-side (10k+
          rows) or row-level auth/scoping must happen server-side.
          <strong>Don't use when:</strong> the data is small - the round-trip per
          page change adds latency. Production gold-standard:
          <code>/include/contacts_ss.cfm</code> (user-scoped, CSRF-checked, joined
          search). This sandbox is the minimum-viable shape over
          <code>pgpages</code>.
        </p>
        <table id="dt-server-side" class="table dt-responsive nowrap w-100 table-striped">
          <thead>
            <tr>
              <th>pgID</th><th>Slug</th><th>Name</th><th>Title</th>
              <th>Filename</th><th>compID</th>
            </tr>
          </thead>
          <tbody></tbody>
        </table>
        <script>
          $(document).ready(function () {
            <cfoutput>#initJsByID["dt-server-side"]#</cfoutput>
          });
        </script>
        <details class="sandbox-snippet mt-3">
          <summary class="text-muted small">Show init code</summary>
          <pre><code class="language-js"><cfoutput>#htmlEditFormat(initJsByID["dt-server-side"])#</cfoutput></code></pre>
        </details>
      </div>
    </div>

    <!--- ===================== §7 Modal-hosted ===================== --->
    <div class="card mb-3 sandbox-section" id="sec-modal">
      <div class="card-body">
        <h4 class="header-title">7. Modal-hosted</h4>
        <p class="sandbox-when">
          <strong>Use when:</strong> the table is supplementary content surfaced
          on demand (picker, audit trail). <strong>Don't use when:</strong> the
          table is the primary interaction - put it on the page.
          Eager init at dom-ready; the global <code>shown.bs.modal</code> handler
          in <code>tao-datatables-defaults.js</code> fires <code>columns.adjust()</code>
          when the modal opens. No per-init plumbing required.
        </p>
        <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#modalSandbox">
          Open modal table
        </button>
        <script>
          $(document).ready(function () {
            <cfoutput>#initJsByID["dt-modal"]#</cfoutput>
          });
        </script>
        <details class="sandbox-snippet mt-3">
          <summary class="text-muted small">Show init code</summary>
          <pre><code class="language-js"><cfoutput>#htmlEditFormat(initJsByID["dt-modal"])#</cfoutput></code></pre>
        </details>
      </div>
    </div>

    <!--- ===================== §8 scrollY + scrollX ===================== --->
    <div class="card mb-3 sandbox-section" id="sec-scroll-yx">
      <div class="card-body">
        <h4 class="header-title">8. scrollY + scrollX combo</h4>
        <p class="sandbox-when">
          <strong>Use when:</strong> many rows AND many columns - vertical scroll
          caps height, horizontal scroll keeps wide tables in their card.
          <strong>Don't use when:</strong> only one axis exceeds the viewport -
          you only need one scroll. <code>tao-datatables.css</code> strips the
          margin-bottom Bootstrap adds to <code>.table</code>; without that fix,
          scroll-head and scroll-body misalign.
        </p>
        <table id="dt-scroll-yx" class="table dt-responsive nowrap w-100 table-striped">
          <thead>
            <tr>
              <th>ID</th><th>Title</th><th>Type</th><th>Status</th><th>Priority</th>
              <th>Hours</th><th>Created</th>
              <th>User</th><th>Major</th><th>Minor</th><th>Page</th>
            </tr>
          </thead>
          <tbody>
            <cfoutput query="qScroll">
              <tr>
                <td>#qScroll.ticketID#</td>
                <td>#left(qScroll.ticketName, 60)#</td>
                <td>#qScroll.tickettype#</td>
                <td>#qScroll.ticketstatus#</td>
                <td>#qScroll.ticketpriority#</td>
                <td>#qScroll.esthours#</td>
                <td>#qScroll.createdDate#</td>
                <td>#qScroll.userName#</td>
                <td>#qScroll.verMajor#</td>
                <td>#qScroll.verMinor#</td>
                <td>#qScroll.pageName#</td>
              </tr>
            </cfoutput>
          </tbody>
        </table>
        <script>
          $(document).ready(function () {
            <cfoutput>#initJsByID["dt-scroll-yx"]#</cfoutput>
          });
        </script>
        <details class="sandbox-snippet mt-3">
          <summary class="text-muted small">Show init code</summary>
          <pre><code class="language-js"><cfoutput>#htmlEditFormat(initJsByID["dt-scroll-yx"])#</cfoutput></code></pre>
        </details>
      </div>
    </div>

    <!--- ===================== §9 Inline-details responsive ===================== --->
    <div class="card mb-3 sandbox-section" id="sec-responsive-inline">
      <div class="card-body">
        <h4 class="header-title">9. Inline-details responsive (gold-standard)</h4>
        <p class="sandbox-when">
          <strong>Use when:</strong> contact-list-style page that must collapse
          gracefully on narrow viewports (mobile, narrow tabs).
          <strong>Don't use when:</strong> users only ever view this on a wide
          screen - the green <strong>+</strong> icon adds visual noise.
          <strong>This is the only pattern where the green +
          icon is intentional.</strong>
          Overrides global <code>responsive:false</code> to opt in. Resize the
          window to see columns collapse into the expandable detail rows.
        </p>
        <table id="dt-responsive-inline" class="table dt-responsive nowrap w-100 table-striped">
          <thead>
            <tr>
              <th>pgID</th><th>Slug</th><th>Name</th><th>Title</th>
              <th>Filename</th><th>compID</th>
            </tr>
          </thead>
          <tbody>
            <cfoutput query="qResponsive">
              <tr>
                <td>#qResponsive.pgID#</td>
                <td>#qResponsive.pgDir#</td>
                <td>#qResponsive.pgName#</td>
                <td>#qResponsive.pgTitle#</td>
                <td>#qResponsive.pgFilename#</td>
                <td>#qResponsive.compID#</td>
              </tr>
            </cfoutput>
          </tbody>
        </table>
        <script>
          $(document).ready(function () {
            <cfoutput>#initJsByID["dt-responsive-inline"]#</cfoutput>
          });
        </script>
        <details class="sandbox-snippet mt-3">
          <summary class="text-muted small">Show init code</summary>
          <pre><code class="language-js"><cfoutput>#htmlEditFormat(initJsByID["dt-responsive-inline"])#</cfoutput></code></pre>
        </details>
      </div>
    </div>

    <!--- ===================== §10 Status-badge stress (CANARY) ===================== --->
    <div class="card mb-3 sandbox-section" id="sec-badge-stress">
      <div class="card-body">
        <h4 class="header-title">10. Status-badge stress test (regression canary)</h4>
        <p class="sandbox-when">
          <strong>Regression canary for TAO-DT-03</strong> (badge wrapping under
          autoWidth:false + scrollX:true) <strong>and TAO-DT-04</strong>
          (.status-badge compressing under table-layout:auto).
          The status column is deliberately constrained to ~80px. Badges must
          render on one line (no wrap, no character compression, no vertical squish).
          If badges break here, the global defaults regressed -
          <strong>report it; do NOT fix from this work order.</strong>
        </p>
        <p class="text-muted small">
          <strong>Out-of-scope finding (separate work order):</strong>
          <code>.status-badge</code> is currently defined in four places with three
          different definitions:
          <code>share/share.cfm:309</code> (the pill style with TAO-DT-04 nowrap
          protection - the one this sandbox copies),
          <code>app/admin-import-v3/index.cfm:38</code>,
          <code>include/import-auditions.cfm:135</code>,
          <code>include/import-contacts.cfm:112</code>. Consolidating into a single
          rule in <code>tao-components.css</code> is recommended but out of scope
          for this work order.
        </p>
        <table id="dt-badge-stress" class="table dt-responsive nowrap w-100 table-striped">
          <thead>
            <tr>
              <th>ID</th>
              <th>Project Name</th>
              <th class="badge-status-col">Status</th>
              <th>Date</th>
            </tr>
          </thead>
          <tbody>
            <cfloop array="#badgeStressRows#" index="row">
              <cfoutput>
                <tr>
                  <td>#row.id#</td>
                  <td>#row.name#</td>
                  <td class="badge-status-col"><span class="status-badge status-#row.status#">#row.status#</span></td>
                  <td>#row.date#</td>
                </tr>
              </cfoutput>
            </cfloop>
          </tbody>
        </table>
        <script>
          $(document).ready(function () {
            <cfoutput>#initJsByID["dt-badge-stress"]#</cfoutput>
          });
        </script>
        <details class="sandbox-snippet mt-3">
          <summary class="text-muted small">Show init code</summary>
          <pre><code class="language-js"><cfoutput>#htmlEditFormat(initJsByID["dt-badge-stress"])#</cfoutput></code></pre>
        </details>
      </div>
    </div>

  </div>
</div>

<!--- ============================================================
      §7 Modal markup (lives at end of page so the modal is a
      direct child of body for Bootstrap to position correctly)
      ============================================================ --->
<div id="modalSandbox" class="modal fade" tabindex="-1" aria-labelledby="modalSandboxLabel" aria-hidden="true">
  <div class="modal-dialog modal-lg">
    <div class="modal-content">
      <div class="modal-header">
        <h4 class="modal-title" id="modalSandboxLabel">Modal-hosted DataTable</h4>
        <button type="button" class="close" data-bs-dismiss="modal" aria-label="Close">
          <i class="mdi mdi-close-thick"></i>
        </button>
      </div>
      <div class="modal-body">
        <table id="dt-modal" class="table dt-responsive nowrap w-100 table-striped">
          <thead>
            <tr>
              <th>ID</th><th>Version</th><th>Type</th><th>Status</th>
            </tr>
          </thead>
          <tbody>
            <cfoutput query="qVersions">
              <tr>
                <td>#qVersions.verid#</td>
                <td>#qVersions.vername#</td>
                <td>#qVersions.versiontype#</td>
                <td>#qVersions.versionstatus#</td>
              </tr>
            </cfoutput>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</div>
