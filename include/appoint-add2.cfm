<!--- This ColdFusion page processes event details, cleans data, and inserts records into the database. --->

<cfparam name="rcontactid" default="0"/>
<cfparam name="relationships" default="0"/>
<cfparam name="eventStart" default=""/>
<cfparam name="eventEnd" default=""/>
<cfparam name="eventstarttime" default="12:00:00"/>
<cfparam name="new_eventStopTime" default=""/>
<cfparam name="eventendtime" default=""/>
<cfparam name="dow" default=""/>
<cfparam name="endRecur" default=""/>

<!--- Adjust endRecur date if provided --->
 <cfif structKeyExists(variables, "endRecur") and isDate(variables.endRecur)>,
    <cfset endRecur = dateAdd('d', 1, endRecur) />
</cfif>

<!--- Set default event start date if not provided --->
<cfif #eventStart# is "">
    <cfset eventstart = dateformat(now(), 'YYYY-mm-dd') />
</cfif>

<!--- Set default event end date if not provided --->
<cfif #eventEnd# is "">
    <cfset eventEnd = dateformat(eventstart, 'YYYY-mm-dd') />
</cfif>

<!--- Calculate new event stop time if event start time is provided --->
<cfif #eventStartTime# is not "">
    <cfinclude template="/include/qry/duration_467_1.cfm" />
    <cfset new_durseconds = duration.durseconds />
    <cfset new_eventStopTime = "#timeformat(DateAdd("s", "#new_durseconds#", "#eventStartTime#"), 'HH:MM:SS')#" />

</cfif>

<!--- Clean event description and limit its length
<cfset cleanData = REReplace(eventDescription, "[^a-zA-Z0-9,.!? ]", "", "ALL")>
<cfset eventDescription = Left(cleanData, 5000)> --->
<!--- Now insert 'cleanData' into your database --->
<cfif NOT isDate(endRecur)>
    <cfset endRecur = JavaCast("null", "")>
</cfif>

<cfinclude template="/include/qry/add_14_1.cfm" />
<cfinclude template="/include/qry/t_14_2.cfm" />
<cfinclude template="/include/qry/tt_14_3.cfm" />
<cfinclude template="/include/qry/dd_14_4.cfm" />

<!--- Loop through relationships and process each one --->
<cfloop list="#relationships#" index="relationship">
    <cfif #isnumeric(relationship)# is 1>
        <cfinclude template="/include/qry/FIND_14_5.cfm" />
        <cfif #find.recordcount# is "1">
            <cfset new_contactid = relationship />
        <cfelse>
            <cfset new_contactid = 0 />
        </cfif>
    <cfelse>
        <cfinclude template="/include/qry/add_14_6.cfm" />
        <cfset currentid =newcontactid />
        <cfset contactid = newcontactid />
        <cfset new_contactid = newcontactid />
        <cfset select_userid = userid />
        <cfset select_contactid = currentid />
        <cfinclude template="/include/folder_setup.cfm" />
    </cfif>

    <!--- Insert relationship data if new_contactid is not zero --->
    <cfif #new_contactid# is not "0">
        <cfinclude template="/include/qry/inserts_14_7.cfm" />
    </cfif>
</cfloop>

<!--- Insert note details if provided --->
<cfif #noteDetails# is not "">
    <cfinclude template="/include/qry/InsertNote_14_8.cfm" />
</cfif>

<!--- Process audition-specific data if event type is Audition --->
<cfif #eventTypeName# is "Audition">
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

<!--- Determine return URL based on contact ID --->
<cfif "#rcontactid#" is "0">
    <cfoutput>
        <cfset return_url = "/app/#returnurl#/" />
    </cfoutput>
<cfelse>
    <cfoutput>
        <cfset return_url = "/app/#returnurl#?contactid=#rcontactid#" />
    </cfoutput>
</cfif>

<cfset script_name_include = "/include/#ListLast(GetCurrentTemplatePath(), " \")#"/>
<cfinclude template="/include/bigbrotherinclude.cfm" />

<!--- Redirect to the appointment page with new event ID --->
<cflocation url="/app/appoint/?eventid=#new_eventid#"/>
