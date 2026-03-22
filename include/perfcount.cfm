<!--- PERF: Increment per-request query counter for instrumentation --->
<!--- MIGRATE: In Go, this becomes middleware-level query counting via database/sql driver hooks --->
<cfif structKeyExists(request, "perfQueryCount")>
    <cfset request.perfQueryCount = request.perfQueryCount + 1 />
</cfif>
