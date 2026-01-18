<!--- This ColdFusion page initializes parameters and includes a query for inserting audio sources. --->

<cfparam name="new_audsource" default="" />
<cfparam name="new_isDeleted" default="0" />

<!--- Include the query for inserting audio sources. --->
<cfinclude template="/include/qry/audsources_ins_415_1.cfm" />
