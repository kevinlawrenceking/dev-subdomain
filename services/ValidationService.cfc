<cfcomponent displayname="ValidationService" hint="Field-level and row-level validation for contact imports">

<!--- ========================================
      VALIDATION SERVICE
      Purpose: Validate, normalize, and report
      errors for contact import data. Never
      throws; returns structured results.
     ======================================== --->

<!--- ========================================
      EMAIL VALIDATION
     ======================================== --->

<cffunction name="validateEmail" access="public" returntype="struct" output="false"
    hint="Validate and normalize email address">
    <cfargument name="value" type="string" required="true">

    <cfset var result = {
        valid: true,
        normalized: "",
        error: "",
        warning: ""
    }>

    <!--- Handle empty --->
    <cfset var trimmed = trim(arguments.value)>
    <cfif not len(trimmed)>
        <cfset result.normalized = "">
        <cfreturn result>
    </cfif>

    <!--- Normalize: lowercase and trim --->
    <cfset result.normalized = lcase(trimmed)>

    <!--- Remove mailto: prefix if present --->
    <cfif left(result.normalized, 7) eq "mailto:">
        <cfset result.normalized = mid(result.normalized, 8, len(result.normalized) - 7)>
    </cfif>

    <!--- Check max length (RFC 5321) --->
    <cfif len(result.normalized) gt 254>
        <cfset result.valid = false>
        <cfset result.error = "Email exceeds maximum length of 254 characters">
        <cfreturn result>
    </cfif>

    <!--- Basic format validation --->
    <cfset var emailPattern = "^[a-zA-Z0-9.!##$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$">

    <cfif not reFindNoCase(emailPattern, result.normalized)>
        <cfset result.valid = false>
        <cfset result.error = "Invalid email format">
        <cfreturn result>
    </cfif>

    <!--- Check for common typos --->
    <cfif reFindNoCase("@(gmial|gmal|gamil|gnail)\.", result.normalized)>
        <cfset result.warning = "Did you mean @gmail.com?">
    <cfelseif reFindNoCase("@(yaho|yahooo|tahoo)\.", result.normalized)>
        <cfset result.warning = "Did you mean @yahoo.com?">
    <cfelseif reFindNoCase("@(hotmal|hotmial)\.", result.normalized)>
        <cfset result.warning = "Did you mean @hotmail.com?">
    </cfif>

    <cfreturn result>
</cffunction>


<!--- ========================================
      PHONE VALIDATION
     ======================================== --->

<cffunction name="validatePhone" access="public" returntype="struct" output="false"
    hint="Validate and normalize phone number">
    <cfargument name="value" type="string" required="true">

    <cfset var result = {
        valid: true,
        normalized: "",
        error: "",
        warning: ""
    }>

    <!--- Handle empty --->
    <cfset var trimmed = trim(arguments.value)>
    <cfif not len(trimmed)>
        <cfset result.normalized = "">
        <cfreturn result>
    </cfif>

    <!--- Extract digits and plus sign --->
    <cfset var cleaned = reReplace(trimmed, "[^0-9+]", "", "ALL")>

    <!--- Handle leading plus --->
    <cfset var hasPlus = left(cleaned, 1) eq "+">
    <cfset var digitsOnly = reReplace(cleaned, "[^0-9]", "", "ALL")>

    <!--- Check minimum length --->
    <cfif len(digitsOnly) lt 7>
        <cfset result.valid = false>
        <cfset result.error = "Phone number too short (minimum 7 digits)">
        <cfset result.normalized = trimmed>
        <cfreturn result>
    </cfif>

    <!--- Check maximum length --->
    <cfif len(digitsOnly) gt 15>
        <cfset result.valid = false>
        <cfset result.error = "Phone number too long (maximum 15 digits)">
        <cfset result.normalized = trimmed>
        <cfreturn result>
    </cfif>

    <!--- Format based on length --->
    <cfif len(digitsOnly) eq 10 and not hasPlus>
        <!--- US format: (XXX) XXX-XXXX --->
        <cfset result.normalized = "(" & left(digitsOnly, 3) & ") " & mid(digitsOnly, 4, 3) & "-" & right(digitsOnly, 4)>
    <cfelseif len(digitsOnly) eq 11 and left(digitsOnly, 1) eq "1" and not hasPlus>
        <!--- US with country code: +1 (XXX) XXX-XXXX --->
        <cfset result.normalized = "+1 (" & mid(digitsOnly, 2, 3) & ") " & mid(digitsOnly, 5, 3) & "-" & right(digitsOnly, 4)>
    <cfelseif hasPlus>
        <!--- International format: +XX XXX XXX XXXX --->
        <cfset result.normalized = "+" & digitsOnly>
    <cfelse>
        <!--- Keep as-is but cleaned --->
        <cfset result.normalized = digitsOnly>
    </cfif>

    <cfreturn result>
