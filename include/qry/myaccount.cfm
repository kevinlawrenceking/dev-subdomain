<!--- This ColdFusion page processes user input and displays results based on certain conditions. --->

<cfset userInput = "">

<!--- Check if the form is submitted --->
<cfif structKeyExists(form, "submit")>
    <cfset userInput = trim(form.inputField)>

    <!--- Validate user input --->
    <cfif userInput neq "">
        <cfset result = "You entered: " & userInput>
    <cfelse>
        <cfset result = "Input cannot be empty.">
    </cfif>
</cfif>

<!--- Display the result --->
<cfoutput>
    <h1>Result</h1>
    <p>#result#</p>
</cfoutput>

<!--- Loop through a list of items and display them --->
<cfset items = ["Item 1", "Item 2", "Item 3"]>
<cfloop array="#items#" index="item">
    <cfoutput>
        <p>#item#</p>
    </cfoutput>
</cfloop>
