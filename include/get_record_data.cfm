<!--- This ColdFusion page retrieves a record based on an ID, fetches related categories and sources, and constructs a JSON response. --->

<cfparam name="id" default="460" />

<cfif NOT isNumeric(id)>
    <cfset response = { "error": "Invalid ID" }>
<cfelse>
    <!--- Fetch the record --->
    <cfinclude template="/include/qry/getRecord_132_1.cfm" />

    <!--- Fetch categories and subcategories --->
    <cfinclude template="/include/qry/getCategories_132_2.cfm" />

    <!--- Fetch sources --->
    <cfinclude template="/include/qry/getSources_132_3.cfm" />

    <cfif getRecord.recordcount EQ 0>
        <cfset response = { "error": "Record not found" }>
    <cfelse>
        <!--- Convert the categories query to a struct of arrays for JSON serialization --->
        <cfset categories = []>
        <cfloop query="getCategories">
            <cfset arrayAppend(categories, {id: getCategories.ID, name: getCategories.NAME})>
        </cfloop>

        <!--- Convert the sources query to a struct of arrays for JSON serialization --->
        <cfset sources = []>
        <cfset sourceFound = false>
        <cfloop query="getSources">
            <cfset arrayAppend(sources, {name: getSources.NAME})>
            <cfif getRecord.audsource EQ getSources.NAME>
                <cfset sourceFound = true>
            </cfif>
        </cfloop>

        <!--- Set audSource to "Unknown" if it's not in the list --->
        <cfif NOT sourceFound>
            <cfset getRecord.audsource = "Unknown">
        </cfif>

        <!--- Construct the response JSON --->
        <cfset response = {
            "id": getRecord.id,
            "audsubcatid": getRecord.audsubcatid,
            "projDate": dateFormat(getRecord.projdate, "yyyy-mm-dd"),
            "projName": getRecord.projname,
            "audRoleName": getRecord.audrolename,
            "audSource": getRecord.audsource,
            "cdFirstName": getRecord.cdfirstname,
            "cdLastName": getRecord.cdlastname,
            "callbackYN": getRecord.callback_yn,  
            "redirectYN": getRecord.redirect_yn,
            "pinYN": getRecord.pin_yn,
            "bookedYN": getRecord.booked_yn,
            "projDescription": getRecord.projdescription,
            "charDescription": getRecord.chardescription,
            "note": getRecord.note,
            "status": getRecord.status,
            "categories": categories,
            "sources": sources
        }> 
    </cfif>
</cfif>

<cfcontent type="application/json" reset="true">
<cfoutput>#SerializeJSON(response)#</cfoutput>
