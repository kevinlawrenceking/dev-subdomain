<!---
    admin-enum-dashboard.cfm
    Shared dashboard renderer for admin enum panels.
    Expects caller to set: variables.enumGroup ("audition" or "relationship")
    Included by: app/admin-enum-audition/index.cfm, app/admin-enum-relationship/index.cfm
--->

<!--- Security: admin only. userRole is set by fetchUsers.cfm in onRequestStart. --->
<cfif NOT isDefined("userRole") OR (userRole NEQ "Admin" AND userRole NEQ "Administrator")>
    <cflocation url="/app/dashboard_new/" addtoken="false">
</cfif>

<!--- Resolve group label for page header --->
<cfswitch expression="#variables.enumGroup#">
    <cfcase value="audition">
        <cfset pageTitle = "Audition Admin">
        <cfset pageSubtitle = "Manage audition lookup tables">
    </cfcase>
    <cfcase value="relationship">
        <cfset pageTitle = "Relationship Admin">
        <cfset pageSubtitle = "Manage relationship system lookup tables">
    </cfcase>
    <cfdefaultcase>
        <cfset pageTitle = "Admin Enums">
        <cfset pageSubtitle = "Manage lookup tables">
    </cfdefaultcase>
</cfswitch>

<!--- Load service and data --->
<cfset svc = createObject("component", "services.AdminEnumService")>
<cfset qEnums = svc.getEnumsByGroup(variables.enumGroup)>

<!--- Pre-load all rows and parent options for server-side rendering --->
<cfset enumData = {}>
<cfloop query="qEnums">
    <cfset eid = qEnums.enum_id>
    <cfset enumData[eid] = {
        "rows"          = svc.getEnumRows(eid),
        "parentOptions" = len(trim(qEnums.parent_table)) ? svc.getParentOptions(eid) : queryNew("id,name")
    }>
</cfloop>

<!--- CSRF token for AJAX calls --->
<cfset csrfToken = CSRFGenerateToken()>

<!DOCTYPE html>
<html>
<head>
    <title><cfoutput>#pageTitle#</cfoutput> | TAO Admin</title>
    <link href="/app/assets/css/bootstrap.css" rel="stylesheet">
    <link href="/app/assets/css/app.min.css" rel="stylesheet">
    <link href="/app/assets/css/admin-enum.css" rel="stylesheet">
    <meta name="csrf-token" content="<cfoutput>#csrfToken#</cfoutput>">
</head>
<body>
    <div class="container-fluid" style="padding: 20px;">

        <!--- Page header --->
        <div class="row mb-4">
            <div class="col-12">
                <h1><cfoutput>#pageTitle#</cfoutput></h1>
                <p class="text-muted"><cfoutput>#pageSubtitle#</cfoutput></p>
            </div>
        </div>

        <!--- Panel grid --->
        <div class="admin-enum-grid">
            <cfoutput query="qEnums">
                <cfset eid       = qEnums.enum_id>
                <cfset qRows     = enumData[eid].rows>
                <cfset qParent   = enumData[eid].parentOptions>
                <cfset hasParent = len(trim(qEnums.parent_table))>
                <cfset readOnly  = (qEnums.is_read_only EQ 1)>
                <cfset parentLbl = len(trim(qEnums.parent_label)) ? qEnums.parent_label : "Parent">

                <div class="card admin-enum-panel<cfif readOnly> admin-enum-readonly</cfif>"
                     data-enum-id="#eid#"
                     data-has-parent="#hasParent ? 'true' : 'false'#"
                     data-parent-label="#encodeForHTMLAttribute(parentLbl)#"
                     data-read-only="#readOnly ? 'true' : 'false'#">

                    <!--- Card header --->
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h5 class="m-0">
                            <cfif readOnly><i class="mdi mdi-lock-outline text-muted me-1" title="Read-only"></i></cfif>
                            #encodeForHTML(qEnums.display_name)#
                        </h5>
                        <span class="badge bg-secondary" data-role="count">#qRows.recordCount#</span>
                    </div>

                    <!--- Card body: scrollable row list --->
                    <div class="card-body p-0">
                        <div class="admin-enum-list" style="max-height: 300px; overflow-y: auto;">
                            <cfif qRows.recordCount EQ 0>
                                <div class="admin-enum-empty text-center text-muted py-3">
                                    No items
                                </div>
                            <cfelse>
                                <cfloop query="qRows">
                                    <div class="admin-enum-row d-flex align-items-center px-3 py-2"
                                         data-pk="#encodeForHTMLAttribute(qRows.id)#"
                                         <cfif hasParent>data-parent-id="#encodeForHTMLAttribute(qRows.parent_id)#"</cfif>>
                                        <span class="admin-enum-name flex-grow-1" title="#encodeForHTMLAttribute(qRows.name)#">#encodeForHTML(qRows.name)#</span>
                                        <cfif hasParent AND listFindNoCase(qRows.columnList, "parent_name")>
                                            <span class="admin-enum-parent text-muted small me-2">#encodeForHTML(qRows.parent_name)#</span>
                                        </cfif>
                                        <cfif NOT readOnly>
                                            <button class="btn btn-sm btn-link p-0" data-action="edit" title="Edit">
                                                <i class="mdi mdi-square-edit-outline"></i>
                                            </button>
                                        </cfif>
                                    </div>
                                </cfloop>
                            </cfif>
                        </div>
                    </div>

                    <!--- Card footer: Add button (hidden for read-only) --->
                    <cfif NOT readOnly>
                        <div class="card-footer p-2">
                            <button class="btn btn-sm btn-outline-primary w-100" data-action="add">
                                <i class="mdi mdi-plus"></i> Add
                            </button>
                        </div>
                    </cfif>

                    <!--- Hidden parent options data for JS (avoids extra AJAX call) --->
                    <cfif hasParent AND qParent.recordCount GT 0>
                        <script type="application/json" class="parent-options-data">
                            [<cfloop query="qParent"><cfif qParent.currentRow GT 1>,</cfif>{"id":"#encodeForJavaScript(qParent.id)#","name":"#encodeForJavaScript(qParent.name)#"}</cfloop>]
                        </script>
                    </cfif>
                </div>
            </cfoutput>
        </div><!--- /.admin-enum-grid --->

    </div><!--- /.container-fluid --->

    <script src="/app/assets/js/bootstrap.bundle.js"></script>
    <script src="/app/assets/js/admin-enum.js"></script>
</body>
</html>
