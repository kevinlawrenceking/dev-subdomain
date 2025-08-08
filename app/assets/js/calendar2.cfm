

<cfsavecontent variable="events_loop">
    <cfoutput>
    <cfloop query="events">
        <cfset startRecur = DateFormat(events.col3, "yyyy-mm-dd")>
        <cfif events.endrecur neq "">
            <cfset endRecur = DateFormat(events.endrecur, "yyyy-mm-dd")>
        </cfif>
        
        <!--- Validate and fix end date/time logic --->
        <cfset eventStartDate = events.col3>
        <cfset eventStartTime = events.eventStartTime>
        <cfset eventStopDate = events.eventstop>
        <cfset eventStopTime = events.eventstopTime>
        
        <!--- Fix missing or invalid stop date --->
        <cfif NOT isDate(eventStopDate) OR dateCompare(eventStopDate, eventStartDate) LT 0>
            <cfset eventStopDate = eventStartDate>
        </cfif>
        
        <!--- Fix missing or invalid stop time --->
        <cfif NOT isDate(eventStopTime)>
            <!--- If stop time is invalid, add 1 hour to start time --->
            <cfset eventStopTime = timeAdd("h", 1, eventStartTime)>
        <cfelseif dateCompare(eventStopDate, eventStartDate) EQ 0>
            <!--- Same date: check if stop time is after start time --->
            <cfset startSeconds = hour(eventStartTime) * 3600 + minute(eventStartTime) * 60 + second(eventStartTime)>
            <cfset stopSeconds = hour(eventStopTime) * 3600 + minute(eventStopTime) * 60 + second(eventStopTime)>
            <cfif stopSeconds LTE startSeconds>
                <!--- Stop time is before or equal to start time, add 1 hour --->
                <cfset eventStopTime = timeAdd("h", 1, eventStartTime)>
            </cfif>
        </cfif>
        
        {
            <cfif events.dow neq "">
                groupId: "recurring#events.eventid#",
                startRecur: "#startRecur#",
                daysOfWeek: [ "#replace(trim(events.dow), ',', "','")#" ],
                startTime: "#timeformat(eventStartTime, 'HH:mm')#",
                endTime: "#timeformat(eventStopTime, 'HH:mm')#",
                <cfif events.endrecur neq "">
                    endRecur: "#endRecur#",
                </cfif>
            </cfif>
            title: "#JSStringFormat(events.col1)#",
            start: "#dateFormat(eventStartDate, "yyyy-mm-dd")# #timeformat(eventStartTime, 'HH:mm')#",
            end: "#dateFormat(eventStopDate, "yyyy-mm-dd")# #timeformat(eventStopTime, 'HH:mm')#",
            url: "<cfif events.audprojectid eq "">/app/appoint/?eventid=#events.eventid#&returnurl=calendar-appoint&rcontactid=0<cfelse>/app/audition/?focusid=#events.eventid#&audprojectid=#events.audprojectid#</cfif>",
            description: "#JSStringFormat(events.col5)#",
            className: "colorkey-#events.id#"
        }<cfif events.currentrow lt events.recordcount>,</cfif>
    </cfloop>
    </cfoutput>
</cfsavecontent>


<script>
! function(l) {
    "use strict";
    function e() {
        this.$body = l("body"), this.$modal = l("#event-modal"), this.$calendar = l("#calendar"), this.$btnNewEvent = l("#btn-new-event"), this.$btnDeleteEvent = l("#btn-delete-event"), this.$btnSaveEvent = l("#btn-save-event"), this.$modalTitle = l("#modal-title"), this.$calendarObj = null, this.$selectedEvent = null, this.$newEventData = null
    }
    e.prototype.init = function() {
        var e = new Date(l.now());
        var t = [<cfoutput>#events_loop#</cfoutput>
              ],
            a = this;
        a.$calendarObj = new FullCalendar.Calendar(a.$calendar[0], {
            plugins: ["bootstrap", "dayGrid", "timeGrid", "list"],
            slotDuration: "00:30:00",
            contentHeight: 'auto',
            timeZone: 'America/Los_Angeles',
            minTime: "<cfoutput>#CalStarttime#</cfoutput>",
            maxTime: "<cfoutput>#CalEndtime#</cfoutput>",
            themeSystem: "bootstrap",
            bootstrapFontAwesome: !1,
            buttonText: {
                today: "Today",
                month: "Month",
                week: "Week",
                day: "Day",
                list: "List",
                prev: "Prev",
                next: "Next"
            },
displayEventTime: false,
            defaultView: "timeGridWeek",
            handleWindowResize: !0,
            header: {
                left: "prev,next today",
                center: "title",
                right: "dayGridMonth,timeGridWeek,timeGridDay,listMonth"
            },
            events: t,
            eventClick: function(e) {
                a.onEventClick(e)
            }
        }), a.$calendarObj.render(), a.$btnNewEvent.on("click", function(e) {
            a.onSelect({
                date: new Date,
                allDay: !0
            })
        })
            , 
            l(a.$btnDeleteEvent.on("click", function(e) {
            a.$selectedEvent && (a.$selectedEvent.remove(), a.$selectedEvent = null, a.$modal.modal("hide"))
        }))
    }, l.CalendarApp = new e, l.CalendarApp.Constructor = e
}(window.jQuery),
function() {
    "use strict";
    window.jQuery.CalendarApp.init()
}();
</script>
    