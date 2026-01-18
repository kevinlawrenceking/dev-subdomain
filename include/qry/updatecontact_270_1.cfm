<cfset contactService = createObject("component", "services.ContactService")>
<cfset contactService.UPDcontactdetails_24202(
    contactid = contactid,
    contactfullname = trim(contactfullname),
    contactPronoun = contactPronoun,
    custom = trim(custom),
    contactbirthday = contactbirthday,
    contactmeetingdate = contactmeetingdate,
    contactmeetingloc = trim(contactmeetingloc),
    deleteitem = (deleteitem is "1"),
    refer_contact_id = refer_contact_id
)>