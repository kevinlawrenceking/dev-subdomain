<cfparam name="contacts_table" default="#contacts_table#" type="string">
<cfparam name="userid" default="#userid#" type="numeric">
<cfparam name="draw" default="1" type="integer" />
<cfparam name="start" default="0" type="integer" />
<cfparam name="length" default="10" type="integer" />
<cfparam name="search" default="" type="string" />
<cfparam name="uploadid" default="0" type="integer" />
<cfparam name="bytag" default="" type="string" />
<cfparam name="byimport" default="" type="string" />
<cfparam name="bylike" default="" type="string" />
<cfset listColumns = "col1,col2,col2b,col3,col4,col5" />
<cfset sIndexColumn = "contactid" />

<cfif len(form["search[value]"]) gt 0>
    <cfset search = form["search[value]"]>
</cfif>

<cfif structKeyExists(form, "order[0][column]")>
    <cfset formOrderColumn = form["order[0][column]"]>
    <cfset formOrderDir = form["order[0][dir]"]>
<cfelse>
    <cfset formOrderColumn = "">
    <cfset formOrderDir = "asc">
</cfif>

<cfset contactService = createObject("component", "services.ContactService")>
<cfset qFiltered = contactService.getFilteredContacts(
    contacts_table = contacts_table,
    userid = userid,
    bytag = bytag,
    byimport = byimport,
    bylike = bylike,
    uploadid = uploadid,
    search = search,
    listColumns = listColumns,
    formOrderColumn = formOrderColumn,
    formOrderDir = formOrderDir
)>

<cfif NOT isQuery(qFiltered)>
    <cfthrow message="The query did not execute properly.">
</cfif>