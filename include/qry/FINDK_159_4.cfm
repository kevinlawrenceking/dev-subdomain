<cfset contactService = createObject("component", "services.ContactSSService")>
<cfset FINDK = contactService.SELcontacts_ss_23946(userid=userid, topsearch_myteam=topsearch_myteam)>