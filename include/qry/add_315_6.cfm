<cfset contactService = createObject("component", "services.ContactService")>

<!--- Simulate form submission or variable inputs --->
<cfparam name="fname" default="">
<cfparam name="lname" default="">
<cfparam name="contactMeetingDate" default="">
<cfparam name="contactMeetingLoc" default="">
<cfparam name="birthday" default="">

<!--- Construct contact struct dynamically from submitted variables --->
<cfset new_X = {
    new_id = new.id,
    fname = trim(new.fname),
    lname = trim(new.lname),
    contactMeetingDate = trim(new.contactMeetingDate),
    contactMeetingLoc = trim(new.contactMeetingLoc),
    birthday = trim(new.birthday)
}>

<!--- Call the function and pass variables --->
<cfset result = contactService.INScontactdetails_24399(new_x=new_x, userid=userid)>
<Cfdump var="#result#" />
