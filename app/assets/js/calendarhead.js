document.addEventListener("DOMContentLoaded", function() {
        var calendarEl = document.getElementById("calendar");
        var calendar = new FullCalendar.Calendar(calendarEl, {
plugins: ["bootstrap", "interaction", "dayGrid", "timeGrid", "list"],
            slotDuration: "00:30:00",
            timeZone: 'America/Los_Angeles',
            minTime: "<cfoutput>#userCalStarttime#</cfoutput>",
            maxTime: "<cfoutput>#userCalEndtime#</cfoutput>",
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
            defaultView: "dayGridWeek",
            handleWindowResize: !0,
      
            header: {
                left: "prev,next today",
                center: "title",
                right: "dayGridMonth,timeGridWeek,timeGridDay,listMonth"
            },
            events: t,
            editable: !0,
            droppable: !0,
            eventLimit: !0,
            selectable: !0,
        });
        calendar.render();
      });