</cffunction>


<!--- ========================================
      DATE VALIDATION
     ======================================== --->

<cffunction name="validateDate" access="public" returntype="struct" output="false"
    hint="Validate and normalize date value">
    <cfargument name="value" type="string" required="true">
    <cfargument name="formats" type="array" required="false" default="#[]#">

    <cfset var result = {
        valid: true,
        normalized: "",
        error: "",
        warning: "",
        originalFormat: ""
    }>

    <!--- Handle empty --->
    <cfset var trimmed = trim(arguments.value)>
    <cfif not len(trimmed)>
        <cfset result.normalized = "">
        <cfreturn result>
    </cfif>

    <!--- Try multiple date formats --->
    <cfset var dateFormats = [
        "yyyy-mm-dd",
        "mm/dd/yyyy",
        "m/d/yyyy",
        "mm-dd-yyyy",
        "dd/mm/yyyy",
        "d/m/yyyy",
        "dd-mm-yyyy",
        "yyyy/mm/dd",
        "mmm d, yyyy",
        "mmmm d, yyyy",
        "d mmm yyyy"
    ]>

    <!--- Add custom formats if provided --->
    <cfif arrayLen(arguments.formats)>
        <cfset dateFormats = arguments.formats>
    </cfif>

    <!--- Check if value looks like an Excel date serial --->
    <cfif isNumeric(trimmed) and val(trimmed) gt 1 and val(trimmed) lt 100000>
        <cftry>
            <!--- Convert Excel serial to date --->
            <!--- Excel base date is Jan 1, 1900 (serial 1) --->
            <!--- But there's a bug where Excel thinks 1900 was a leap year --->
            <cfset var excelBase = createDate(1899, 12, 30)>
            <cfset var parsedDate = dateAdd("d", val(trimmed), excelBase)>

            <!--- Validate reasonable range --->
            <cfif year(parsedDate) gte 1900 and year(parsedDate) lte 2100>
                <cfset result.normalized = dateFormat(parsedDate, "yyyy-mm-dd")>
                <cfset result.originalFormat = "Excel serial">
                <cfreturn result>
            </cfif>

            <cfcatch>
                <!--- Not a valid Excel date --->
            </cfcatch>
        </cftry>
    </cfif>

    <!--- Try parsing with ColdFusion's isDate --->
    <cfif isDate(trimmed)>
        <cftry>
            <cfset var parsedDate = parseDateTime(trimmed)>

            <!--- Validate reasonable range --->
            <cfif year(parsedDate) lt 1900 or year(parsedDate) gt 2100>
                <cfset result.valid = false>
                <cfset result.error = "Date out of reasonable range (1900-2100)">
                <cfset result.normalized = trimmed>
                <cfreturn result>
            </cfif>

            <cfset result.normalized = dateFormat(parsedDate, "yyyy-mm-dd")>
            <cfset result.originalFormat = "auto-detected">
            <cfreturn result>

            <cfcatch>
                <!--- Fall through to format-specific parsing --->
            </cfcatch>
        </cftry>
    </cfif>

    <!--- Try format-specific parsing --->
    <cfloop array="#dateFormats#" index="fmt">
        <cftry>
            <cfset var parsedDate = parseDateTime(trimmed, fmt)>

            <cfif year(parsedDate) gte 1900 and year(parsedDate) lte 2100>
                <cfset result.normalized = dateFormat(parsedDate, "yyyy-mm-dd")>
                <cfset result.originalFormat = fmt>
                <cfreturn result>
            </cfif>

            <cfcatch>
                <!--- Try next format --->
            </cfcatch>
        </cftry>
    </cfloop>

    <!--- Check for ambiguous date (could be MM/DD or DD/MM) --->
    <cfif reFindNoCase("^\d{1,2}[/\-]\d{1,2}[/\-]\d{2,4}$", trimmed)>
        <cfset var parts = reMatch("\d+", trimmed)>
        <cfif arrayLen(parts) eq 3>
            <cfset var first = val(parts[1])>
            <cfset var second = val(parts[2])>
            <cfif first lte 12 and second lte 12 and first neq second>
                <cfset result.warning = "Ambiguous date format. Interpreted as #result.originalFormat#.">
            </cfif>
        </cfif>
    </cfif>

    <!--- Could not parse --->
    <cfset result.valid = false>
    <cfset result.error = "Could not parse date. Expected formats: YYYY-MM-DD, MM/DD/YYYY, etc.">
    <cfset result.normalized = trimmed>

    <cfreturn result>
