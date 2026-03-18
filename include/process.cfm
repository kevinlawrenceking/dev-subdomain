<!--- This ColdFusion page handles redirection based on the selected category. --->

<cfparam name="form.category" default="" />
<cfparam name="form.selectedId" default="" />
<cfparam name="form.topsearch" default="" />

<cfset category = trim(form.category) />
<cfset selectedid = trim(form.selectedId) />
<cfset topsearch = trim(form.topsearch) />

<!--- If no autocomplete selection was made, redirect to contacts list --->
<cfif not len(category) or not len(selectedid)>
    <cflocation url="/app/contacts/" addtoken="false" />
</cfif>

<!--- Redirect based on category --->
<cfif category eq "Contacts">
    <cflocation url="/app/contact/?contactid=#selectedid#" addtoken="false" />

<cfelseif category eq "Tags">
    <cflocation url="/app/contacts/?bytag=#selectedid#" addtoken="false" />

<cfelseif category eq "Events" or category eq "Appointments">
    <cflocation url="/app/appoint-update/?eventid=#selectedid#&returnurl=calendar-appoint&rcontactid=0" addtoken="false" />

<cfelse>
    <cflocation url="/app/contacts/" addtoken="false" />
</cfif>
