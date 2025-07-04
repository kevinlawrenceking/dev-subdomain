<!--- This ColdFusion page initializes parameters for an audit role and includes a template for inserting audit roles. --->

<cfparam name="new_audRoleName" default="" />
<!--- Initialize the audit role name parameter --->

<cfparam name="new_audprojectID" default="" />
<!--- Initialize the audit project ID parameter --->

<cfparam name="new_audRoleTypeID" default="" />
<!--- Initialize the audit role type ID parameter --->

<cfparam name="new_charDescription" default="" />
<!--- Initialize the character description parameter --->

<cfparam name="new_holdStartDate" default="" />
<!--- Initialize the hold start date parameter --->

<cfparam name="new_holdEndDate" default="" />
<!--- Initialize the hold end date parameter --->

<cfparam name="new_audDialectID" default="" />
<!--- Initialize the audit dialect ID parameter --->

<cfparam name="new_audSourceID" default="" />
<!--- Initialize the audit source ID parameter --->

<cfparam name="new_userid" default="" />
<!--- Initialize the user ID parameter --->

<cfparam name="new_isDeleted" default="0" />
<!--- Initialize the is deleted parameter to 0 --->

<cfinclude template="/include/qry/audroles_ins_411_1.cfm" />
<!--- Include the template for inserting audit roles --->
