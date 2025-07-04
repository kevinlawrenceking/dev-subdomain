<!--- This ColdFusion page initializes parameters for a new audit role and includes a query for inserting the role into the database. --->
<cfparam name="new_audRoleName" default="" />
<cfparam name="isdirect" default="0" />
<cfparam name="new_audRoleTypeID" default="" />
<cfparam name="new_charDescription" default="" />
<cfparam name="new_holdStartDate" default="" />
<cfparam name="new_holdEndDate" default="" />
<cfparam name="new_audDialectID" default="" />
<cfparam name="new_audSourceID" default="" />
<cfparam name="new_userid" default="" />
<cfparam name="new_isDeleted" default="0" />

<!--- Include the query for inserting the new audit role into the database --->
<cfinclude template="/include/qry/audroles_ins_39_1.cfm" />

