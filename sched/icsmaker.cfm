<cfset dbug="N" />
<CFINCLUDE template="remote_load.cfm" />
<cfset currentURL=cgi.server_name />
<cfset host=ListFirst(currentURL, "." ) />
<Cfparam name="target_userid" default="0" />

<!--- Check if session.userSharePath exists, if not create a fallback path --->
<cfif not structKeyExists(session, "userSharePath")>
    <cfif structKeyExists(session, "userMediaPath")>
        <cfset session.userSharePath = session.userMediaPath & "\share">
    <cfelse>
        <cfset session.userSharePath = application.baseMediaPath & "\share">
    </cfif>
</cfif>

<cfoutput>
    <cfset cal_root_dir="#session.userSharePath#\" />
    <cfset cal_root_url="https://#host#.theactorsoffice.com/calendar/" />
</cfoutput>

<cfquery result="result"  name="U">
    SELECT
    u.userid
    ,REPLACE(REPLACE(u.recordname, ' ', ''), '-', '') AS calendarName
    ,u.recordname
    ,u.userFirstName
    ,u.userLastName
    ,u.userEmail
    ,u.contactid
    ,u.userRole
    ,u.tzid
    FROM taousers u
<Cfif #target_userid# is not "0">
WHERE u.userid = #target_userid#
</cfif>
</cfquery>

<cfloop query="U">

    <cfset new_userid=U.userid />

        <cfquery result="result"  name="eventItem">
        SELECT
        e.eventID
        ,e.eventID as recid
        ,e.eventTitle as summary
        ,e.eventDescription
        ,e.eventLocation as LOCATION
        ,e.eventStatus as col4
        ,e.eventCreation
        ,e.eventStart
        ,e.eventStop
        ,e.eventTypeName as col5
        ,'Appointment' as head1
        ,'Location' as head2
        ,'Date' as head3
        ,'Status' as head4
        ,'Type' as head5
        ,e.userid
        ,e.eventStartTime
        ,DATE_FORMAT(e.eventStartTime, '%k') as starthours_h
        ,DATE_FORMAT(e.eventStopTime, '%k') as stophours_h
        ,e.eventStopTime
        ,t.eventtypecolor
        FROM events e INNER JOIN eventtypes t on t.eventtypename = e.eventtypename
        WHERE e.userid = #new_userid# and e.eventStart is not null and e.eventStop is not null and e.eventstatus = 'Active' and e.isdeleted = 0
    </cfquery>

<Cfif #eventItem.recordcount# is not "0">

    <cfoutput>

        <cfset tzid="#u.tzid#" />

        <cfset calendar_name3="#U.userfirstname##u.userlastname#" />

        <cfset calendar_name2=#REReplace(calendar_name3,"[^0-9A-Za-z ]","","all")# />

        <cfset calendar_name=#replace(calendar_name2," ",""," all")# />

        <cfset calendar_dir="#cal_root_dir##calendar_name#" />

        <cfset calendar_url="#cal_root_url##calendar_name#" />

        <cfif #dbug# is "Y">

            <h2>User: #u.userid#</h2>
            <h2>calendar: #calendar_name#</h2>

            <h2>calendar url: #calendar_url#</h2>
            <h2>calendar dir: #calendar_dir#</h2>
        </cfif>

</cfoutput>

<cfset UTCHourOffset=3 />
    <cfset PRODID="TheActorsOffice" />
    <cfset CALNAME="TAO Calendar" />

    <cfparam name="tzid" default="America/Los_Angeles" />
    <cfparam name="DATESTART" default="20210725" />
    <cfparam name="DATEEND" default="20210725" />
    <cfparam name="TIMESTART" default="100000" />
    <cfparam name="TIMEEND" default="143000" />
    <cfparam name="DTSTAMP" default="20210725T221010" />
    <cfparam name="CALSCALE" default="Gregorian" />
    <cfparam name="utcHourOffset" default="Gregorian" />
    <cfparam name="location" default="" />


<cfif #isdefined('tzid')#>
        <cfset tzid=tzid />
    </cfif>

    <cfquery result="result"  name="tzdetails">
        SELECT tzid,gmt,tzname,utchouroffset FROM timezones
        where tzid = '#tzid#'
    </cfquery>

    <cfif #isdefined('tzdetails.utchouroffset')#>
        <cfset utcHourOffset=tzdetails.utchouroffset />
        <cfelse>
            <cfset utcHourOffset=0 />

    </cfif>

<cfset ICSContent="" />
    <cfset ICSContent=ICSContent & "BEGIN:VCALENDAR#chr(13)##chr(10)#" />
    <cfset ICSContent=ICSContent & "PRODID:#prodid##chr(13)##chr(10)#" />
    <cfset ICSContent=ICSContent & "VERSION:2.0#chr(13)##chr(10)#" />
    <cfset ICSContent=ICSContent & "CALSCALE:#calscale##chr(13)##chr(10)#" />
    <cfset ICSContent=ICSContent & "X-WR-CALNAME:#calname##chr(13)##chr(10)#" />
    <cfset ICSContent=ICSContent & "X-WR-TIMEZONE:#tzid##chr(13)##chr(10)#" />

