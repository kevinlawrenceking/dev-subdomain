<!---
    P11 Step 7: Completion Summary
    Read-only summary of everything set up. Terminal step.
--->
<cfset userid = session.userid>

<!--- Fetch summary counts --->
<cfquery name="qProfile" datasource="#application.datasource#" maxrows="1">
    SELECT userFirstName, userLastName, userEmail,
           (SELECT tzname FROM timezones WHERE tzid = u.tzid) AS tzname,
           (SELECT formatexample FROM dateformats WHERE id = u.dateFormatID) AS dateformat,
           isAuditionModule
    FROM taousers u
    WHERE userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer" />
</cfquery>

<cfquery name="qRepCount" datasource="#application.datasource#">
    SELECT COUNT(DISTINCT cd.contactid) AS cnt
    FROM contactdetails cd
    INNER JOIN contactitems ci ON ci.contactid = cd.contactid
        AND ci.valueCategory = 'Tag' AND ci.valueType = 'Tags'
        AND ( ci.valuetext = 'My Rep Team' OR ci.valuetext IN ('Agent','Manager','Publicist') ) AND ci.itemStatus = 'Active'
    WHERE cd.userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer" />
      AND cd.contactStatus = 'Active'
</cfquery>

<cfquery name="qContactCount" datasource="#application.datasource#">
    SELECT COUNT(*) AS cnt
    FROM contactdetails
    WHERE userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer" />
      AND contactStatus = 'Active' AND COALESCE(user_yn, 'N') <> 'Y'
</cfquery>

<cfquery name="qAudCount" datasource="#application.datasource#">
    SELECT COUNT(*) AS cnt FROM audprojects
    WHERE userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer" />
</cfquery>

<cfquery name="qEnrollCount" datasource="#application.datasource#">
    SELECT COUNT(*) AS cnt FROM fusystemusers
    WHERE userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer" />
      AND sustatus = 'Active'
</cfquery>

<cfquery name="qLinkCount" datasource="#application.datasource#">
    SELECT COUNT(*) AS cnt FROM sitelinks_user_tbl
    WHERE userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer" />
      AND isdeleted = 0 AND LENGTH(TRIM(siteurl)) > 0
</cfquery>

<cfoutput>

<div class="text-center mb-4">
    <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="##28a745" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
    <h3 class="mt-2">You're all set!</h3>
    <p class="text-muted">Here's a summary of your setup. You can edit any of these from your dashboard.</p>
</div>

<div class="row g-3">

    <!--- Account --->
    <div class="col-md-4">
        <div class="summary-card">
            <svg class="summary-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
            <h6>Account</h6>
            <div class="summary-value">
                #encodeForHTML(qProfile.userFirstName)# #encodeForHTML(qProfile.userLastName)#<br>
                <small class="text-muted">#encodeForHTML(qProfile.tzname)# &middot; #encodeForHTML(qProfile.dateformat)#</small>
            </div>
        </div>
    </div>

    <!--- Representation --->
    <div class="col-md-4">
        <div class="summary-card">
            <svg class="summary-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
            <h6>Representation</h6>
            <div class="summary-value">
                <cfif qRepCount.cnt GT 0>
                    #qRepCount.cnt# rep(s) added
                <cfelse>
                    None added yet
                </cfif>
            </div>
        </div>
    </div>

    <!--- Contacts --->
    <div class="col-md-4">
        <div class="summary-card">
            <svg class="summary-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"/><rect x="8" y="2" width="8" height="4" rx="1" ry="1"/></svg>
            <h6>Contacts</h6>
            <div class="summary-value">
                <cfif qContactCount.cnt GT 0>
                    #qContactCount.cnt# contact(s)
                <cfelse>
                    None added yet
                </cfif>
            </div>
        </div>
    </div>

    <!--- Auditions --->
    <div class="col-md-4">
        <div class="summary-card">
            <svg class="summary-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="7" width="20" height="14" rx="2" ry="2"/><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"/></svg>
            <h6>Auditions</h6>
            <div class="summary-value">
                <cfif NOT val(qProfile.isAuditionModule)>
                    Module not enabled
                <cfelseif qAudCount.cnt GT 0>
                    #qAudCount.cnt# audition(s) logged
                <cfelse>
                    Skipped
                </cfif>
            </div>
        </div>
    </div>

    <!--- Reminders --->
    <div class="col-md-4">
        <div class="summary-card">
            <svg class="summary-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>
            <h6>Reminders</h6>
            <div class="summary-value">
                <cfif qEnrollCount.cnt GT 0>
                    #qEnrollCount.cnt# contact(s) enrolled
                <cfelse>
                    None set up yet
                </cfif>
            </div>
        </div>
    </div>

    <!--- Links --->
    <div class="col-md-4">
        <div class="summary-card">
            <svg class="summary-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"/></svg>
            <h6>Links</h6>
            <div class="summary-value">
                <cfif qLinkCount.cnt GT 0>
                    #qLinkCount.cnt# link(s) set up
                <cfelse>
                    None added yet
                </cfif>
            </div>
        </div>
    </div>

</div>

<script>
// Step 7 submit: no form data to collect, just trigger the status flip
window.wizardCollectStepData = function() {
    return {}; // save-step7.cfm handles the status transition
};
</script>

</cfoutput>
