<!--- This ColdFusion page handles user email validation by checking if the provided email exists for users other than the specified user ID. --->

<cfif structKeyExists(url, "userID")>
    <cfset userID = url.userID>
</cfif>

<cfif structKeyExists(form, "email")>
    <!--- Query to check for existing emails --->
    <cfquery name="emailCheck" >
        SELECT COUNT(*) AS total_row
        FROM taousers
        WHERE userid <> <cfqueryparam value="#userID#" cfsqltype="CF_SQL_INTEGER">
        AND useremail = <cfqueryparam value="#trim(form.email)#" cfsqltype="CF_SQL_VARCHAR">
    </cfquery>

    <!--- Check if no matching emails were found --->
    <cfif emailCheck.total_row EQ 0>
        <cfset output = { "success" = true }>
        <cfoutput>#serializeJSON(output)#</cfoutput>
    </cfif>
</cfif>
