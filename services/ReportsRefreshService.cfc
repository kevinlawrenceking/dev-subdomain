<cfcomponent displayname="ReportsRefreshService" hint="Handles operations for reports" output="false">

<cffunction name="report_2" access="public" returntype="struct" output="false">
        <cfargument name="userid" type="numeric" required="true">
        <cfargument name="rangestart" type="date" required="true">
        <cfargument name="rangeend" type="date" required="true">
        <cfargument name="new_audcatid" type="numeric" required="true">

<!--- Initialize variables --->
        <cfset var i = 0>
        <cfset var new_reportid = 2>
        <cfset var new_label = "">
        <cfset var new_itemValueInt = 0>
        <cfset var new_itemDataset = "">
        <cfset var new_id = 0>
        <cfset var insertCount = 0>
        <cfset var resultSummary = {totalSelected = 0, totalInserted = 0, reportId = new_reportid}>

<!--- Query to fetch report data --->
        <cfquery name="report_2">
            SELECT 
                count(r.audroleid) AS totals, 
                g.audgenre AS label, 
                'Auditions' AS itemDataset
            FROM 
                audgenres_audition_xref x  
            INNER JOIN 
                audgenres_user g ON g.audgenreid = x.audgenreid
                inner join audroles r on r.audroleid = x.audroleid
                inner join audprojects p on p.audprojectid = r.audprojectid
                inner join audsubcategories s on s.audsubcatid = p.audsubcatid
            WHERE 
                 p.isdeleted <> 1
                AND p.projdate >= <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.rangestart#">
                AND p.projdate <= <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.rangeend#">
                AND p.userid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.userid#">
                AND s.audcatid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_audcatid#">
            GROUP BY 
                g.audgenre
            ORDER BY 
                g.audgenre
        </cfquery>

<!--- Update summary with total selected --->
        <cfset resultSummary.totalSelected = report_2.recordcount>

<!--- Loop through the query results --->
        <cfloop query="report_2">
            <cfset i = i + 1>
            <cfset new_label = report_2.label>
            <cfset new_itemValueInt = report_2.totals>
            <cfset new_itemDataset = report_2.itemDataset>

<!--- Find or create the report item ID --->
            <cfquery name="findid">
                SELECT r.ID AS new_id
                FROM reports_user r
                WHERE r.userid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.userid#">
                AND r.reportid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_reportid#">
            </cfquery>

<cfif findid.recordcount eq 1>
                <cfset new_id = findid.new_id>
            </cfif>

<!--- Sanitize the label --->
            <cfset var new_label_new = Replace(new_label, "'", "", "All")>

<!--- Insert the report item --->
            <cfquery name="Insert_ReportItems" result="insertResult">
                INSERT INTO reportitems (
                    itemLabel,
                    itemOrderNo,
                    itemValueInt,
                    ID,
                    itemDataset,
                    userid
                ) VALUES (
                    <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#new_label_new#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#i#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_itemValueInt#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_id#">,
                    <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#new_itemDataset#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.userid#">
                )
            </cfquery>

<!--- Increment insert counter --->
            <cfset insertCount = insertCount + 1>
        </cfloop>

<!--- Update summary with total inserted --->
        <cfset resultSummary.totalInserted = insertCount>

<!--- Return the summary --->
        <cfreturn resultSummary>
    </cffunction>

<cffunction name="report_3" access="public" returntype="struct" output="false" hint="Generates report 3, updates reportitems, and provides a summary.">
        <cfargument name="userid" type="numeric" required="true">
        <cfargument name="rangestart" type="date" required="true">
        <cfargument name="rangeend" type="date" required="true">

<!--- Initialize variables --->
        <cfset var totalSelected = 0>
        <cfset var totalInserted = 0>
        <cfset var new_reportid = 3>
        <cfset var i = 0>
        <cfset var resultSummary = {totalSelected = 0, totalInserted = 0, reportId = new_reportid}>

<!--- Query to calculate category totals --->
        <cfquery name="report_3">
            SELECT 
                COUNT(p.audprojectID) AS totals,
                c.audcatname AS label,
                'Auditions' AS itemDataset
            FROM audprojects p
            INNER JOIN audsubcategories s ON s.audsubcatid = p.audsubcatid
            inner join audcategories c on c.audcatid = s.audcatid
       WHERE  p.isdeleted <> 1
     

                  AND p.projdate >= <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.rangestart#">
                AND p.projdate <= <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.rangeend#">
                AND p.userid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.userid#">


            GROUP BY c.audcatname
            ORDER BY c.audcatname
        </cfquery>


<!--- Update summary with total selected --->
        <cfset resultSummary.totalSelected = report_3.recordCount>

<!--- Loop through results --->
        <cfloop query="report_3">
            <!--- Increment order number --->
            <cfset i++>

<!--- Define report variables --->
            <cfset var new_label = report_3.label>
            <cfset var new_itemValueInt = report_3.totals>
            <cfset var new_itemDataset = report_3.itemDataset>

<!--- Find existing ID for report item --->
            <cfquery name="findid">
                SELECT r.ID AS new_id
                FROM reports_user r
                WHERE 
                    r.userid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.userid#">
                    AND r.reportid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_reportid#">
            </cfquery>

<cfset var new_id = 0>
            <cfif findid.recordcount EQ 1>
                <cfset new_id = findid.new_id>
            </cfif>

