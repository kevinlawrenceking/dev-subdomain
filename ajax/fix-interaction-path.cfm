<cfsilent>
<!--- One-time fix: normalize interaction plugin path in pgapplinks --->
<!--- DELETE THIS FILE after running --->
</cfsilent>
<cftry>
    <!--- Check current state --->
    <cfquery name="qCheck" datasource="abod">
        SELECT linkid, linkurl, linktype, linkloc_tb, link_no
        FROM pgapplinks
        WHERE linkurl LIKE '%fullcalendar%interaction%'
    </cfquery>

    <!--- Fix JS path --->
    <cfquery datasource="abod">
        UPDATE pgapplinks
        SET linkurl = '/app/assets/libs/@fullcalendar/interaction/main.min.js'
        WHERE linkurl = '/assets/libs/@fullcalendar/interaction/main.min.js'
    </cfquery>

    <!--- Fix CSS path if it exists at wrong path --->
    <cfquery datasource="abod">
        UPDATE pgapplinks
        SET linkurl = '/app/assets/libs/@fullcalendar/interaction/main.min.css'
        WHERE linkurl = '/assets/libs/@fullcalendar/interaction/main.min.css'
    </cfquery>

    <!--- Verify --->
    <cfquery name="qAfter" datasource="abod">
        SELECT linkid, linkurl, linktype, linkloc_tb, link_no
        FROM pgapplinks
        WHERE linkurl LIKE '%fullcalendar%interaction%'
    </cfquery>

    <cfoutput>
    <h3>BEFORE:</h3>
    <table border="1" cellpadding="4">
        <tr><th>linkid</th><th>linkurl</th><th>linktype</th><th>linkloc_tb</th><th>link_no</th></tr>
        <cfloop query="qCheck">
            <tr><td>#linkid#</td><td>#linkurl#</td><td>#linktype#</td><td>#linkloc_tb#</td><td>#link_no#</td></tr>
        </cfloop>
    </table>

    <h3>AFTER:</h3>
    <table border="1" cellpadding="4">
        <tr><th>linkid</th><th>linkurl</th><th>linktype</th><th>linkloc_tb</th><th>link_no</th></tr>
        <cfloop query="qAfter">
            <tr><td>#linkid#</td><td>#linkurl#</td><td>#linktype#</td><td>#linkloc_tb#</td><td>#link_no#</td></tr>
        </cfloop>
    </table>

    <p style="color:green; font-weight:bold;">Done. DELETE this file now: ajax/fix-interaction-path.cfm</p>
    </cfoutput>

    <cfcatch>
        <cfoutput><p style="color:red;">Error: #cfcatch.message# - #cfcatch.detail#</p></cfoutput>
    </cfcatch>
</cftry>
