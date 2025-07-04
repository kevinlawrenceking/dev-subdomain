<!--- This ColdFusion page processes birthday information from a query and determines the appropriate birthday date for the current or next year. It includes another template for updating records based on the calculated date. --->

<cfinclude template="/include/qry/xx_55_1.cfm" />

<cfloop query="xx">
    <!--- Loop through each record in the query 'xx' --->
    
    <cfoutput>
        <!--- Output the current year and calculate the next year --->
        <cfset current_year = #year(now())# />
        current year: #current_year#<BR>
        
        <cfset next_year = #current_year# + 1 />
        next year: #next_year#<BR>
        
        <cfset new_contactid = #xx.contactid# />
        
        <!--- Extract the day and month from the contact's birthday --->
        <cfset new_day = #day(contactbirthday)# />
        <cfset new_month = #month(contactbirthday)# /> 
        
        <!--- Construct the date for this year based on the birthday --->
        <cfset new_date_thisyear = "#new_month#-#new_day#-#current_year#">
        
        <!--- Determine the final birthday date based on whether it has passed this year or not --->
        <cfif #new_date_thisyear# LTE #dateformat(now(),"m-d-yyyy")#>
            <cfset final_birthday = "#new_month#-#new_day#-#next_year#">
        <cfelse>
            <cfset final_birthday = "#new_month#-#new_day#-#current_year#"> 
        </cfif>
    </cfoutput>
    
    <!--- Check if the final birthday date is valid and include the update template if true --->
    <cfif #isdate(final_birthday)# is "true">
        <cfinclude template="/include/qry/update_55_2.cfm" />
    </cfif>
</cfloop>
