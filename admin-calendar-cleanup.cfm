<!---
    PURPOSE: Clean up corrupted calendar event dates and times
    AUTHOR: Kevin King  
    DATE: 2025-08-08
    DESCRIPTION: Fixes events with invalid end dates/times that cause calendar display issues
--->

<cfquery name="qFixEventDates" datasource="#application.dsn#">
    <!--- Fix events where end date is before start date --->
    UPDATE events 
    SET eventstop = eventStart
    WHERE eventstop < eventStart 
      AND eventStart IS NOT NULL 
      AND eventstop IS NOT NULL
      AND isdeleted = 0;
      
    <!--- Fix events where end date is null but start date exists --->
    UPDATE events 
    SET eventstop = eventStart  
    WHERE eventstop IS NULL 
      AND eventStart IS NOT NULL
      AND isdeleted = 0;
      
    <!--- Fix events where end time is before start time on same date --->
    UPDATE events 
    SET eventstopTime = ADDTIME(eventStartTime, '01:00:00')
    WHERE eventstop = eventStart 
      AND eventStartTime IS NOT NULL 
      AND eventstopTime IS NOT NULL
      AND TIME(eventstopTime) <= TIME(eventStartTime)
      AND isdeleted = 0;
      
    <!--- Fix events where end time is null --->
    UPDATE events 
    SET eventstopTime = ADDTIME(eventStartTime, '01:00:00')
    WHERE eventstopTime IS NULL 
      AND eventStartTime IS NOT NULL
      AND isdeleted = 0;
      
    <!--- Fix events where start time is null (set to reasonable default) --->
    UPDATE events 
    SET eventStartTime = '09:00:00'
    WHERE eventStartTime IS NULL 
      AND eventStart IS NOT NULL
      AND isdeleted = 0;
      
    <!--- Ensure stop time is set after fixing start time --->
    UPDATE events 
    SET eventstopTime = '10:00:00'
    WHERE eventstopTime IS NULL 
      AND eventStartTime = '09:00:00'
      AND isdeleted = 0;
</cfquery>

<cfquery name="qGetFixedCount" datasource="#application.dsn#">
    SELECT 
        COUNT(*) as totalEvents,
        SUM(CASE WHEN eventstop IS NULL THEN 1 ELSE 0 END) as nullEndDates,
        SUM(CASE WHEN eventstopTime IS NULL THEN 1 ELSE 0 END) as nullEndTimes,
        SUM(CASE WHEN eventstop < eventStart THEN 1 ELSE 0 END) as invalidEndDates
    FROM events 
    WHERE isdeleted = 0 
      AND eventStart IS NOT NULL
</cfquery>

<h2>Calendar Event Data Cleanup Complete</h2>

<cfoutput>
    <div class="alert alert-success">
        <h4>Cleanup Results:</h4>
        <ul>
            <li>Total active events processed: #qGetFixedCount.totalEvents#</li>
            <li>Events with null end dates remaining: #qGetFixedCount.nullEndDates#</li>
            <li>Events with null end times remaining: #qGetFixedCount.nullEndTimes#</li>
            <li>Events with invalid end dates remaining: #qGetFixedCount.invalidEndDates#</li>
        </ul>
        
        <p><strong>What was fixed:</strong></p>
        <ul>
            <li>End dates that were before start dates</li>
            <li>Missing end dates (set to same as start date)</li>
            <li>End times that were before start times (added 1 hour duration)</li>
            <li>Missing start times (set to 9:00 AM default)</li>
            <li>Missing end times (set to 1 hour after start time)</li>
        </ul>
        
        <p><strong>Next steps:</strong></p>
        <ol>
            <li>Clear your browser cache</li>
            <li>Refresh the calendar page</li>
            <li>Events should now display with proper time slots instead of spanning entire days</li>
        </ol>
    </div>
</cfoutput>

<style>
    .alert {
        padding: 15px;
        margin-bottom: 20px;
        border: 1px solid transparent;
        border-radius: 4px;
    }
    .alert-success {
        color: #3c763d;
        background-color: #dff0d8;
        border-color: #d6e9c6;
    }
    h2 {
        color: #333;
        margin-bottom: 20px;
    }
    h4 {
        margin-top: 0;
        color: inherit;
    }
    ul, ol {
        margin-bottom: 10px;
    }
</style>