</cffunction>


<!--- ========================================
      URL VALIDATION
     ======================================== --->

<cffunction name="validateURL" access="public" returntype="struct" output="false"
    hint="Validate and normalize URL">
    <cfargument name="value" type="string" required="true">

    <cfset var result = {
        valid: true,
        normalized: "",
        error: "",
        warning: ""
    }>

    <!--- Handle empty --->
    <cfset var trimmed = trim(arguments.value)>
    <cfif not len(trimmed)>
        <cfset result.normalized = "">
        <cfreturn result>
    </cfif>

    <!--- Add protocol if missing --->
    <cfif not reFindNoCase("^https?://", trimmed)>
        <cfset trimmed = "https://" & trimmed>
        <cfset result.warning = "Added https:// prefix">
    </cfif>

    <!--- Basic URL format check --->
    <cfset var urlPattern = "^https?://[a-zA-Z0-9][-a-zA-Z0-9]*(\.[a-zA-Z0-9][-a-zA-Z0-9]*)+(/[-a-zA-Z0-9()@:%_\+.~##?&//=]*)?$">

    <cfif not reFindNoCase(urlPattern, trimmed)>
        <!--- Try more lenient validation for edge cases --->
        <cfif not reFindNoCase("^https?://[^\s]+$", trimmed)>
            <cfset result.valid = false>
            <cfset result.error = "Invalid URL format">
            <cfset result.normalized = arguments.value>
            <cfreturn result>
        </cfif>
    </cfif>

    <!--- Check max length --->
    <cfif len(trimmed) gt 500>
        <cfset result.valid = false>
        <cfset result.error = "URL exceeds maximum length of 500 characters">
        <cfset result.normalized = arguments.value>
        <cfreturn result>
    </cfif>

    <cfset result.normalized = trimmed>
    <cfreturn result>
</cffunction>


<!--- ========================================
      STRING VALIDATION
     ======================================== --->

<cffunction name="validateString" access="public" returntype="struct" output="false"
    hint="Validate and normalize string value">
    <cfargument name="value" type="string" required="true">
    <cfargument name="maxLength" type="numeric" required="false" default="255">
    <cfargument name="minLength" type="numeric" required="false" default="0">
    <cfargument name="allowEmpty" type="boolean" required="false" default="true">

    <cfset var result = {
        valid: true,
        normalized: "",
        error: "",
        warning: ""
    }>

    <!--- Trim and normalize whitespace --->
    <cfset var trimmed = trim(arguments.value)>
    <!--- Normalize internal whitespace (multiple spaces to single) --->
    <cfset trimmed = reReplace(trimmed, "\s+", " ", "ALL")>
    <!--- Normalize line breaks --->
    <cfset trimmed = reReplace(trimmed, "[\r\n]+", " ", "ALL")>

    <cfset result.normalized = trimmed>

    <!--- Check empty --->
    <cfif not len(trimmed)>
        <cfif not arguments.allowEmpty>
            <cfset result.valid = false>
            <cfset result.error = "This field is required">
        </cfif>
        <cfreturn result>
    </cfif>

    <!--- Check minimum length --->
    <cfif len(trimmed) lt arguments.minLength>
        <cfset result.valid = false>
        <cfset result.error = "Must be at least " & arguments.minLength & " characters">
        <cfreturn result>
    </cfif>

    <!--- Check maximum length --->
    <cfif len(trimmed) gt arguments.maxLength>
        <cfset result.valid = false>
        <cfset result.error = "Exceeds maximum length of " & arguments.maxLength & " characters">
        <cfset result.warning = "Value will be truncated">
        <!--- Truncate --->
        <cfset result.normalized = left(trimmed, arguments.maxLength)>
    </cfif>

    <cfreturn result>
