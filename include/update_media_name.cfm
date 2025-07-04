<cfparam name="mediaid" default="">
<cfparam name="medianame" default="">

    <!--- Set current URL and host based on server name --->
    <cfset currentURL = cgi.server_name />
    <cfset host = ListFirst(currentURL, ".") />
    
    <!--- Determine the data source name and version based on the host --->
    <cfif #host# is "app">
        <cfset dsn = "abo" />
        <cfset rev = "1.4" />
        <cfset suffix = "_1.4" />
    <cfelse>
        <cfset dsn = "abod" />
        <cfset rev = rand() />
        <cfset suffix = "" />
    </cfif>
 

<cfif isNumeric(mediaid) AND len(trim(medianame)) GT 0>
    <cfquery datasource="#dsn#">
        UPDATE audmedia
        SET medianame = <cfqueryparam value="#medianame#" cfsqltype="CF_SQL_VARCHAR">
        WHERE mediaid = <cfqueryparam value="#mediaid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

    <cfoutput>success</cfoutput>
<cfelse>
    <cfoutput>error</cfoutput>
</cfif>