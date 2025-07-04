<!--- This ColdFusion page initializes parameters and processes role information for auditing purposes. --->

<cfparam name="new_audRoleName" default=""/>

<cfparam name="isdirect" default="0"/>

<cfparam name="new_audRoleTypeID" default=""/>

<cfparam name="new_charDescription" default=""/>

<cfparam name="new_holdStartDate" default=""/>

<cfparam name="new_holdEndDate" default=""/>

<cfparam name="new_audDialectID" default=""/>

<cfparam name="new_audSourceID" default=""/>

<cfparam name="new_userid" default=""/>

<cfparam name="new_isDeleted" default="0"/>

<cfparam name="iscallback" default="0"/>

<cfparam name="ispin" default="0"/>

<cfparam name="isredirect" default="0"/>

<!--- Check if the request is direct and set booking status accordingly. --->
<cfif #isdirect# is "1">
    <cfset isbooked = 1 />
</cfif>

<!--- Include the template for inserting audit roles. --->
<cfinclude template="/include/qry/audroles_ins_409_1.cfm" />
