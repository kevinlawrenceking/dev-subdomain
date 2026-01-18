<!--- This ColdFusion page handles redirection based on the value of the 'dd' parameter. --->

<cfparam name="dd" default="0" />

<cfinclude template="/include/qry/update_113_1.cfm" />

<!--- Check if 'dd' is equal to "0" to determine the redirection URL. --->
<cfif #dd# is "0">
    <cflocation url="/app/myaccount/?t1=1&target_id=#target_id#" />    
<cfelse>
    <cflocation url="/app/dashboard/?t1=1&target_id=#target_id#" />  
</cfif>
