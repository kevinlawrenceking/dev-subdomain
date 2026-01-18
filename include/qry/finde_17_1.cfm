<cfset eventContactsXRefService = createObject("component", "services.EventContactsXRefService")>

<!--- Validate that both contactid and eventid exist and are numeric before calling the function --->
<cfif isDefined("contactid") AND isNumeric(contactid) AND contactid GT 0 AND 
      isDefined("eventdetails.eventid") AND isNumeric(eventdetails.eventid) AND eventdetails.eventid GT 0>
    <cfset finde = eventContactsXRefService.SELeventcontactsxref(ContactID=contactid, EventID=eventdetails.eventid)>
<cfelse>
    <!--- Create empty query if contactid or eventid is not valid --->
    <cfset finde = queryNew("eventcontactid,contactid,eventid", "integer,integer,integer")>
</cfif>