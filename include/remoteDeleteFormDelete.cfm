<!--- This ColdFusion page handles the loading of RPG data and manages updates based on user input. --->
<cfinclude template="rpg_load.cfm" />

<cfparam name="OldValue" default="" />
<cfparam name="Recordname" default="" />
<cfparam name="NewValue" default="" />
<cfparam name="updatename" default="" />
<cfparam name="recid" default="0" />
<cfparam name="updatedetails" default="" />
<cfparam name="loginname" default="" />
<cfparam name="t1" default="0" />
<cfparam name="t2" default="0" />
<cfparam name="t3" default="0" />
<cfparam name="t4" default="0" />
<cfparam name="contactid" default="0" />

<cfoutput>
    <cfparam name="userid" default="#userid#" />
    <cfparam name="compid" default="#rpg_compid#" />
    <cfparam name="compTable" default="#rpg_comptable#" />
    <cfparam name="recname" default="#fid#" />
    <cfparam name="compName" default="#rpg_compname#" />
</cfoutput>

<!--- Include delete query template for specific operation --->
<cfinclude template="/include/qry/delete_233_1.cfm" />
<cfset suidList = []>

<cfquery result="result" name="suidQuery" >
    SELECT suid FROM fusystemusers
</cfquery>

<cfloop query="suidQuery">
    <cfset arrayAppend(suidList, suidQuery.suid)>
</cfloop>

<!--- Check if RPG ID is 40 and include additional delete query if true --->
<cfif #rpgid# is "40">
    <cfinclude template="/include/qry/del_233_2.cfm" />
</cfif>

<cfoutput>
    <cfset returnpage = "/app/#rpg_compDir#/" />
</cfoutput>

<!--- Redirect to the specified location with parameters --->
<cflocation url="/app/#pgDir#/?contactid=#contactid#&t1=#t1#&t2=#t2#&t3=#t3#&t4=#t4#" />
