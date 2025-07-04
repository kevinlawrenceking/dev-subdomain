

<cfparam name="contact_expand" default="true" />
<cfparam name="a" default="0" />
<cfparam name="d" default="0" />
<cfparam name="s" default="0" />
<cfparam name="contactcheckvisible" default="false" />
<cfparam name="maintenance_expand" default="false" />
<cfparam name="bytag" default="" />
<cfparam name="target_expand" default="false" />
<cfparam name="followup_expand" default="false" />
<cfparam name="all_expand" default="false" />
<cfparam name="pgaction" default="view" />
<cfif NOT #isdefined('session.pgaction')#>
    <cfset session.pgaction="view" />
</cfif>
<div class="row">
    <div class="card mb-3 w-100" >
        <div class="card-body">
            <div class="col-md-12">
                <div class="media pt-3">
                    <figure>
                        <cfoutput>
                            <center>
                                <img src="#userAvatarUrl#?ver=#rand()#" class="mr-3 rounded-circle gambar img-responsive img-thumbnail" style="height:80px;" alt="profile-image" id="item-img-output" />
                                <figcaption style="margin-left:-5px;"></figcaption>
                            </center>
                        </cfoutput>
                    </figure>
                    <cfoutput>
                        <div class="media-body pl-2">
                            <h3 class="mt-0 mb-0"> #userfirstname# #userlastname# </h3>
                            <p class="mt-1 mb-0 text-muted font-12">
                                <strong>Report Date:#dateformat('#now()#','medium')#</strong>
                                <BR />
                                <A HREF="https://#host#.theactorsoffice.com/share/export.cfm?userid=#userid#" class="btn btn-xs btn-primary waves-effect mb-2 waves-light" style="background-color: ##406e8e; border: ##406e8e;"> Download <i class="fe-download"></i>
                                </A>
                            </p>
                        </div>
                    </cfoutput>
                </div>
            </div>
            <table id="basic-datatable" class="table display nowrap table-striped dataTable w-100 dtr-inline dt-checkboxes-select dt-responsive" role="grid">
                <thead>
                    <tr>
                        <th></th>
                        <th>Name</th>
                    <cfif #isdefined('auditions')#>  <th>Audition</th></cfif>  
                        <th>Company</th>
                        <th>Title</th>
                         <th>Audition Status</th>
                        <th>Where Met</th>
                        <th>When Met</th>
                        <th>Notes</th>
                    </tr>
                </thead>
                <cfloop query="shares">
                    
                    <cfquery result="result" name="events" >

SELECT 
eventid
,eventTitle
,eventDescription
,eventLocation
,eventstatus
,eventcreation
,eventStart
,eventStop
,eventTypeName
,userid
,eventStartTime
,eventStopTime
,recordname
,contactid
,isDeleted

 FROM events
 WHERE contactid = #shares.CONTACTID#
 AND EventTypeName IN ('Meeting','Audition')
 
ORDER BY eventCreation
</cfquery>

<cfoutput>

<tr>
                                    <td style="white-space: nowrap;">
                                        <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##remoteShareViewC#shares.contactid#" data-bs-placement="top" title="View Contact Info and Audition List" data-bs-original-title="View Contact Info and Audition List">
                                            <i class="fe-search"></i>
                                        </a>
                                    </td>
                            <td style="white-space: nowrap;">#name#
                                     
                                                  <cfif events.recordcount neq 0>

                        <span class="badge  badge-primary badge-pill">

                            <cfoutput>#numberformat(events.recordcount)#</cfoutput>

                        </span>

                    </cfif>

<cfif #isdefined('auditionsgggg')#>    
                                               
                                               <td style="white-space: nowrap;">#events.recordcount#</td>
                                            
                    </cfif>
                                            
                                    <!--- Name --->
                                    <td style="white-space: nowrap;">#Company#</td>
                                    <!--- Company --->
                                    <td style="white-space: nowrap;">#Title#</td>
                                    
                                                <td style="white-space: nowrap;">#audition#</td>
                                    <!--- Title --->
                                    <td style="white-space: nowrap;">#Wheremet#</td>
                                    <!--- Where Met --->
                                    <td style="white-space: nowrap;">#dateformat('#whenmet#','medium')#</td>
                                    <!--- When Met --->

                                    <td style="white-space: break-spaces;">#NotesLog#</td>
                                    <!--- Notes --->
                                </tr>
                    </cfoutput>
                </cfloop>
            </table>
        </div>
    </div>
</div>

<SCRIPT>
    $(document).ready(function() {
        $("#basic-datatable").DataTable({
            "searching": true,
            "autowidth": false,
            "columnDefs": [
     
      { "width": "50%", "targets": 7, "className": "text-wrap" },
        { "width": "10%", "targets": 4 } ,       
                   { "width": "20%", "targets": 5, "className": "text-wrap" }     
                
    ],
            language: {
                paginate: {
                    previous: "<i class='mdi mdi-chevron-left'>",
                    next: "<i class='mdi mdi-chevron-right'>"
                }
            },
            drawCallback: function() {
                $(".dataTables_paginate > .pagination").addClass("pagination-rounded")
            }
        });
        var a = $("#datatable-buttons").DataTable({
            lengthChange: !1,
            language: {
                paginate: {
                    previous: "<i class='mdi mdi-chevron-left'>",
                    next: "<i class='mdi mdi-chevron-right'>"
                }
            },
            drawCallback: function() {
                $(".dataTables_paginate > .pagination").addClass("pagination-rounded")
            }
        });
    });

</SCRIPT>
