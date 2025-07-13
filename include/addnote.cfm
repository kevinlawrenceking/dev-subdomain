<!--- This  page handles user actions for adding, deleting, or updating notes based on the provided user ID and page type. --->

<cfif #isdefined('userid')#>

    <!--- Check the page type to determine the action to perform --->
    <cfif #pgtype# is "add">
        
        <cfinclude template="/include/qry/InsertNote_4_1.cfm" />
        
    <cfelseif #pgtype# is "delete">
        
        <cfinclude template="/include/qry/DeleteNote_4_2.cfm" />
        
    <cfelseif #pgtype# is "update">
        
        <cfinclude template="/include/qry/InsertNote_4_1.cfm" />
        <cfinclude template="/include/qry/DeleteNote_4_4.cfm" />
        
    <cfelse>
        
        <!--- Handle unexpected page type --->
        Error! <cfabort>
        
    </cfif>

    <!--- Redirect to the contact index page with the new contact ID --->
    <cflocation addtoken="false" url="/app/contact/index.cfm?contactid=#newcontactid#&t3=1" />
    
<cfelse>
    
    <!--- Handle case where user ID is not defined --->
    No User!
    
</cfif>

