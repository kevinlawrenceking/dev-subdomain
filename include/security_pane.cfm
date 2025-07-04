<!--- This ColdFusion page processes user data and displays results based on specific conditions. --->

<cfset userData = []> <!--- Initialize an empty array to store user data --->

<!--- Check if the form has been submitted --->
<cfif structKeyExists(form, "submit")>
    <cfset userName = trim(form.userName)> <!--- Get and trim the username from the form --->
    <cfset userAge = trim(form.userAge)> <!--- Get and trim the user age from the form --->

    <!--- Validate user input --->
    <cfif userName neq "" AND isNumeric(userAge)>
        <cfset userData = [{name=userName, age=userAge}]> <!--- Store valid user data in the array --->
    <cfelse>
        <cfset errorMessage = "Please enter a valid name and age."> <!--- Set error message for invalid input --->
    </cfif>
</cfif>

<!--- Display the user data if available --->
<cfif arrayLen(userData) GT 0>
    <h2>User Data</h2>
    <ul>
        <cfloop array="#userData#" index="user">
            <li>#user.name# is #user.age# years old.</li> <!--- Display each user's name and age --->
        </cfloop>
    </ul>
<cfelse>
<cfif structKeyExists(variables, "errorMessage") AND Len(errorMessage)>
    <p>#encodeForHTML(errorMessage)#</p> <!--- Display error message if present --->
<cfelse>
    <p>No user data available.</p> <!--- Message for no user data --->
</cfif>

</cfif>
