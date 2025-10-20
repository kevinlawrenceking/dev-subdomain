 <script>
$(document).ready(function() {
    function setupAutocomplete(inputSelector, resultContainerSelector, cfcFile, remoteMethod) {
        $(inputSelector).on('input', function() {
            const searchTerm = $(this).val();
            if (searchTerm.length >= 2) {
                $.ajax({
                    url: cfcFile,
                    data: {
                        method: remoteMethod,
                        searchTerm: searchTerm,
                        dsn: "<Cfoutput>#application.dsn#</cfoutput>",
                        userid: "<Cfoutput>#userid#</cfoutput>"
                    },
                    dataType: 'json',
                    success: function(data) {
                        const results = data.DATA;
                        const resultsDiv = $(resultContainerSelector);
                        resultsDiv.empty();
                        resultsDiv.css('display', 'block');
        
                        for (let i = 0; i < results.length; i++) {
                            const resultValue = results[i][0];
                            const resultDiv = $('<div class="autocomplete-suggestion">').text(resultValue);
                            resultsDiv.append(resultDiv);
                        }
                    }
                });
            } else {
                $(resultContainerSelector).css('display', 'none');
            }
        });

        $(resultContainerSelector).on('click', 'div.autocomplete-suggestion', function() {
            const selectedValue = $(this).text();
            $(inputSelector).val(selectedValue);
            $(resultContainerSelector).css('display', 'none');
        });
    }

    setupAutocomplete('#companySearch', '#results', '/include/CompanyLookup.cfc', 'getCompanies');
    setupAutocomplete('#contactFullName', '#nameResults', '/include/FullNameLookup.cfc', 'getFullNames');

$('#contactFullName, #new_audrolename').on('keydown', function(e) {
        if (e.keyCode == 13) {
            e.preventDefault();
            $(this).blur();
            return false;
        }
    });
});

        </script>
