<cfparam name="contact_expand" default="true" />
<cfparam name="a" default="0" />
<cfparam name="d" default="0" />
<cfparam name="s" default="0" />

<cfparam name="contactcheckvisible" default="false" />
<cfparam name="maintenance_expand" default="false" />
<cfparam name="bytag" default="" />
<cfparam name="byimport" default="" />
<cfparam name="target_expand" default="false" />
<cfparam name="followup_expand" default="false" />
<cfparam name="all_expand" default="false" />
<cfparam name="pgaction" default="view" />

<cfif NOT #isdefined('session.pgaction')#>
    <cfset session.pgaction="view">
</cfif>

<cfinclude template="/include/qry/lastupdates.cfm" />

<script>
    $(document).ready(function() {
        $("#remoteAddName").on("show.bs.modal", function(event) {
            
            $(this).find(".modal-body").load("/include/remoteAddName.cfm");
        });
    });
</script>

<div id="remoteAddName" class="modal fade" tabindex="-1" role="dialog" >


    <div class="modal-dialog">

        <div class="modal-content">

            <div class="modal-header">

                <h4 class="modal-title">Add A Relationship</h4>

                <button type="button" class="close" data-bs-dismiss="modal" >
<i class="mdi mdi-close-thick"></i></button>

            </div>

            <div class="modal-body">

            </div>

        </div>

    </div>

</div>

<cfif #session.pgaction# is "bulk">
  <cfset session.pgaction="view" />
    <script>
        $(document).ready(function() {
            $("#bulkModal").modal('show');
        });
    </script>

    <script>
        var table = $("#contacts_ss");
        var btn = $('#btnSelectedRows');

        function enableBtn() {
            btn.prop("disabled", table.find("input:checked").length === 0)
        }

        table.on("change", "input", enableBtn);
        enableBtn();
    </script>

<div id="bulkModal" class="modal fade">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Selected Updated Summary</h5>
                    <button type="button" class="close" data-bs-dismiss="modal" >
<i class="mdi mdi-close-thick"></i></button>
                </div>
                <div class="modal-body">
                    <cfif #a# is not "0">
                     <p>
                        <cfoutput>#a# #bt#<cfif #a# is not "1">s</cfif> added.</cfoutput>
                    </p>
                    </cfif>
                    <cfif #d# is not "0">
                     <p>
                        <cfoutput>#d# #bt#<cfif #d# is not "1">s</cfif> removed.</cfoutput>
                    </p>
                    </cfif>
                    <cfif #s# is not "0">
                    <p>
                        <cfoutput>#s# relationship<cfif #s# is not "1">s</cfif> skipped.</cfoutput>
                    </p>
                    </cfif>

<div class="form-group text-center col-md-12">
                        <A href="/app/contacts/" >
             <button class=" btn btn-primary  btn-sm waves-effect waves-light" type="button" style="background-color: #406e8e; border: #406e8e;">Continue</button></A>
         </div>

</div>
            </div>
        </div>
    </div>

<cfelse>
         <script>
        $(document).ready(function() {
            $("#bulkModal").modal('hide');
        });
    </script>
</cfif>

<div class="row">

    <div class="col-lg-12">

        <div class="card mb-3">

            <div class="card-body">    
                      <cfif #bytag# is not "">
                    <cfoutput>
                       <div class="container"> <cfset bytag="#bytag#"><A HREF="/app/contacts/"> <span class="badge badge-blue">#bytag# X</span></A></div>
                    </cfoutput>
                </cfif>
                          
                                     <cfif #byimport# is not "">
                    <cfoutput>
                       <div class="container"> <cfset byimport="#byimport#"><A HREF="/app/contacts/"> <span class="badge badge-blue">Import ###byimport# X</span></A></div>
                    </cfoutput>
                </cfif>

<div class="container responsive-tabs">
        <ul class="nav nav-pills navtab-bg nav-justified p-1" role="tablist">
            
            <li class="nav-item">
                <a id="tab-A" href="#contacts" class="nav-link <cfif #contact_expand# is 'true'> active</cfif>" data-bs-toggle="tab" role="tab">All Relationships</a>
            </li>
            
            <li class="nav-item">
                <a id="tab-B" href="#target" class="nav-link <cfif #target_expand# is 'true'> active</cfif>" data-bs-toggle="tab" role="tab">Targeted List</a>
            </li>
            
            <li class="nav-item">
                <a id="tab-C" href="#followup" class="nav-link <cfif #followup_expand# is 'true'> active</cfif>" data-bs-toggle="tab" role="tab">Follow-Up List</a>
            </li>
            
            <li class="nav-item">
                <a id="tab-D" href="#maintenance" class="nav-link <cfif #maintenance_expand# is 'true'> active</cfif>" data-bs-toggle="tab" role="tab">Maintenance List</a>
            </li>
            
        </ul>

