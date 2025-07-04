<!--- This ColdFusion page initializes parameters and includes a query template for audit question types. --->

<cfparam name="new_qtype" default="" />
<!--- Set default value for new_qtype parameter --->

<cfparam name="new_isDeleted" default="0" />
<!--- Set default value for new_isDeleted parameter --->

<cfinclude template="/include/qry/audqtypes_ins_404_1.cfm" />
<!--- Include the query template for audit question types --->
