<cfquery result="result"  name="z"  >
SELECT contactid,contactbirthday FROM contactdetails WHERE contactbirthday IS not null
</cfquery>  
<cfloop query="z">
<cfoutput>
<cfset newest_contactid = z.contactid />
<cfset new_contactbirthday = "#z.contactbirthday#" />
</cfoutput>  
     
<Cfif #isdate(new_contactbirthday)# is "false">
    <cfquery result="result"  name="update"  >   
    update contactdetails
    set contactbirthday = NULL  
    where contactid = <cfqueryparam cfsqltype="cf_sql_integer" value="#newest_contactid#" />
    </cfquery>
    <cfoutput>
    (#newest_contactid#) #new_contactbirthday# is not a valid date - deleted.
    </cfoutput>
<cfelse>
    <cfoutput>
    <cfset new_day = #day(new_contactbirthday)# />
    <cfset new_month = #month(new_contactbirthday)# /> 
    <cfset new_date_thisyear = "#new_month#-#new_day#-2021" />
    <cfif #new_date_thisyear# LTE #dateformat(now(),"m-d-yyyy")#>
            <cfset final_birthday =  "#new_month#-#new_day#-2022" />                  
    <cfelse>
            <cfset final_birthday =  "#new_month#-#new_day#-2021" /> 
    </cfif>
    </cfoutput>            
    <cfif #dateformat(z.contactbirthday)# is not "#dateformat(final_birthday)#">
        <cfquery result="result"  name="update"  >   
        update contactdetails
        set contactbirthday = <cfqueryparam cfsqltype="cf_sql_date" value="#dateformat(final_birthday)#" />
        where contactid = <cfqueryparam cfsqltype="cf_sql_integer" value="#newest_contactid#" />
        </cfquery>   
        <cfoutput>
        (#newest_contactid#) Birthday changed from "#dateformat(z.contactbirthday)#" to  "#dateformat(final_birthday)#"
        </cfoutput>
    </cfif>
</cfif>
</cfloop>

<cfquery result="result"  name="getUsers"  >
  SELECT * FROM taousers
</cfquery>
<cfloop query="getUsers">
  <cfquery result="result"  name="setPasswordHash"   >
    UPDATE taousers
    SET passwordHash = <cfqueryparam cfsqltype="char" value="#hash(Password,'SHA')#">
    WHERE userID = <cfqueryparam cfsqltype="integer" value="#userID#">
  </cfquery>
</cfloop>

