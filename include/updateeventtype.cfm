<!--- This ColdFusion page is used to update event type details including name and color. --->

<cfinclude template="/include/qry/linkdetails_309_1.cfm" /> 
<cfinclude template="/include/qry/find_events_309_2.cfm" /> 

<form action="/include/updateeventtypeupdate.cfm" method="post" class="needs-validation" validate id="profile-form">
    <cfoutput>
        <input type="hidden" name="eventtypeid" value="#eventtypeid#"  />
        <input type="hidden" name="new_iscustom" value="#linkdetails.iscustom#"  />
    </cfoutput>

    <div class="row">
    
        <!--- Check if the event is not custom --->
        <cfif #linkdetails.iscustom# is "0"> 
            <cfoutput>
                <input type="hidden" name="new_eventtypename" value="#linkdetails.eventtypename#" />
            </cfoutput>
        
  <div class="form-group col-md-6">
    <h5>
        <cfoutput>
            <span class="fc-event-dot" style="background-color:#linkdetails.eventtypecolor#;"></span>&nbsp;#linkdetails.eventtypename#
        </cfoutput>
    </h5>
</div>
        
        <!--- If the event is custom, show input for event name --->
        <cfelse>
            <div class="form-group col-md-12">
                <label for="new_eventtypename">Name:</label>
                <cfoutput>
                    <input class="form-control" type="text" id="new_eventtypename" name="new_eventtypename" value="#linkdetails.eventtypename#" required placeholder="Enter an Event Type" />
                </cfoutput>
                <div class="invalid-feedback">
                    Please enter your Event Type.
                </div>
            </div>
        </cfif>


  <div class="form-group col-md-12">
    <label for="hexa-colorpicker">Color:</label>
    <cfoutput>
        <input type="color" id="hexa-colorpicker_#eventtypeid#" name="new_eventtypecolor" 
            class="form-control" 
            value="#linkdetails.eventtypecolor#" 
            onchange="updatePreview('##preview_#eventtypeid#', this.value)" />

    <div class="invalid-feedback">
        Please enter a color.
    </div>
    <div id="preview_#eventtypeid#" style="margin-top: 10px; font-size: 18px; color:#linkdetails.eventtypecolor#;display:hidden;">
        Color Preview
    </div>
</div>
    </cfoutput>
<script>
    function updatePreview(previewId, colorValue) {
        const previewElement = document.querySelector(previewId);
        if (previewElement) {
            previewElement.style.color = colorValue;
        }
    }
</script>
        <!--- Check if the event is custom and has no associated events --->
        <cfif #linkdetails.isCustom# is "1">
            <cfif #find_events.recordcount# is "0">
                <div class="form-group col-md-12">
                    <div class="custom-control custom-checkbox">
                        <input type="checkbox" class="custom-control-input" id="deletelink" value="1" name="deletelink" />
                        <label class="custom-control-label" for="deletelink">Remove</label>
                    </div>
                </div>
            </cfif>
        </cfif>

        <div class="form-group col-md-12">
            <button class="btn btn-primary editable-submit btn-sm waves-effect waves-light" type="submit" style="background-color: #406e8e; border: #406e8e;">Update</button>
        </div>
    
    </div>
</form>

<script>
    $(function () {
        $('#hexa-colorpicker<cfoutput>_#linkdetails.id#</cfoutput>').colorpicker();
    });
</script>
