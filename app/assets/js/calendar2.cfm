<!--- calendar2.cfm — FullCalendar v6 init (upgraded from v4.4.0)
     Loaded via script_include after FindLinksB JS assets.
     CFML variables in scope: userCalStarttime, userCalendtime, tzid, userid, session.csrfToken
--->
<cfparam name="userCalStarttime" default="07:00:00" />
<cfparam name="userCalendtime" default="21:00:00" />
<cfparam name="tzid" default="America/Los_Angeles" />

<script>
(function() {
    "use strict";

    var calendarEl = document.getElementById('calendar');
    if (!calendarEl) return;

    // --- View persistence via localStorage [Sub-phase F] ---
    var savedView = localStorage.getItem('tao-calendar-view');
    var isMobile = window.innerWidth < 768;

    // --- CSRF token for state-changing requests ---
    var csrfToken = '<cfoutput>#JSStringFormat(session.csrfToken)#</cfoutput>';

    // --- Slot times from user preferences ---
    var slotStart = '<cfoutput>#timeFormat(userCalStarttime, "HH:mm:ss")#</cfoutput>';
    var slotEnd = '<cfoutput>#timeFormat(userCalendtime, "HH:mm:ss")#</cfoutput>';

    // --- Responsive toolbar [Sub-phase F] ---
    var headerToolbar = isMobile
        ? { left: 'prev,next today', center: 'title', right: 'listWeek' }
        : { left: 'prev,next today', center: 'title', right: 'dayGridMonth,timeGridWeek,timeGridDay,listMonth' };

    var initialView = isMobile ? 'listWeek' : (savedView || 'dayGridMonth');

    // --- Calendar init (FullCalendar v6 — no plugins array, global builds self-register) ---
    var calendar = new FullCalendar.Calendar(calendarEl, {

        // Core config
        initialView: initialView,
        headerToolbar: headerToolbar,
        themeSystem: 'bootstrap5',
        timeZone: '<cfoutput>#JSStringFormat(tzid)#</cfoutput>',
        slotDuration: '00:30:00',
        slotMinTime: slotStart,
        slotMaxTime: slotEnd,
        contentHeight: 'auto',
        handleWindowResize: true,

        // Button labels
        buttonText: {
            today: 'Today',
            month: 'Month',
            week: 'Week',
            day: 'Day',
            list: 'List'
        },

        // UX features [Sub-phase C]
        nowIndicator: true,
        navLinks: true,
        dayMaxEvents: true,
        selectable: true,
        selectMirror: true,
        editable: true,
        eventStartEditable: true,
        eventDurationEditable: true,
        lazyFetching: true,

        // Business hours (visual shading only)
        businessHours: {
            daysOfWeek: [1, 2, 3, 4, 5],
            startTime: slotStart,
            endTime: slotEnd
        },

        // --- JSON feed event source [Sub-phase D] ---
        events: {
            url: '/ajax/calendar-events.cfm',
            failure: function() {
                document.getElementById('calendar').innerHTML =
                    '<div class="alert alert-danger m-3">Error loading calendar events. Please refresh the page.</div>';
            }
        },

        loading: function(isLoading) {
            var spinner = document.getElementById('calendar-loading');
            if (spinner) spinner.style.display = isLoading ? 'flex' : 'none';
        },

        eventSourceSuccess: function(events) {
            var emptyMsg = document.getElementById('calendar-empty');
            if (emptyMsg) emptyMsg.style.display = events.length === 0 ? 'block' : 'none';
        },

        // --- Event click — navigate to appointment/audition [Sub-phase C fix] ---
        eventClick: function(info) {
            if (info.event.url) {
                info.jsEvent.preventDefault();
                window.location.href = info.event.url;
            }
        },

        // --- Tooltips on hover [Sub-phase F] ---
        eventMouseEnter: function(info) {
            if (info.event.title) {
                var tooltip = new bootstrap.Tooltip(info.el, {
                    title: info.event.title,
                    placement: 'top',
                    trigger: 'manual',
                    container: 'body'
                });
                tooltip.show();
                info.el._tooltip = tooltip;
            }
        },
        eventMouseLeave: function(info) {
            if (info.el._tooltip) {
                info.el._tooltip.dispose();
                delete info.el._tooltip;
            }
        },

        // --- Click-to-create [Sub-phase F] ---
        dateClick: function(info) {
            window.location.href = '/app/appoint-add/?returnurl=calendar-appoint&rcontactid=0&date=' + info.dateStr;
        },

        select: function(info) {
            window.location.href = '/app/appoint-add/?returnurl=calendar-appoint&rcontactid=0&start=' + info.startStr + '&end=' + info.endStr;
        },

        // --- Drag-and-drop rescheduling [Sub-phase F] ---
        eventDrop: function(info) {
            if (!confirm('Move "' + info.event.title + '" to ' + info.event.start.toLocaleString() + '?')) {
                info.revert();
                return;
            }
            fetch('/ajax/calendar-event-update.cfm', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-Token': csrfToken
                },
                body: JSON.stringify({
                    eventid: info.event.id,
                    start: info.event.start.toISOString(),
                    end: info.event.end ? info.event.end.toISOString() : null
                })
            }).then(function(r) {
                if (!r.ok) { alert('Failed to save. Reverting.'); info.revert(); }
            }).catch(function() { alert('Network error. Reverting.'); info.revert(); });
        },

        eventResize: function(info) {
            if (!confirm('Resize "' + info.event.title + '"?')) {
                info.revert();
                return;
            }
            fetch('/ajax/calendar-event-update.cfm', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-Token': csrfToken
                },
                body: JSON.stringify({
                    eventid: info.event.id,
                    start: info.event.start.toISOString(),
                    end: info.event.end ? info.event.end.toISOString() : null
                })
            }).then(function(r) {
                if (!r.ok) { alert('Failed to save. Reverting.'); info.revert(); }
            }).catch(function() { alert('Network error. Reverting.'); info.revert(); });
        },

        // --- View persistence [Sub-phase F] ---
        viewDidMount: function(info) {
            localStorage.setItem('tao-calendar-view', info.view.type);
        }
    });

    calendar.render();

    // --- Event type filter toggles [Sub-phase F] ---
    document.querySelectorAll('.event-type-filter').forEach(function(cb) {
        cb.addEventListener('change', function() {
            var className = this.value;
            var checked = this.checked;
            calendar.getEvents().forEach(function(event) {
                if (event.classNames.indexOf(className) !== -1) {
                    event.setProp('display', checked ? 'auto' : 'none');
                }
            });
        });
    });

})();
</script>
