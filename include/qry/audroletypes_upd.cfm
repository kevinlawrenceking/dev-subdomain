<!--- This ColdFusion page initializes parameters for a new audit role type and includes a query template for processing. --->

<cfparam name="new_audroletype" default="" />
<!--- Set default value for new_audroletype parameter --->

<cfparam name="new_audCatid" default="2" />
<!--- Set default value for new_audCatid parameter --->

<cfparam name="new_isDeleted" default="0" />
<!--- Set default value for new_isDeleted parameter --->

<cfinclude template="/include/qry/audroletypes_ins_414_1.cfm" />
<!--- Include the query template for inserting audit role types --->
