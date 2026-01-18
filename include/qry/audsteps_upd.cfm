<!--- This ColdFusion page initializes parameters and includes a query for auditing steps. --->

<cfparam name="new_audstep" default="" />
<cfparam name="new_isDeleted" default="0" />

<!--- Include the query for auditing steps --->
<cfinclude template="/include/qry/audsteps_ins_420_1.cfm" />
