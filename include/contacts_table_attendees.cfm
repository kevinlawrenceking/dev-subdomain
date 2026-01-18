<cfset contactService = createObject("component", "services.ContactService")>

<cfset qFiltered = contactService.getFilteredContactsByEvent(
    contacts_table = contacts_table,
    userid = userid,
    eventid = eventid
)>

<table id="<cfoutput>#contacts_table#</cfoutput>"  class="table display dt-responsive nowrap w-100 table-striped" role="grid">
    <thead>
        <tr>
     
            <th>Name</th>
            <th>Tags</th>
            <th>Company</th>
            <th>Phone</th>
            <th>Email</th>
        </tr>
    </thead>
    <tbody>
        <cfoutput query="qFiltered">
            <tr>
              
                <td>
                <a href="/app/contact/?contactid=#contactid#">#col1#</a>
                </td> <!--- Assuming "Name" --->
                <td>#col2#</td> <!--- Assuming "Tags" --->
                <td>#col5#</td> <!--- Assuming "Company" --->
                <td>#col3#</td> <!--- Assuming "Phone" --->
                <td>#col4#</td> <!--- Assuming "Email" --->
            </tr>
        </cfoutput>
    </tbody>
</table>
