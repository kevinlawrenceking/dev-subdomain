<!--- This ColdFusion page includes query templates and redirects to the audition page based on the provided project ID. --->
<cfinclude template="/include/qry/del_230_1.cfm" />
<!--- Include the first query template for deletion --->
<cfinclude template="/include/qry/del2_230_2.cfm" />
<!--- Include the second query template for deletion --->
<cfinclude template="/include/qry/remove_191_11.cfm" />
<!--- Include the removal query template --->
<cflocation url="/app/audition/?audprojectid=#audprojectid#" />
<!--- Redirect to the audition page with the specified project ID --->

