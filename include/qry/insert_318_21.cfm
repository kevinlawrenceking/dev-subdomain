<cfinclude template="/include/perfcount.cfm" />
<cfset objEventTypesUserService = createObject("component", "services.EventTypesUserService")>
<cfset objEventTypesUserService.INSeventtypes_user(
    eventTypeName = xs.eventTypeName,
    eventtypedescription = xs.eventtypedescription,
    eventtypecolor = xs.eventtypecolor,
    userid = users.userid
)>