
<cfparam name="select_userid" default="%" />
<cfparam name="select_ticketstatus" default="%" />
<cfparam name="select_tickettype" default="%" />
<cfparam name="select_ticketpriority" default="%" />
<cfparam name="select_pgid" default="%" />
<cfparam name="select_verid" default="%" />

<div class="row">
    <div class="col-12">
        <div class="card">
            <div class="card-body">
                <h4 class="header-title">Support Tickets</h4>
                <p class="text-muted font-13 mb-4">
                </p>
                <form action="/app/admin-support/">
                <div class="row">
                    
                    
                    
                    
                <div class="form-group col-md-4">
                                        <label for="select_userid">User</label>
                                        <select class="form-control" name="select_userid" id="select_userid" onchange='this.form.submit()'>
                                            <option value="%" <cfif #select_userid# is "%">Selected</cfif>>All Users</option>
                                            <cfoutput query="users"><option value="#users.userid#" <cfif #users.userid# is "#select_userid#">Selected </cfif>>#users.recordname# <cfif #users.userrole# is not "user">(#users.userrole#)</cfif></option></cfoutput>

                            

                                    
                                </select>

                                <div class="invalid-feedback">
                                    Please select a User.
                                </div>

                                </div>
        
        
        
        
        
        
        
        
                        <div class="form-group col-md-4">
                                        <label for="select_ticketstatus">Status</label>
                                        <select class="form-control" name="select_ticketstatus" id="select_ticketstatus" onchange='this.form.submit()'>
                                            <option value="%" <cfif #select_ticketstatus# is "%">Selected</cfif>>All</option>
                                            <cfoutput query="statuses"><option value="#statuses.ticketstatus#" <cfif #statuses.ticketstatus# is "#select_ticketstatus#">Selected </cfif>>#statuses.ticketstatus# </option></cfoutput>

                            

                                    
                                </select>

                                <div class="invalid-feedback">
                                    Please select a Status.
                                </div>

                                </div>
        
        
        
        
                           <div class="form-group col-md-4">
                                        <label for="select_tickettype">Type</label>
                                        <select class="form-control" name="select_tickettype" id="select_tickettype" onchange='this.form.submit()'>
                                            <option value="%" <cfif #select_tickettype# is "%">Selected</cfif>>All Types</option>
                                            <cfoutput query="types"><option value="#types.tickettype#" <cfif #types.tickettype# is "#select_tickettype#">Selected </cfif>>#types.tickettype# </option></cfoutput>

                            

                                    
                                </select>

                                <div class="invalid-feedback">
                                    Please select a Status.
                                </div>

                                </div>     
        
        
        




                <div class="form-group col-md-4">
                                        <label for="select_pgid">Pages</label>
                                        <select class="form-control" name="select_pgid" id="select_pgid" onchange='this.form.submit()'>
                                            <option value="%" <cfif #select_pgid# is "%">Selected</cfif>>All Pages</option>
                                            <cfoutput query="pages"><option value="#pages.pgid#" <cfif #pages.pgid# is "#select_pgid#">Selected </cfif>>#pages.pgname# </option></cfoutput>

                            

                                    
                                </select>

                                <div class="invalid-feedback">
                                    Please select a Page.
                                </div>

                                </div>
        
            <div class="form-group col-md-4">
                                        <label for="select_pgid">Priority</label>
                                        <select class="form-control" name="select_ticketpriority" id="select_priorityid" onchange='this.form.submit()'>
                                            <option value="%" <cfif #select_ticketpriority# is "%">Selected</cfif>>All Priorities</option>
                                            <cfoutput query="priorities"><option value="#priorities.name#" <cfif #priorities.name# is "#select_ticketpriority#">Selected </cfif>>#priorities.name# </option></cfoutput>

                            

                                    
                                </select>

                                <div class="invalid-feedback">
                                    Please select a Priority.
                                </div>

                                </div>



            <div class="form-group col-md-4">
                                        <label for="select_pgid">Release (hours left)</label>
                                        <select class="form-control" name="select_verid" id="select_verid" onchange='this.form.submit()'>
                                            <option value="%" <cfif #select_verid# is "%">Selected</cfif>>All Releases</option>
                                         <option value="0" <cfif #select_verid# is "0">Selected</cfif>>None</option>

