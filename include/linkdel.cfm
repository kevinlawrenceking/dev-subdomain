<!--- This ColdFusion page processes event and contact information, including setting return URLs based on conditions. --->

<cfparam name="rcontactid" default="0" /> 
<cfparam name="reventid" default="0" /> 

<!--- Include the first query template to find event details --->
<cfinclude template="/include/qry/find_150_1.cfm" />

<cfset eventid = find.eventid />

<!--- Include the second query template to delete link details --->
<cfinclude template="/include/qry/deletelink_150_2.cfm" />

<!--- Check if the return URL is for contact --->
<cfif returnurl eq 'contact'>
    <cfoutput> 
        <cfset returnurl = "/app/#returnurl#/?contactid=#rcontactid#&t3=1&tab2_expand=true&secid=178" />
    </cfoutput>
</cfif>

<!--- Check if the return URL is for audition --->
<cfif returnurl eq 'audition'>
    <cfoutput> 
        <cfset returnurl = "/app/#returnurl#/?contactid=#rcontactid#&audprojectid=#audprojectid#&tab2_expand=true&t3=1&secid=178" />
    </cfoutput>
</cfif>

<!--- Redirect to the constructed return URL --->
<cflocation url="#returnurl#" />