</cffunction>


<cffunction name="validateRequired" access="public" returntype="struct" output="false"
    hint="Validate that a field has a value">
    <cfargument name="value" type="string" required="true">
    <cfargument name="fieldName" type="string" required="false" default="This field">

    <cfset var result = {
        valid: true,
        normalized: trim(arguments.value),
        error: "",
        warning: ""
    }>

    <cfif not len(trim(arguments.value))>
        <cfset result.valid = false>
        <cfset result.error = arguments.fieldName & " is required">
    </cfif>

    <cfreturn result>
</cffunction>


<!--- ========================================
      TAG VALIDATION
     ======================================== --->

<cffunction name="validateTag" access="public" returntype="struct" output="false"
    hint="Validate and normalize tag value">
    <cfargument name="value" type="string" required="true">

    <cfset var result = {
        valid: true,
        normalized: "",
        error: "",
        warning: ""
    }>

    <!--- Handle empty --->
    <cfset var trimmed = trim(arguments.value)>
    <cfif not len(trimmed)>
        <cfset result.normalized = "">
        <cfreturn result>
    </cfif>

    <!--- Normalize whitespace --->
    <cfset trimmed = reReplace(trimmed, "\s+", " ", "ALL")>

    <!--- Check max length (TAO uses 40 char limit for tags) --->
    <cfif len(trimmed) gt 40>
        <cfset result.warning = "Tag truncated to 40 characters">
        <cfset result.normalized = left(trimmed, 40)>
    <cfelse>
        <cfset result.normalized = trimmed>
    </cfif>

    <cfreturn result>
</cffunction>


<!--- ========================================
      ROW-LEVEL VALIDATION
     ======================================== --->

