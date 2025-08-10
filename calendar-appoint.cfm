<!--- This ColdFusion page includes various templates related to calendar functionality and event management. --->

<!--- Include event types for user --->
<cfinclude template="/include/qry/eventtypes_user.cfm" />

<!--- Include events by user --->
<cfinclude template="/include/qry/events_byuser.cfm" />

<!--- Include calendar section --->
<cfinclude template="calendarSectionCalendar.cfm" />

<!--- Include modal for adding event type --->
<cfinclude template="calendarModalAddeventtype.cfm" />

<!--- Include modal for subscription --->
<cfinclude template="calendarModalSubscription.cfm" />

<!--- Include modal for updating event type --->
<cfinclude template="calendarModalUpdateeventtype.cfm" />

<!--- Set script name for include path --->
<cfset script_name_include="/include/#ListLast(GetCurrentTemplatePath(), " \")#" />
