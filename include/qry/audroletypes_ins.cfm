<!--- This ColdFusion page initializes parameters and includes a template for processing role types. --->
<cfparam name="new_audroletype" default="" />
<cfparam name="new_audCatid" default="2" />
<cfparam name="new_isDeleted" default="0" />

<!--- Include the template for inserting role types --->
<cfinclude template="/include/qry/audroletypes_ins_412_1.cfm" />