<!--- Insert or update report item --->
            <cfquery name="Insert_ReportItems" result="insertResult">
                INSERT INTO reportitems (
                    itemLabel, 
                    itemOrderNo, 
                    itemValueInt, 
                    ID, 
                    itemDataset, 
                    userid
                ) VALUES (
                    <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#new_label#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#i#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_itemValueInt#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_id#">,
                    <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#new_itemDataset#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.userid#">
                )
            </cfquery>

<!--- Track insertions --->
            <cfset totalInserted++>
        </cfloop>

<!--- Update summary with total inserted --->
        <cfset resultSummary.totalInserted = totalInserted>

<!--- Return summary --->
        <cfreturn resultSummary>
    </cffunction>

<cffunction name="report_4" access="public" returntype="struct" output="false" hint="Generates report 4, updates reportitems, and provides a summary.">
        <cfargument name="userid" type="numeric" required="true">
        <cfargument name="rangestart" type="date" required="true">
        <cfargument name="rangeend" type="date" required="true">

<!--- Initialize summary variables --->
        <cfset var totalProcessed = 0>
        <cfset var totalInserted = 0>
        <cfset var totalUpdated = 0>
        <cfset var new_reportid = 4>
        <cfset var i = 0>
        <cfset var resultSummary = {totalSelected = 0, totalInserted = 0, totalUpdated = 0}>

<!--- Query to get initial report loop data --->
        <cfquery name="report_4_loop">
            SELECT 
                audstepid, 
                #new_reportid# AS new_reportid,
                audtypeid AS new_audtypeid, 
                audtype, 
                audtype AS new_label, 
                audstep AS new_itemDataset
            FROM audtypes, audsteps
            WHERE audstepid IN (1, 2)
            ORDER BY audtypes.audtype, audsteps.audstep
        </cfquery>

<!--- Update total selected --->
        <cfset resultSummary.totalSelected = report_4_loop.recordCount>

<cfquery name="findid">
                SELECT r.ID AS new_id
                FROM reports_user r
                WHERE 
                    r.userid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.userid#">
                    AND r.reportid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_reportid#">
            </cfquery>

<cfset var new_id = 0>
            <cfif findid.recordcount EQ 1>
                <cfset new_id = findid.new_id>
            </cfif>

<!--- Loop through report data --->
        <cfloop query="report_4_loop">
            <cfset i++>

<!--- Insert initial report item --->
            <cfquery name="Insert_ReportItems" result="insertResult">
                INSERT INTO reportitems (
                    itemLabel, 
                    itemOrderNo, 
                    itemValueInt, 
                    ID, 
                    itemDataset, 
                    userid
                ) VALUES (
                    <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#report_4_loop.new_label#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#i#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="0">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_id#">,
                    <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#report_4_loop.new_itemDataset#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.userid#">
                )
            </cfquery>
 <cfset new_itemid=insertResult.GENERATEDKEY />
            <!--- Track inserted records --->
            <cfset totalInserted++>

<cfquery  name="Findit">
                SELECT
                count(p.audprojectid) as totals
                from
                events a
                inner join audroles r on r.audroleid = a.audroleid
                inner join audprojects p on p.audprojectid = r.audprojectid
                inner join audtypes t on t.audtypeid = a.audtypeid
                WHERE a.isdeleted <> 1
                AND p.isdeleted <> 1
                and a.audstepid = #report_4_loop.audstepid#
                and t.audtypeid = #report_4_loop.new_audtypeid#
    AND p.projdate >= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.rangestart#" /> 
    AND p.projdate <= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.rangeend#" />
AND p.userid=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.userid#"> 
</cfquery>

<cfif #findit.recordcount# is "0">

<cfset new_itemvalueint=0 />

<cfelse>

<cfoutput>

<cfset new_itemvalueint=#int(FindIt.totals)# />

</cfoutput>

</cfif>

<cfquery  name="update">
                        update reportitems set itemValueInt =
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#new_itemvalueint#" />
                        where itemid =
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#new_itemid#" />
                    </cfquery>

</cfloop>

<!--- Update result summary --->
        <cfset resultSummary.totalInserted = totalInserted>

<!--- Return summary --->
        <cfreturn resultSummary>
    </cffunction>

<cffunction name="report_5" access="public" returntype="struct" output="false" hint="Generates report 5, updates reportitems, and provides a summary.">
        <cfargument name="userid" type="numeric" required="true">
        <cfargument name="rangestart" type="date" required="true">
        <cfargument name="rangeend" type="date" required="true">

<!--- Initialize variables --->
        <cfset var totalSelected = 0>
        <cfset var totalInserted = 0>
        <cfset var new_reportid = 5>
        <cfset var i = 0>
        <cfset var resultSummary = {totalSelected = 0, totalInserted = 0, reportId = new_reportid}>

<!--- Query to calculate essence totals --->
        <cfquery name="report_5">
            SELECT 
                COUNT(r.audroleid) AS totals,
                e.essencename AS label,
                'Auditions' AS itemDataset
            FROM  audroles r
            inner join audprojects p on p.audprojectid = r.audprojectid
            INNER JOIN audessences_audtion_xref x ON x.audroleid = r.audroleid
            INNER JOIN essences e ON e.essenceid = x.essenceid
            WHERE 
                r.isdeleted <> 1
                and p.isdeleted <> 1
                AND r.userid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.userid#">
                AND p.projdate >= <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.rangestart#">
                AND p.projdate <= <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.rangeend#">
            GROUP BY e.essencename
            ORDER BY e.essencename
        </cfquery>

