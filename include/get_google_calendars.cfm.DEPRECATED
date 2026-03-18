<!--- This ColdFusion page retrieves the user's calendar list from the Google Calendar API and outputs it as JSON --->
<cfset apiUrl = "https://www.googleapis.com/calendar/v3/users/me/calendarList">

<!--- Make an HTTP GET request to the Google Calendar API to retrieve the calendar list --->
<cfhttp url="#apiUrl#" method="get" result="calendarListResponse">
    <cfhttpparam type="header" name="Authorization" value="Bearer #accessToken#">
</cfhttp>

<!--- Abort the processing of the page to prevent further execution --->


<!--- Deserialize the JSON response from the API into a ColdFusion structure --->
<cfset calendars = DeserializeJSON(calendarListResponse.FileContent)>

<!--- Serialize the ColdFusion structure back into JSON format for output --->
<cfset calendarsJSON = SerializeJSON(calendars)>

<!--- Set the content type of the response to application/json --->
<cfheader name="Content-Type" value="application/json">

<!--- Output the JSON response --->
<cfoutput>#calendarsJSON#</cfoutput>
