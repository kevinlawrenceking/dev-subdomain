<!--- This ColdFusion page updates audition role properties and redirects to the audition page. --->

<cfparam name="NEW_ISREDIRECT" default="0" />
<cfparam name="NEW_ispin" default="0" />
<cfparam name="NEW_Iscallback" default="0" />
<cfparam name="NEW_ISbooked" default="0" />

<!--- Output SQL update statement for audition roles --->
<cfoutput>
    update audroles
    set 
        iscallback = #new_iscallback#,
        isredirect = #new_isredirect#,
        ispin = #new_ispin#,
        isbooked = #new_isbooked#
    WHERE audroleid = #audroleid#
</cfoutput>

<!--- Include the update query template --->
<cfinclude template="/include/qry/update_285_1.cfm" />

<!--- Redirect to the audition page with parameters --->
<cflocation url="/app/audition/?audroleid=#audroleid#&eventid=#eventid#&pgaction=view" />
