<!---
    PURPOSE: Debug calendar events data to identify why events are stretching
    AUTHOR: Kevin King
    DATE: 2025-08-08
--->

<cfinclude template="/include/qry/eventtypes_user.cfm" />
<cfinclude template="/include/qry/events_byuser.cfm" />

<h2>Calendar Events Debug Information</h2>

<style>
    .debug-table { border-collapse: collapse; width: 100%; margin: 20px 0; }
    .debug-table th, .debug-table td { border: 1px solid #ddd; padding: 8px; text-align: left; }
    .debug-table th { background-color: #f2f2f2; }
    .debug-table .problem { background-color: #ffebee; }
    .debug-table .fixed { background-color: #e8f5e8; }
</style>

<table class="debug-table">
    <tr>
        <th>Event ID</th>
        <th>Title</th>
        <th>Start Date</th>
        <th>Start Time</th>
        <th>End Date</th>
        <th>End Time</th>
        <th>Status</th>
        <th>Generated Start</th>
        <th>Generated End</th>
    </tr>
    
    <cfoutput query="events" maxrows="20">
        <cfset eventStartDate = events.col3>
        <cfset eventStartTime = events.eventStartTime>
        <cfset eventStopDate = events.eventstop>
        <cfset eventStopTime = events.eventstopTime>
        
        <!--- Apply the same logic as calendar2.cfm --->
        <cfset problemClass = "">
        
        <!--- Check for problems --->
        <cfif NOT isDate(eventStartDate)>
            <cfset problemClass = "problem">
            <cfset eventStartDate = now()>
        </cfif>
        <cfif NOT isDate(eventStartTime)>
            <cfset problemClass = "problem">
            <cfset eventStartTime = createTime(9, 0, 0)>
        </cfif>
        
        <cfif NOT isDate(eventStopDate) OR dateCompare(eventStopDate, eventStartDate) LT 0>
            <cfset problemClass = "problem">
            <cfset eventStopDate = eventStartDate>
        </cfif>
        
        <cfif NOT isDate(eventStopTime)>
            <cfset problemClass = "problem">
            <cfset eventStopTime = createTime(hour(eventStartTime) + 1, minute(eventStartTime), 0)>
        <cfelseif dateCompare(eventStopDate, eventStartDate) EQ 0>
            <cfset startMinutes = hour(eventStartTime) * 60 + minute(eventStartTime)>
            <cfset stopMinutes = hour(eventStopTime) * 60 + minute(eventStopTime)>
            <cfif stopMinutes LTE startMinutes>
                <cfset problemClass = "problem">
                <cfset newHour = hour(eventStartTime) + 1>
                <cfif newHour GTE 24>
                    <cfset newHour = 23>
                    <cfset newMinute = 59>
                <cfelse>
                    <cfset newMinute = minute(eventStartTime)>
                </cfif>
                <cfset eventStopTime = createTime(newHour, newMinute, 0)>
            </cfif>
        </cfif>
        
        <cfif problemClass EQ "problem">
            <cfset problemClass = "fixed">
        </cfif>
        
        <tr class="#problemClass#">
            <td>#events.eventid#</td>
            <td>#events.col1#</td>
            <td>#dateFormat(events.col3, "yyyy-mm-dd")#</td>
            <td>#timeFormat(events.eventStartTime, "HH:mm:ss")#</td>
            <td>#dateFormat(events.eventstop, "yyyy-mm-dd")#</td>
            <td>#timeFormat(events.eventstopTime, "HH:mm:ss")#</td>
            <td>
                <cfif NOT isDate(events.eventstop) OR dateCompare(events.eventstop, events.col3) LT 0>
                    ❌ Bad End Date
                </cfif>
                <cfif NOT isDate(events.eventstopTime)>
                    ❌ Bad End Time
                </cfif>
            </td>
            <td>#dateFormat(eventStartDate, "yyyy-mm-dd")# #timeFormat(eventStartTime, "HH:mm")#</td>
            <td>#dateFormat(eventStopDate, "yyyy-mm-dd")# #timeFormat(eventStopTime, "HH:mm")#</td>
        </tr>
    </cfoutput>
</table>

<h3>Legend:</h3>
<ul>
    <li><span style="background-color: #ffebee; padding: 2px;">Red background</span> - Original problematic data</li>
    <li><span style="background-color: #e8f5e8; padding: 2px;">Green background</span> - Data that was fixed by validation</li>
    <li><span style="background-color: white; padding: 2px;">White background</span> - Data that was already correct</li>
</ul>

<p><strong>Next steps:</strong></p>
<ol>
    <li>Run the database cleanup script: <a href="/admin-calendar-cleanup.cfm">admin-calendar-cleanup.cfm</a></li>
    <li>Check if any events still show problems after cleanup</li>
    <li>Verify the FullCalendar configuration</li>
</ol>
