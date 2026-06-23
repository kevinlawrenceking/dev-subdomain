<!---
    P11 Step 5: Relationship Reminders
    Explain Target vs Maintenance systems and enroll contacts.
    Tutorial defaults to EXPANDED on this step.
--->
<cfset userid = session.userid>

<!--- Fetch available relationship systems --->
<cfquery name="qSystems" datasource="#application.datasource#">
    SELECT systemid, systemname, systemtype
    FROM fusystems
    WHERE systemtype IN ('Target', 'Maintenance')
    ORDER BY systemtype
</cfquery>

<!--- Fetch user's contacts from Steps 2-3 (non-self, active) --->
<cfquery name="qContacts" datasource="#application.datasource#">
    SELECT cd.contactid, cd.contactFullName, cd.contactTitle
    FROM contactdetails cd
    WHERE cd.userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer" />
      AND cd.contactStatus = 'Active'
      AND COALESCE(cd.user_yn, 'N') <> 'Y'
    ORDER BY cd.contactFullName
</cfquery>

<!--- For each contact, determine scope via tag check --->
<cfset contactItemService = request.svc("ContactItemService")>
<cfset contactList = []>
<cfloop query="qContacts">
    <cftry>
        <cfset scope = contactItemService.getContactTagStatus(contactid=qContacts.contactid, userid=userid)>
        <cfcatch>
            <cfset scope = "Industry">
            <cflog file="TAO_setup_wizard" type="warning" text="getContactTagStatus failed for contact #qContacts.contactid#: #cfcatch.message#">
        </cfcatch>
    </cftry>
    <!--- Check if tagged as My Rep Team --->
    <cfquery name="qRepTag" datasource="#application.datasource#" maxrows="1">
        SELECT 1 FROM contactitems
        WHERE contactid = <cfqueryparam value="#qContacts.contactid#" cfsqltype="cf_sql_integer" />
          AND valueCategory = 'Tag' AND valueType = 'Tags'
          AND ( valuetext = 'My Rep Team' OR valuetext IN ('Agent','Manager','Publicist') ) AND itemStatus = 'Active'
    </cfquery>
    <cfset isRep = qRepTag.recordCount GT 0>

    <!--- Check if already enrolled in any system --->
    <cfquery name="qEnrolled" datasource="#application.datasource#" maxrows="1">
        SELECT suid FROM fusystemusers
        WHERE contactid = <cfqueryparam value="#qContacts.contactid#" cfsqltype="cf_sql_integer" />
          AND userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer" />
          AND sustatus = 'Active'
    </cfquery>

    <cfset arrayAppend(contactList, {
        contactid: qContacts.contactid,
        name: qContacts.contactFullName,
        title: qContacts.contactTitle,
        scope: scope,
        isRep: isRep,
        isEnrolled: qEnrolled.recordCount GT 0
    })>
</cfloop>

<!--- Find the default Target and Maintenance system IDs --->
<cfset targetSystemId = 0>
<cfset maintSystemId = 0>
<cfloop query="qSystems">
    <cfif qSystems.systemtype EQ "Target" AND targetSystemId EQ 0>
        <cfset targetSystemId = qSystems.systemid>
    </cfif>
    <cfif qSystems.systemtype EQ "Maintenance" AND maintSystemId EQ 0>
        <cfset maintSystemId = qSystems.systemid>
    </cfif>
</cfloop>
<cfset systemsMissing = (targetSystemId EQ 0 AND maintSystemId EQ 0)>
<cfif systemsMissing>
    <cflog file="TAO_setup_wizard" type="warning"
           text="Step 5: No Target or Maintenance systems found in fusystems table.">
</cfif>

<cfoutput>

<!--- Tutorial (DEFAULT EXPANDED on step 5) --->
<div class="wizard-tutorial-toggle" data-bs-toggle="collapse" data-bs-target="##tutorial5">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
    What are relationship reminders?
</div>
<div class="collapse show" id="tutorial5">
    <div class="wizard-tutorial">
        <p>Relationship reminders are TAO's secret weapon. There are two systems:</p>
        <p><strong>Target</strong> -- For people you want to work with but haven't built a relationship with yet. TAO will remind you to reach out on a structured schedule.</p>
        <p><strong>Maintenance</strong> -- For people you've already connected with. TAO helps you stay in touch so relationships don't go cold.</p>
        <p>Select a few contacts below and choose a system. TAO will start generating reminders for you.</p>
    </div>
