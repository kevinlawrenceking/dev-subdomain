<!--- This ColdFusion page retrieves active and inactive notifications for a user based on various criteria. --->

<Cfset currentStartDate="#DateFormat(Now(),'yyyy-mm-dd')#" /> 

<cfparam name="hide_completed" default="N" />

<!--- Query to retrieve active notifications --->
<cfinclude template="/include/qry/notsActive_510_1.cfm" />

<!--- Query to retrieve inactive notifications --->
<cfinclude template="/include/qry/notsInactive_510_2.cfm" />