<cfoutput query="vers"><option value="#vers.id#" <cfif #vers.id# is "#select_verid#">Selected </cfif>>#vers.name# (#numberformat(vers.hoursleft,'9.99')# hrs) </option></cfoutput>

                            

                                    
                                </select>

                                <div class="invalid-feedback">
                                    Please select a Releases.
                                </div>

                                </div>




                        
                </div>
    
                
                
                
                
                </form>
                
                
                
                
                <table id="basic-datatable" class="table dt-responsive nowrap w-100 table-striped" role="grid">
                    <thead>
                        <cfloop query="results"  endrow="1">
                            <cfoutput>
                                <cfif (Results.CurrentRow MOD 2) >
                                    <Cfset rowtype="Odd" />
                                    <cfelse>
                                        <Cfset rowtype="Even" />
                                </cfif>


                                <tr class="#rowtype#">
                                      <th>Action</th>
                                     <th>#head1#</th>
                                    <th>#head2#</th>
                                   <cfif #isdefined('safddfs')#>     <th>#head3#</th></cfif>
                                <cfif #isdefined('safddfs')#>   <th>#head4#</th></cfif> 
                                        <th>#head45#</th>
                                    <th>#head5#</th>
                                        <th>#head6#</th> 
                                 <th>#head7#</th>
                                         <th>Testing</th>
                                </tr>
                                </tr>
                            </cfoutput>
                        </cfloop>
                    </thead>
                    <tbody>
                        <cfloop query="results">
 
                                          	<cfquery name="versions" datasource="#dsn#" >
    SELECT v.major,v.minor,v.patch,v.verid AS id, v.alphabeta,CONCAT(v.major,'.',v.minor,'.',v.patch,'-',v.alphabeta) as name
      ,((v.hoursavail) - IFNULL((SELECT SUM(esthours) FROM tickets t WHERE verid = v.verid),0)   ) AS hoursleft              
    
                                                FROM taoversions v 
                                                WHERE v.verid <> #results.verid#
                                                and ((v.hoursavail) - IFNULL((SELECT SUM(esthours) FROM tickets t WHERE verid = v.verid),0)   ) - #numberformat(results.col6,'99999.99')# >= 0
                                                and v.versionstatus = 'Pending'
                                                
    UNION
        SELECT v.major,v.minor,v.patch,v.verid AS id, v.alphabeta,CONCAT(v.major,'.',v.minor,'.',v.patch,'-',v.alphabeta) as name
      ,((v.hoursavail) - (SELECT SUM(esthours) FROM tickets t WHERE verid = v.verid)) AS hoursleft              
    
                                                FROM taoversions v  WHERE v.verid = #results.verid#
                                                
                                                
                                                
                                              ORDER BY major,minor,patch
                                                
    </cfquery>
                            
                            
                            
                            



                                    <cfoutput>
                                       <script>
$(document).ready(function(){
    $("##myModal#results.recid#").on("show.bs.modal", function(event){
        // Place the returned HTML into the selected element
        $(this).find(".modal-body").load("/include/remotecontent.cfm?recid=#results.recid#");
    });
});
</script>
                                        
                                            <script>
$(document).ready(function(){
    $("##remoteNewForm").on("show.bs.modal", function(event){
        // Place the returned HTML into the selected element
        $(this).find(".modal-body").load("/include/RemoteNewForm.cfm?rpgid=36");
    });
});
</script>
                                                       
 

                                            <tr>
                                              
                                                  <td>
                                            <cfif  #isdefined('sdfsdf')#>   <a href="remoteContent.cfm?recid=#results.recid#" data-remote="true" data-toggle="modal" data-target="##myModal#results.recid#">
                                                     
                                                       <i class="mdi mdi-square-edit-outline"></i>
                                                     
                                                     </a>
                                                     
                                                  &nbsp;
                                                      </cfif>  
                                                      <A href="/include/deleteticket.cfm?recid=#results.recid#">
                                                       <i class="mdi mdi-trash-can-outline mr-1"></i></A>
                                                      
                                                      
                                                </td>
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                    

                                    <TD> <A href="/app/admin-support-details/?recid=#results.recid#" title="#results.col4# - #results.col5#">#results.recid#</A>
                             
                                        
                                       
                                    
                                    </TD>
                            
                                    <td>#results.col2#</td>
                                     <cfif #isdefined('safddfs')#><td>#results.col3#</td></cfif> 

                                    <cfif #isdefined('safddfs')#><td>#results.col4#</td></cfif>
                                    <td>#results.col45#</td>
                              <form class="px-3 col-md-12" id="updatever#results.recid#" method="post" action="/include/updatetickver2.cfm">
                                      <td>
                                     <input type="hidden" name="ticketid" value="#results.recid#" />
                                         <input type="hidden" name="old_verid" value="#results.verid#" />     
                                     <input type="hidden" name="old_ticketpriority" value="#results.col5#" />   
                                          </cfoutput>
                                          
                                          
