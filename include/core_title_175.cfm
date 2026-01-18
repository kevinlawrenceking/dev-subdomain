<!--- This ColdFusion page handles role checking and displays options for managing project roles with callback, redirect, pin, and booked functionalities. --->

<cfinclude template="/include/qry/rolecheck_90_1.cfm" />

<cfparam name="NEW_ISREDIRECT" default="0" />
<cfparam name="NEW_ispin" default="0" />
<cfparam name="NEW_Iscallback" default="0" />
<cfparam name="NEW_ISbooked" default="0" />

<form action="/include/rolecheck.cfm">
    
    <cfoutput>
        
        <input type="hidden" name="audroleid" value="#audroleid#" />
        <input type="hidden" name="eventid" value="#eventid#" />
        <input type="hidden" name="pgaction" value="switchit" />   
         
        <div class="container">
    
            <div class="row">
                
                <h4 class="col-md-12 col-lg-6">
                    <cfoutput>#projectdetails.projname# 
                        <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##remoteDeleteFormAudproject#projectdetails.audprojectid#" data-bs-placement="top" title="Delete Project" data-bs-original-title="Delete Project"> 
                            <i class="fe-trash-2"></i>
                        </a>
                    </cfoutput>  
                </h4><!--- end col-md-12 --->
  
                <div class="col-md-12 col-lg-6">                                
                      
                    <div class="form-check form-switch form-control-md form-check-inline">
                        <input class="form-check-input form-check-input-callback" 
                               type="checkbox" 
                               id="new_iscallback" 
                               name="new_iscallback" 
                               value="1"  
                               onchange="this.form.submit()"  
                               <cfif #rolecheck.iscallback# is "1"> checked </cfif> />
                        <label class="form-check-label" for="new_iscallback">Callback </label>
                        <cfif #rolecheck.iscallback# is "1">
                            <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##changecallback" data-bs-placement="top" title="Add Callback appointment" data-bs-original-title="Add Callback">
                                <i class="fe-plus-circle"></i>
                            </a>
                        </cfif>
                    </div><!--- end form-check --->  

                    <div class="form-check form-switch form-control-md form-check-inline">
                        <input class="form-check-input form-check-input-redirect" 
                               type="checkbox" 
                               id="new_isredirect" 
                               name="new_isredirect" 
                               value="1"  
                               onchange="this.form.submit()"  
                               <cfif #rolecheck.isredirect# is "1"> checked </cfif> />
                        <label class="form-check-label" for="new_isredirect">Redirect </label>
                        <cfif #rolecheck.isredirect# is "1">
                            <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##changeredirect" data-bs-placement="top" title="Add Redirect appointment" data-bs-original-title="Add Redirect">
                                <i class="fe-plus-circle"></i>
                            </a>
                        </cfif>
                    </div><!--- end form-check --->            

                    <div class="form-check form-switch form-control-md form-check-inline">
                        <input class="form-check-input form-check-input-pin"  
                               type="checkbox" 
                               id="new_ispin" 
                               name="new_ispin"  
                               value="1"   
                               onchange="this.form.submit()"  
                               <cfif #rolecheck.ispin# is "1"> checked </cfif> />
                        <label class="form-check-label" for="new_ispin">Pin/avail </label>
                    </div><!--- end form-check --->  

                    <div class="form-check form-switch form-control-md form-check-inline">
                        <input class="form-check-input form-check-input-booked" 
                               type="checkbox" 
                               id="new_isbooked" 
                               name="new_isbooked"  
                               value="1"  
                               onchange="this.form.submit()"  
                               <cfif #rolecheck.isbooked# is "1"> checked </cfif> />
                        <label class="form-check-label" for="new_isbooked">Booked </label>
                        <cfif #rolecheck.isbooked# is "1">
                            <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##changebooked" data-bs-placement="top" title="Add Booked appointment" data-bs-original-title="Add Booking Appointment">
                                <i class="fe-plus-circle"></i>
                            </a>
                        </cfif>
                    </div><!--- end form-check --->     

                </div><!--- end col-md-12 ---> 

            </div><!--- end row --->

        </div><!--- end container --->

    </cfoutput>    

</form>
