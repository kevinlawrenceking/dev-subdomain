document.addEventListener("DOMContentLoaded", function() {
    var calendarEl = document.getElementById("calendar");
    
    // Check if calendar element exists
    if (!calendarEl) {
        console.warn("Calendar element not found");
        return;
    }
    
    var calendar = new FullCalendar.Calendar(calendarEl, {
        plugins: ["bootstrap", "interaction", "dayGrid", "timeGrid", "list"],
        slotDuration: "00:30:00",
        timeZone: 'America/Los_Angeles',
        minTime: "08:00:00", // Default fallback
        maxTime: "18:00:00", // Default fallback
        themeSystem: "bootstrap",
        bootstrapFontAwesome: false,
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
        handleWindowResize: true,
        header: {
            left: "prev,next today",
            center: "title",
            right: "dayGridMonth,timeGridWeek,timeGridDay,listMonth"
        },
        events: [], // Initialize with empty events array
        editable: true,
        droppable: true,
        eventLimit: true,
        selectable: true,
        eventClick: function(info) {
            // Handle event click - redirect to the event URL
            if (info.event.url) {
                window.open(info.event.url, '_self');
                info.jsEvent.preventDefault(); // prevent browser from following link in current tab
            }
        },
        dateClick: function(info) {
            // Handle date click if needed
            console.log('Date clicked:', info.dateStr);
        }
    });
    
    calendar.render();
});
