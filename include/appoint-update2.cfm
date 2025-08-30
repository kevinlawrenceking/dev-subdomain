<!--- This coldfusion page processes event details, calculates event stop time, cleans event descriptions, and manages relationships for contacts. --->

<!--- Safely setup form and URL parameters with cfparam --->
<cfparam name="form.rcontactid" default="0" />
<cfparam name="form.reventid" default="0" />
<cfparam name="form.returnurl" default="calendar" />
<cfparam name="form.eventid" default="0" />
<cfparam name="form.eventTitle" default="" />
<cfparam name="form.relationships" default="" />
<cfparam name="form.eventDescription" default="" />
<cfparam name="form.eventLocation" default="" />
<cfparam name="form.eventStart" default="" />
<cfparam name="form.eventTypeName" default="" />
<cfparam name="form.eventStartTime" default="" />
<cfparam name="form.new_durid" default="4" />
<cfparam name="form.dow" default="" />
<cfparam name="form.endRecur" default="" />

<!--- Set local variables from form scope --->
<cfset rcontactid = form.rcontactid />
<cfset reventid = form.reventid />
<cfset returnurl = form.returnurl />
<cfset eventid = form.eventid />
<cfset eventTitle = form.eventTitle />
<cfset relationships = form.relationships />
<cfset eventDescription = form.eventDescription />
<cfset eventLocation = form.eventLocation />
<cfset eventStart = form.eventStart />
<cfset eventTypeName = form.eventTypeName />
<cfset eventStartTime = form.eventStartTime />
<cfset new_durid = form.new_durid />
<cfset dow = form.dow />
<cfset endRecur = form.endRecur />

<!--- Adjust endRecur date if provided --->
<cfif len(trim(endRecur)) GT 0 and isDate(endRecur)>
    <cfset endRecur = dateAdd('d', 1, endRecur) />
</cfif>

<!--- Check if event start time is provided --->
<cfif len(trim(eventStartTime)) GT 0>
    <!--- Include duration calculation template --->
    <cfinclude template="/include/qry/durations.cfm" />
    <cfinclude template="/include/qry/duration_467_1.cfm" />
    
    <cfset new_durseconds = duration.durseconds />
    <cfset new_eventStopTime = timeformat(DateAdd("s", new_durseconds, eventStartTime), 'HH:MM:SS') />
<cfelse>
    <cfset new_eventStopTime = "" />
</cfif>


<!--- Clean event description and limit its length 
<cfset cleanData = REReplace(eventDescription, "[^a-zA-Z0-9,.!? ]", "", "ALL")>
<cfset eventDescription = Left(cleanData, 5000)>--->
 
<!--- Include update and delete templates for event --->
<cfinclude template="/include/qry/update_18_1.cfm" /> 
<cfinclude template="/include/qry/d_18_2.cfm" />

<!--- Loop through relationships --->
<cfloop list="#relationships#" index="relationship">
    <!--- Check if relationship is numeric --->
    <cfif isNumeric(relationship)>
        <!--- Include find template for relationship --->
        <cfinclude template="/include/qry/FIND_18_3.cfm" />
        
        <!--- Check if a record was found --->
        <cfif find.recordcount EQ 1>
            <cfset new_contactid = relationship />
        <cfelse>
            <cfset new_contactid = 0 />
        </cfif>
    <cfelse>
        <!--- Include add template for new relationship --->
        <cfinclude template="/include/qry/add_14_6.cfm" />
        
        <cfset currentid = result.generated_key />
        <cfset contactid = result.generated_key />
        <cfset new_contactid = result.generated_key />
        
        <cfset select_userid = session.userid />
        <cfset select_contactid = currentid />
        
        <!--- Include folder setup template --->
        <cfinclude template="/include/folder_setup.cfm" />
    </cfif> 
    
    <!--- If a new contact ID was generated, include insert template --->
    <cfif new_contactid NEQ 0>
        <cfinclude template="/include/qry/inserts_18_5.cfm" />
    </cfif>
</cfloop>

<!--- Determine return URL based on contact ID --->
<cfif rcontactid EQ 0>
    <cfset return_url = "/app/#returnurl#/?eventid=#eventid#" />
<cfelse>
    <cfset return_url = "/app/#returnurl#?contactid=#rcontactid#&t2=1" />
</cfif>

<!--- Redirect to the return URL --->
<cflocation url="#return_url#" />

