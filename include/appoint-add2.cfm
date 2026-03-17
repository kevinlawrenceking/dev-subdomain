<!--- This ColdFusion page processes event details, cleans data, and inserts records into the database. --->

<!--- Safely setup form and URL parameters with cfparam --->
<cfparam name="form.rcontactid" default="0"/>
<cfparam name="form.relationships" default="0"/>
<cfparam name="form.eventStart" default=""/>
<cfparam name="form.eventEnd" default=""/>
<cfparam name="form.eventStartTime" default="12:00:00"/>
<cfparam name="form.eventStopTime" default=""/>
<cfparam name="form.eventTitle" default=""/>
<cfparam name="form.eventDescription" default=""/>
<cfparam name="form.eventLocation" default=""/>
<cfparam name="form.eventTypeName" default=""/>
<cfparam name="form.new_durid" default="4"/>
<cfparam name="form.noteDetails" default=""/>
<cfparam name="form.dow" default=""/>
<cfparam name="form.endRecur" default=""/>
<cfparam name="form.returnurl" default="calendar"/>
<cfparam name="form.userid" default="#session.userid#"/>

<!--- Set local variables from form scope --->
<cfset rcontactid = form.rcontactid />
<cfset relationships = form.relationships />
<cfset eventStart = form.eventStart />
<cfset eventEnd = form.eventEnd />
<cfset eventStartTime = form.eventStartTime />
<cfset new_eventStopTime = form.eventStopTime />
<cfset eventTitle = form.eventTitle />
<cfset eventDescription = form.eventDescription />
<cfset eventLocation = form.eventLocation />
<cfset eventTypeName = form.eventTypeName />
<cfset new_durid = form.new_durid />
<cfset noteDetails = form.noteDetails />
<cfset dow = form.dow />
<cfset endRecur = form.endRecur />
<cfset returnurl = form.returnurl />
<cfset userid = form.userid />

<!--- Adjust endRecur date if provided --->
<cfif len(trim(endRecur)) and isDate(endRecur)>
    <cfset endRecur = dateAdd('d', 1, endRecur) />
</cfif>

<!--- Set default event start date if not provided --->
<cfif len(trim(eventStart)) EQ 0>
    <cfset eventStart = dateformat(now(), 'YYYY-mm-dd') />
</cfif>

<!--- Set default event end date if not provided --->
<cfif len(trim(eventEnd)) EQ 0>
    <cfset eventEnd = dateformat(eventStart, 'YYYY-mm-dd') />
</cfif>

<!--- Calculate new event stop time if event start time is provided --->
<cfif len(trim(eventStartTime)) GT 0>
    <cfinclude template="/include/qry/duration_467_1.cfm" />
    <cfset new_durseconds = duration.durseconds />
    <cfset new_eventStopTime = timeformat(DateAdd("s", new_durseconds, eventStartTime), 'HH:MM:SS') />
</cfif>

<!--- Clean event description and limit its length
<cfset cleanData = REReplace(eventDescription, "[^a-zA-Z0-9,.!? ]", "", "ALL")>
<cfset eventDescription = Left(cleanData, 5000)> --->
<!--- Now insert 'cleanData' into your database --->
<cfif NOT isDate(endRecur)>
    <cfset endRecur = JavaCast("null", "")>
</cfif>

<!--- Transaction wraps all event creation writes (event + contacts + notes + audition) --->
<cftransaction>

<cfinclude template="/include/qry/add_14_1.cfm" />
<cfinclude template="/include/qry/t_14_2.cfm" />
<cfinclude template="/include/qry/tt_14_3.cfm" />
<cfinclude template="/include/qry/dd_14_4.cfm" />

<!--- Loop through relationships and process each one --->
<cfloop list="#relationships#" index="relationship">
    <cfif isNumeric(relationship)>
        <cfinclude template="/include/qry/FIND_14_5.cfm" />
        <cfif find.recordcount EQ 1>
            <cfset new_contactid = relationship />
        <cfelse>
            <cfset new_contactid = 0 />
        </cfif>
    <cfelse>
        <cfinclude template="/include/qry/add_14_6.cfm" />
        <cfset currentid = newcontactid />
        <cfset contactid = newcontactid />
        <cfset new_contactid = newcontactid />
        <cfset select_userid = userid />
        <cfset select_contactid = currentid />
        <cfinclude template="/include/folder_setup.cfm" />
    </cfif>

    <!--- Insert relationship data if new_contactid is not zero --->
    <cfif new_contactid NEQ 0>
        <cfinclude template="/include/qry/inserts_14_7.cfm" />
    </cfif>
</cfloop>

<!--- Insert note details if provided --->
<cfif len(trim(noteDetails)) GT 0>
    <cfinclude template="/include/qry/InsertNote_14_8.cfm" />
</cfif>

<!--- Process audition-specific data if event type is Audition --->
<cfif eventTypeName EQ "Audition">
    <cfparam name="new_audlocid" default="0" />
    <cfset new_audStepID = 1 />
    <cfset new_audcatid = 1 />
    <cfset new_audsubcatid = 6 />
    <cfset new_userid = userid />
    <cfset new_audtypeid = "1" />
    <cfset new_projname = "Unknown" />
    <cfset new_audplatformid = 4 />
    <cfset new_audrolename = "Unknown" />
    <cfset new_audroletypeid = 1 />
    <cfset new_contactid = 0 />
    <cfset new_eventStart = eventStart />
    <cfset new_eventStartTime = eventStartTime />
    <cfset new_new_eventStopTime = new_eventStopTime />

    <cfinclude template="/include/qry/audprojects_ins.cfm" />
    <cfinclude template="/include/qry/audroles_ins.cfm" />
    <cfinclude template="/include/qry/auditions_ins.cfm" />
</cfif>

</cftransaction>

<!--- Determine return URL based on contact ID --->
<cfif rcontactid EQ 0>
    <cfset return_url = "/app/#returnurl#/" />
<cfelse>
    <cfset return_url = "/app/#returnurl#?contactid=#rcontactid#" />
</cfif>

<cfset script_name_include = "/include/#ListLast(GetCurrentTemplatePath(), " \")#"/>
<cfinclude template="/include/bigbrotherinclude.cfm" />

<!--- Redirect to the appointment page with new event ID --->
<cflocation url="/app/appoint/?eventid=#new_eventid#"/>
