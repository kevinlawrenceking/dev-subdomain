<!--- This ColdFusion page initializes parameters and includes a query for audplatforms --->
<cfparam name="new_audplatform" default="" />
<cfparam name="new_isDeleted" default="0" />

<!--- Include the audplatforms query template --->
<cfinclude template="/include/qry/audplatforms_ins_395_1.cfm" />
