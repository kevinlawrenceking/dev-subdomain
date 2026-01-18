

<cfquery result="result" datasource="#application.dsn#" name="x">
SELECT * FROM tickets WHERE verid = 7 AND ticketstatus = 'Implemented'
 
</cfquery>

<cfloop query="x">
    
    <cfquery result="result" name="add" datasource="#application.dsn#">
        INSERT INTO tickets (pgid,ticketName,ticketdetails,tickettype,userid,ticketactive,ticketstring,verid,ticketresponse,ticketcreateddate,ticketstatus,tickettype,environ,ticketpriority,esthours)
        Values (
        <cfqueryparam value="#x.pgid#" cfsqltype="cf_sql_integer" />
        ,
        <cfqueryparam value="#x.ticketName#" cfsqltype="cf_sql_varchar" />
        ,
        <cfqueryparam value="#x.ticketdetails#" cfsqltype="cf_sql_varchar" />
        ,
        <cfqueryparam value="#x.tickettype#" cfsqltype="cf_sql_varchar" />
        ,
        <cfqueryparam value="#x.userid#" cfsqltype="cf_sql_integer" />
        ,
        <cfqueryparam value="Y" cfsqltype="cf_sql_varchar" />
        ,
        <cfqueryparam value="#x.ticketstring#" cfsqltype="cf_sql_varchar" />
    
        ,
        <cfqueryparam value="8" cfsqltype="cf_sql_integer" />         
                                                               
         ,
        <cfqueryparam value="#x.ticketresponse#" cfsqltype="cf_sql_varchar" />                                                        ,
        <cfqueryparam value="#x.ticketcreateddate#" cfsqltype="cf_sql_date" />   
        
                ,
        <cfqueryparam value="Pending" cfsqltype="cf_sql_varchar" />
                                              ,
        <cfqueryparam value="Bug" cfsqltype="cf_sql_varchar" />     

,
        <cfqueryparam value="D" cfsqltype="cf_sql_varchar" />   
        
          ,
        <cfqueryparam value="Medium" cfsqltype="cf_sql_varchar" />   
        
          ,
        <cfqueryparam value="#x.esthours#" cfsqltype="cf_sql_decimal" />   
        
        )

</cfquery>

</cfloop>
