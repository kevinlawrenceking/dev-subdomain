<cfset eventTypesUserService = createObject("component", "services.EventTypesUserService")>
<cfset find = eventTypesUserService.SELeventtypes_user(
    eventTypeName = xs.eventtypeName,
    userId = users.userid
)>