<div id="content" class="tab-content" role="tablist">
            <div id="contacts" class="card tab-pane fade<cfif #contact_expand# is 'true'> show active</cfif>" role="tabpanel" aria-labelledby="tab-A">
                <div class="card-header" role="tab" id="heading-A">
                    <h5 class="mb-0">
                        <a data-bs-toggle="collapse" href="#collapse-A" aria-expanded="<cfoutput>#contact_expand#</cfoutput>" aria-controls="collapse-A">
                            All Relationships
                        </a>
                    </h5>
                </div>
                <div id="collapse-A" class="collapse show" data-bs-parent="#content" role="tabpanel" aria-labelledby="heading-A">
                    <div class="card-body">
                        <cfset contacts_table="contacts_ss" />
                        <cfinclude template="/include/contacts_table.cfm" />
                    </div>
                </div>
            </div>

            <div id="target" class="card tab-pane fade<cfif #target_expand# is 'true'> show active</cfif>" role="tabpanel" aria-labelledby="tab-B">
                <div class="card-header" role="tab" id="heading-B">
                    <h5 class="mb-0">
                        <a class="collapsed" data-bs-toggle="collapse" href="#collapse-B" aria-expanded="<cfoutput>#target_expand#</cfoutput>" aria-controls="collapse-B">
                            Targeted List
                        </a>
                    </h5>
                </div>
                <div id="collapse-B" class="collapse" data-bs-parent="#content" role="tabpanel" aria-labelledby="heading-B">
                    <div class="card-body" id="targettest">
                        <cfset contacts_table="contacts_ss_target" />
                        <cfinclude template="/include/contacts_table.cfm" />
                    </div>
                </div>
            </div>

            <div id="followup" class="card tab-pane fade<cfif #followup_expand# is 'true'> show active</cfif>" role="tabpanel" aria-labelledby="tab-C">
                <div class="card-header" role="tab" id="heading-C">
                    <h5 class="mb-0">
                        <a data-bs-toggle="collapse" href="#collapse-C" aria-expanded="<cfoutput>#followup_expand#</cfoutput>" aria-controls="collapse-C">
                            Follow-Up List
                        </a>
                    </h5>
                </div>
                <div id="collapse-C" class="collapse" data-bs-parent="#content" role="tabpanel"
                    aria-labelledby="heading-C">
                              <div class="card-body">       
                        <cfset contacts_table="contacts_ss_followup" />

                        <cfinclude template="/include/contacts_table.cfm" />
                    </div>
                </div>
            </div>
            
                     <div id="maintenance" class="card tab-pane fade<cfif #maintenance_expand# is 'true'> show active</cfif>" role="tabpanel" aria-labelledby="tab-D">
                <div class="card-header" role="tab" id="heading-D">
                    <h5 class="mb-0">
                        <a data-bs-toggle="collapse" href="#collapse-D" aria-expanded="<cfoutput>#maintenance_expand#</cfoutput>" aria-controls="collapse-D">
                            Maintenance List
                        </a>
                    </h5>
                </div>
                <div id="collapse-D" class="collapse" data-bs-parent="#content" role="tabpanel"
                    aria-labelledby="heading-D">
                              <div class="card-body">       
                        <cfset contacts_table="contacts_ss_maint" />

                        <cfinclude template="/include/contacts_table.cfm" />
                    </div>
                </div>
            </div>
        </div>
    </div>

                <cfif #bytag# is not "">
                    <cfoutput>
                        <cfset bytag="#bytag#"><A HREF="/app/contacts/"> <span class="badge badge-blue">#bytag# X</span></A>
                    </cfoutput>
                </cfif>

</div>

        </div>

    </div>

    </div>

</div> 

<cfquery name="tags">
    SELECT tagid,tagname FROM tags_user where userid = #userid# order by tagname
</cfquery>

<div class="modal fade" id="exampleModal2" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel2" >

    <div class="modal-dialog modal-dialog-slideout modal-sm" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="exampleModalLabel">Tag Selector</h5>
                <button type="button" class="close" data-bs-dismiss="modal" aria-label="Close">
                    <span >
X</span>
                </button>
            </div>
            <div class="modal-body">
                <div class="row">
                    <Cfoutput query="tags">
                        <div class="col-md-6">
                            <A HREF="/app/contacts?bytag=#tagname#"> <span class="badge badge-blue">#tagname#</span></A>
                        </div>
                    </Cfoutput>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>

<cfinclude template="/include/qry/imports.cfm" />

<div class="modal fade" id="exampleModal22" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel2" >

    <div class="modal-dialog modal-dialog-slideout modal-sm" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="exampleModalLabel">Import History</h5>
                <button type="button" class="close" data-bs-dismiss="modal" aria-label="Close">
                    <span >
