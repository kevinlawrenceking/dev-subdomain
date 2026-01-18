<!--- This ColdFusion page handles redirection based on the value of returnurl. --->
<cfinclude template="/include/qry/deletenote_103_1.cfm" />

<!--- Check if returnurl is "audition" and redirect accordingly --->
<cfif #returnurl# is "audition">
    <cflocation url="/app/audition/?audprojectid=#audprojectid#&secid=178">
</cfif>

<!--- Check if returnurl is "contact" and redirect accordingly --->
<cfif #returnurl# is "contact">
    <cflocation url="/app/contact/?currentid=#contactid#&contactid=#contactid#&t3=1">
</cfif>

<!--- If returnurl is not "contact", redirect to appointment page --->
<cfif #returnurl# is not "contact">
    <cflocation url="/app/appoint/?eventid=#eventid#&tab2_expand=true">
</cfif>
