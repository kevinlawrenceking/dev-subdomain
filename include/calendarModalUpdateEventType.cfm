<!--- This ColdFusion page generates modals for updating event types based on user data from the eventtypes_user query. --->

<cfloop query="eventtypes_user">
    <!--- Loop through each event type for user and generate modal and script for each. --->
    <cfoutput>
        <script>
            $(document).ready(function() {
                <!--- Attach event handler for showing modal. --->
                $("##updateeventtype_#eventtypes_user.id#").on("show.bs.modal", function(event) {
                    <!--- Load the HTML content into the modal body. --->
                    $(this).find(".modal-body").load("/include/updateeventtype.cfm?eventtypeid=#eventtypes_user.id#&id=#eventtypes_user.id#");
                });
            });
        </script>
    </cfoutput>
    
    <cfoutput>
        <div id="updateeventtype_#eventtypes_user.id#" class="modal fade" tabindex="-1" aria-labelledby="standard-modalLabel" >

            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header" >
                        <h4 class="modal-title" id="standard-modalLabel">#eventtypes_user.eventtypename# Appointment Type Update</h4>
                        <button type="button" class="close" data-bs-dismiss="modal" >

                            <i class="mdi mdi-close-thick"></i>
                        </button>
                    </div>
                    <div class="modal-body">
                    </div>
                </div>
            </div>
        </div>
    </cfoutput>
</cfloop>
