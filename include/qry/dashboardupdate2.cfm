<!--- This ColdFusion page handles the deletion and insertion of user panel references based on provided panel IDs. --->

<cfparam name="newpnids" default="" />

<!--- Delete existing user panel references for the current user --->
<cfinclude template="/include/qry/del_460_1.cfm" />

<cfset newuserid = userid />

<!--- Check if new panel IDs are provided --->
<cfif #newpnids# is not "">
    
    <!--- Retrieve panel IDs from the database based on the provided IDs --->
    <cfinclude template="/include/qry/pgpanels_460_2.cfm" />

    <!--- Loop through the retrieved panel IDs and insert them for the current user --->
    <cfloop query="pgpanels">
        <cfset newpnid = pgpanels.pnid />

        <!--- Insert new user panel reference into the database --->
        <cfinclude template="/include/qry/insert_460_3.cfm" />
    </cfloop>
</cfif>

<!--- Redirect to the user's account page --->
<cflocation url="/app/myaccount/?t4=1" />

