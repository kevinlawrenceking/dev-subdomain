<!---
    PURPOSE: Top bar search autocomplete - navigate directly to selected result
    Replaces the old form-POST-to-process.cfm pattern which broke when
    CSRF validation was added to all POST requests.
    LOADED BY: core.cfm (line 204) on every authenticated page
--->
<script>
/**
 * Navigate directly to the selected search result via GET.
 * No form POST needed - eliminates CSRF token requirement for search.
 */
function taoSearchNavigate(id, category) {
    var eid = encodeURIComponent(id);
    if (category === "Contacts") {
        window.location.href = "/app/contact/?contactid=" + eid;
    } else if (category === "Tags") {
        window.location.href = "/app/contacts/?bytag=" + eid;
    } else if (category === "Events" || category === "Appointments") {
        window.location.href = "/app/appoint-update/?eventid=" + eid + "&returnurl=calendar-appoint&rcontactid=0";
    } else {
        window.location.href = "/app/contacts/";
    }
}

$(function() {
    // Desktop search autocomplete
    if ($("#autocomplete").length) {
        $("#autocomplete").autocomplete({
            source: function(request, response) {
                $.ajax({
                    url: '/app/autolookup.cfm',
                    dataType: 'json',
                    data: {
                        userid: '<cfoutput>#userid#</cfoutput>',
                        searchTerm: request.term
                    },
                    success: function(data) {
                        response($.map(data.suggestions, function(item) {
                            return {
                                label: item.value + " (" + item.data.category + ")",
                                value: item.value,
                                id: item.id,
                                category: item.data.category
                            };
                        }));
                    }
                });
            },
            minLength: 2,
            select: function(event, ui) {
                taoSearchNavigate(ui.item.id, ui.item.category);
                return false;
            },
            open: function() {
                var inputWidth = $("#autocomplete").outerWidth();
                $(".ui-autocomplete").css({
                    "width": (inputWidth * 1.5) + "px",
                    "white-space": "nowrap"
                });
            }
        });

        // Intercept form submit (Enter key without selecting) - go to contacts list
        $("#submitform").on("submit", function(e) {
            e.preventDefault();
            var term = $.trim($("#autocomplete").val());
            if (term.length) {
                window.location.href = "/app/contacts/?search=" + encodeURIComponent(term);
            } else {
                window.location.href = "/app/contacts/";
            }
        });
    }

    // Mobile search autocomplete
    if ($("#autocomplete_mobile").length) {
        $("#autocomplete_mobile").autocomplete({
            source: function(request, response) {
                $.ajax({
                    url: '/app/autolookup.cfm',
                    dataType: 'json',
                    data: {
                        userid: '<cfoutput>#userid#</cfoutput>',
                        searchTerm: request.term
                    },
                    success: function(data) {
                        response($.map(data.suggestions, function(item) {
                            return {
                                label: item.value + " (" + item.data.category + ")",
                                value: item.value,
                                id: item.id,
                                category: item.data.category
                            };
                        }));
                    }
                });
            },
            minLength: 2,
            select: function(event, ui) {
                taoSearchNavigate(ui.item.id, ui.item.category);
                return false;
            },
            open: function() {
                var inputWidth = $("#autocomplete_mobile").outerWidth();
                $(".ui-autocomplete").css({
                    "width": (inputWidth * 1.5) + "px",
                    "white-space": "nowrap"
                });
            }
        });

        // Mobile form submit intercept
        $("#submitform_mobile").on("submit", function(e) {
            e.preventDefault();
            var term = $.trim($("#autocomplete_mobile").val());
            if (term.length) {
                window.location.href = "/app/contacts/?search=" + encodeURIComponent(term);
            } else {
                window.location.href = "/app/contacts/";
            }
        });
    }
});
</script>