<cffunction name="validateRow" access="public" returntype="struct" output="false"
    hint="Validate an entire row of contact data">
    <cfargument name="rowData" type="struct" required="true">
    <cfargument name="fieldRules" type="struct" required="false" default="#{}#">

    <cfset var result = {
        valid: true,
        normalized: {},
        validation: {},
        errorCount: 0,
        warningCount: 0
    }>

    <!--- Default field rules --->
    <cfset var rules = {
        firstName: {type: "string", maxLength: 100, required: false},
        lastName: {type: "string", maxLength: 100, required: false},
        contactFullName: {type: "string", maxLength: 255, required: false},
        email_business: {type: "email", required: false},
        email_personal: {type: "email", required: false},
        phone_work: {type: "phone", required: false},
        phone_mobile: {type: "phone", required: false},
        phone_home: {type: "phone", required: false},
        company: {type: "string", maxLength: 255, required: false},
        department: {type: "string", maxLength: 255, required: false},
        jobTitle: {type: "string", maxLength: 255, required: false},
        address_street: {type: "string", maxLength: 255, required: false},
        address_extended: {type: "string", maxLength: 255, required: false},
        address_city: {type: "string", maxLength: 100, required: false},
        address_state: {type: "string", maxLength: 100, required: false},
        address_zip: {type: "string", maxLength: 20, required: false},
        address_country: {type: "string", maxLength: 100, required: false},
        tag1: {type: "tag", required: false},
        tag2: {type: "tag", required: false},
        tag3: {type: "tag", required: false},
        website: {type: "url", required: false},
        birthday: {type: "date", required: false},
        meetingDate: {type: "date", required: false},
        meetingLocation: {type: "string", maxLength: 255, required: false},
        notes: {type: "text", maxLength: 65535, required: false}
    }>

    <!--- Merge custom rules --->
    <cfloop collection="#arguments.fieldRules#" item="field">
        <cfset rules[field] = arguments.fieldRules[field]>
    </cfloop>

    <!--- Validate each field --->
    <cfloop collection="#arguments.rowData#" item="field">
        <cfset var value = arguments.rowData[field]>
        <cfset var fieldValidation = {valid: true, error: "", warning: ""}>

        <!--- Get rule for this field --->
        <cfif structKeyExists(rules, field)>
            <cfset var rule = rules[field]>

            <!--- Validate by type --->
            <cfswitch expression="#rule.type#">
                <cfcase value="email">
                    <cfset var vResult = validateEmail(value)>
                </cfcase>
                <cfcase value="phone">
                    <cfset var vResult = validatePhone(value)>
                </cfcase>
                <cfcase value="date">
                    <cfset var vResult = validateDate(value)>
                </cfcase>
                <cfcase value="url">
                    <cfset var vResult = validateURL(value)>
                </cfcase>
                <cfcase value="tag">
                    <cfset var vResult = validateTag(value)>
                </cfcase>
                <cfcase value="text">
                    <cfset var vResult = validateString(value, structKeyExists(rule, "maxLength") ? rule.maxLength : 65535)>
                </cfcase>
                <cfdefaultcase>
                    <cfset var vResult = validateString(value, structKeyExists(rule, "maxLength") ? rule.maxLength : 255)>
                </cfdefaultcase>
            </cfswitch>

            <!--- Check required --->
            <cfif structKeyExists(rule, "required") and rule.required and not len(trim(vResult.normalized))>
                <cfset vResult.valid = false>
                <cfset vResult.error = "This field is required">
            </cfif>

            <!--- Store results --->
            <cfset result.normalized[field] = vResult.normalized>

            <cfif not vResult.valid or len(vResult.error)>
                <cfset fieldValidation.valid = false>
                <cfset fieldValidation.error = vResult.error>
                <cfset result.errorCount++>
            </cfif>

            <cfif len(vResult.warning)>
                <cfset fieldValidation.warning = vResult.warning>
                <cfset result.warningCount++>
            </cfif>

            <cfset result.validation[field] = fieldValidation>
        <cfelse>
            <!--- Unknown field, just normalize as string --->
            <cfset var vResult = validateString(value)>
            <cfset result.normalized[field] = vResult.normalized>
        </cfif>
    </cfloop>

    <!--- Check that we have at least a name --->
    <cfset var hasName = false>
    <cfif structKeyExists(result.normalized, "firstName") and len(result.normalized.firstName)>
        <cfset hasName = true>
    </cfif>
    <cfif structKeyExists(result.normalized, "lastName") and len(result.normalized.lastName)>
        <cfset hasName = true>
    </cfif>
    <cfif structKeyExists(result.normalized, "contactFullName") and len(result.normalized.contactFullName)>
        <cfset hasName = true>
    </cfif>

    <cfif not hasName>
        <!--- Add error for missing name --->
        <cfset result.validation["_row"] = {
            valid: false,
            error: "At least one name field (First Name, Last Name, or Full Name) is required"
        }>
        <cfset result.errorCount++>
    </cfif>

    <!--- Set overall validity --->
    <cfset result.valid = result.errorCount eq 0>

    <cfreturn result>
</cffunction>


<!--- ========================================
      BATCH VALIDATION
     ======================================== --->

<cffunction name="validateBatch" access="public" returntype="struct" output="false"
    hint="Validate multiple rows and return summary">
    <cfargument name="rows" type="array" required="true">
    <cfargument name="fieldRules" type="struct" required="false" default="#{}#">

    <cfset var result = {
        totalRows: arrayLen(arguments.rows),
        validRows: 0,
        problemRows: 0,
        results: []
    }>

    <cfloop array="#arguments.rows#" index="row">
        <cfset var rowResult = validateRow(row, arguments.fieldRules)>
        <cfset arrayAppend(result.results, rowResult)>

        <cfif rowResult.valid>
            <cfset result.validRows++>
        <cfelse>
            <cfset result.problemRows++>
        </cfif>
    </cfloop>

    <cfreturn result>
</cffunction>


<!--- ========================================
      NORMALIZATION HELPERS
     ======================================== --->

