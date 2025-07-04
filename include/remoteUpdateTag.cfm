<!--- This ColdFusion page manages the selection and updating of tags for contacts in The Actor's Office. --->

<cfinclude template="/include/qry/tagsContact.cfm" />

<script>
    $("#select-tag").selectize({
        persist: !1,
        createOnBlur: !0,
        create: !0,
        plugins: ["remove-button"],
        delimiter: ",",
        persist: false,
        create: function (input) {
            return {
                value: input,
                text: input,
            };
        },
    });
</script>

<script>
    $('.selectize-input input[type=text]').attr('maxlength', '40');
</script>

<cfinclude template="/include/qry/tags_203_2.cfm" />

<form action="/include/tagchange.cfm"> 
    <cfoutput>
        <input type="hidden" name="userid" value="#userid#" />
        <input type="hidden" name="contactid" value="#contactid#" />
    </cfoutput>

    <div class="row">
        <div class="col-lg-12">
            <center>
                <input name="submit" type="submit" value="Update" class="btn btn-primary editable-submit btn-sm waves-effect waves-light" />
            </center>
        </div>
        <div class="col-lg-12">
            <div class="form-group mb-3">
                <label for="select-tag">Click in the box to select a tag <strong>or</strong> type a new one:</label>
                <select id="select-tag" name="tag" multiple class="demo-default selectize-close-btn w-100" placeholder="Select a tag..." value="Publicist">
                    <option value="">Select a tag...</option>
                    
                    <!--- Loop through the tags query to populate the select options --->
                    <cfloop query="tags">
                        <cfset new_tagname = tags.tagname />
                        <cfinclude template="/include/qry/findt_272_2.cfm" />
                        
                        <cfif #findt.recordcount# is "1">
                            <cfset new_select = "selected" />
                        <cfelse>
                            <cfset new_select = "" />
                        </cfif>
                        <cfoutput>
                            <option value="#tagname#" #new_select#>#tagname#</option>
                        </cfoutput>
                    </cfloop>
                </select>
            </div>
        </div>
    </div>
</form>

<p>Using <strong>tags</strong> is the foundational component of The Actor's Office. Tags allow you to search, group and filter your contacts.</p>
<p>The Actor's Office comes with pre-loaded tags that will be the main ones you will use as an actor and you have the ability to add your own as well.</p>
<p>Your contact will be placed in the appropriate Automated Relationship Reminder System depending on how you tag them. From now on, look at your relationships through the lens of either Casting Directors OR Industry folks. Industry folks are everyone else, writers, producers, directors, etc.</p>

