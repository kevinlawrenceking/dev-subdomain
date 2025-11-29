<!---
    Component: ContactImportValidationService
    Purpose: Validate contact import data and provide preview information
    Author: TAO Development
    Date: 2025-11-26
    Phase: 1 - Contact Import Upgrade
--->

<cfcomponent displayname="ContactImportValidationService" hint="Validates contact import data">

<!--- ========================================
      VALIDATION METHODS
     ======================================== --->

<cffunction name="validateImportData" access="public" returntype="struct" output="false"
            hint="Validate imported contact data and return summary">
    <cfargument name="importQuery" type="query" required="true" hint="Query containing imported data">
    <cfargument name="userid" type="numeric" required="true" hint="User ID performing the import">

    <!--- Initialize result structure --->
    <cfset var result = {
        valid: true,
        newCount: 0,
        updateCount: 0,
        errorCount: 0,
        errors: [],
        warnings: [],
        duplicates: [],
        summary: ""
    }>

    <!--- Skip header row if present, start from row 2 --->
    <cfset var startRow = 2>

    <!--- Validate each row --->
    <cfloop query="arguments.importQuery" startrow="#startRow#">
        <cfset var rowNum = arguments.importQuery.currentRow>
        <cfset var rowErrors = []>
        <cfset var fullName = trim(arguments.importQuery.FirstName) & " " & trim(arguments.importQuery.LastName)>

        <!--- ========================================
              REQUIRED FIELD VALIDATION
             ======================================== --->

        <!--- Require at least first name OR last name --->
        <cfif NOT len(trim(arguments.importQuery.FirstName)) AND NOT len(trim(arguments.importQuery.LastName))>
            <cfset arrayAppend(rowErrors, "Row #rowNum#: Missing both first and last name")>
        </cfif>

        <!--- Require at least ONE contact method (email or phone) --->
        <cfset var hasContactMethod = (
            len(trim(arguments.importQuery.BusinessEmail)) OR
            len(trim(arguments.importQuery.PersonalEmail)) OR
            len(trim(arguments.importQuery.WorkPhone)) OR
            len(trim(arguments.importQuery.MobilePhone)) OR
            len(trim(arguments.importQuery.HomePhone))
        )>

        <cfif NOT hasContactMethod>
            <cfset arrayAppend(rowErrors, "Row #rowNum#: Missing contact method (must have at least one email or phone)")>
        </cfif>

        <!--- ========================================
              FORMAT VALIDATION
             ======================================== --->

        <!--- Validate business email format --->
        <cfif len(trim(arguments.importQuery.BusinessEmail))>
            <cfif NOT isValid("email", trim(arguments.importQuery.BusinessEmail))>
                <cfset arrayAppend(rowErrors, "Row #rowNum#: Invalid business email format (#trim(arguments.importQuery.BusinessEmail)#)")>
            </cfif>
        </cfif>

        <!--- Validate personal email format --->
        <cfif len(trim(arguments.importQuery.PersonalEmail))>
            <cfif NOT isValid("email", trim(arguments.importQuery.PersonalEmail))>
                <cfset arrayAppend(rowErrors, "Row #rowNum#: Invalid personal email format (#trim(arguments.importQuery.PersonalEmail)#)")>
            </cfif>
        </cfif>

        <!--- Validate date formats --->
        <cfif len(trim(arguments.importQuery.contactMeetingDate))>
            <cfif NOT isDate(trim(arguments.importQuery.contactMeetingDate))>
                <cfset arrayAppend(rowErrors, "Row #rowNum#: Invalid meeting date format")>
            </cfif>
        </cfif>

        <cfif len(trim(arguments.importQuery.Birthday))>
            <cfif NOT isDate(trim(arguments.importQuery.Birthday))>
                <cfset arrayAppend(rowErrors, "Row #rowNum#: Invalid birthday format")>
            </cfif>
        </cfif>

        <!--- ========================================
              DUPLICATE CHECK
             ======================================== --->

        <cfif arrayLen(rowErrors) EQ 0>
            <!--- Only check for duplicates if row has no validation errors --->
            <cfset var duplicateCheck = checkForDuplicate(
                fullName,
                trim(arguments.importQuery.BusinessEmail),
                trim(arguments.importQuery.PersonalEmail),
                arguments.userid
            )>

            <cfif duplicateCheck.isDuplicate>
                <cfset result.updateCount++>
                <cfset arrayAppend(result.duplicates, {
                    row: rowNum,
                    name: fullName,
                    matchedContact: duplicateCheck.contactFullName,
                    contactid: duplicateCheck.contactid,
                    matchType: duplicateCheck.matchType
                })>
            <cfelse>
                <cfset result.newCount++>
            </cfif>
        <cfelse>
            <!--- Row has errors --->
            <cfset result.errorCount++>
            <cfset result.valid = false>
            <cfset arrayAppend(result.errors, {
                row: rowNum,
                name: fullName,
                errors: rowErrors
            })>
        </cfif>
    </cfloop>

    <!--- Generate summary message --->
    <cfset result.summary = generateSummary(result)>

    <cfreturn result>
