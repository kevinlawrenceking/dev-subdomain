<!--- This ColdFusion page handles the creation of a new contact and redirects to the contact view page. --->
<cfparam name="refer_contact_id" default="" />

<!--- Include the query to add a new contact --->
<cfinclude template="/include/qry/add_211_1.cfm" />

<!--- Set the contact ID for further processing --->
<cfset contactid = currentid />

<!--- Retrieve the user ID from the session --->
<cfset select_userid = userid />
<!--- Set the current contact ID for reference --->
<cfset select_contactid = currentid />

<!--- Include the folder setup for the contact --->
<cfinclude template="/include/folder_setup.cfm" />

<!--- Redirect to the contact view page with the newly created contact ID --->
<cflocation url="/app/contact/?contactid=#contactid#&ctaction=view" />
