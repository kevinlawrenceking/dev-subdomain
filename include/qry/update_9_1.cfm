<!--- Safely setup form parameters with cfparam --->
<cfparam name="form.ticketid" default="0" />
<cfparam name="form.new_ticketname" default="" />
<cfparam name="form.new_ticketdetails" default="" />
<cfparam name="form.new_ticketresponse" default="" />
<cfparam name="form.new_ticketstatus" default="" />
<cfparam name="form.new_tickettype" default="" />
<cfparam name="form.new_testingscript" default="" />
<cfparam name="form.new_patchnote" default="" />
<cfparam name="form.new_environ" default="" />
<cfparam name="form.new_ticketpriority" default="" />
<cfparam name="form.new_userid" default="0" />
<cfparam name="form.new_verid" default="0" />
<cfparam name="form.new_pgid" default="0" />
<cfparam name="form.new_esthours" default="0" />

<cfset ticketService = request.svc("TicketService")>
<cfset ticketService.UPDtickets(
    ticketid = form.ticketid,
    new_ticketname = form.new_ticketname,
    new_ticketdetails = form.new_ticketdetails,
    new_ticketresponse = form.new_ticketresponse,
    new_ticketStatus = form.new_ticketstatus,
    new_ticketType = form.new_tickettype,
    new_testingscript = form.new_testingscript,
    new_patchNote = form.new_patchnote,
    new_environ = form.new_environ,
    new_ticketPriority = form.new_ticketpriority,
    new_userid = isNumeric(form.new_userid) AND form.new_userid NEQ "" ? form.new_userid : 0,
    new_verid = isNumeric(form.new_verid) AND form.new_verid NEQ "" ? form.new_verid : 0,
    new_pgid = isNumeric(form.new_pgid) AND form.new_pgid NEQ "" ? form.new_pgid : 0,
    new_esthours = isNumeric(form.new_esthours) AND form.new_esthours NEQ "" ? decimalformat(form.new_esthours) : 0
)>