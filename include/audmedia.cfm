<!--- This ColdFusion page initializes parameters and includes a query template for processing event media data. --->

<cfparam name="eventid" default="0" />

<!--- Include the query template for event media data. --->
<cfinclude template="/include/qry/audmedia_38_1.cfm" />