<cfloop query="eventItem">

<cfoutput>
            <cfset new_description1="#eventitem.eventDescription#" />

<cfset new_description2=#replace(new_description1, "#chr(13)#" ,"\n","All")# />
            <cfset new_description3=#replace(new_description2, "#chr(10)#" ,"\n","All")# />
            <cfset new_description=#replace(new_description3, "," , "\," ,"All")# />

        </cfoutput>

        <cfoutput>
            <cfset new_location1="#eventitem.location#" />

<cfset new_location2=#replace(new_location1, "#chr(13)#" ,"\n","All")# />
            <cfset new_location3=#replace(new_location2, "#chr(10)#" ,"\n","All")# />
            <cfset new_location=#replace(new_location3, "," , "\," ,"All")# />

        </cfoutput>

        <cfif #eventitem.eventStart# is not "">

            <cfset initial_datestart=eventitem.eventStart />

            <cfelse>

                ERROR! - no start date!<cfabort>

        </cfif>

        <cfif #eventitem.eventStop# is not "">

            <cfset initial_dateend=eventitem.eventStop />

            <cfelse>

                <cfset initial_dateend=eventitem.eventStart />

        </cfif>

        <cfif #eventitem.eventStartTime# is not "">

            <cfset TIMESTART=eventItem.eventStartTime />

            <cfelse>

                <cfset TIMESTART="12:00:00" />

        </cfif>

        <cfif #eventitem.eventStopTime# is not "">

            <cfset TIMEEND=eventItem.eventStopTime />

            <cfelse>

                <cfset TIMEEND="13:00:00" />

        </cfif>

        <cfset starthours_h=eventitem.starthours_h />

        <cfset starthours=#replace(starthours_h,'h','','All')# />
      <cfset starthours = numberformat(starthours) />
        <cfset final_start_hour=numberformat(starthours + utchouroffset) />

        <cfset stopthours_h=eventitem.stophours_h />

        <cfset stophours=#replace(stophours_h,'h','','All')# />
   <cfset stophours = numberformat(stophours) />
        <cfif #dbug# is "Y">
            <Cfoutput>
                stophours: #stophours# utchouroffset: utchouroffset <BR>

            </Cfoutput>

        </cfif>
        <cfset final_stop_hour=numberformat(stophours + utchouroffset) />

        <cfif final_start_hour gte 24>

            <cfset datestart=DateAdd('d', 1, initial_datestart) />

            <cfelseif final_start_hour lte 0>

                <cfset datestart=DateAdd('d', -1, initial_datestart) />

                <cfelse>

                    <cfset datestart=initial_datestart />

        </cfif>

        <cfif final_stop_hour gte 24>

            <cfset dateend=DateAdd('d', 1, initial_dateend) />

            <cfelseif final_stop_hour lte 0>

                <cfset dateend=DateAdd('d', -1, initial_dateend) />

                <cfelse>

                    <cfset dateend=initial_dateend />

        </cfif>

<cfset ICSContent=ICSContent & "BEGIN:VEVENT#chr(13)##chr(10)#" />
        <cfset ICSContent=ICSContent & "UID:#CreateUUID()##chr(13)##chr(10)#" />
        <cfset ICSContent=ICSContent & "SUMMARY:#eventItem.summary##chr(13)##chr(10)#" />
        <cfset ICSContent=ICSContent & "DESCRIPTION:#new_description##chr(13)##chr(10)#" />
        <cfset ICSContent=ICSContent & "LOCATION:#new_location##chr(13)##chr(10)#" />
        <cfset ICSContent=ICSContent & "DTSTART:#DateFormat(datestart,'yyyymmdd')#T#TimeFormat(DateAdd('h',utcHourOffset,timestart),'HHmmss')#Z#chr(13)##chr(10)#" />
        <cfset ICSContent=ICSContent & "DTEND:#DateFormat(dateend,'yyyymmdd')#T#TimeFormat(DateAdd('h',utcHourOffset,timeend),'HHmmss')#Z#chr(13)##chr(10)#" />
        <cfset ICSContent=ICSContent & "DTSTAMP:#DateFormat(now(),'yyyymmdd')#T#TimeFormat(now(),'HHmmss')#Z#chr(13)##chr(10)#">
        <cfset ICSContent=ICSContent & "END:VEVENT#chr(13)##chr(10)#" />
    
    </cfloop>
 
<cfset ICSContent=ICSContent & "END:VCALENDAR" />

<Cfset calendar_path = "C:\home\theactorsoffice.com\media-#dsn#\calendar\#u.calendarname#.ics" />

<cffile action="write" file="#calendar_path#" output="#TRIM(ICSContent)#" />
</cfif>
</cfloop>