</cffunction>

<!--- ========================================
      DUPLICATE DETECTION
     ======================================== --->

<cffunction name="checkForDuplicate" access="private" returntype="struct" output="false"
            hint="Check if contact already exists based on name or email">
    <cfargument name="fullName" type="string" required="true">
    <cfargument name="businessEmail" type="string" required="true">
    <cfargument name="personalEmail" type="string" required="true">
    <cfargument name="userid" type="numeric" required="true">

    <cfset var result = {
        isDuplicate: false,
        contactid: 0,
        contactFullName: "",
        matchType: ""
    }>

    <!--- Check for exact name match --->
    <cfquery name="checkName" maxrows="1">
        SELECT contactid, contactFullName
        FROM contactdetails
        WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        AND contactFullName = <cfqueryparam value="#arguments.fullName#" cfsqltype="CF_SQL_VARCHAR">
        AND (isdeleted IS NULL OR isdeleted = 0)
    </cfquery>

    <cfif checkName.recordCount GT 0>
        <cfset result.isDuplicate = true>
        <cfset result.contactid = checkName.contactid>
        <cfset result.contactFullName = checkName.contactFullName>
        <cfset result.matchType = "name">
        <cfreturn result>
    </cfif>

    <!--- Check for business email match --->
    <cfif len(trim(arguments.businessEmail))>
        <cfquery name="checkBusinessEmail" maxrows="1">
            SELECT d.contactid, d.contactFullName
            FROM contactdetails d
            INNER JOIN contactitems i ON i.contactid = d.contactid
            WHERE d.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
            AND i.valuetext = <cfqueryparam value="#trim(arguments.businessEmail)#" cfsqltype="CF_SQL_VARCHAR">
            AND i.valuecategory = 'Email'
            AND i.itemstatus = 'Active'
            AND (d.isdeleted IS NULL OR d.isdeleted = 0)
        </cfquery>

        <cfif checkBusinessEmail.recordCount GT 0>
            <cfset result.isDuplicate = true>
            <cfset result.contactid = checkBusinessEmail.contactid>
            <cfset result.contactFullName = checkBusinessEmail.contactFullName>
            <cfset result.matchType = "business email">
            <cfreturn result>
        </cfif>
    </cfif>

    <!--- Check for personal email match --->
    <cfif len(trim(arguments.personalEmail))>
        <cfquery name="checkPersonalEmail" maxrows="1">
            SELECT d.contactid, d.contactFullName
            FROM contactdetails d
            INNER JOIN contactitems i ON i.contactid = d.contactid
            WHERE d.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
            AND i.valuetext = <cfqueryparam value="#trim(arguments.personalEmail)#" cfsqltype="CF_SQL_VARCHAR">
            AND i.valuecategory = 'Email'
            AND i.itemstatus = 'Active'
            AND (d.isdeleted IS NULL OR d.isdeleted = 0)
        </cfquery>

        <cfif checkPersonalEmail.recordCount GT 0>
            <cfset result.isDuplicate = true>
            <cfset result.contactid = checkPersonalEmail.contactid>
            <cfset result.contactFullName = checkPersonalEmail.contactFullName>
            <cfset result.matchType = "personal email">
            <cfreturn result>
        </cfif>
    </cfif>

    <cfreturn result>
</cffunction>

<!--- ========================================
      HELPER METHODS
     ======================================== --->

<cffunction name="generateSummary" access="private" returntype="string" output="false">
    <cfargument name="validationResult" type="struct" required="true">

    <cfset var summary = "">

    <cfif arguments.validationResult.newCount GT 0>
        <cfset summary &= "#arguments.validationResult.newCount# new contact(s) will be created. ">
    </cfif>

    <cfif arguments.validationResult.updateCount GT 0>
        <cfset summary &= "#arguments.validationResult.updateCount# existing contact(s) will be updated. ">
    </cfif>

    <cfif arguments.validationResult.errorCount GT 0>
        <cfset summary &= "#arguments.validationResult.errorCount# row(s) have errors and will be skipped. ">
    </cfif>

    <cfif arguments.validationResult.errorCount EQ 0 AND arguments.validationResult.newCount + arguments.validationResult.updateCount EQ 0>
        <cfset summary = "No valid rows found to import.">
    </cfif>

    <cfreturn summary>
</cffunction>

</cfcomponent>
