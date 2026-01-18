<!--- This ColdFusion page formats a phone number based on specific rules and outputs the formatted version. --->
<cfset cleanPhoneNumber = reReplace(phoneNumber, "[^0-9]|^\+1(?=\d{10})$", "", "ALL")>

<!--- Check if the cleaned phone number has a length of 10 digits --->
<cfif "#len(cleanPhoneNumber)#" is "10">
    
    <cfoutput>
        <!--- Format the phone number into a standard format --->
        <cfset formatPhoneNumber = "(#left(cleanPhoneNumber, 3)#) #mid(cleanPhoneNumber, 4, 3)#-#right(cleanPhoneNumber, 4)#" />
        <cfset anchorPhoneNumber = "#left(cleanPhoneNumber, 3)#-#mid(cleanPhoneNumber, 4, 3)#-#right(cleanPhoneNumber, 4)#" />
    </cfoutput>
    
<cfelse>
    <cfoutput>
        <!--- If the phone number is not 10 digits, use the original phone number --->
        <cfset formatPhoneNumber = "#phoneNumber#" /> 
        <cfset anchorPhoneNumber = "#cleanPhoneNumber#" /> 
    </cfoutput>
</cfif>

<!--- Set the formatted phone number variables for later use --->
<cfset formatphonenumber = cleanphonenumber />
<cfset anchorPhoneNumber = cleanphonenumber />