</div>

<h3>Set up relationship reminders</h3>

<!--- System explanation cards --->
<div class="row g-3 mb-4">
    <div class="col-md-6">
        <div class="system-card">
            <svg class="system-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><circle cx="12" cy="12" r="6"/><circle cx="12" cy="12" r="2"/></svg>
            <h5>Target</h5>
            <p>Build new relationships with structured outreach reminders.</p>
        </div>
    </div>
    <div class="col-md-6">
        <div class="system-card">
            <svg class="system-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="23 4 23 10 17 10"/><polyline points="1 20 1 14 7 14"/><path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"/></svg>
            <h5>Maintenance</h5>
            <p>Stay in touch with people you've already connected with.</p>
        </div>
    </div>
</div>

<cfif systemsMissing>
    <div class="alert alert-warning" role="alert">
        Relationship systems are not configured yet. You can skip this step and set up reminders later from the Contacts page.
    </div>
<cfelseif arrayLen(contactList) EQ 0>
    <div class="text-center py-4 text-muted">
        <p>You haven't added any contacts yet. You can set up reminders later from the Contacts page.</p>
        <a href="javascript:void(0)" onclick="$('##btn-back').trigger('click');" class="btn btn-outline-primary btn-sm">Back to Add Contacts</a>
    </div>
<cfelse>
    <!--- Contact enrollment table --->
    <div class="table-responsive">
        <table class="table reminder-table">
            <thead>
                <tr>
                    <th>Contact</th>
                    <th>Role / Company</th>
                    <th class="text-center">Target</th>
                    <th class="text-center">Maintenance</th>
                    <th class="text-center">None</th>
                </tr>
            </thead>
            <tbody>
                <cfloop array="#contactList#" index="ct">
                    <cfset defaultVal = "none">
                    <cfif ct.isEnrolled>
                        <cfset defaultVal = "enrolled">
                    <cfelseif ct.isRep>
                        <cfset defaultVal = "maintenance">
                    <cfelseif ct.scope EQ "Casting Director">
                        <cfset defaultVal = "target">
                    </cfif>
                    <tr>
                        <td>#encodeForHTML(ct.name)#</td>
                        <td class="text-muted">#encodeForHTML(ct.title)#</td>
                        <td class="text-center">
                            <cfif ct.isEnrolled>
                                <span class="text-muted" style="font-size:12px;">Enrolled</span>
                            <cfelse>
                                <input type="radio" name="sys_#ct.contactid#" value="target"
                                       class="form-check-input" #defaultVal EQ "target" ? "checked" : ""# />
                            </cfif>
                        </td>
                        <td class="text-center">
                            <cfif ct.isEnrolled>
                                <span></span>
                            <cfelse>
                                <input type="radio" name="sys_#ct.contactid#" value="maintenance"
                                       class="form-check-input" #defaultVal EQ "maintenance" ? "checked" : ""# />
                            </cfif>
                        </td>
                        <td class="text-center">
                            <cfif ct.isEnrolled>
                                <span></span>
                            <cfelse>
                                <input type="radio" name="sys_#ct.contactid#" value="none"
                                       class="form-check-input" #defaultVal EQ "none" ? "checked" : ""# />
                            </cfif>
                        </td>
                    </tr>
                </cfloop>
            </tbody>
        </table>
    </div>
</cfif>

<script>
window.wizardCollectStepData = function() {
    var enrollments = [];
    var targetId = #targetSystemId#;
    var maintId = #maintSystemId#;

    $('.reminder-table input[type="radio"]:checked').each(function() {
        var val = $(this).val();
        if (val === 'none') return;
        var name = $(this).attr('name'); // sys_123
        var contactId = parseInt(name.replace('sys_', ''), 10);
        var systemId = (val === 'target') ? targetId : maintId;
        if (systemId > 0) {
            enrollments.push({ contactId: contactId, systemId: systemId });
        }
    });
    return { enrollments: JSON.stringify(enrollments) };
};
</script>

</cfoutput>
