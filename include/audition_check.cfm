<!--- This ColdFusion page handles access control for the audition module and manages follow-up actions. --->

<cfparam name="isnew" default="0" />

<!--- Check if the user has access to the audition module --->
<cfif #isAuditionModule# is not "1">
    <h5>You do not have access to the audition module.</h5>
    
    <form>
        <input type="button" value="Go back!" onclick="history.back()" />
    </form>
    <cfabort>
</cfif>

<!--- Include the query that updates events based on audition project. TRIGGER ADDED.
cfinclude template= /include/qry/uu_33_1.cfm    --->

<!--- Check if the record is new --->
<cfif isnew eq 1>
    
    <!--- Include follow-up queries --->
    <cfinclude template="/include/qry/folowup_body.cfm" />
    
    <!--- Check if there is exactly one follow-up record --->
    <cfif followup_contactid neq 0>

<cfoutput>
                <script>
                    $(document).ready(function() {
                  
                        $("##follow").on("show.bs.modal", function(event) {
                            $(this).find(".modal-body").load("/include/folowup_body.cfm?followup_contactid=#followup_contactid#");
                        });
                        $("##follow").modal('show');
                    });
                </script>
            </cfoutput>

<!--- Modal for adding follow-up system --->
        <div id="follow" class="modal fade" tabindex="-1" role="dialog" >
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h4 class="modal-title">
                            <cfoutput>Add Follow Up System</cfoutput>
                        </h4>
                        <button type="button" class="close" data-bs-dismiss="modal">
                            <i class="mdi mdi-close-thick"></i>
                        </button>
                    </div>
                    <div class="modal-body">
                    </div>
                </div>
            </div>
        </div>
    </cfif>
</cfif>

<!--- Include the query for adding missing records --->
<cfinclude template="/include/qry/addmissing_33_3.cfm" />
