<!--- This ColdFusion page handles the display and submission of a form for updating book details including income type, pay rate, and buyout information. --->

<cfinclude template="/include/qry/audplatforms_sel.cfm" />
<cfinclude template="/include/qry/incometypes_sel.cfm" />
<cfinclude template="/include/qry/audpaycyles_sel.cfm" />
<cfinclude template="/include/qry/book_det_57_1.cfm" />

<!--- Check if the income type is not equal to 1 to conditionally apply styles. --->
<Cfif #book_det.incometypeid# is not "1">
    <style>
        #hidden_divs {
            display: none;
        }
    </style>
</cfif>

<!--- Set debug variable and include jQuery chained script. --->
<cfset dbug = "N" />
<script src="/app/assets/js/jquery.chained.js"></script>

<p>Enter the information below and press the update button to continue.</p>

<!--- Form for updating book details. --->
<form action="/include/bookupdateform2.cfm" method="post" class="parsley-examples" name="event-form" id="form-event" data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden" data-parsley-trigger="keyup" data-parsley-validate>
    <cfoutput> 
        <input type="hidden" name="focusid" value="#focusid#" />
        <input type="hidden" name="audprojectid" value="#audprojectid#" />
        <input type="hidden" name="new_userid" value="#userid#" />
        <input type="hidden" name="eventid" value="#eventid#" />
        <input type="hidden" name="secid" value="#secid#" />     
        <input type="hidden" name="new_audroleid" value="#audroleid#" />
    </cfoutput>
    
    <!--- JavaScript function to show/hide divs based on income type selection. --->
    <script>
        function showDivs(divId, element) {
            document.getElementById(divId).style.display = element.value == 1 ? 'block' : 'none';
        }
    </script>
    
    <div class="row">
        <!--- Income Type Selection --->
        <div class="form-group col-md-6 col-sm-12">
            <label for="new_incometypeid">Income Type</label>
            <select id="new_incometypeid" name="new_incometypeid" class="form-control" onChange="showDivs('hidden_divs', this);">
                <cfoutput query="incometypes_sel">
                    <option value="#incometypes_sel.id#" <cfif #incometypes_sel.id# is "#book_det.incometypeid#">selected</cfif>>#incometypes_sel.name#</option>
                </cfoutput>
            </select>
        </div>      

        <!--- Conditional Net Income Input --->
        <div class="form-group col-md-6 col-sm-12">
            <div id="hidden_divs">
                <cfoutput>
                    <label for="new_netincome">Net Income ($)</label>
                    <input class="form-control" id="new_netincome" name="new_netincome" value="#book_det.netincome#" placeholder="net income" type="number" step="0.01" data-parsley-type="number" />
                    <div class="invalid-feedback">
                        Please enter a Net Income.
                    </div>
                </cfoutput>
            </div>
        </div>   

        <!--- Pay Rate Input --->
        <cfoutput>
            <div class="form-group col-md-6 col-sm-12">
                <label for="new_payrate">Payrate ($)</label>
                <input class="form-control" id="new_payrate" name="new_payrate" value="#book_det.payrate#" placeholder="Payrate" type="number" step="0.01" data-parsley-type="number" />
                <div class="invalid-feedback">
                    Please enter a Payrate.
                </div>
            </div>   
        </cfoutput>

        <!--- Pay Cycle Selection --->
        <div class="form-group col-md-6 col-sm-12">
            <label for="new_payrate">Pay Cycle</label>
            <select id="new_paycycleid" name="new_paycycleid" class="form-control">
                <cfoutput query="audpaycyles_sel">
                    <option value="#audpaycyles_sel.id#" <cfif #audpaycyles_sel.id# is "#book_det.paycycleid#">selected</cfif>>#audpaycyles_sel.name#</option>
                </cfoutput>
            </select>
        </div>

        <!--- Conditional Buyout Input for Commercial Category --->
        <cfoutput>
            <cfif #book_det.audcatname# is "Commercial">
                <div class="form-group col-md-6 col-sm-12">
                    <label for="new_buyout">Buyout ($)</label>
                    <input class="form-control" id="new_buyout" name="new_buyout" value="#book_det.buyout#" placeholder="buyout" type="number" data-parsley-type="integer" />
                    <div class="invalid-feedback">
                        Please enter a Net Income.
                    </div>
                </div>   
            <cfelse>
                <input type="hidden" name="new_buyout" value="#book_det.buyout#" />
            </cfif>
        </cfoutput>
        
        <!--- Conflict Notes and End Date --->
        <cfoutput>
            <div class="form-group row">
                <div class="col-md-6 col-sm-12">
                    <label for="new_conflict_notes">Conflict</label>
                    <input class="form-control" id="new_conflict_notes" name="new_conflict_notes" value="#book_det.conflict_notes#" placeholder="Enter conflict details" type="text" />
                </div>
                <div class="col-md-6 col-sm-12">
                    <label for="new_conflict_enddate">End Date of Conflict</label>
                    <input class="form-control" id="new_conflict_enddate" name="new_conflict_enddate" value="#dateFormat(book_det.conflict_enddate, 'yyyy-mm-dd')#" type="date" />
                </div>
            </div>
        </cfoutput>

        <!--- Submit Button --->
        <div class="form-group text-center col-md-12">
            <button class="btn btn-xs btn-primary waves-effect mb-2 waves-light" style="background-color: ##406e8e; border: ##406e8e;" type="submit">Update</button>
        </div>
    </div>
</form>