<!--- Update summary with total selected --->
        <cfset resultSummary.totalSelected = report_5.recordCount>

<!--- Loop through results --->
        <cfloop query="report_5">
            <!--- Increment order number --->
            <cfset i++>

<!--- Define report variables --->
            <cfset var new_label = report_5.label>
            <cfset var new_itemValueInt = report_5.totals>
            <cfset var new_itemDataset = report_5.itemDataset>

<!--- Find existing ID for report item --->
            <cfquery name="findid">
                SELECT r.ID AS new_id
                FROM reports_user r
                WHERE 
                    r.userid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.userid#">
                    AND r.reportid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_reportid#">
            </cfquery>

<cfset var new_id = 0>
            <cfif findid.recordcount EQ 1>
                <cfset new_id = findid.new_id>
            </cfif>

<!--- Insert or update report item --->
            <cfquery name="Insert_ReportItems" result="insertResult">
                INSERT INTO reportitems (
                    itemLabel, 
                    itemOrderNo, 
                    itemValueInt, 
                    ID, 
                    itemDataset, 
                    userid
                ) VALUES (
                    <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#new_label#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#i#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_itemValueInt#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_id#">,
                    <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#new_itemDataset#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.userid#">
                )
            </cfquery>

<!--- Track insertions --->
            <cfset totalInserted++>
        </cfloop>

<!--- Update summary with total inserted --->
        <cfset resultSummary.totalInserted = totalInserted>

<!--- Return summary --->
        <cfreturn resultSummary>
    </cffunction>

<cffunction name="report_6" access="public" returntype="struct" output="false">
        <cfargument name="userid" type="numeric" required="true">
        <cfargument name="rangestart" type="date" required="true">
        <cfargument name="rangeend" type="date" required="true">
        <cfargument name="new_audsourceidb" type="numeric" required="true">

<!--- Initialize variables --->
        <cfset var i = 0>
        <cfset var new_reportid = 6>
        <cfset var new_label = "">
        <cfset var new_itemValueInt = 0>
        <cfset var new_itemDataset = "">
        <cfset var new_id = 0>
        <cfset var insertCount = 0>
        <cfset var resultSummary = {totalSelected = 0, totalInserted = 0, reportId = new_reportid}>

<!--- Prepare the source label logic --->
        <cfset var sourceField = "s.audsource">
        <cfif arguments.new_audsourceidb EQ 1>
            <cfset sourceField = "c.recordname">
        <cfelseif arguments.new_audsourceidb EQ 2>
            <cfset sourceField = "ss.submitsitename">
        <cfelseif arguments.new_audsourceidb EQ 3>
            <cfset sourceField = "c.recordname">
        <cfelseif arguments.new_audsourceidb EQ 4>
            <cfset sourceField = "o.opencallname">
        </cfif>

