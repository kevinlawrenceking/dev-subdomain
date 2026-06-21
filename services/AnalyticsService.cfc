<cfcomponent displayname="AnalyticsService" output="false"
    hint="Read-only system-wide aggregates for the admin Activity Analytics page. Performs zero writes.">

<!---
    TAO-ADMIN-ANALYTICS-01 -- Admin Activity Analytics service.
    System-wide (all users) aggregates for four tiles and their monthly trends:
      auditions, relationships (non-self contacts), reminders completed, bookings.
    Conventions: reads application.dsn; every request-derived value is cfqueryparam'd;
    MySQL syntax (DATE_FORMAT/COALESCE). No INSERT/UPDATE/DELETE anywhere.
    // MIGRATE: maps to a Go AnalyticsRepository, one method per concern; range resolved in the handler.
--->

    <cffunction name="init" access="public" returntype="any" output="false">
        <cfreturn this>
    </cffunction>

    <!--- Production data start. Rows before this are test data and are excluded from the
          All-time range (totals and charts). Bounded ranges never reach back this far. --->
    <cffunction name="allTimeFloor" access="private" returntype="date" output="false">
        <cfreturn createDate(2021, 10, 1)>
    </cffunction>

    <!--- Resolve a whitelisted preset to concrete bounds.
          Upper bound is half-open (< today+1) so it includes today and excludes future-dated rows. --->
    <cffunction name="resolveRange" access="public" returntype="struct" output="false">
        <cfargument name="rangeKey" type="string" required="true">

        <cfset var today  = createDate(year(now()), month(now()), day(now()))>
        <cfset var toExcl = dateAdd("d", 1, today)>
        <cfset var fromDate = "">
        <cfset var label = "">
        <cfset var isAll = false>
        <cfset var key = lcase(trim(arguments.rangeKey))>

        <cfswitch expression="#key#">
            <cfcase value="30d">
                <cfset fromDate = dateAdd("d", -30, today)>
                <cfset label = "Last 30 days">
            </cfcase>
            <cfcase value="12m">
                <cfset fromDate = dateAdd("m", -12, today)>
                <cfset label = "Last 12 months">
            </cfcase>
            <cfcase value="all">
                <cfset isAll = true>
                <cfset label = "All time">
            </cfcase>
            <cfdefaultcase>
                <cfset key = "90d">
                <cfset fromDate = dateAdd("d", -90, today)>
                <cfset label = "Last 90 days">
            </cfdefaultcase>
        </cfswitch>

        <cfreturn {
            "key": key,
            "isAll": isAll,
            "from": fromDate,
            "toExcl": toExcl,
            "publicView": {
                "key": key,
                "from": isAll ? dateFormat(allTimeFloor(), "yyyy-mm-dd") : dateFormat(fromDate, "yyyy-mm-dd"),
                "to": dateFormat(today, "yyyy-mm-dd"),
                "label": label
            }
        }>
    </cffunction>

    <!--- Four headline totals for the selected range. Totals run through today;
          All-time is floored at the production start (test data excluded). --->
    <cffunction name="getTotals" access="public" returntype="struct" output="false">
        <cfargument name="from"   type="any"     required="true">
        <cfargument name="toExcl" type="any"     required="true">
        <cfargument name="isAll"  type="boolean" required="true">

        <!--- Auditions: audprojects x audroles, unit = audroleid. Soft-delete/status copied from getAuditions. --->
        <cfquery name="qAud" datasource="#application.dsn#">
            SELECT COUNT(DISTINCT r.audroleid) AS cnt
            FROM audprojects p
            INNER JOIN audroles r ON p.audprojectID = r.audprojectID
            WHERE r.isdeleted = 0 AND p.isDeleted = 0
            <cfif arguments.isAll>
              AND p.projdate >= <cfqueryparam value="#allTimeFloor()#" cfsqltype="cf_sql_date">
            <cfelse>
              AND p.projdate >= <cfqueryparam value="#arguments.from#"   cfsqltype="cf_sql_date">
              AND p.projdate <  <cfqueryparam value="#arguments.toExcl#" cfsqltype="cf_sql_date">
            </cfif>
        </cfquery>

        <!--- Bookings: same base + Booking (isbooked=1) OR Direct Booking (isDirect=1).
              Flags are bit(1) (confirmed via SHOW COLUMNS) -> integer literal = 1, no cast. --->
        <cfquery name="qBook" datasource="#application.dsn#">
            SELECT COUNT(DISTINCT r.audroleid) AS cnt
            FROM audprojects p
            INNER JOIN audroles r ON p.audprojectID = r.audprojectID
            WHERE r.isdeleted = 0 AND p.isDeleted = 0
              AND (r.isbooked = 1 OR p.isDirect = 1)
            <cfif arguments.isAll>
              AND p.projdate >= <cfqueryparam value="#allTimeFloor()#" cfsqltype="cf_sql_date">
            <cfelse>
              AND p.projdate >= <cfqueryparam value="#arguments.from#"   cfsqltype="cf_sql_date">
              AND p.projdate <  <cfqueryparam value="#arguments.toExcl#" cfsqltype="cf_sql_date">
            </cfif>
        </cfquery>

        <!--- Relationships: non-self contacts. COALESCE keeps NULL/empty user_yn (real contacts). --->
        <cfquery name="qRel" datasource="#application.dsn#">
            SELECT COUNT(*) AS cnt
            FROM contactdetails d
            WHERE COALESCE(d.user_yn,'N') <> 'Y'
            <cfif arguments.isAll>
              AND d.contactCreationDate >= <cfqueryparam value="#allTimeFloor()#" cfsqltype="cf_sql_date">
            <cfelse>
              AND d.contactCreationDate >= <cfqueryparam value="#arguments.from#"   cfsqltype="cf_sql_date">
              AND d.contactCreationDate <  <cfqueryparam value="#arguments.toExcl#" cfsqltype="cf_sql_date">
            </cfif>
        </cfquery>

        <!--- Reminders completed: anchored on notenddate (written = today on completion). --->
        <cfquery name="qRem" datasource="#application.dsn#">
            SELECT COUNT(*) AS cnt
            FROM funotifications
            WHERE notstatus = 'Completed' AND isdeleted = 0
            <cfif arguments.isAll>
              AND notenddate >= <cfqueryparam value="#allTimeFloor()#" cfsqltype="cf_sql_date">
            <cfelse>
              AND notenddate >= <cfqueryparam value="#arguments.from#"   cfsqltype="cf_sql_date">
              AND notenddate <  <cfqueryparam value="#arguments.toExcl#" cfsqltype="cf_sql_date">
            </cfif>
        </cfquery>

        <cfreturn {
            "auditions": val(qAud.cnt),
            "relationships": val(qRel.cnt),
            "remindersCompleted": val(qRem.cnt),
            "bookings": val(qBook.cnt)
        }>
    </cffunction>

    <!--- Monthly series for all four metrics over a shared, continuous month axis. --->
    <cffunction name="getActivitySeries" access="public" returntype="struct" output="false">
        <cfargument name="from"   type="any"     required="true">
        <cfargument name="toExcl" type="any"     required="true">
        <cfargument name="isAll"  type="boolean" required="true">

        <!--- Graphs show COMPLETE months only: cut the trailing current (partial) month so the
              last point is never an artificial dip. Totals (getTotals) still run through today.
              Upper bound for the series = first day of the current month (exclusive). --->
        <cfset var seriesToExcl = createDate(year(now()), month(now()), 1)>
        <cfset var lowerBound = arguments.isAll ? allTimeFloor() : arguments.from>

        <cfset var qAud  = seriesAuditions(lowerBound, seriesToExcl, false)>
        <cfset var qBook = seriesAuditions(lowerBound, seriesToExcl, true)>
        <cfset var qRel  = seriesRelationships(lowerBound, seriesToExcl)>
        <cfset var qRem  = seriesReminders(lowerBound, seriesToExcl)>

        <!--- Axis ends at the last FULL month (the day before the current month begins). --->
        <cfset var lastFull = dateAdd("d", -1, seriesToExcl)>
        <cfset var endYM = dateFormat(lastFull, "yyyy") & "-" & numberFormat(month(lastFull), "00")>
        <cfset var startYM = "">
        <cfif arguments.isAll>
            <!--- Earliest real data month within the production window; floor guards stray dates. --->
            <cfset startYM = earliestYM([qAud, qBook, qRel, qRem], endYM, "2021-10")>
        <cfelse>
            <cfset startYM = dateFormat(arguments.from, "yyyy") & "-" & numberFormat(month(arguments.from), "00")>
        </cfif>

        <!--- No complete month in range yet -> empty axis rather than a bogus single point. --->
        <cfif startYM GT endYM>
            <cfreturn { "labels": [], "auditions": [], "relationships": [], "remindersCompleted": [], "bookings": [] }>
        </cfif>

        <cfset var labels = buildMonthLabels(startYM, endYM)>

        <cfreturn {
            "labels": labels,
            "auditions": mapSeries(qAud, labels),
            "relationships": mapSeries(qRel, labels),
            "remindersCompleted": mapSeries(qRem, labels),
            "bookings": mapSeries(qBook, labels)
        }>
    </cffunction>

    <!--- Auditions (bookedOnly=false) or Bookings (bookedOnly=true) monthly buckets.
          Always bounded [from, toExcl) -- toExcl is the first of the current month (full months only). --->
    <cffunction name="seriesAuditions" access="private" returntype="query" output="false">
        <cfargument name="from"       type="any"     required="true">
        <cfargument name="toExcl"     type="any"     required="true">
        <cfargument name="bookedOnly" type="boolean" required="true">
        <cfquery name="q" datasource="#application.dsn#">
            SELECT DATE_FORMAT(p.projdate, '%Y-%m') AS ym, COUNT(DISTINCT r.audroleid) AS cnt
            FROM audprojects p
            INNER JOIN audroles r ON p.audprojectID = r.audprojectID
            WHERE r.isdeleted = 0 AND p.isDeleted = 0
              AND p.projdate >= <cfqueryparam value="#arguments.from#"   cfsqltype="cf_sql_date">
              AND p.projdate <  <cfqueryparam value="#arguments.toExcl#" cfsqltype="cf_sql_date">
            <cfif arguments.bookedOnly>
              AND (r.isbooked = 1 OR p.isDirect = 1)
            </cfif>
            GROUP BY DATE_FORMAT(p.projdate, '%Y-%m')
            ORDER BY ym
        </cfquery>
        <cfreturn q>
    </cffunction>

    <cffunction name="seriesRelationships" access="private" returntype="query" output="false">
        <cfargument name="from"   type="any" required="true">
        <cfargument name="toExcl" type="any" required="true">
        <cfquery name="q" datasource="#application.dsn#">
            SELECT DATE_FORMAT(d.contactCreationDate, '%Y-%m') AS ym, COUNT(*) AS cnt
            FROM contactdetails d
            WHERE COALESCE(d.user_yn,'N') <> 'Y'
              AND d.contactCreationDate >= <cfqueryparam value="#arguments.from#"   cfsqltype="cf_sql_date">
              AND d.contactCreationDate <  <cfqueryparam value="#arguments.toExcl#" cfsqltype="cf_sql_date">
            GROUP BY DATE_FORMAT(d.contactCreationDate, '%Y-%m')
            ORDER BY ym
        </cfquery>
        <cfreturn q>
    </cffunction>

    <cffunction name="seriesReminders" access="private" returntype="query" output="false">
        <cfargument name="from"   type="any" required="true">
        <cfargument name="toExcl" type="any" required="true">
        <cfquery name="q" datasource="#application.dsn#">
            SELECT DATE_FORMAT(notenddate, '%Y-%m') AS ym, COUNT(*) AS cnt
            FROM funotifications
            WHERE notstatus = 'Completed' AND isdeleted = 0
              AND notenddate >= <cfqueryparam value="#arguments.from#"   cfsqltype="cf_sql_date">
              AND notenddate <  <cfqueryparam value="#arguments.toExcl#" cfsqltype="cf_sql_date">
            GROUP BY DATE_FORMAT(notenddate, '%Y-%m')
            ORDER BY ym
        </cfquery>
        <cfreturn q>
    </cffunction>

    <cffunction name="earliestYM" access="private" returntype="string" output="false">
        <cfargument name="queries"  type="array"  required="true">
        <cfargument name="fallback" type="string" required="true">
        <cfargument name="floorYM"  type="string" required="false" default="2021-10">
        <cfset var minYM = "">
        <cfset var q = "">
        <cfloop array="#arguments.queries#" index="q">
            <cfloop query="q">
                <!--- Ignore anything below the production floor so a stray/old row cannot
                      stretch the all-time chart axis. --->
                <cfif q.ym GTE arguments.floorYM AND (NOT len(minYM) OR q.ym LT minYM)>
                    <cfset minYM = q.ym>
                </cfif>
            </cfloop>
        </cfloop>
        <cfreturn len(minYM) ? minYM : arguments.fallback>
    </cffunction>

    <cffunction name="buildMonthLabels" access="private" returntype="array" output="false">
        <cfargument name="startYM" type="string" required="true">
        <cfargument name="endYM"   type="string" required="true">
        <cfset var labels = []>
        <cfset var cur  = createDate(listFirst(arguments.startYM,"-"), listLast(arguments.startYM,"-"), 1)>
        <cfset var endD = createDate(listFirst(arguments.endYM,"-"),   listLast(arguments.endYM,"-"),   1)>
        <cfset var guard = 0>
        <cfloop condition="cur LTE endD AND guard LT 600">
            <cfset arrayAppend(labels, dateFormat(cur,"yyyy") & "-" & numberFormat(month(cur),"00"))>
            <cfset cur = dateAdd("m", 1, cur)>
            <cfset guard = guard + 1>
        </cfloop>
        <cfreturn labels>
    </cffunction>

    <cffunction name="mapSeries" access="private" returntype="array" output="false">
        <cfargument name="q"      type="query" required="true">
        <cfargument name="labels" type="array" required="true">
        <cfset var m = {}>
        <cfloop query="arguments.q">
            <cfset m[arguments.q.ym] = val(arguments.q.cnt)>
        </cfloop>
        <cfset var out = []>
        <cfset var lbl = "">
        <cfloop array="#arguments.labels#" index="lbl">
            <cfset arrayAppend(out, structKeyExists(m, lbl) ? m[lbl] : 0)>
        </cfloop>
        <cfreturn out>
    </cffunction>

</cfcomponent>
