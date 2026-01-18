var e = $.map([ < cfloop query = "jtags" > < cfoutput > < cfif #jtags.currentrow # is not "1" > , < /cfif>"#Replace(jtags.col1,"""""","","all")#"</cfoutput> < /cfloop>], function(e) {
                return {
                    value: e,
                    data: {
                        category: "Tags"
                    }
                }
            }),
            a = $.map([ < cfloop query = "jsons" > < cfoutput > < cfif #jsons.currentrow # is not "1" > , < /cfif>"#Replace(jsons.col1,"""""","","all")#"</cfoutput> < /cfloop>], function(e) {
                return {
                    value: e,
                    data: {
                        category: "Contacts"
                    }
                }
            }),

            b = $.map([ < cfloop query = "jsons_myteam" > < cfoutput > < cfif #jsons_myteam.currentrow # is not "1" > , < /cfif>"#Replace(jsons_myteam.col1,"""""","","all")#"</cfoutput> < /cfloop>], function(e) {
                return {
                    value: e,
                    data: {
                        category: "Contacts"
                    }
                }
            }),


            j = b;
        i = e.concat(a);


        $("#autocomplete")
            .devbridgeAutocomplete({
                lookup: i,
                minChars: 2,
                width: "300",
                maxheight: "400",
                onSelect: function(event, ui) {
                    $("#submitform").submit();
                },
                showNoSuggestionNotice: !0,
                noSuggestionNotice: "Sorry, no matching results",
                groupBy: "category"

            });

        $("#autocomplete2")
            .devbridgeAutocomplete({
                lookup: j,
                minChars: 2,
                width: "300",
                maxheight: "400",
                onSelect: function(e) {
                    $("#selection")
                        .html("You selected: " + e.value + ", " + e.data.category)
                },
                showNoSuggestionNotice: !0,
                noSuggestionNotice: "Sorry, no matching results",
                groupBy: "Contacts"
            })
