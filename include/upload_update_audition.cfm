<!--- This ColdFusion page initializes parameters for a project and includes necessary templates for processing auditions. --->

<cfparam name="new_projName" default=""/>
<cfparam name="new_projDescription" default=""/>
<cfparam name="new_audSubCatID" default=""/>
<cfparam name="new_unionID" default=""/>
<cfparam name="new_networkID" default=""/>
<cfparam name="new_toneID" default=""/>
<cfparam name="new_contractTypeID" default=""/>
<cfparam name="new_contactid" default=""/>
<cfparam name="isdirect" default="0"/>
<cfparam name="isbooked" default="0"/>
<cfparam name="ispin" default="0"/>
<cfparam name="new_audsourceid" default="0"/>

<cfset currentURL = cgi.server_name/>
<cfset host = ListFirst(currentURL, ".")/>

<!--- Include the first query template for processing auditions --->
<cfinclude template="/include/qry/find_317_1.cfm" />

<!--- Include the audition transfer template --->
<cfinclude template="transfer_audition.cfm" />

<!--- Include the second query template for fixing auditions --->
<cfinclude template="/include/qry/fix_191_9.cfm" />

<!--- Redirect to the auditions import page with the new upload ID --->
<cflocation url="/app/auditions-import/?uploadid=#new_uploadid#">

