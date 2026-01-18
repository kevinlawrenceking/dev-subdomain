<cfparam name="dsn" default="abo" />

<cfquery datasource="#dsn#" result="result"  name="z">
SELECT contactid,contactbirthday FROM contactdetails WHERE contactbirthday IS not null
</cfquery>

<cfoutput>

    <cfset current_year = "#dateformat(now(),'yyyy')#" />
    
    <cfset next_year = #current_year# + 1 />

</cfoutput>

 <cfloop query="z">
     
     <cfoutput>
         
         <cfset newest_contactid=#z.contactid# />
         
         <cfset new_contactbirthday="#z.contactbirthday#" />
         
     </cfoutput>
     
     <Cfif #isdate(new_contactbirthday)# is "false">
         
         <cfquery datasource="#dsn#" result="result"  name="update">
             update contactdetails
             set contactbirthday = NULL
             where contactid =
             <cfqueryparam cfsqltype="cf_sql_integer" value="#newest_contactid#" />
         </cfquery>
         
         <cfoutput>
             (#newest_contactid#) #new_contactbirthday# is not a valid date - deleted.
         </cfoutput>
         
         <cfelse>

<cfoutput>
                 
                 <cfset new_day=#day(new_contactbirthday)# />
                 
                 <cfset new_month=#month(new_contactbirthday)# />
                 
                 <cfset new_date_thisyear="#new_month#-#new_day#-#current_year#" />
                 
                 <cfif #new_date_thisyear# LTE #dateformat(now(),"m-d-yyyy")#>
                     
                     <cfset final_birthday="#new_month#-#new_day#-#next_year#" />
                     
                     <cfelse>
                         
                         <cfset final_birthday="#new_month#-#new_day#-#current_year#" />
                         
                 </cfif>
                     
             </cfoutput>
                 
             <cfif #dateformat(z.contactbirthday)# is not "#dateformat(final_birthday)#">
                 
                 <cfquery datasource="#dsn#" result="result"  name="update">
                     update contactdetails
                     set contactbirthday =
                     <cfqueryparam cfsqltype="cf_sql_date" value="#dateformat(final_birthday)#" />
                     where contactid =
                     <cfqueryparam cfsqltype="cf_sql_integer" value="#newest_contactid#" />
                 </cfquery>
                 
                 <cfoutput>
                     (#newest_contactid#) Birthday changed from "#dateformat(z.contactbirthday)#" to "#dateformat(final_birthday)#"<BR>
                 </cfoutput>
                 
             </cfif>
     </cfif>
             
 </cfloop>

