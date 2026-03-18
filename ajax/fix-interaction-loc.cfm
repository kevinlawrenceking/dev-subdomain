<cftry>
    <!--- Check current FC link order --->
    <cfquery name="qBefore" datasource="abod">
        SELECT linkid, linkurl, linktype, linkloc_tb, link_no
        FROM pgapplinks
        WHERE linkurl LIKE '%fullcalendar%'
        ORDER BY linkloc_tb, link_no
    </cfquery>

    <!--- Move interaction from head (t) to body (b), after list plugin --->
    <cfquery datasource="abod">
        UPDATE pgapplinks
        SET linkloc_tb = 'b',
            link_no = (
                SELECT max_no + 1 FROM (
                    SELECT MAX(link_no) AS max_no
                    FROM pgapplinks
                    WHERE linkurl LIKE '%fullcalendar/list%'
                    AND linkloc_tb = 'b'
                ) tmp
            )
        WHERE linkid = 46
    </cfquery>

    <!--- Verify --->
    <cfquery name="qAfter" datasource="abod">
        SELECT linkid, linkurl, linktype, linkloc_tb, link_no
        FROM pgapplinks
        WHERE linkurl LIKE '%fullcalendar%'
        ORDER BY linkloc_tb, link_no
    </cfquery>

    <cfoutput>
    <h3>BEFORE:</h3>
    <table border="1" cellpadding="4">
        <tr><th>linkid</th><th>linkurl</th><th>linkloc_tb</th><th>link_no</th></tr>
        <cfloop query="qBefore">
            <tr><td>#linkid#</td><td>#linkurl#</td><td>#linkloc_tb#</td><td>#link_no#</td></tr>
        </cfloop>
    </table>
    <h3>AFTER:</h3>
    <table border="1" cellpadding="4">
        <tr><th>linkid</th><th>linkurl</th><th>linkloc_tb</th><th>link_no</th></tr>
        <cfloop query="qAfter">
            <tr><td>#linkid#</td><td>#linkurl#</td><td>#linkloc_tb#</td><td>#link_no#</td></tr>
        </cfloop>
    </table>
    <p style="color:green;font-weight:bold;">Done. Interaction now loads in BODY after other FC plugins. DELETE this file.</p>
    </cfoutput>
    <cfcatch>
        <cfoutput><p style="color:red;">Error: #cfcatch.message# - #cfcatch.detail#</p></cfoutput>
    </cfcatch>
</cftry>
