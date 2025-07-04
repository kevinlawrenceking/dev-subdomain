<!--- This ColdFusion page implements an auto lookup field for company names using AJAX to fetch data dynamically. --->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Auto Lookup Field</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

</head>
<body>

    <form>
        <input type="text" id="companySearch" autocomplete="off" />
        <div id="results"></div>
    </form>

    <script>
        $(document).ready(function() {
            <!--- Event listener for input changes in the company search field --->
            $('#companySearch').on('input', function() {
                const searchTerm = $(this).val();
                if (searchTerm.length >= 2) {
                    $.ajax({
                        url: 'CompanyLookup.cfc',
                        data: {
                            method: 'getCompanies',
                            searchTerm: searchTerm,
                            dsn: <Cfoutput>#dsn#</cfoutput>,
                            userid: <Cfoutput>#userid#</cfoutput>
                        },
                        dataType: 'json',
                        success: function(data) {
                            const results = data.DATA;
                            const resultsDiv = $('#results');
                            resultsDiv.empty();
                            resultsDiv.css('display', 'block');

                            if (results.length > 0) {
                                <!--- Loop through the results and display them --->
                                for (let i = 0; i < results.length; i++) {
                                    const coName = results[i][0];
                                    const resultDiv = $('<div>').text(coName);
                                    resultsDiv.append(resultDiv);
                                }
                            } else {
                                <!--- Show option to add a new company if no results found --->
                                const addNewDiv = $('<div>').addClass('add-new').text(`Add new: ${searchTerm}`);
                                resultsDiv.append(addNewDiv);
                            }
                        }
                    });
                } else {
                    $('#results').css('display', 'none');
                }
            });

            <!--- Event listener for selecting a company from the results --->
            $('#results').on('click', 'div', function() {
                const selectedValue = $(this).text();
                if ($(this).hasClass('add-new')) {
         
                    const newCompanyName = selectedValue.replace(/^Add new: /, '');
                    $('#companySearch').val(newCompanyName);
                 
                } else {
                    $('#companySearch').val(selectedValue);
                }
                $('#results').css('display', 'none');
            });
        });
    </script>
</body>
</html>