X</span>
                </button>
            </div>
            <div class="modal-body">
             
                    <Cfoutput query="imports">   <div class="row">
                        <div class="col-md-12">
                            <A HREF="/app/contacts/?byimport=#imports.uploadid#"> <span class="badge badge-blue">#dateTimeFormat(imports.timestamp, "d-m-yyyy h:nn tt")# (#imports.total_adds# record<cfif #imports.recordcount# is not "1">s</cfif>)</span></A><p style="line-height:6px;">&nbsp;</p>
                        </div>  </div>
                    </Cfoutput>
              
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>

<div id="exampleModal5" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="standard-modalLabel" >

    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title" id="standard-modalLabel">Export Contacts</h4>
                <button type="button" class="close" data-bs-dismiss="modal" >
<i class="mdi mdi-close-thick"></i></button>
            </div>
            
<div class="modal-body">

  <form  method="post" class="parsley-examples demo-default selectize-close-btn" 
 data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden" data-parsley-trigger="keyup" data-parsley-validate="" novalidate="" id="myformexport" name="myformexport" action="/include/exportcontacts.cfm" method="POST" >
   
     <div class="form-group col-md-12">
         <label for="valuetext">Export all selected relationships</label>
     </div>

<div class="form-group text-center col-md-12">

                        <button class="btn btn-primary editable-submit btn-sm waves-effect waves-light" type="submit" style="background-color: #406e8e; border: #406e8e;">Export</button>

                    </div>

<input type="hidden" name="idlist" value="">
</form>

</div>
        </div>
    </div>
</div><!--- xxx --->

<script>
$(document).ready(function() {
  $('#myformexport').on('submit', function(e) {
    e.preventDefault(); // Prevents the default form submit action
    console.log('Form submitted'); // Debug line

    // Your AJAX code here

    $('#exampleModal5').modal('hide');
    
    if ($('#exampleModal5').hasClass('show')) {
      console.log('Modal did not close');
    } else {
      console.log('Modal closed');
    }
  });
});

</script>

<div id="exampleModaldelete" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="standard-modalLabel" >

    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header" style="background-color: red";>
                <h4 class="modal-title" id="standard-modalLabel">Delete Contacts</h4>
                <button type="button" class="close" data-bs-dismiss="modal" >
<i class="mdi mdi-close-thick"></i></button>
            </div>
            
<div class="modal-body">

 <form  method="post" class="parsley-examples demo-default selectize-close-btn" data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden" data-parsley-trigger="keyup" data-parsley-validate="" novalidate="" id="myformdelete" name="myformdelete" action="/include/deletecontacts.cfm" method="POST" >
   
     <div class="form-group col-md-12">
         <label for="valuetext">Delete all selected relationships</label>
     </div>

<div class="form-group text-center col-md-12">

                        <button class="btn btn-red editable-submit btn-sm waves-effect waves-light" type="submit" style="background-color: red; border: #406e8e;">Delete</button>

                    </div>

<input type="hidden" name="idlist" value="">
</form>

</div>
        </div>
    </div>
</div><!--- xxx --->

<div id="exampleModal99" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="standard-modalLabel" >

    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title" id="standard-modalLabel">System Delete</h4>
                <button type="button" class="close" data-bs-dismiss="modal" >
<i class="mdi mdi-close-thick"></i></button>
            </div>
            
<div class="modal-body">

               <form method="post" class="parsley-examples demo-default selectize-close-btn" data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden" data-parsley-trigger="keyup" data-parsley-validate="" novalidate=""   id="myformsystemdelete" name="myformsystemdelete"  action="/include/deletesystemfromrel.cfm" method="POST" >
   
     <div class="form-group col-md-12">
         <label for="valuetext">Delete system from all selected relationships.</label>
     </div>

<div class="form-group col-md-6">
    <select id="select-system" name="new_systemid" class="form-control" data-parsley-required="" data-parsley-error-message="System is required">
        <option value="">Select a System...</option>
        <cfoutput query="systemNAMES">
            <option value="#systemNAMES.id#">#systemNAMES.systemname#</option>
        </cfoutput>
    </select>
</div>

<div class="form-group text-center col-md-12">

                        <button class="btn btn-primary editable-submit btn-sm waves-effect waves-light" type="submit" style="background-color: #406e8e; border: #406e8e;">Delete System</button>

                    </div>

<input type="hidden" name="idlist" value="">
</form>

</div>
        </div>
    </div>
</div><!--- xxx --->

<div id="exampleModal3" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="standard-modalLabel" >

    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title" id="standard-modalLabel">System Selected Update</h4>
                <button type="button" class="close" data-bs-dismiss="modal" >
<i class="mdi mdi-close-thick"></i></button>
            </div>
            