<!--- Query to fetch report data based on audsourceidb --->
        <cfquery name="report_6">
            SELECT
                COUNT(p.audprojectid) AS totals,
                IFNULL(#sourceField#, 'Unknown') AS label,
                'Auditions' AS itemDataset
            FROM
                audprojects p
            INNER JOIN audroles r ON p.audprojectID = r.audprojectID
            INNER JOIN audsources s ON s.audsourceid = r.audsourceid
            LEFT JOIN contactdetails c ON c.contactid = r.contactid
            LEFT JOIN audsubmitsites_user ss ON ss.submitsiteid = r.submitsiteid
            LEFT JOIN audopencalloptions_user o ON o.opencallid = r.opencallid
            WHERE
                r.isdeleted <> 1
                AND p.isDeleted <> 1
                AND p.projdate >= <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.rangestart#">
                AND p.projdate <= <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.rangeend#">
                AND p.userid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.userid#">
                <cfif arguments.new_audsourceidb NEQ 0>
                    AND s.audsourceid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_audsourceidb#">
                </cfif>
            GROUP BY label
            ORDER BY label
        </cfquery>

<!--- Update summary with total selected --->
        <cfset resultSummary.totalSelected = report_6.recordcount>

<!--- Loop through the query results --->
        <cfloop query="report_6">
            <cfset i = i + 1>
            <cfset new_label = report_6.label>
            <cfset new_itemValueInt = report_6.totals>
            <cfset new_itemDataset = report_6.itemDataset>

<!--- Find or create the report item ID --->
            <cfquery name="findid">
                SELECT r.ID AS new_id
                FROM reports_user r
                WHERE r.userid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.userid#">
                AND r.reportid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_reportid#">
            </cfquery>

<cfif findid.recordcount eq 1>
                <cfset new_id = findid.new_id>
            </cfif>

<!--- Sanitize the label --->
            <cfset var new_label_new = Replace(new_label, "'", "", "All")>

<!--- Insert the report item --->
            <cfquery name="Insert_ReportItems" result="insertResult">
                INSERT INTO reportitems (
                    itemLabel,
                    itemOrderNo,
                    itemValueInt,
                    ID,
                    itemDataset,
                    userid
                ) VALUES (
                    <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#new_label_new#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#i#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_itemValueInt#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_id#">,
                    <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#new_itemDataset#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.userid#">
                )
            </cfquery>

<!--- Increment insert counter --->
            <cfset insertCount = insertCount + 1>
        </cfloop>

<!--- Update summary with total inserted --->
        <cfset resultSummary.totalInserted = insertCount>

<!--- Return the summary --->
        <cfreturn resultSummary>
    </cffunction>

<cffunction name="report_7" access="public" returntype="struct" output="false" hint="Generates report 7, updates reportitems, and provides a summary.">
        <cfargument name="userid" type="numeric" required="true">
        <cfargument name="rangestart" type="date" required="true">
        <cfargument name="rangeend" type="date" required="true">
        <cfargument name="new_audcatid" type="numeric" required="true">

<!--- Initialize variables --->
        <cfset var totalSelected = 0>
        <cfset var totalInserted = 0>
        <cfset var new_reportid = 7>
        <cfset var i = 0>
        <cfset var resultSummary = {totalSelected = 0, totalInserted = 0, reportId = new_reportid}>

<!--- Query to fetch data --->
        <cfquery name="report_7">
            SELECT
                COUNT(p.audprojectid) AS totals,
                rt.audroletype AS label,
                'Auditions' AS itemDataset
            FROM
                audprojects p
            INNER JOIN
                audroles r ON p.audprojectID = r.audprojectID
            INNER JOIN
                audroletypes rt ON r.audroletypeid = rt.audroletypeid
            INNER JOIN
                audsubcategories s ON s.audsubcatid = p.audsubcatid
            WHERE
                r.isdeleted <> 1
                AND p.isdeleted <> 1
                AND p.userid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.userid#">
                AND p.projdate >= <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.rangestart#">
                AND p.projdate <= <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.rangeend#">
                AND s.audcatid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_audcatid#">
            GROUP BY
                rt.audroletype
            ORDER BY
                rt.audroletype
        </cfquery>

<!--- Update summary with total selected --->
        <cfset resultSummary.totalSelected = report_7.recordCount>

<!--- Loop through the results and insert report items --->
        <cfloop query="report_7">
            <cfset i++>
            <cfset var new_label = report_7.label>
            <cfset var new_itemValueInt = report_7.totals>
            <cfset var new_itemDataset = report_7.itemDataset>

<!--- Find or create report item ID --->
            <cfquery name="findid">
                SELECT r.ID AS new_id
                FROM reports_user r
                WHERE r.userid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.userid#">
                AND r.reportid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_reportid#">
            </cfquery>

<cfset var new_id = 0>
            <cfif findid.recordCount EQ 1>
                <cfset new_id = findid.new_id>
            </cfif>

<!--- Sanitize label --->
            <cfset var new_label_new = Replace(new_label, "'", "", "All")>

<!--- Insert report item --->
            <cfquery name="Insert_ReportItems" result="insertResult">
                INSERT INTO reportitems (
                    itemLabel,
                    itemOrderNo,
                    itemValueInt,
                    ID,
                    itemDataset,
                    userid
                ) VALUES (
                    <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#new_label_new#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#i#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_itemValueInt#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_id#">,
                    <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#new_itemDataset#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.userid#">
                )
            </cfquery>

<!--- Track insertions --->
            <cfset totalInserted++>
        </cfloop>

<!--- Update summary with total inserted --->
        <cfset resultSummary.totalInserted = totalInserted>

<!--- Return summary --->
        <cfreturn resultSummary>
    </cffunction>

<cffunction name="report_8" access="public" returntype="struct" output="false" hint="Generates report 8, updates reportitems, and provides a summary.">
        <cfargument name="userid" type="numeric" required="true">
        <cfargument name="rangestart" type="date" required="true">
        <cfargument name="rangeend" type="date" required="true">
        <cfargument name="new_audcatid" type="numeric" required="true">

<!--- Initialize variables --->
        <cfset var totalSelected = 0>
        <cfset var totalInserted = 0>
        <cfset var new_reportid = 8>
        <cfset var i = 0>
        <cfset var resultSummary = {totalSelected = 0, totalInserted = 0, reportId = new_reportid}>

<!--- Query to fetch report data --->
        <cfquery name="report_8">
         SELECT
                COUNT(x.audprojectid) AS totals,
                m.medianame AS label,
                s.audcatid,
                'Auditions' AS itemDataset
            FROM audmedia m
            Inner JOIN audmedia_auditions_xref x ON x.mediaid = m.mediaid
            Inner JOIN audmediatypes t ON t.mediaTypeID = m.mediatypeid
            Inner JOIN audprojects p ON p.audprojectID = x.audprojectid
            Inner JOIN audsubcategories s ON s.audsubcatid = p.audsubcatid
            WHERE 
                m.isdeleted <> 1
                AND x.audprojectid <> 0
                AND p.userid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.userid#">
                AND s.audcatid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_audcatid#">
                AND p.projdate >= <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.rangestart#">
                AND p.projdate <= <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.rangeend#">
            GROUP BY 
                m.medianame, t.mediatype, s.audcatid
            HAVING 
                t.mediatype = 'Headshot'
            ORDER BY 
                m.medianame
        </cfquery>

<!--- Update summary with total selected --->
        <cfset resultSummary.totalSelected = report_8.recordCount>

<!--- Loop through the query results --->
        <cfloop query="report_8">
            <cfset i++>
            <cfset var new_label = report_8.label>
            <cfset var new_itemValueInt = report_8.totals>
            <cfset var new_itemDataset = report_8.itemDataset>

<!--- Find or create the report item ID --->
            <cfquery name="findid">
                SELECT r.ID AS new_id
                FROM reports_user r
                WHERE r.userid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.userid#">
                AND r.reportid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_reportid#">
            </cfquery>

<cfset var new_id = 0>
            <cfif findid.recordcount EQ 1>
                <cfset new_id = findid.new_id>
            </cfif>

<!--- Sanitize the label --->
            <cfset var new_label_new = Replace(new_label, "'", "", "All")>

<!--- Insert the report item --->
            <cfquery name="Insert_ReportItems" result="insertResult">
                INSERT INTO reportitems (
                    itemLabel,
                    itemOrderNo,
                    itemValueInt,
                    ID,
                    itemDataset,
                    userid
                ) VALUES (
                    <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#new_label_new#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#i#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_itemValueInt#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_id#">,
                    <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#new_itemDataset#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.userid#">
                )
            </cfquery>

<!--- Track insertions --->
            <cfset totalInserted++>
        </cfloop>

<!--- Update summary with total inserted --->
        <cfset resultSummary.totalInserted = totalInserted>

<!--- Return summary --->
        <cfreturn resultSummary>
    </cffunction>

<cffunction name="report_9" access="public" returntype="struct" output="false">
        <cfargument name="userid" type="numeric" required="true">
        <cfargument name="rangestart" type="date" required="true">
        <cfargument name="rangeend" type="date" required="true">

<!--- Initialize variables --->
        <cfset var i = 0>
        <cfset var new_reportid = 9>
        <cfset var new_label = "">
        <cfset var new_itemValueInt = 0>
        <cfset var new_itemDataset = "">
        <cfset var new_id = 0>
        <cfset var insertCount = 0>
        <cfset var resultSummary = {totalSelected = 0, totalInserted = 0, reportId = new_reportid}>

<!--- Query to fetch report data --->
        <cfquery name="report_9">
            SELECT
                COUNT(r.audroleid) AS totals,
                a.rangename AS label,
                'Auditions' AS itemDataset
            FROM audprojects p
            INNER JOIN audroles r ON p.audprojectID = r.audprojectID
            INNER JOIN audageranges_audtion_xref x ON x.audroleid = r.audroleid
            INNER JOIN audageranges a ON a.rangeid = x.rangeid
            WHERE 
                r.isdeleted <> 1
                AND p.isdeleted <> 1
                AND p.userid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.userid#">
                AND p.projdate >= <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.rangestart#">
                AND p.projdate <= <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.rangeend#">
            GROUP BY 
                a.rangename
            ORDER BY 
                a.rangename
        </cfquery>

<!--- Update summary with total selected --->
        <cfset resultSummary.totalSelected = report_9.recordcount>

<!--- Loop through the query results --->
        <cfloop query="report_9">
            <cfset i = i + 1>
            <cfset new_label = report_9.label>
            <cfset new_itemValueInt = report_9.totals>
            <cfset new_itemDataset = report_9.itemDataset>

<!--- Find or create the report item ID --->
            <cfquery name="findid">
                SELECT r.ID AS new_id
                FROM reports_user r
                WHERE r.userid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.userid#">
                AND r.reportid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_reportid#">
            </cfquery>

<cfif findid.recordcount eq 1>
                <cfset new_id = findid.new_id>
            </cfif>

<!--- Sanitize the label --->
            <cfset var new_label_new = Replace(new_label, "'", "", "All")>

<!--- Insert the report item --->
            <cfquery name="Insert_ReportItems" result="insertResult">
                INSERT INTO reportitems (
                    itemLabel,
                    itemOrderNo,
                    itemValueInt,
                    ID,
                    itemDataset,
                    userid
                ) VALUES (
                    <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#new_label_new#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#i#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_itemValueInt#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_id#">,
                    <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#new_itemDataset#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.userid#">
                )
            </cfquery>

<!--- Increment insert counter --->
            <cfset insertCount = insertCount + 1>
        </cfloop>

<!--- Update summary with total inserted --->
        <cfset resultSummary.totalInserted = insertCount>

<!--- Return the summary --->
        <cfreturn resultSummary>
    </cffunction>

<cffunction name="report_10" access="public" returntype="struct" output="false" hint="Generates report 10, inserts into reportitems, and provides a summary.">
        <cfargument name="userid" type="numeric" required="true">
        <cfargument name="new_rangestart" type="date" required="true">
        <cfargument name="new_rangeend" type="date" required="true">

<!--- Initialize variables for summary --->
        <cfset var totalSelected = 0>
        <cfset var totalInserted = 0>
        <cfset var new_reportid = 10>
        <cfset var i = 0>

<!--- Query to fetch report data --->
        <cfquery name="reportQuery">
            SELECT 
                COUNT(p.audprojectID) AS totals,
                'Number of Callbacks' AS label,
                'Auditions' AS itemDataset
            FROM audprojects p
            INNER JOIN audroles r ON p.audprojectID = r.audprojectID
            WHERE 
                r.isdeleted <> 1
                AND p.isdeleted <> 1
                AND r.iscallback = 1
                AND p.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
                AND p.projdate >= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.new_rangestart#">
                AND p.projdate <= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.new_rangeend#">
        </cfquery>

<!--- Update total selected --->
        <cfset totalSelected = reportQuery.recordCount>

<!--- Loop through the query results and insert data into reportitems --->
        <cfloop query="reportQuery">
            <cfset i++>
            <cfset var new_label = reportQuery.label>
            <cfset var new_itemValueInt = reportQuery.totals>
            <cfset var new_itemDataset = reportQuery.itemDataset>

<!--- Find the associated ID --->
            <cfquery name="findIdQuery">
                SELECT r.ID AS new_ID
                FROM reports_user r
                WHERE 
                    r.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
                    AND r.reportid = <cfqueryparam cfsqltype="cf_sql_integer" value="#new_reportid#">
            </cfquery>

<cfset var new_id = 0>
            <cfif findIdQuery.recordCount EQ 1>
                <cfset new_id = findIdQuery.new_ID>
            </cfif>

<!--- Sanitize the label --->
            <cfset var new_label_new = Replace(new_label, "'", "", "All")>

<!--- Insert data into reportitems --->
            <cfquery name="insertReportItemQuery">
                INSERT INTO reportitems (
                    itemLabel, 
                    itemOrderNo, 
                    itemValueInt, 
                    ID, 
                    itemDataset, 
                    userid
                ) VALUES (
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#new_label_new#">,
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#i#">,
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#new_itemValueInt#">,
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#new_id#">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#new_itemDataset#">,
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
                )
            </cfquery>

<!--- Update total inserted --->
            <cfset totalInserted++>
        </cfloop>

<!--- Return summary of report --->
        <cfreturn {
            totalSelected = totalSelected,
            totalInserted = totalInserted,
            reportId = new_reportid,
            startDate = arguments.new_rangestart,
            endDate = arguments.new_rangeend
        }>
    </cffunction>

<cffunction name="report_11" access="public" returntype="struct" output="false" hint="Generates report 11, updates reportitems, and provides a summary.">
        <cfargument name="userid" type="numeric" required="true">
        <cfargument name="rangestart" type="date" required="true">
        <cfargument name="rangeend" type="date" required="true">

<!--- Initialize summary variables --->
        <cfset var totalProcessed = 0>
        <cfset var totalInserted = 0>
        <cfset var new_reportid = 11>
        <cfset var i = 0>
        <cfset var resultSummary = {totalSelected = 0, totalInserted = 0, reportId = new_reportid}>

<!--- Query to calculate totals for redirects --->
        <cfquery name="report_11">
            SELECT 
                COUNT(p.audprojectID) AS totals,
                'Number of Redirects' AS label,
                'Auditions' AS itemDataset
            FROM audprojects p
            INNER JOIN audroles r ON p.audprojectID = r.audprojectID
            WHERE 
                r.isdeleted <> 1
                AND p.isdeleted <> 1
                AND r.isredirect = 1
                AND p.userid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.userid#">
                AND p.projdate >= <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.rangestart#">
                AND p.projdate <= <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.rangeend#">
        </cfquery>

<!--- Update totalSelected in the summary --->
        <cfset resultSummary.totalSelected = report_11.recordCount>

<!--- Loop through results --->    
        <cfloop query="report_11">
            <cfset i++>
            <cfset var new_label = report_11.label>
            <cfset var new_itemValueInt = report_11.totals>
            <cfset var new_itemDataset = report_11.itemDataset>

<!--- Find existing ID for report item --->    
            <cfquery name="findid">
                SELECT r.ID AS new_id
                FROM reports_user r
                WHERE 
                    r.userid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.userid#">
                    AND r.reportid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_reportid#">
            </cfquery>

<cfset var new_id = 0>
            <cfif findid.recordCount EQ 1>
                <cfset new_id = findid.new_id>
            </cfif>

<!--- Insert report item --->    
            <cfquery name="Insert_ReportItems" result="insertResult">
                INSERT INTO reportitems (
                    itemLabel, 
                    itemOrderNo, 
                    itemValueInt, 
                    ID, 
                    itemDataset, 
                    userid
                ) VALUES (
                    <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#new_label#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#i#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_itemValueInt#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_id#">,
                    <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#new_itemDataset#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.userid#">
                )
            </cfquery>

<!--- Track totalInserted and totalProcessed --->
            <cfset totalInserted++>
            <cfset totalProcessed++>
        </cfloop>

<!--- Update resultSummary totals --->
        <cfset resultSummary.totalInserted = totalInserted>
        <cfset resultSummary.totalProcessed = totalProcessed>

<!--- Return summary --->
        <cfreturn resultSummary>
    </cffunction>

<cffunction name="report_12" access="public" returntype="struct" output="false" hint="Generates report 12, updates reportitems, and provides a summary.">
        <cfargument name="userid" type="numeric" required="true">
        <cfargument name="rangestart" type="date" required="true">
        <cfargument name="rangeend" type="date" required="true">

<!--- Initialize variables --->
        <cfset var totalSelected = 0>
        <cfset var totalInserted = 0>
        <cfset var new_reportid = 12>
        <cfset var i = 0>
        <cfset var resultSummary = {totalSelected = 0, totalInserted = 0, reportId = new_reportid}>

<!--- Query to calculate totals for pins/avails --->
        <cfquery name="report_12">
            SELECT 
                COUNT(p.audprojectID) AS totals,
                'Number of Pins/Avails' AS label,
                'Auditions' AS itemDataset
            FROM audprojects p
            INNER JOIN audroles r ON p.audprojectID = r.audprojectID
            WHERE 
                r.isdeleted <> 1
                AND p.isdeleted <> 1
                AND r.ispin = 1
                AND p.userid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.userid#">
                AND p.projdate >= <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.rangestart#">
                AND p.projdate <= <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.rangeend#">
        </cfquery>

<!--- Update summary with total selected --->
        <cfset resultSummary.totalSelected = report_12.recordCount>

<!--- Loop through results --->    
        <cfloop query="report_12">
            <cfset i++>
            <cfset var new_label = report_12.label>
            <cfset var new_itemValueInt = report_12.totals>
            <cfset var new_itemDataset = report_12.itemDataset>

<!--- Find existing ID for report item --->    
            <cfquery name="findid">
                SELECT r.ID AS new_id
                FROM reports_user r
                WHERE 
                    r.userid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.userid#">
                    AND r.reportid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_reportid#">
            </cfquery>

<cfset var new_id = 0>
            <cfif findid.recordCount EQ 1>
                <cfset new_id = findid.new_id>
            </cfif>

<!--- Sanitize label --->
            <cfset var new_label_new = Replace(new_label, "'", "", "All")>

<!--- Insert or update report item --->    
            <cfquery name="Insert_ReportItems" result="insertResult">
                INSERT INTO reportitems (
                    itemLabel, 
                    itemOrderNo, 
                    itemValueInt, 
                    ID, 
                    itemDataset, 
                    userid
                ) VALUES (
                    <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#new_label_new#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#i#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_itemValueInt#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_id#">,
                    <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#new_itemDataset#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.userid#">
                )
            </cfquery>

<!--- Track insertions --->
            <cfset totalInserted++>
        </cfloop>

<!--- Update summary with total inserted --->
        <cfset resultSummary.totalInserted = totalInserted>

<!--- Return summary --->
        <cfreturn resultSummary>
    </cffunction>

<cffunction name="report_13" access="public" returntype="struct" output="false" hint="Generates report 13, updates reportitems, and provides a summary.">
        <cfargument name="userid" type="numeric" required="true">
        <cfargument name="rangestart" type="date" required="true">
        <cfargument name="rangeend" type="date" required="true">

<!--- Initialize variables --->
        <cfset var totalSelected = 0>
        <cfset var totalInserted = 0>
        <cfset var new_reportid = 13>
        <cfset var i = 0>
        <cfset var resultSummary = {totalSelected = 0, totalInserted = 0, reportId = new_reportid}>

<!--- Query to fetch report data --->
        <cfquery name="report_13">
            SELECT 
                COUNT(p.audprojectID) AS totals,
                'Number of Bookings' AS label,
                'Auditions' AS itemDataset
            FROM audprojects p
            INNER JOIN audroles r ON p.audprojectID = r.audprojectID
            WHERE 
                r.isdeleted <> 1
                AND p.isdeleted <> 1
                AND r.isbooked = 1
                AND p.userid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.userid#">
                AND p.projdate >= <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.rangestart#">
                AND p.projdate <= <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.rangeend#">
        </cfquery>

<!--- Update summary with total selected --->
        <cfset resultSummary.totalSelected = report_13.recordCount>

<!--- Loop through the query results --->
        <cfloop query="report_13">
            <cfset i++>
            <cfset var new_label = report_13.label>
            <cfset var new_itemValueInt = report_13.totals>
            <cfset var new_itemDataset = report_13.itemDataset>

<!--- Find or create the report item ID --->
            <cfquery name="findid">
                SELECT r.ID AS new_id
                FROM reports_user r
                WHERE r.userid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.userid#">
                AND r.reportid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_reportid#">
            </cfquery>

<cfset var new_id = 0>
            <cfif findid.recordcount EQ 1>
                <cfset new_id = findid.new_id>
            </cfif>

<!--- Sanitize the label --->
            <cfset var new_label_new = Replace(new_label, "'", "", "All")>

<!--- Insert or update report item --->
            <cfquery name="Insert_ReportItems" result="insertResult">
                INSERT INTO reportitems (
                    itemLabel,
                    itemOrderNo,
                    itemValueInt,
                    ID,
                    itemDataset,
                    userid
                ) VALUES (
                    <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#new_label_new#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#i#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_itemValueInt#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_id#">,
                    <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#new_itemDataset#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.userid#">
                )
            </cfquery>

<!--- Track insertions --->
            <cfset totalInserted++>
        </cfloop>

<!--- Update summary with total inserted --->
        <cfset resultSummary.totalInserted = totalInserted>

<!--- Return summary --->
        <cfreturn resultSummary>
    </cffunction>

<cffunction name="report_17" access="public" returntype="struct" output="false" hint="Generates report 17, updates reportitems, and provides a summary.">
        <cfargument name="userid" type="numeric" required="true">
        <cfargument name="rangestart" type="date" required="true">
        <cfargument name="rangeend" type="date" required="true">

<!--- Initialize variables --->
        <cfset var totalSelected = 0>
        <cfset var totalInserted = 0>
        <cfset var new_reportid = 17>
        <cfset var i = 0>
        <cfset var resultSummary = {totalSelected = 0, totalInserted = 0, reportId = new_reportid}>

<!--- Query to calculate report data --->
        <cfquery name="report_17">
            SELECT 
                COUNT(p.audprojectID) AS totals,
                'Number of Auditions' AS label,
                'Auditions' AS itemDataset
            FROM audprojects p
            INNER JOIN audroles r ON p.audprojectID = r.audprojectID
            WHERE 
                r.isdeleted <> 1
                AND p.isdeleted <> 1
                AND p.userid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.userid#">
                AND p.projdate >= <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.rangestart#">
                AND p.projdate <= <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.rangeend#">
        </cfquery>

<!--- Update summary with total selected --->
        <cfset resultSummary.totalSelected = report_17.recordCount>

<!--- Loop through report data ---> 
        <cfloop query="report_17">
            <!--- Increment order number ---> 
            <cfset i++>

<!--- Define report variables ---> 
            <cfset var new_label = report_17.label>
            <cfset var new_itemValueInt = report_17.totals>
            <cfset var new_itemDataset = report_17.itemDataset>

<!--- Find existing ID for the report item ---> 
            <cfquery name="findid">
                SELECT r.ID AS new_id
                FROM reports_user r
                WHERE 
                    r.userid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.userid#">
                    AND r.reportid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_reportid#">
            </cfquery>

<!--- Handle missing ID ---> 
            <cfset var new_id = 0>
            <cfif findid.recordcount EQ 1>
                <cfset new_id = findid.new_id>
            </cfif>

<!--- Sanitize label ---> 
            <cfset var new_label_new = Replace(new_label, "'", "", "All")>

<!--- Insert report item ---> 
            <cfquery name="Insert_ReportItems" result="insertResult">
                INSERT INTO reportitems (
                    itemLabel, 
                    itemOrderNo, 
                    itemValueInt, 
                    ID, 
                    itemDataset, 
                    userid
                ) VALUES (
                    <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#new_label_new#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#i#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_itemValueInt#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_id#">,
                    <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#new_itemDataset#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.userid#">
                )
            </cfquery>

<!--- Track insertions ---> 
            <cfset totalInserted++>
        </cfloop>

<!--- Update summary with total inserted --->
        <cfset resultSummary.totalInserted = totalInserted>

<!--- Return summary --->
        <cfreturn resultSummary>
    </cffunction>

<cffunction name="report_18" access="public" returntype="struct" output="false" hint="Generates report 18, updates reportitems, and provides a summary.">
        <cfargument name="userid" type="numeric" required="true">
        <cfargument name="rangestart" type="date" required="true">
        <cfargument name="rangeend" type="date" required="true">
        <cfargument name="new_audsourceid" type="numeric" required="false" default="0">

<!--- Initialize summary variables --->
        <cfset var totalSelected = 0>
        <cfset var totalInserted = 0>
        <cfset var new_reportid = 18>
        <cfset var i = 0>
        <cfset var resultSummary = {totalSelected = 0, totalInserted = 0, reportId = new_reportid}>

<!--- Query to fetch data --->
        <cfquery name="report_18">
            SELECT 
                COUNT(p.audprojectid) AS totals, 
                'Non-Union' AS label, 
                'Auditions' AS itemDataset 
            FROM 
                audprojects p 
            INNER JOIN 
                audroles r ON p.audprojectID = r.audprojectID 
            INNER JOIN 
                audunions u ON u.unionid = p.unionid 
            INNER JOIN 
                audsources s ON s.audsourceid = r.audsourceid 
            WHERE 
                r.isdeleted = 0
                AND p.isdeleted = 0
                AND u.unionName = 'Non-Union' 
                <cfif arguments.new_audsourceid neq 0>
                    AND s.audsourceid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_audsourceid#">
                </cfif>
                AND p.userid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.userid#">
                AND p.projdate >= <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.rangestart#">
                AND p.projdate <= <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.rangeend#">
            GROUP BY 
                label, 
                itemDataset

UNION ALL

SELECT 
                COUNT(p.audprojectid) AS totals, 
                'Union' AS label, 
                'Auditions' AS itemDataset 
            FROM 
                audprojects p 
            INNER JOIN 
                audroles r ON p.audprojectID = r.audprojectID 
            INNER JOIN 
                audunions u ON u.unionid = p.unionid 
            INNER JOIN 
                audsources s ON s.audsourceid = r.audsourceid 
            WHERE 
                r.isdeleted <> 1 
                AND p.isdeleted <> 1 
                AND u.unionName <> 'Non-Union' 
                <cfif arguments.new_audsourceid neq 0>
                    AND s.audsourceid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_audsourceid#">
                </cfif>
                AND p.userid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.userid#">
                AND p.projdate >= <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.rangestart#">
                AND p.projdate <= <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.rangeend#">
            GROUP BY 
                label, 
                itemDataset
            ORDER BY label
        </cfquery>

<!--- Update summary with total selected --->
        <cfset resultSummary.totalSelected = report_18.recordCount>

<!--- Loop through the results and insert report items --->
        <cfloop query="report_18">
            <cfset i = i + 1>
            <cfset var new_label = report_18.label>
            <cfset var new_itemValueInt = report_18.totals>
            <cfset var new_itemDataset = report_18.itemDataset>

<!--- Find or create report item ID --->
            <cfquery name="findid">
                SELECT r.ID AS new_id
                FROM reports_user r
                WHERE r.userid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.userid#">
                AND r.reportid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_reportid#">
            </cfquery>

<cfset var new_id = 0>
            <cfif findid.recordcount eq 1>
                <cfset new_id = findid.new_id>
            </cfif>

<!--- Sanitize the label --->
            <cfset var new_label_new = Replace(new_label, "'", "", "All")>

<!--- Insert report item --->
            <cfquery name="Insert_ReportItems" result="insertResult">
                INSERT INTO reportitems (
                    itemLabel,
                    itemOrderNo,
                    itemValueInt,
                    ID,
                    itemDataset,
                    userid
                ) VALUES (
                    <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#new_label_new#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#i#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_itemValueInt#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_id#">,
                    <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#new_itemDataset#">,
                    <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.userid#">
                )
            </cfquery>

<!--- Track insertions --->
            <cfset totalInserted++>
        </cfloop>

<!--- Update summary with total inserted --->
        <cfset resultSummary.totalInserted = totalInserted>

<!--- Return summary --->
        <cfreturn resultSummary>
    </cffunction>

</cfcomponent>
