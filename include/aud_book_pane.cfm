<!--- This ColdFusion page handles the display of media types and booking details, including modals for adding and updating bookings. --->

<div class="row">
    
    <!--- Include the types query template --->
    <cfinclude template="/include/qry/SEL_Media_types_material.cfm" />
    
    <!--- Loop through each type to create modals for media uploads --->
    <cfloop query="types">
        <cfoutput>
            <script>
                $(document).ready(function() {
                    $("##remoteadd#types.mediatypeid#").on("show.bs.modal", function(event) {
                        
                        $(this).find(".modal-body").load("/include/remotaudmatadd.cfm?eventid=#eventid#&audprojectid=#audprojectid#&mediatypeid=#types.mediatypeid#&secid=177");
                    });
                });
            </script>

            <div id="remoteadd#types.mediatypeid#" class="modal fade" tabindex="-1" aria-labelledby="standard-modalLabel" >

                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header" >
                            <h4 class="modal-title" id="standard-modalLabel">Upload Media</h4>
                            <button type="button" class="close" data-bs-dismiss="modal" >
<i class="mdi mdi-close-thick"></i></button>
                        </div>
                        <div class="modal-body">
                        </div>
                    </div>
                </div>
            </div>
        </cfoutput>
    </cfloop>

    <!--- Check if the role is not booked --->
    <cfif #roledetails.isbooked# is "0">
        <div class="col-md-12 col-lg-12 col-xl-12 p-1 text-nowrap">
            <cfoutput>
                <a href="/include/booked.cfm?audprojectid=#audprojectid#&eventid=#eventid#&secid=181&audroleid=#audroleid#" class="btn btn-success waves-effect waves-light">I Booked It!</a>
            </cfoutput>
        </div>
    </cfif>

    <!--- Check if the role is booked --->
    <cfif #roledetails.isbooked# is "1">
        <cfoutput>
            <script>
                $(document).ready(function() {
                    $("##bookupdate").on("show.bs.modal", function(event) {
                        
                        $(this).find(".modal-body").load("/include/bookupdateform.cfm?secid=<cfoutput>#secid#</cfoutput>&audprojectid=<cfoutput>#audprojectid#</cfoutput>&focusid=<cfoutput>#focusid#</cfoutput>&eventid=<cfoutput>#eventid#&audroleid=#audroleid#</cfoutput>&pgdir=audition");
                    });
                });
            </script>
            <div id="bookupdate" class="modal fade" tabindex="-1" aria-labelledby="standard-modalLabel" >

                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header" >
                            <h4 class="modal-title" id="standard-modalLabel">Booking Update</h4>
                            <button type="button" class="close" data-bs-dismiss="modal" >
<i class="mdi mdi-close-thick"></i></button>
                        </div>
                        <div class="modal-body">
                        </div>
                    </div>
                </div>
            </div>
        </cfoutput>

        <!--- Script for adding audition --->
        <script>
            $(document).ready(function() {
                $("#auditionadd").on("show.bs.modal", function(event) {
                    
                    $(this).find(".modal-body").load("/include/remoteaudaddform.cfm?new_audprojectid=<cfoutput>#audprojectid#</cfoutput>&new_audstepid=4&secid=181&audroleid=<cfoutput>#audroleid#</cfoutput>&pgdir=audition");
                });
            });
        </script>
        
        <div id="auditionadd" class="modal fade" tabindex="-1" aria-labelledby="standard-modalLabel" >

            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header" >
                        <h4 class="modal-title" id="standard-modalLabel">Booking Appointment Add</h4>
                        <button type="button" class="close" data-bs-dismiss="modal" >
<i class="mdi mdi-close-thick"></i></button>
                    </div>
                    <div class="modal-body">
                    </div>
                </div>
            </div>
        </div>

        <h4 class="p-1 d-flex">Booking Details
            <span class="ms-auto text-muted">
                <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="#bookupdate" data-bs-placement="top" title="Update Booking" data-bs-original-title="Update Booking">
                    <i class="mdi mdi-square-edit-outline"></i>
                </a>
            </span>
        </h4>

<cfoutput>
            <div class="col-md-12 col-lg-6 col-xl-4 p-1 text-nowrap"><strong>Income Type: </strong>#roledetails.incometype#</div>
            <div class="col-md-12 col-lg-6 col-xl-4 p-1 text-nowrap"><strong>Payrate/Session fee: </strong>#dollarformat(roledetails.payrate)#
                <cfif #roledetails.paycycleid# is not ""> (#roledetails.paycyclename#)</cfif>
            </div>

            <!--- Check if income type is W2 --->
            <cfif #roledetails.incometype# is "w2">
                <div class="col-md-12 col-lg-6 col-xl-4 p-1 text-nowrap"><strong>Net income: </strong>#dollarformat(roledetails.netincome)#</div>
            </cfif>

            <!--- Check if the project category is Commercial --->
            <cfif #projectDetails.audcatname# is "Commercial">
                <div class="col-md-12 col-lg-6 col-xl-4 p-1 text-nowrap"><strong>Buyout: </strong>#dollarformat(roledetails.buyout)#</div>
            </cfif>
        </cfoutput>
    </cfif>
</div>
