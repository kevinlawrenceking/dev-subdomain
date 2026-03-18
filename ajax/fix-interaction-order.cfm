<cfsilent>
<!--- Diagnostic + fix: check FC script load order and move interaction to body --->
<!--- DELETE THIS FILE after running --->
</cfsilent>
<cftry>
    <!--- Show all FullCalendar-related pgapplinks entries with their load order --->
    <cfquery name="qAll" datasource="abod">
        SELECT linkid, linkurl, linktype, linkloc_tb, link_no, pluginname
        FROM pgapplinks
        WHERE linkurl LIKE '%fullcalendar%' OR linkurl LIKE '%calendar2%'
        ORDER BY linkloc_tb DESC, link_no ASC
    </cfquery>

    <h3>BEFORE — All FullCalendar pgapplinks entries (ordered by location, then link_no):</h3>
    <table border="1" cellpadding="4">
        <tr><th>linkid</th><th>linkurl</th><th>linktype</th><th>loc (t=head, b=body)</th><th>link_no</th><th>pluginname</th></tr>
        <cfoutput query="qAll">
            <tr style="<cfif linkurl CONTAINS 'interaction'>background:#fdd;<cfelseif linkloc_tb EQ 't'>background:#ffc;</cfif>">
                <td>#linkid#</td><td>#linkurl#</td><td>#linktype#</td><td>#linkloc_tb#</td><td>#link_no#</td><td>#pluginname#</td>
            </tr>
        </cfoutput>
    </table>

    <!--- Fix: move interaction from head to body, right after list plugin --->
    <!--- First find the max link_no among body FC scripts --->
    <cfquery name="qMaxBody" datasource="abod">
        SELECT MAX(link_no) AS maxno
        FROM pgapplinks
        WHERE linkurl LIKE '%fullcalendar%'
          AND linkloc_tb = 'b'
          AND linktype = 'script'
    </cfquery>

    <cfset newLinkNo = qMaxBody.maxno + 1>

    <cfquery datasource="abod">
        UPDATE pgapplinks
        SET linkloc_tb = 'b',
            link_no = <cfqueryparam value="#newLinkNo#" cfsqltype="cf_sql_integer">
        WHERE linkurl LIKE '%fullcalendar%interaction%'
          AND linktype = 'script'
    </cfquery>

    <!--- Verify --->
    <cfquery name="qAfter" datasource="abod">
        SELECT linkid, linkurl, linktype, linkloc_tb, link_no, pluginname
        FROM pgapplinks
        WHERE linkurl LIKE '%fullcalendar%' OR linkurl LIKE '%calendar2%'
        ORDER BY linkloc_tb DESC, link_no ASC
    </cfquery>

    <h3>AFTER — Interaction moved to body:</h3>
    <table border="1" cellpadding="4">
        <tr><th>linkid</th><th>linkurl</th><th>linktype</th><th>loc (t=head, b=body)</th><th>link_no</th><th>pluginname</th></tr>
        <cfoutput query="qAfter">
            <tr style="<cfif linkurl CONTAINS 'interaction'>background:#dfd;<cfelseif linkloc_tb EQ 't'>background:#ffc;</cfif>">
                <td>#linkid#</td><td>#linkurl#</td><td>#linktype#</td><td>#linkloc_tb#</td><td>#link_no#</td><td>#pluginname#</td>
            </tr>
        </cfoutput>
    </table>

    <p style="color:green; font-weight:bold;">Interaction plugin moved to body (link_no=<cfoutput>#newLinkNo#</cfoutput>). It will now load AFTER core and other plugins.</p>
    <p>DELETE this file now: ajax/fix-interaction-order.cfm</p>

    <cfcatch>
        <cfoutput><p style="color:red;">Error: #cfcatch.message# - #cfcatch.detail#</p></cfoutput>
    </cfcatch>
</cftry>
