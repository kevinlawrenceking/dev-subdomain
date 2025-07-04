<!--- This ColdFusion page is a version update form that allows users to update version details such as major, minor, patch, and build numbers, as well as review and release dates and times. --->

<script>
  $(document).ready(function () {
    $("#select-relationship").selectize({
      persist: !1,
      createOnBlur: !0,
      create: !0,
      plugins: ["remove-button"],
      delimiter: ",",
      persist: false,
      create: function (input) {
        return {value: input, text: input};
      }
    });
  });
</script>

<div class="row">
  <div class="col-xl-6 col-lg-8 col-md-12">
    <div class="card mb-3">
      <div class="card-body">
        <!--- Form for updating version details --->
        <form method="post" action="/include/version-update2.cfm" class="parsley-examples" name="version-form" id="form-version" data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden" data-parsley-trigger="keyup" data-parsley-validate="data-parsley-validate">
          <h5>Version Update Form</h5>

          <cfoutput>
            <input type="hidden" name="verid" value="#details.verid#" />
            </cfoutput>

            <div class="row">
              <div class="col-md-2">
                <div class="form-group">
                  <label class="control-label">Major
                    <span class="text-danger">*</span>
                  </label>
                  <select class="form-control" name="new_major" id="new_major" required="required">
                    <cfloop index="m" from="0" to="99">
                      <cfoutput>
                        <option value="#m#" <cfif "#m#" is "#details.major#">selected</cfif>>#m#</option>
                      </cfoutput>
                    </cfloop>
                  </select>
                </div>
              </div>

              <div class="col-md-2">
                <div class="form-group">
                  <label class="control-label">Minor
                    <span class="text-danger">*</span>
                  </label>
                  <select class="form-control" name="new_minor" id="new_minor" required="required">
                    <cfloop index="mi" from="0" to="99">
                      <cfoutput>
                        <option value="#mi#" <cfif #mi# is "#details.minor#">selected</cfif>>#mi#</option>
                      </cfoutput>
                    </cfloop>
                  </select>
                </div>
              </div>

              <div class="col-md-2">
                <div class="form-group">
                  <label class="control-label">Patch
                    <span class="text-danger">*</span>
                  </label>
                  <select class="form-control" name="new_patch" id="new_patch" required="required">
                    <cfloop index="p" from="0" to="99">
                      <cfoutput>
                        <option value="#p#" <cfif #p# is "#details.patch#">selected</cfif>>#p#</option>
                      </cfoutput>
                    </cfloop>
                  </select>
                </div>
              </div>

              <div class="col-md-2">
                <div class="form-group">
                  <label class="control-label">Version
                    <span class="text-danger">*</span>
                  </label>
                  <select class="form-control" name="new_version" id="new_version" required="required">
                    <cfloop index="v" from="0" to="99">
                      <cfoutput>
                        <option value="#v#" <cfif #v# is "#details.version#">selected</cfif>>#v#</option>
                      </cfoutput>
                    </cfloop>
                  </select>
                </div>
              </div>

              <div class="col-md-2">
                <div class="form-group">
                  <label class="control-label">Build
                    <span class="text-danger">*</span>
                  </label>
                  <select class="form-control" name="new_build" id="new_build" required="required">
                    <cfloop index="b" from="0" to="99">
                      <cfoutput>
                        <option value="#b#" <cfif #b# is "#details.build#">selected</cfif>>#b#</option>
                      </cfoutput>
                    </cfloop>
                  </select>
                </div>
              </div>
            </div>

            <div class="row">
              <div class="col-md-4">
                <div class="form-group">
                  <label for="tickettype">Status
                    <span class="text-danger">*</span>
                  </label>
                  <select class="form-control" name="new_versionstatus" id="new_versionstatus" required="required">
                    <cfoutput query="statuses">
                      <option value="#statuses.id#" <cfif #statuses.id# is "#details.versionstatus#">selected</cfif>>#statuses.name#</option>
                    </cfoutput>
                  </select>
                </div>
              </div>

              <div class="col-md-4">
                <div class="form-group">
                  <label for="tickettype">Type
                    <span class="text-danger">*</span>
                  </label>
                  <select class="form-control" name="new_versiontype" id="new_versionstatus" required="required">
                    <option value="Feature" <cfif #details.versiontype# is "Feature">selected</cfif>>Feature</option>
                    <option value="Patch" <cfif #details.versiontype# is "Patch">selected</cfif>>Patch</option>
                  </select>
                </div>
              </div>

              <cfoutput>
                <div class="col-md-4">
                  <div class="form-group">
                    <label class="control-label">Hours Available</label>
                    <input class="form-control" placeholder="Add Hours Available" value="#numberformat(details.hoursavail)#" type="number" name="new_hoursavail" id="new_hoursavail" /></div>
                  </div>
                </cfoutput>
              </div>

              <cfoutput>
                <div class="row">
                  <div class="col-md-6">
                    <div class="form-group">
                      <label for="eventStart">Review Date</label>
                      <input class="form-control" id="reviewDate" value="#dateFormat(details.reviewDate, 'yyyy-mm-dd')#" name="new_reviewDate" type="date" />
                        <div class="invalid-feedback">
                          Please choose a Review Date.
                        </div>
                      </div>
                    </div>

<div class="col-md-6">
                    <div class="form-group">
                      <label for="eventStartTime">Review Time</label>
                      <input id="reviewtime" class="form-control" value="#timeformat(details.reviewtime, 'hh:mm')#" name="new_reviewtime" type="time" />
                        <div class="invalid-feedback">
                          Please choose a Review Time.
                        </div>
                      </div>
                    </div>
                  </div>

                  <div class="row">
                    <div class="col-md-6">
                      <div class="form-group">
                        <label for="eventStart">Release Date</label>
                        <input class="form-control" id="releaseDate" value="#dateFormat(details.releaseDate, 'yyyy-mm-dd')#" name="new_releaseDate" type="date" />
                          <div class="invalid-feedback">
                            Please choose a Release Date.
                          </div>
                        </div>
                      </div>

<div class="col-md-6">
                      <div class="form-group">
                        <label for="eventStartTime">Release Time</label>
                        <input id="releasetime" class="form-control" value="#timeformat(details.releasetime, 'hh:mm')#" name="new_releasetime" type="time" />
                          <div class="invalid-feedback">
                            Please choose a Release Time.
                          </div>
                        </div>
                      </div>
                    </div>

                  </cfoutput>

                  <div class="row mt-2">
                    <div class="col-6">
                      <!--- Empty Column for Alignment --->
                    </div>
                    <div class="col-6 text-right">
                      <a href="javascript:history.go(-1)">
                        <button type="button" class="btn btn-light mr-1 btn-sm">Back</button>
                      </a>
                      <button type="submit" class="btn btn-primary btn-sm waves-effect waves-light" id="btn-save-event">Update</button>
                    </div>
                  </div>
                </form>
              </div>
            </div>
          </div>
        </div>

        <script>
          $(document).ready(function () {
            $(".form-ticket").parsley()
          });
        </script>

        <script>
          $('#reviewtime').timepicker();
          $('#releasetime').timepicker();
          $('#reviewDate').datepicker({
            autoclose: true,
            beforeShow: function (input, inst) {
              setTimeout(function () {
                inst
                  .dpDiv
                  .css({top: 100, left: 200});
              }, 0);
            }
          });

          $('#releaseDate').datepicker({autoclose: true, top: 10, left: 10});
        </script>
