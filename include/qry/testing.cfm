<!--- This ColdFusion page retrieves ticket details based on user input and displays associated information. --->

<cfset sel_search = "">
<cfparam name="select_userid" default="%" />
<cfparam name="select_ticketstatus" default="%" />
<cfparam name="select_tickettype" default="%" />
<cfparam name="select_pgid" default="%" />

<!--- Query to fetch ticket statuses --->
<cfinclude template="/include/qry/statuses_543_1.cfm" />

<!--- Query to fetch ticket details based on ticket ID --->
<cfinclude template="/include/qry/details_543_2.cfm" />

