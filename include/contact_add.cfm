<!--- This ColdFusion page processes user information and redirects to a contact view page. --->
<cfinclude template="/include/qry/add_82_1.cfm" />

<!--- Set current and contact IDs from the result generated key --->
<cfset currentid = result.generated_key />
<cfset contactid = result.generated_key />

<!--- Set user and contact IDs for session management --->
<cfset select_userid = userid />
<cfset select_contactid = currentid />

<!--- Include folder setup for further processing --->
<cfinclude template="/include/folder_setup.cfm" />

<!--- Redirect to the contact view page with the specified contact ID --->
<cflocation url="/app/contact/?contactid=#contactid#&ctaction=view" />
