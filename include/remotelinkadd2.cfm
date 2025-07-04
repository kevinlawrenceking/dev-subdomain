<!--- This ColdFusion page processes account-related actions and redirects based on the results of queries. --->

<cfparam name="target" default="myaccount" />
<cfparam name="ver" default="1" />

<!--- Include the query to find records based on certain criteria --->
<cfinclude template="/include/qry/find_242_1.cfm" />

<!--- Check if any records were found --->
<cfif #find.recordcount# is not "0">
    <cfset ver = find.recordcount />
</cfif>

<cfset preurl = "https://" />

<!--- Check if the new site URL starts with "http" --->
<cfif #left(new_siteurl, 4)# is "http">
    <!--- No action needed if it starts with "http" --->
<cfelse>
    <!--- Prepend the preurl to the new site URL --->
    <cfoutput>
        <cfset new_siteurl = "#preurl##new_siteurl#" /> 
    </cfoutput>
</cfif>

<!--- Include the query to add records based on certain criteria --->
<cfinclude template="/include/qry/add_242_2.cfm" />

<!--- Now, lastInsertedId contains the ID of the newly inserted record --->
<cfinclude template="/include/customicon_single.cfm" />

<!--- Redirect to the target account page with the appropriate parameters --->
<cflocation url="/app/#target#/?t1=1&target_id=#target_id###item#id#" addtoken="false" />
