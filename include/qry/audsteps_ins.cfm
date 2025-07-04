<!--- This ColdFusion page initializes parameters and includes a query template for processing audit steps. --->
<cfparam name="new_audstep" default="" />
<cfparam name="new_isDeleted" default="0" />

<!--- Include the query template for inserting audit steps --->
<cfinclude template="/include/qry/audsteps_ins_418_1.cfm" />
