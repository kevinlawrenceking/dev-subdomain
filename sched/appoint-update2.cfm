<cfparam name="rcontactid" default="0" />     
<cfparam name="eventstarttime" default="" />     
<cfparam name="dow" default="" />     

<cfif #eventStartTIme# is not "">

    <cfinclude template="/include/qry/duration.cfm" />

 <cfset new_durseconds = duration.durseconds />

<cfset eventStopTime = "#DateAdd("s","#eventStartTIme#","#new_durseconds#")#" />

<cfoutput>
    
    eventStartTIme: #timeformat(eventStartTime,'HH:MM:SS')#<BR>
    new_durseconds: #new_durseconds#<BR>

  statement:     SELECT ADDTIME("#timeformat('#eventStartTIme#','HH:MM:SS')#", "#new_durseconds#") as new_eventStopTime <BR>  

<cfset new_eventStopTime="#timeformat(DateAdd("s","#new_durseconds#","#eventStartTIme#"),'HH:MM:SS')#" />
    
    new_eventStopTime: #new_eventStopTime#<BR>
    
</cfoutput>

</cfif>

<cfset cleanData = eventDescription >
<cfset eventDescription = Left(cleanData, 5000)>

<cfinclude template="/include/qry/update_618_1.cfm" /> 

<cfquery result="result"  name="d"      >
update eventcontactsxref set isdeleted = 1 where eventid = <cfqueryparam cfsqltype="cf_sql_integer" value="#eventid#" />
</cfquery>

<Cfloop list="#relationships#" index="relationship" >

<cfif #isnumeric(relationship)# is "YES">

<cfquery result="result"  name="FIND"      >
    Select * from contactdetails where userid = #userid# and contactid = #relationship#
    </cfquery>

<cfif #find.recordcount# is "1">
        
            <cfset new_contactid  = relationship />
            
        <cfelse>
            
            <cfset new_contactid  = 0 />
        
        </cfif>

<cfelse>

<cfquery  name="add"   result="result">
        INSERT INTO contactdetails (userid,contactFullName) VALUES (#userid#,'#relationship#');
</cfquery>
    
        <cfset currentid=result.generated_key />
       
        <cfset contactid=result.generated_key />
 
        <cfset new_contactid=result.generated_key />

<cfset select_userid = cookie.userid />
        
<cfset select_contactid = currentid />

<cfinclude template="/include/folder_setup.cfm" />

</cfif> 

<cfif #new_contactid# is not "0">
 <cfinclude template="/include/qry/inserts_619_2.cfm" />
    
    </cfif>

</Cfloop>

<Cfif "#rcontactid#" is "0">
      <cfoutput>
     <cfset return_url = "/app/#returnurl#/?eventid=#eventid#" />
     </cfoutput>
     <Cfelse>
         
               <cfoutput>
     <cfset return_url = "/app/#returnurl#?contactid=#rcontactid#&t2=1" />
     </cfoutput>

</Cfif>

<cflocation url="#return_url#" >