<cffunction name="normalizeFullName" access="public" returntype="struct" output="false"
    hint="Create full name from parts or parse full name into parts">
    <cfargument name="firstName" type="string" required="false" default="">
    <cfargument name="lastName" type="string" required="false" default="">
    <cfargument name="fullName" type="string" required="false" default="">

    <cfset var result = {
        firstName: trim(arguments.firstName),
        lastName: trim(arguments.lastName),
        fullName: trim(arguments.fullName)
    }>

    <!--- If we have full name but not parts, try to split --->
    <cfif len(result.fullName) and not len(result.firstName) and not len(result.lastName)>
        <cfset var nameParts = listToArray(result.fullName, " ")>
        <cfif arrayLen(nameParts) gte 2>
            <cfset result.firstName = nameParts[1]>
            <cfset arrayDeleteAt(nameParts, 1)>
            <cfset result.lastName = arrayToList(nameParts, " ")>
        <cfelseif arrayLen(nameParts) eq 1>
            <cfset result.firstName = nameParts[1]>
        </cfif>
    </cfif>

    <!--- If we have parts but no full name, combine --->
    <cfif (len(result.firstName) or len(result.lastName)) and not len(result.fullName)>
        <cfset result.fullName = trim(result.firstName & " " & result.lastName)>
    </cfif>

    <cfreturn result>
</cffunction>


<cffunction name="normalizeAddress" access="public" returntype="struct" output="false"
    hint="Normalize address fields">
    <cfargument name="street" type="string" required="false" default="">
    <cfargument name="extended" type="string" required="false" default="">
    <cfargument name="city" type="string" required="false" default="">
    <cfargument name="state" type="string" required="false" default="">
    <cfargument name="zip" type="string" required="false" default="">
    <cfargument name="country" type="string" required="false" default="">

    <cfset var result = {
        street: trim(arguments.street),
        extended: trim(arguments.extended),
        city: trim(arguments.city),
        state: trim(arguments.state),
        zip: trim(arguments.zip),
        country: trim(arguments.country)
    }>

    <!--- Normalize US state abbreviations --->
    <cfset var stateAbbrevs = {
        "alabama": "AL", "alaska": "AK", "arizona": "AZ", "arkansas": "AR",
        "california": "CA", "colorado": "CO", "connecticut": "CT", "delaware": "DE",
        "florida": "FL", "georgia": "GA", "hawaii": "HI", "idaho": "ID",
        "illinois": "IL", "indiana": "IN", "iowa": "IA", "kansas": "KS",
        "kentucky": "KY", "louisiana": "LA", "maine": "ME", "maryland": "MD",
        "massachusetts": "MA", "michigan": "MI", "minnesota": "MN", "mississippi": "MS",
        "missouri": "MO", "montana": "MT", "nebraska": "NE", "nevada": "NV",
        "new hampshire": "NH", "new jersey": "NJ", "new mexico": "NM", "new york": "NY",
        "north carolina": "NC", "north dakota": "ND", "ohio": "OH", "oklahoma": "OK",
        "oregon": "OR", "pennsylvania": "PA", "rhode island": "RI", "south carolina": "SC",
        "south dakota": "SD", "tennessee": "TN", "texas": "TX", "utah": "UT",
        "vermont": "VT", "virginia": "VA", "washington": "WA", "west virginia": "WV",
        "wisconsin": "WI", "wyoming": "WY", "district of columbia": "DC"
    }>

    <cfif len(result.state) and structKeyExists(stateAbbrevs, lcase(result.state))>
        <cfset result.state = stateAbbrevs[lcase(result.state)]>
    <cfelseif len(result.state) eq 2>
        <cfset result.state = ucase(result.state)>
    </cfif>

    <!--- Normalize US country variants --->
    <cfset var usVariants = "usa,us,united states,united states of america,u.s.,u.s.a.">
    <cfif len(result.country) and listFindNoCase(usVariants, lcase(result.country))>
        <cfset result.country = "US">
    </cfif>

    <!--- Normalize zip code --->
    <cfif len(result.zip)>
        <!--- Remove non-alphanumeric except hyphen --->
        <cfset result.zip = reReplace(result.zip, "[^a-zA-Z0-9\-]", "", "ALL")>
    </cfif>

    <cfreturn result>
</cffunction>

</cfcomponent>
