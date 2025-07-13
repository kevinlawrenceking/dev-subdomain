<!--- This page processes event details, calculates event stop time, cleans event descriptions, and manages relationships for contacts. --->

<cfparam name="rcontactid" default="0" />     
<cfparam name="eventstarttime" default="" />     
<cfparam name="dow" default="" />     

<!--- Adjust endRecur date if provided --->
 <cfif structKeyExists(variables, "endRecur") and isDate(variables.endRecur)>,
    <cfset endRecur = dateAdd('d', 1, endRecur) />
</cfif>

<!--- Check if event start time is provided --->
<cfif eventStartTIme neq "">

    <!--- Include duration calculation template --->
<cfinclude template="/include/qry/durations.cfm" />


    <cfif #eventStartTime# is not "">
    <cfinclude template="/include/qry/duration_467_1.cfm" />
    <cfset new_durseconds = duration.durseconds />
    <cfset new_eventStopTime = "#timeformat(DateAdd("s", "#new_durseconds#", "#eventStartTime#"), 'HH:MM:SS')#" />

</cfif>



    <cfoutput>
        eventStartTIme: #timeformat(eventStartTime,'HH:MM:SS')#<BR>
        new_durseconds: #new_durseconds#<BR>
        statement: SELECT ADDTIME("#timeformat('#eventStartTIme#','HH:MM:SS')#", "#new_durseconds#") as new_eventStopTime <BR>  
    </cfoutput>
    
    
    
    <cfoutput>
        new_eventStopTime: #new_eventStopTime#<BR>
    </cfoutput>

</cfif>
<cfoutput>
eventTypeName: #eventTypeName#<br>
eventDescription: #eventDescription#<br>
eventLocation: #eventLocation#<br>
eventStart: #eventStart#<br>
 
dow: #dow#<br>
eventStopTime: #new_eventStopTime#<br>
endRecur: #endRecur#<br>
eventID: #eventid#<br>
</cfoutput>


<!--- Clean event description and limit its length 
<cfset cleanData = REReplace(eventDescription, "[^a-zA-Z0-9,.!? ]", "", "ALL")>
<cfset eventDescription = Left(cleanData, 5000)>--->
 
<!--- Include update and delete templates for event --->
<cfinclude template="/include/qry/update_18_1.cfm" /> 
<cfinclude template="/include/qry/d_18_2.cfm" />

<!--- Loop through relationships --->
<Cfloop list="#relationships#" index="relationship" >

    <!--- Check if relationship is numeric --->
    <cfif #isnumeric(relationship)# is "YES">
    
        <!--- Include find template for relationship --->
        <cfinclude template="/include/qry/FIND_18_3.cfm" />
        
        <!--- Check if a record was found --->
        <cfif #find.recordcount# is "1">
            <cfset new_contactid  = relationship />
        <cfelse>
            <cfset new_contactid  = 0 />
        </cfif>
        
    <cfelse>
    
        <!--- Include add template for new relationship --->
        <cfinclude template="/include/qry/add_14_6.cfm" />
        
        <cfset currentid=result.generated_key />
        <cfset contactid=result.generated_key />
        <cfset new_contactid=result.generated_key />
        
        <cfset select_userid = cookie.userid />
        <cfset select_contactid = currentid />
        
        <!--- Include folder setup template --->
        <cfinclude template="/include/folder_setup.cfm" />
        
    </cfif> 
    
    <!--- If a new contact ID was generated, include insert template --->
    <cfif #new_contactid# is not "0">
        <cfinclude template="/include/qry/inserts_18_5.cfm" />
    </cfif>

</Cfloop>

<!--- Determine return URL based on contact ID --->
<Cfif "#rcontactid#" is "0">
    <cfoutput>
        <cfset return_url = "/app/#returnurl#/?eventid=#eventid#" />
    </cfoutput>
<Cfelse>
    <cfoutput>
        <cfset return_url = "/app/#returnurl#?contactid=#rcontactid#&t2=1" />
    </cfoutput>
</Cfif>

<!--- Redirect to the return URL --->
<cflocation url="#return_url#" />

