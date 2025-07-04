<cfset sel_search = "">
<cfparam name="select_userid" default="%" />
<cfparam name="select_ticketstatus" default="%" />
   <cfparam name="select_tickettype" default="%" />     
   <cfparam name="select_ticketpriority" default="%" />     
       <cfparam name="select_pgid" default="%" />     
     <cfparam name="select_verid" default="%" />  
     <cfset dsn="abo"> 
<cfquery name="results"     >
    
    SELECT
'ID' as head1
,'Details' as head2    
,'Page' as head3  
,'Type' as head4 
,'Status' as head45
,'Priority' as head5
,'Hours' as head6
,'Release' as head7
,t.ticketID as col1
    ,t.ticketID as recid
,t.ticketName AS col2   
,p.pgname AS col3
,t.tickettype as col4
,t.ticketstatus as col45
,t.ticketpriority as col5
,t.ticketpriority
,t.esthours as col6
,CONCAT(v.major,'.',v.minor,'.',v.patch,'-',v.alphabeta) AS col7
,t.verid
,t.tickettype
,t.ticketstatus

,p.pgname
,p.pgdir
 FROM tickets t
 INNER JOIN taousers_tbl u ON u.userid = t.userid
 left JOIN pgpages p ON p.pgid = t.pgid
left join taoversions v on v.verid = t.verid
    
    
    
WHERE ticketActive = 'Y' 

    <cfif #select_userid# is not "%">
    
    and t.userid = #select_userid#
    </cfif>
    
        <cfif #select_ticketstatus# is not "%">
    
    and t.ticketstatus = '#select_ticketstatus#'
    </cfif>
    
    
           <cfif #select_ticketpriority# is not "%">
    
    and t.ticketpriority = '#select_ticketpriority#'
    </cfif>
    
            <cfif #select_tickettype# is not "%">
    
    and t.tickettype = '#select_tickettype#'
    </cfif>
        <cfif #select_pgid# is not "%">
    
    and p.pgid = #select_pgid#
    </cfif>
    
            <cfif #select_verid# is not "%">
    
    and t.verid = #select_verid#
    </cfif>
    
ORDER BY t.ticketCreatedDate DESC limit 5
</cfquery> 

    

    
       	<cfquery name="priorities" datasource="#dsn#" >
    
    SELECT ticketpriority AS id, ticketpriority AS name FROM ticketpriority ORDER BY orderNo
    </cfquery>
    
    
            	<cfquery name="vers" datasource="#dsn#" >
    SELECT v.major,v.minor,v.patch,v.verid AS id, v.alphabeta,CONCAT(v.major,'.',v.minor,'.',v.patch,'-',v.alphabeta) as name
      ,((v.hoursavail) - (SELECT SUM(esthours) FROM tickets t WHERE verid = v.verid)) AS hoursleft              
                    FROM taoversions v ORDER BY v.major,v.minor,v.patch
    </cfquery>
    
    
  


<cfparam name="select_userid" default="%" />
<cfparam name="select_ticketstatus" default="%" />
<cfparam name="select_tickettype" default="%" />
<cfparam name="select_ticketpriority" default="%" />
<cfparam name="select_pgid" default="%" />
<cfparam name="select_verid" default="%" />
    <Cfoutput>
 <cfset cookie.select_ticketstatus = "#select_ticketstatus#" />
       <cfset cookie.select_ticketpriority = "#select_ticketpriority#" />  
   <cfset cookie.select_userid = "#select_userid#" />
     <cfset cookie.select_tickettype = "#select_tickettype#" />
           <cfset cookie.select_pgid = "#select_pgid#" />  
<cfset cookie.select_verid = "#select_verid#" /> 
    </Cfoutput>
    
    
    
<cfset select_ticketstatus = cookie.select_ticketstatus />
    
  <CFINCLUDE template="/include/remote_load.cfm" />
    
<cfquery datasource="#dsn#" name="users"      >

SELECT distinct u.recordname,u.userrole, u.userid 
FROM taousers u INNER JOIN tickets t on u.userID = t.userid
WHERE t.ticketactive = 'Y'
ORDER BY u.userlastname, u.userfirstname
</cfquery>
    
    <cfquery datasource="#dsn#" name="statuses"      >

SELECT DISTINCT t.ticketstatus from
tickets t

ORDER BY  t.ticketstatus
</cfquery>
    
<cfquery datasource="#dsn#" name="types"      >

SELECT DISTINCT t.tickettype
FROM taousers u INNER JOIN tickets t on u.userID = t.userid
WHERE t.ticketactive = 'Y'
ORDER BY t.tickettype
</cfquery>
    
<cfquery datasource="#dsn#" name="pages"      >  
    SELECT DISTINCT p.pgid,p.pgname
FROM taousers u INNER JOIN tickets t on u.userID = t.userid
INNER JOIN pgpages p ON p.pgid = t.pgid
WHERE t.ticketactive = 'Y'
ORDER BY p.pgname
    </cfquery>
   