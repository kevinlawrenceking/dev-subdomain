<!--- This ColdFusion page handles the display and completion of a ticket, including responses and patch notes. --->

<cfinclude template="/include/qry/details_223_1.cfm" />
<cfinclude template="/include/qry/uu_223_2.cfm" />

<div class="row">

    <cfset cur_icon = "">

    <!--- Form for completing the ticket --->
    <form class="px-3 col-md-11" action="/include/ticketcomplete.cfm">

        <cfoutput query="details">

            <div class="form-group">
                <div class="col-md-11">#details.ticketdetails#</div>
            </div>

            <input type="hidden" name="recid" value="#details.recid#" />

            <div class="form-group">
                <label for="emailaddress">Patch Note</label>
                <input class="form-control" type="text" id="patchnote" value="#details.patchnote#" name="patchnote" /> 
            </div>

            <!--- Check if the ticket status is Pending --->
            <cfif #details.col5# is "Pending">

                <div class="form-group">
                    <label for="emailaddress">Response</label>
                    <textarea class="form-control" type="text" id="ticketresponse" name="ticketresponse" rows="4">#details.ticketresponse#</textarea>
                </div>

                <div class="form-check">
                    <input type="checkbox" name="email_user" value="Y" class="form-check-input" id="customCheck1" />
                    <label class="form-check-label" for="customCheck1">Email User</label>
                </div>

                <div class="form-group text-center">
                    <button class="btn btn-primary" type="submit">Completed</button>
                </div>
            </cfif>

        </cfoutput>

        <!--- Check if the ticket status is Completed --->
        <cfif #details.col5# is "Completed">
            <div class="form-group text-center">
                <a href="/include/ticketclose.cfm?recid=#recid#&userid=#uu.userid#"> Close Ticket</a>
            </div>
            <p>Ticket has been reviewed by #uu.userFirstName# #uu.userLastName#</p>
        </cfif>

        <cfoutput>
            <!--- Check if the user ID is 30 for special access --->
            <cfif #userid# is "30">
                <p><a href="/include/ticketpass.cfm?recid=#recid#">pass</a></p>
            </cfif>
        </cfoutput>
    </form>
</div>
