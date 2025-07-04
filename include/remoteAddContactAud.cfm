<!--- 
***********************************************
** Page Title: Add Contact to Audition modal
** Author: Kevin King
** Creation Date:
** Last Modification Date:
** Description: Modal pop-up from the audition.cfm page Relationships tab. Fired when add link is pressed to add a relationship to an audition.
** 
** Change Log:
***********************************************
--->

<!--- Define the style for the hidden div --->

<!--- Include the file for remote loading --->
<cfinclude template="/include/qry/events_203_1.cfm" />

<!--- Query to fetch tags based on user id --->
<cfinclude template="/include/qry/tags_203_2.cfm" />

<!--- Query to fetch companies based on user id --->
<cfinclude template="/include/qry/companies_203_3.cfm" />

<!--- Start of the form --->
<form action="/include/remoteAddContactAddaud.cfm" method="post" class="needs-validation" id="profile-form">

    <!--- Hidden inputs for the form --->
    <cfoutput>
        <input type="hidden" name="audprojectid" value="#audprojectid#" />
        <input type="hidden" name="userid" value="#userid#" />
        <input type="hidden" name="src" value="#src#" />
    </cfoutput>

    <div class="row">

        <!--- Input field for the name --->
        <div class="form-group col-md-6">
            <label for="contactfullname">Name:</label>
            <input class="form-control" type="text" id="contactfullname" name="contactfullname" required placeholder="Enter Name" />
        </div>

        <!--- Dropdown for tags --->
        <div class="form-group col-md-6">
            <label for="tag">Tag</label>
            <select id="new_tag" name="new_tag" required class="form-control">
                <option value="">Select a tag</option>
                <cfloop query="tags">
                    <cfoutput>
                        <option value="#tags.tagname#">#tags.tagname#</option>
                    </cfoutput>
                </cfloop>
            </select>
        </div>

        <!--- Dropdown for companies --->
        <div class="form-group col-sm-6 md-6">
            <label for="company">Company<span class="text-danger">*</span></label>
            <select id="company" name="company" class="form-control" onchange="showDiv('hidden_div', this)">
                <option value=""></option>
                <option value="Custom">***ADD NEW***</option>
                <cfoutput query="companies">
                    <option value="#companies.new_valuecompany#">#companies.new_valuecompany# </option>
                </cfoutput>
            </select>
        </div>

        <!--- Input field for custom company name --->
        <div class="form-group col-sm-6 md-6">
            <div id="hidden_div">
                <label for="company_new">Custom Company<span class="text-danger">*</span></label>
                <input class="form-control" type="text" id="company_new" name="company_new" value="" placeholder="Enter Company" />
            </div>
        </div>

        <!--- Input field for work phone --->
        <div class="form-group col-md-6">
            <label for="workphone">Phone:</label>
            <input class="form-control" type="text" id="workphone" name="workphone" placeholder="Enter Work Phone" />
            <div class="invalid-feedback">
                Please add work phone.
            </div>
        </div>

        <!--- Input field for work email --->
        <div class="form-group col-md-6">
            <label for="workemail">Email:</label>
            <input class="form-control" type="text" id="workemail" name="workemail" placeholder="Enter Email" />
        </div>

        <!--- Closing div for form group --->
        </div>
        <div class="form-group col-md-12">
            <p>This contact will be added to the audition project.</p>
        </div>

        <!--- Check if events exist --->
        <cfif #events.recordcount# is not "0">
            <div class="form-group col-md-12">
                <div class="row">
                    <div class="col-md-4 py-2">
                        <cfif events.recordcount gte 2>
                            Check to add to specific appointment(s):
                        <cfelseif events.recordcount eq 1 >
                            Check to add to appointment:
                        </cfif>
                    </div>
                    <div class="col-md-4 py-2">
                        <div class="form-group">
                            <cfoutput query="events">
                                <div>
                                    <input type="checkbox" name="events_list" value="#events.eventid#" id="event#events.eventid#" />
                                    <label for="event#events.eventid#">#this.formatDate(events.eventStart)#</label>
                                </div>
                            </cfoutput>
                        </div>
                    </div>
                </div>
            </div>
        <cfelse>
            <input type="hidden" name="events_list" value="" />
        </cfif>

        <!--- Submit button for the form --->
        <div class="form-group text-center col-md-12">
            <p>
                <button class="btn btn-primary editable-submit btn-sm waves-effect waves-light" type="submit" style="background-color: #406e8e; border: #406e8e;">Add</button>
            </p>
        </div>

        <!--- Closing div for form --->
    </div>
</form>

<!--- JavaScript function to show div based on select field value --->
<script>
    function showDiv(divId, element) {
        document.getElementById(divId).style.display = element.value == "Custom" ? 'block' : 'none';
    }
</script>

<!--- Setting script name include variable --->
<cfset script_name_include="/include/#ListLast(GetCurrentTemplatePath(), " \")#" />

<!--- Including the big brother file --->
