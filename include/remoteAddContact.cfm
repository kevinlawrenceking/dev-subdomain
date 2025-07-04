<!--- This ColdFusion page is used to create a form for adding a new contact with associated tags. --->

<cfparam name="tagtypes" default="team" /> 

<cfinclude template="/include/qry/tags_200_1.cfm" />

<form action="/include/remoteAddContactAdd.cfm" method="post" class="needs-validation" id="profile-form">
    <cfoutput>
        <input type="hidden" name="new_tag" value="My Team" />
        <input type="hidden" name="userid" value="#userid#" />
        <input type="hidden" name="src" value="#src#" />
    </cfoutput>

    <div class="row">
        <!--- Form Group for Contact Full Name --->
        <div class="form-group col-md-6">
            <label for="contactFullName">Name:</label>
            <input class="form-control" type="text" id="contactfullname" name="contactfullname" required placeholder="Enter Name" />
        </div>

        <!--- Form Group for Company --->
        <div class="form-group required col-md-6">
            <label for="company">Company:</label>
            <input class="form-control" type="text" id="company" name="company" placeholder="Add Company" />
        </div>

        <!--- Form Group for Tag Selection --->
        <div class="form-group col-sm-6 mb-6">
            <label for="tag">Tag</label>
            <select id="new_tag" name="new_tag" required class="form-control">
                <option value="">Select a type</option>
                <cfloop query="tags">
                    <cfoutput>
                        <option value="#tags.tagname#">#tags.tagname#</option>
                    </cfoutput>
                </cfloop>
            </select>
        </div>

        <!--- Form Group for Work Phone --->
        <div class="form-group col-md-6">
            <label for="workphone">Phone:</label>
            <input class="form-control" type="text" id="workphone" name="workphone" data-parsley-phone placeholder="Enter Work Phone" />
            <div class="invalid-feedback">
                Please add work phone.
            </div>
        </div>

        <!--- Form Group for Work Email --->
        <div class="form-group col-md-6">
            <label for="workemail">Email:</label>
            <input class="form-control" type="text" id="workemail" name="workemail" placeholder="Enter Email" />
        </div>
    </div>

    <!--- Submit Button --->
    <div class="form-group text-center col-md-12">
        <p>
            <button class="btn btn-primary editable-submit btn-sm waves-effect waves-light" type="submit" style="background-color: #406e8e; border: #406e8e;">Add</button>
        </p>
    </div>
</form>

<script>
Parsley.addValidator('phone', {
  requirementType: 'string',
  validateString: function(value) {
    // This regex allows various international formats:
    // Digits, spaces, plus sign, parentheses, and dashes
    return /^[0-9\+\-\(\)\s]+$/.test(value);
  },
  messages: {
    en: 'Please enter a valid phone number.'
  }
});
</script>
