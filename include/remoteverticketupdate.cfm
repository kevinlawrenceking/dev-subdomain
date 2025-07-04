<!--- This ColdFusion page handles the display and update of ticket details, including various fields related to the ticket. --->

<cfinclude template="/include/qry/details_274_1.cfm" />
<cfinclude template="/include/qry/uu_274_2.cfm" />
<cfinclude template="/include/qry/pages_274_3.cfm" />
<cfinclude template="/include/qry/users_274_4.cfm" />
<cfinclude template="/include/qry/statuses_274_5.cfm" />
<cfinclude template="/include/qry/types_256_2.cfm" />
<cfinclude template="/include/qry/priorities_274_7.cfm" />
<cfinclude template="/include/qry/vers_274_8.cfm" />

<div class="row">
    <cfset cur_icon="">
    
    <form class="px-3 col-md-12" action="/include/remoteverticketupdate2.cfm">
        <cfoutput query="details">
            <input type="hidden" name="oldverid" value="#oldverid#" />
            <input type="hidden" name="ticketid" value="#details.recid#" />
            
            <div class="form-group col-md-12">
                <label for="tickettype">Ticket Details</label>
                <textarea class="form-control" type="text" id="new_ticketname" name="new_ticketname" placeholder="Details" rows="2" required>#details.ticketname#</textarea>    
            </div>  
            
            <div class="form-group col-md-12">
                <label for="tickettype">Developer Response</label>
                <textarea class="form-control" type="text" id="new_ticketname" name="new_ticketResponse" placeholder="Developer Response" rows="2">#details.ticketResponse#</textarea>    
            </div>  
            
            <div class="form-group col-md-12">
                <label for="testingscript">Testing Script</label>
                <textarea class="form-control" type="text" id="new_testingscript" name="new_testingscript" rows="2">#details.testingscript#</textarea>    
            </div>       
        </cfoutput>                            
                                    
        <div class="form-group col-md-12">                              
            <label for="tickettype"> Page</label>
            <select class="form-control" name="new_pgid" id="new_pgid" required>
                <cfoutput query="pages">
                    <option value="#pages.id#" <cfif #pages.id# is "#details.pgid#"> selected </cfif>>#pages.name#</option>
                </cfoutput>
            </select>
        </div>
        
        <cfoutput query="details">
            <div class="form-group col-md-12">
                <label for="testingscript">Custom Test Page</label>
                <input type="text" class="form-control" id="new_customTestPageName" value="#details.customTestPageName#" name="new_customTestPageName" />
            </div>       
    
            <div class="form-group col-md-12">
                <label for="testingscript">Custom Test Page Link</label>
                <input type="text" class="form-control" id="new_customTestPageLink" value="#details.customTestPageLink#" name="new_customTestPageLink" />
            </div>       
        </cfoutput>
    
        <div class="form-group col-md-12">
            <label for="ticketstatus">Status</label>
            <select class="form-control" name="new_ticketstatus" id="new_ticketstatus" required>
                <cfoutput query="statuses">
                    <option value="#statuses.id#" <cfif #statuses.id# is "#details.ticketstatus#"> selected </cfif>>#statuses.name#</option>
                </cfoutput>
            </select>
        </div>  

        <cfoutput>
            <input type="hidden" name="old_ticketstatus" value="#details.ticketstatus#" />
        </cfoutput>  
    
        <div class="form-group col-md-12">
            <label for="tickettype">Type</label>
            <select class="form-control" name="new_tickettype" id="new_tickettype" required>
                <cfoutput query="types">
                    <option value="#types.id#" <cfif #types.id# is "#details.tickettype#"> selected </cfif>>#types.name#</option>
                </cfoutput>
            </select>
        </div>   

        <div class="form-group col-md-12">
            <label for="tickettype">Priority</label>
            <select class="form-control" name="new_ticketpriority" id="new_ticketpriority" required>
                <cfoutput query="priorities">
                    <option value="#priorities.id#" <cfif #priorities.id# is "#details.ticketpriority#"> selected </cfif>>#priorities.name#</option>
                </cfoutput>
            </select>
        </div>  

        <div class="form-group col-md-12">
            <label for="new_verid">Assigned Release</label>
            <select class="form-control" name="new_verid" id="new_verid" required>
                <option value="NULL">None</option>
                <cfoutput query="vers">
                    <option value="#vers.id#" <cfif #vers.id# is "#details.verid#"> selected </cfif>>#vers.major#.#vers.minor#.#vers.patch#.#vers.version#</option>
                </cfoutput>
            </select>
        </div>                                 
        
        <div class="form-group col-md-6">
            <label for="new_estHours">Est. Hours</label>
            <select class="form-control" name="new_estHours" id="new_estHours" required>
                <cfloop index="z" step=".25" from="0" to="50">
                    <cfoutput>
                        <option value="#z#" <cfif #z# is "#details.esthours#"> selected </cfif>>#z#</option>
                    </cfoutput> 
                </cfloop>
            </select>
        </div>  

        <div class="row mt-2">
            <div class="col-6"></div>
            <div class="col-6 text-right">
                <a href="javascript:history.go(-1)">
                    <button type="button" class="btn btn-light mr-1 btn-sm" data-bs-dismiss="modal">Back</button>
                </a>
                <button type="submit" class="btn btn-primary btn-sm waves-effect waves-light" id="btn-save-event">Update</button>
            </div>
        </div>
    </form>
</div>