<div class="modal-body">

               <form method="post" class="parsley-examples demo-default selectize-close-btn" data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden" data-parsley-trigger="keyup" data-parsley-validate="" novalidate=""   id="myformsystem" name="myformsystem"  action="/include/tmpcontactgroups.cfm" method="POST" >
   
     <div class="form-group col-md-12">
         <label for="valuetext">Add system to all selected relationships.</label>
     </div>

<div class="form-group col-md-6">
    
    <select id="select-system" name="new_systemtype"  class="form-control" data-parsley-required="" data-parsley-error-message="System is required"  >
        
             <option value="">Select a System...</option>
        <cfloop query="systems">

            <cfset new_systemname=systems.systemname />

            <cfset new_select="" />

            <cfoutput>

            <option value="#new_systemname#" #new_select#>#new_systemname#</option>

            </cfoutput>

        </cfloop>
        
    </select>

</div>

<div class="form-group col-md-12">
           
                    <label for="valuetext">If a relationship already has an active system:</label>
     </div>

<div class="form-group col-md-12">
     <div class="form-group col-md-5">

<div class="form-check mb-2 form-check-success">
                                        <input class="form-check-input" type="radio" name="keeplist" value="skip" id="customradio2" checked="checked" />
                                        <label class="form-check-label" for="customradio2">Skip</label>
                                    </div>
         
     </div>

<div class="form-group col-md-6">
                     <div class="form-check mb-2 form-check-danger">
                                        <input class="form-check-input" type="radio" name="keeplist" value="replace" id="customradio4" />
                                        <label class="form-check-label" for="customradio4">Replace</label>
                                    </div>

</div>
     
     </div>
                   <div class="form-group text-center col-md-12">

                        <button class="btn btn-primary editable-submit btn-sm waves-effect waves-light" type="submit" style="background-color: #406e8e; border: #406e8e;">Add System</button>

                    </div>

<input type="hidden" name="idlist" value="">
</form>

<script>      
 $(document).ready(function() {
    $(".parsley-examples").parsley()
});
 </script>     

</div>
        </div>
    </div>
</div><!--- xxx --->

<div id="exampleModal4" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="standard-modalLabel" >

    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title" id="standard-modalLabel">Tag Selected Update</h4>
                <button type="button" class="close" data-bs-dismiss="modal" >
<i class="mdi mdi-close-thick"></i></button>
            </div>

            <div class="modal-body">

                <form method="post" class="parsley-examples demo-default selectize-close-btn" data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden" data-parsley-trigger="keyup" data-parsley-validate="" novalidate="" id="myformtag" name="myformtag" action="/include/tmpcontacttags.cfm" >

                    <div class="form-group col-md-12">
                        <label for="valuetext">Select Tag to add or remove from selected relationships</label>
                    </div>

                    <div class="form-group col-md-6">

                        <select id="select-tag" name="new_tagname" class="form-control" data-parsley-required="" data-parsley-error-message="Tag is required" >

                            <option value="">Select a Tag...</option>
                            <cfloop query="tags">

                                <cfset new_tagname=tags.tagname />

                                 <cfset new_tagselect="" />

                                <cfoutput>

                                    <option value="#new_tagname#" #new_tagselect#>#new_tagname#</option>

                                </cfoutput>

                            </cfloop>

                        </select>

                    </div>

                    <div class="form-group col-md-12">

                        <label for="valuetext">Action:</label>
                    </div>

                    <div class="form-group col-md-12">
                        <div class="form-group col-md-5">

                            <div class="form-check mb-2 form-check-success">
                                <input class="form-check-input" type="radio" name="addremove" value="add" id="add" checked="checked" />
                                <label class="form-check-label" for="customradio2">Add it</label>
                            </div>

                        </div>

                        <div class="form-group col-md-6">
                            
                            <div class="form-check mb-2 form-check-danger">
                                <input class="form-check-input" type="radio" name="addremove" value="remove" id="remove" />
                                <label class="form-check-label" for="customradio4">Remove it</label>
                            </div>

                        </div>

                    </div>
                    
                    <div class="form-group text-center col-md-12">

                        <button class="btn btn-primary editable-submit btn-sm waves-effect waves-light" type="submit" style="background-color: #406e8e; border: #406e8e;">Continue</button>

                    </div>

                <input type="hidden" name="idlist" value="">
</form>

            </div>
            
        </div>
        
    </div>

</div>

<script>
    $(document).ready(function() {
  $('#myformexport').on('submit', function(e) {
    e.preventDefault();
    var formData = $(this).serialize(); // Serialize form data

    $.post('/include/exportcontacts.cfm', formData, function(response) {
      // Do something with the response if you want
      // Close the modal
      $('#exampleModal5').modal('hide');
    });
  });
});
   </script> 

<cfset script_name_include="/include/#ListLast(GetCurrentTemplatePath(), " \")#" />
    <cfinclude template="/include/bigbrotherinclude.cfm" />