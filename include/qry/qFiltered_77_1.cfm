<cfparam name="contacts_table" default="contacts" type="string">
<cfparam name="userid" default="#userid#" type="numeric">
<cfparam name="eventid" default="0" type="numeric">
<cfparam name="draw" default="1" type="integer" />
<cfparam name="start" default="0" type="integer" />
<cfparam name="length" default="10" type="integer" />
<cfparam name="search" default="" type="string" />
<cfset listColumns = "col1,col2,col3,col4,col5" />

<cfif structKeyExists(form, "search[value]") and len(form["search[value]"]) gt 0>
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
<cfset qFiltered = contactService.getFilteredContactsByEvent(
    contacts_table = contacts_table,
    userid = userid,
    eventid = eventid,
    search = search,
    listColumns = listColumns,
    formOrderColumn = formOrderColumn,
    formOrderDir = formOrderDir
)>

<cfif NOT isQuery(qFiltered)>
    <cfthrow message="The query did not execute properly.">
</cfif>

<cfoutput>
    {
        "draw": #draw#,
        "recordsTotal": #qFiltered.recordcount#,
        "recordsFiltered": #qFiltered.recordcount#,
        "data": [
            <cfloop query="qFiltered">
            {
                "contactid": "#contactid#",
                "col1": "#col1#",
                "col2": "#col2#",
                "col3": "#col3#",
                "col4": "#col4#",
                "col5": "#col5#",
                "userid": "#userid#",
                "hlink": "#hlink#"
            }<cfif qFiltered.currentRow lt qFiltered.recordcount>,</cfif>
            </cfloop>
        ]
    }
</cfoutput>