<cfif #results.col45# is not "closed" and #results.col45# is not "Released">
           <cfoutput>
                                    <select   onchange="javascript:this.form.submit()" name="new_ticketpriority" id="new_ticketpriority_#results.recid#" required>

   </cfoutput>
    <cfloop query="priorities" >
        <Cfoutput>
        <option value="#priorities.id#" <cfif #priorities.id# is "#results.col5#"> selected </cfif>  >#priorities.name#</option>
    </cfoutput>
    
                                    
    
           </cfloop>

                       </select>                    
                                             
                                 <cfelse>
                                    <Cfoutput>#results.col5# <input type="hidden" name="new_ticketpriority" value="#results.col5#"></Cfoutput> 
                                     </cfif>
                                    
                                    
                                    </td> 
                                  <cfoutput>
                                    
                                    
                                      <td>#results.col6#</td> </cfoutput>
                                    <td>
                                      
 

           <cfif #results.col45# is not "closed" and #results.col45# is not "Released">
               
               <cfoutput>
                                    <select   onchange="javascript:this.form.submit()" name="new_verid" id="new_verid_#results.recid#" required>
                                        <option value="0" <cfif #results.verid# is "0"> Selected </cfif>>None</option>
                            
  
                          
   </cfoutput>
    <cfloop query="versions" >
        <Cfoutput>
            
            
            <option value="#versions.id#" <cfif #versions.id# is "#results.verid#"> Selected </Cfif>  >#versions.name# (#numberformat(versions.hoursleft,'9.99')# hrs)</option>
    </cfoutput>
    
                                 
                                        
     
           </cfloop>

</select> 
                        <cfelse>
                            
                            <cfoutput>#results.col7# <input type="hidden" name="new_verid" value="#results.verid#" /></cfoutput>
                            </cfif>
                    
                    
                    
                    </form>           
                                    </td>
                        
                        <td>
         	<cfquery name="ticketusers" datasource="#dsn#" >                       
SELECT tu.id
,tu.ticketid
,tu.userid
,u.recordname
,tu.teststatus
,tu.rejectnotes

 FROM tickettestusers tu
 INNER JOIN taousers u ON u.userid = tu.userid
 WHERE tu.ticketid = #results.recid#
                            </cfquery>                      
                        
                      <Cfloop query="ticketusers">
                            <cfoutput>
                                <cfif #ticketusers.teststatus# is "Approved">
                               <a href="##" title="#ticketusers.recordname#"> <i class="mdi mdi-thumb-up" style="color:darkseagreen;"></i></a>
                                    
                                    <cfelse>
                                    <a href="##" title="#ticketusers.recordname#<cfif #ticketusers.rejectnotes# is not "">#ticketusers.rejectnotes#</cfif>"> <i class="mdi mdi-thumb-down"  style="color: darkred;"></i></a>
                                
                                </cfif>
                                
                                
                           </cfoutput>
                            
                            
                            </Cfloop>  
                        
                        
                        
                        </td>
                                </tr>
                                        <cfoutput>
                                        
                                        	<div id="myModal#results.recid#" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="standard-modalLabel" aria-hidden="true">
										<div class="modal-dialog">
											<div class="modal-content">
												<div class="modal-header" style="background-color: ##f3f7f9;">
													<h4 class="modal-title" id="standard-modalLabel">No. 0000#results.recid# - #results.tickettype# </h4>
													<button type="button" class="close" data-bs-dismiss="modal" aria-hidden="true">x</button>
												</div>
												<div class="modal-body">
													
												</div>
											</div>
											<!-- /.modal-content -->
										</div>
										<!-- /.modal-dialog -->
									</div>
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                            
                                    </cfoutput>
                        </cfloop>
                        
                        <div id="remoteNewForm" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="standard-modalLabel" aria-hidden="true">
										<div class="modal-dialog">
											<div class="modal-content">
												<div class="modal-header" style="background-color: #f3f7f9;">
													<h4 class="modal-title" id="standard-modalLabel">Add</h4>
													<button type="button" class="close" data-bs-dismiss="modal" aria-hidden="true">x</button>
												</div>
											<div class="modal-body">
													
												</div>
											</div>
											<!-- /.modal-content -->
										</div>
										<!-- /.modal-dialog -->
										</div>
										</tbody>
										</table>













										</div>






										<!-- end card body-->
        </div> <!-- end card -->







   <SCRIPT>
        $(document).ready(function() {
            $("#basic-datatable").DataTable({
              
                "iDisplayLength": 100,
        
                pageLength: 100,
                
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
                buttons: [{
                    extend: "copy",
                    className: "btn-light"
                }, {
                    extend: "print",
                    className: "btn-light"
                }, {
                    extend: "pdf",
                    className: "btn-light"
                }],
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



<!-- Default bootstrap modal example -->

<cfset script_name_include="/include/#ListLast(GetCurrentTemplatePath(), "\")#" /><cfinclude template="/include/bigbrotherinclude.cfm" /> 

<!--- <cfparam name="select_userid" default="%"/>
<cfparam name="select_ticketstatus" default="%"/>
<cfparam name="select_tickettype" default="%"/>
<cfparam name="select_ticketpriority" default="%"/>
<cfparam name="select_pgid" default="%"/>
<cfparam name="select_verid" default="%"/>

<!--- Main query for fetching ticket results --->
<cfinclude template="/include/qry/results_330_1.cfm" />

<!--- Query for ticket priorities --->
<cfinclude template="/include/qry/priorities_330_2.cfm" />

<!--- Query for versions with available hours calculation --->
<cfinclude template="/include/qry/vers_330_3.cfm" />

--->