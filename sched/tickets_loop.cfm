<cfquery result="result" datasource="abod" name="z"  >
Select * from tickets
</cfquery>  
<cfloop query="z">

<cfquery result="result" datasource="abo" name="update"  >   
        update tickets
        set ticketname  = <cfqueryparam cfsqltype="cf_sql_varchar" value="#z.ticketname#" />
    ,ticketstatus  = <cfqueryparam cfsqltype="cf_sql_varchar" value="#z.ticketstatus#" />
    ,ticketpriority  = <cfqueryparam cfsqltype="cf_sql_varchar" value="#z.ticketpriority#" />
    ,tickettype  = <cfqueryparam cfsqltype="cf_sql_varchar" value="#z.tickettype#" />
    <cfif #z.verid# is not "">
    ,verid  = <cfqueryparam cfsqltype="cf_sql_integer" value="#z.verid#" />
        </cfif>
    
        <cfif #z.esthours# is not "">
    ,esthours = <cfqueryparam cfsqltype="cf_sql_decimal" value="#z.esthours#" />
    </cfif>
     ,patchnote  = <cfqueryparam cfsqltype="cf_sql_varchar" value="#z.patchnote#" />
     ,isdeleted  = <cfqueryparam cfsqltype="cf_sql_bit" value="#z.isdeleted#" />
        where ticketid = <cfqueryparam cfsqltype="cf_sql_integer" value="#z.ticketid#" />
        </cfquery>   

</cfloop>

