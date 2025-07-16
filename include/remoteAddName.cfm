<!--- This ColdFusion page handles a form for adding a new contact with various fields including name, birthday, meeting date, and pronouns. It includes AJAX functionality for autocomplete on name and company fields. --->
<cfif NOT structKeyExists(application, "dsn")>
    <cfset host = ListFirst(cgi.server_name, ".") />
    <cfif host EQ "app">
        <cfset application.dsn = "abo" />
    <cfelse>
        <cfset application.dsn = "abod" />
    </cfif>
</cfif>
<cfinclude template="/include/qry/pronouns_210_1.cfm" />
<cfinclude template="/include/qry/refers_210_2.cfm" />

<form action="/include/remoteAddNameAdd.cfm" method="post" class="parsley-examples" id="profile-form" 
      data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden" 
      data-parsley-trigger="keyup" 
      data-parsley-validate>

    <div class="row" />

    <div class="form-group col-md-6">
        <label for="contactFullName">Name<span class="text-danger">*</span></label>
        <input class="form-control" type="text" id="contactFullName" name="contactFullName" value="" 
               data-parsley-maxlength="500" 
               data-parsley-maxlength-message="Max length 500 characters" 
               data-parsley-required 
               data-parsley-error-message="Valid Name is required" 
               placeholder="Enter Name" autocomplete="off">

    </div>

    <div class="form-group col-sm-6 mb-6">
        <label for="simpleinput">Next Birthday</label>
        <input class="form-control" id="contactbirthday" value="" type="date" name="contactbirthday" />
    </div>

    <div class="form-group col-sm-6 mb-6">
        <label for="simpleinput">Initial Meeting Date</label>
        <input class="form-control" id="contactmeetingdate" value="" type="date" name="contactmeetingdate" />
    </div>

    <div class="form-group col-sm-6 mb-6">
        <label for="contactmeetingloc">Initial Meeting Location</label>
        <input class="form-control" id="contactmeetingloc" type="text" name="contactmeetingloc" value="" />
    </div>

    <div class="form-group col-sm-6 mb-6">
        <label for="refer_contact_id">Referred By</label>
        <select id="refer_contact_id" name="refer_contact_id" class="form-control w-100">
            <option value="">Select a Relationship</option>
            <cfoutput query="refers">
                <option value="#refers.contactid#">#refers.contactfullname#</option>
            </cfoutput>
        </select>
    </div>

    <div class="form-group col-sm-6 mb-6">
        <label for="contactPronoun">Gender Pronoun</label>
        <select id="contactPronoun" name="contactPronoun" class="form-control" 
                onchange="if (this.value=='custom'){this.form['custom'].style.display='block',this.form['custom'].required=true}else {this.form['custom'].style.display='none',this.form['custom'].required=false};">
            <option value="">Select a Pronoun</option>
            <cfoutput query="pronouns">
                <option value="#pronouns.genderPronoun#">#pronouns.genderPronoun#</option>
            </cfoutput>
            <option value="custom">Custom</option>
        </select>
    </div>

    <div class="form-group col-sm-6 mb-6">
    </div>

    <div class="form-group col-sm-6 mb-6">
        <div class="input-group">
            <input class="form-control" type="text" name="custom" id="custom" style="display:none;" 
                   data-parsley-maxlength="50" 
                   placeholder="Add a Gender Pronoun in single/plural format.">
        </div>
    </div>

<div class="form-group text-end">
    <button class="btn btn-primary btn-sm" type="submit">Add</button>
</div>



</form>

<script>
    $(document).ready(function() {
        $(".parsley-examples").parsley();
    });
</script>

<script>
    $(document).ready(function() {
        function setupAutocomplete(inputId, resultsId, cfcPath, cfcMethod) {
            $(inputId).on('input', function() {
                const searchTerm = $(this).val();
                if (searchTerm.length >= 2) {
                    $.ajax({
                        url: cfcPath,
                        data: {
                            method: cfcMethod,
                            searchTerm: searchTerm,
                            dsn: "<Cfoutput>#dsn#</cfoutput>",
                            userid: "<Cfoutput>#userid#</cfoutput>"
                        },
                        dataType: 'json',
                        success: function(data) {
                            const results = data.DATA;
                            const resultsDiv = $(resultsId);
                            resultsDiv.empty();
                            resultsDiv.css('display', 'block');

                            if (results.length > 0) {
                                for (let i = 0; i < results.length; i++) {
                                    const value = results[i][0];
                                    const resultDiv = $('<div>').text(value);
                                    resultsDiv.append(resultDiv);
                                }
                            } else {
                                const addNewDiv = $('<div>').addClass('add-new').text(`Add new: ${searchTerm}`);
                                resultsDiv.append(addNewDiv);
                            }
                        }
                    });
                } else {
                    $(resultsId).css('display', 'none');
                }
            });

            $(resultsId).on('click', 'div', function() {
                const selectedValue = $(this).text();
                if ($(this).hasClass('add-new')) {
                    const newValue = selectedValue.replace(/^Add new: /, '');
                    $(inputId).val(newValue);
                } else {
                    $(inputId).val(selectedValue);
                }
                $(resultsId).css('display', 'none');
            });
        }

        setupAutocomplete('#companySearch', '#results', '/include/CompanyLookup.cfc', 'getCompanies');
        setupAutocomplete('#contactFullName', '#nameResults', '/include/FullNameLookup.cfc', 'getFullNames');

        $('#contactFullName').on('keydown', function(event) {
            if (event.key === 'Enter' || event.keyCode === 13) {
                event.preventDefault();
                const selectedValue = $(this).val();
                $(this).val(selectedValue);
                $('#nameResults').css('display', 'none');
            }
        });
    });
</script>

<cfset script_name_include="/include/#ListLast(GetCurrentTemplatePath(), " \")#" />
