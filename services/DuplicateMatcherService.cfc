<cfcomponent displayname="DuplicateMatcherService" hint="Duplicate detection and matching for contact imports">

<!--- ========================================
      DUPLICATE MATCHER SERVICE
      Purpose: Find potential duplicate contacts
      in the database before import. Uses scoring
      algorithm with configurable thresholds.
     ======================================== --->

<!--- Matching thresholds --->
<cfset this.THRESHOLD_HIGH = 70>
<cfset this.THRESHOLD_MEDIUM = 40>
<cfset this.THRESHOLD_LOW = 25>
<cfset this.MAX_CANDIDATES = 5>

<!--- ========================================
      MAIN MATCHING METHODS
     ======================================== --->

<cffunction name="findDuplicates" access="public" returntype="struct" output="false"
    hint="Find duplicate candidates for a contact row">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="rowData" type="struct" required="true">
    <cfargument name="threshold" type="numeric" required="false" default="#this.THRESHOLD_LOW#">

    <cfset var result = {
        hasDuplicate: false,
        bestMatchScore: 0,
        bestMatchContactId: 0,
        candidates: []
    }>

    <!--- Extract searchable fields from row data --->
    <cfset var email = "">
    <cfset var email2 = "">
    <cfset var phone = "">
    <cfset var phone2 = "">
    <cfset var phone3 = "">
    <cfset var firstName = "">
    <cfset var lastName = "">
    <cfset var fullName = "">
    <cfset var company = "">
    <cfset var city = "">
    <cfset var state = "">

    <!--- Map fields (handle both normalized and raw field names) --->
    <cfif structKeyExists(arguments.rowData, "email_business")>
        <cfset email = lcase(trim(arguments.rowData.email_business))>
    </cfif>
    <cfif structKeyExists(arguments.rowData, "email_personal")>
        <cfset email2 = lcase(trim(arguments.rowData.email_personal))>
    </cfif>
    <cfif structKeyExists(arguments.rowData, "phone_work")>
        <cfset phone = normalizePhoneForMatch(arguments.rowData.phone_work)>
    </cfif>
    <cfif structKeyExists(arguments.rowData, "phone_mobile")>
        <cfset phone2 = normalizePhoneForMatch(arguments.rowData.phone_mobile)>
    </cfif>
    <cfif structKeyExists(arguments.rowData, "phone_home")>
        <cfset phone3 = normalizePhoneForMatch(arguments.rowData.phone_home)>
    </cfif>
    <cfif structKeyExists(arguments.rowData, "firstName")>
        <cfset firstName = trim(arguments.rowData.firstName)>
    </cfif>
    <cfif structKeyExists(arguments.rowData, "lastName")>
        <cfset lastName = trim(arguments.rowData.lastName)>
    </cfif>
    <cfif structKeyExists(arguments.rowData, "contactFullName")>
        <cfset fullName = trim(arguments.rowData.contactFullName)>
    </cfif>
    <cfif structKeyExists(arguments.rowData, "company")>
        <cfset company = trim(arguments.rowData.company)>
    </cfif>
    <cfif structKeyExists(arguments.rowData, "address_city")>
        <cfset city = trim(arguments.rowData.address_city)>
    </cfif>
    <cfif structKeyExists(arguments.rowData, "address_state")>
        <cfset state = trim(arguments.rowData.address_state)>
    </cfif>

    <!--- Build full name if not provided --->
    <cfif not len(fullName) and (len(firstName) or len(lastName))>
        <cfset fullName = trim(firstName & " " & lastName)>
    </cfif>

    <!--- Find candidates by different criteria --->
    <cfset var allCandidates = {}>

    <!--- 1. Email match (strongest signal) --->
    <cfif len(email)>
        <cfset var emailMatches = findByEmail(arguments.userid, email)>
        <cfloop query="emailMatches">
            <cfset addCandidate(allCandidates, emailMatches.contactid, emailMatches, "email", email, 50)>
        </cfloop>
    </cfif>
    <cfif len(email2)>
        <cfset var emailMatches2 = findByEmail(arguments.userid, email2)>
        <cfloop query="emailMatches2">
            <cfset addCandidate(allCandidates, emailMatches2.contactid, emailMatches2, "email", email2, 50)>
        </cfloop>
    </cfif>

    <!--- 2. Phone match (strong signal) --->
    <cfif len(phone)>
        <cfset var phoneMatches = findByPhone(arguments.userid, phone)>
        <cfloop query="phoneMatches">
            <cfset addCandidate(allCandidates, phoneMatches.contactid, phoneMatches, "phone", phone, 40)>
        </cfloop>
    </cfif>
    <cfif len(phone2)>
        <cfset var phoneMatches2 = findByPhone(arguments.userid, phone2)>
        <cfloop query="phoneMatches2">
            <cfset addCandidate(allCandidates, phoneMatches2.contactid, phoneMatches2, "phone", phone2, 40)>
        </cfloop>
    </cfif>
    <cfif len(phone3)>
        <cfset var phoneMatches3 = findByPhone(arguments.userid, phone3)>
        <cfloop query="phoneMatches3">
            <cfset addCandidate(allCandidates, phoneMatches3.contactid, phoneMatches3, "phone", phone3, 40)>
        </cfloop>
    </cfif>

    <!--- 3. Name match (medium signal) --->
    <cfif len(fullName)>
        <cfset var nameMatches = findByName(arguments.userid, fullName)>
        <cfloop query="nameMatches">
            <cfset addCandidate(allCandidates, nameMatches.contactid, nameMatches, "name", fullName, 30)>
        </cfloop>
    </cfif>

    <!--- 4. Name + Company match --->
    <cfif len(fullName) and len(company)>
        <cfset var nameCompanyMatches = findByNameAndCompany(arguments.userid, fullName, company)>
        <cfloop query="nameCompanyMatches">
            <cfset addCandidate(allCandidates, nameCompanyMatches.contactid, nameCompanyMatches, "name+company", fullName & " @ " & company, 25)>
        </cfloop>
    </cfif>

    <!--- 5. Name + City match --->
    <cfif len(fullName) and len(city)>
        <cfset var nameCityMatches = findByNameAndCity(arguments.userid, fullName, city)>
        <cfloop query="nameCityMatches">
            <cfset addCandidate(allCandidates, nameCityMatches.contactid, nameCityMatches, "name+city", fullName & " in " & city, 15)>
        </cfloop>
    </cfif>

    <!--- Convert to sorted array and apply threshold --->
    <cfset var sortedCandidates = []>
    <cfloop collection="#allCandidates#" item="contactid">
        <cfset var candidate = allCandidates[contactid]>
        <cfif candidate.score gte arguments.threshold>
            <cfset arrayAppend(sortedCandidates, candidate)>
        </cfif>
    </cfloop>

    <!--- Sort by score descending --->
    <cfset arraySort(sortedCandidates, function(a, b) {
        return b.score - a.score;
    })>

    <!--- Limit to top N --->
    <cfif arrayLen(sortedCandidates) gt this.MAX_CANDIDATES>
        <cfset sortedCandidates = arraySlice(sortedCandidates, 1, this.MAX_CANDIDATES)>
    </cfif>

    <!--- Set result --->
    <cfset result.candidates = sortedCandidates>
    <cfif arrayLen(sortedCandidates) gt 0>
        <cfset result.hasDuplicate = true>
        <cfset result.bestMatchScore = sortedCandidates[1].score>
        <cfset result.bestMatchContactId = sortedCandidates[1].contactid>
    </cfif>

    <cfreturn result>
</cffunction>


<cffunction name="findDuplicatesBatch" access="public" returntype="array" output="false"
    hint="Find duplicates for multiple rows">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="rows" type="array" required="true">
    <cfargument name="threshold" type="numeric" required="false" default="#this.THRESHOLD_LOW#">

    <cfset var results = []>

    <cfloop array="#arguments.rows#" index="row">
        <cfset var dupeResult = findDuplicates(arguments.userid, row, arguments.threshold)>
        <cfset arrayAppend(results, dupeResult)>
    </cfloop>

    <cfreturn results>
</cffunction>


<!--- ========================================
      DATABASE LOOKUP METHODS
     ======================================== --->

<cffunction name="findByEmail" access="private" returntype="query" output="false"
    hint="Find contacts by email address">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="email" type="string" required="true">

    <cfquery name="result">
        SELECT DISTINCT
            d.contactid,
            d.contactFullName,
            d.recordname,
            ci.valuetext AS matched_email
        FROM contactdetails d
        INNER JOIN contactitems ci ON ci.contactid = d.contactid
        WHERE d.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
          AND (d.isdeleted IS NULL OR d.isdeleted = 0)
          AND ci.valueCategory = 'Email'
          AND ci.itemStatus = 'Active'
          AND (ci.isDeleted IS NULL OR ci.isDeleted = 0)
          AND LOWER(ci.valuetext) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.email)#">
    </cfquery>

    <cfreturn result>
</cffunction>


<cffunction name="findByPhone" access="private" returntype="query" output="false"
    hint="Find contacts by phone number (digits only)">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="phone" type="string" required="true">

    <!--- Phone should already be normalized to digits only --->
    <cfquery name="result">
        SELECT DISTINCT
            d.contactid,
            d.contactFullName,
            d.recordname,
            ci.valuetext AS matched_phone
        FROM contactdetails d
        INNER JOIN contactitems ci ON ci.contactid = d.contactid
        WHERE d.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
          AND (d.isdeleted IS NULL OR d.isdeleted = 0)
          AND ci.valueCategory = 'Phone'
          AND ci.itemStatus = 'Active'
          AND (ci.isDeleted IS NULL OR ci.isDeleted = 0)
          AND REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ci.valuetext, ' ', ''), '-', ''), '(', ''), ')', ''), '+', '') = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.phone#">
    </cfquery>

    <cfreturn result>
</cffunction>


<cffunction name="findByName" access="private" returntype="query" output="false"
    hint="Find contacts by name (exact match)">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="fullName" type="string" required="true">

    <cfquery name="result">
        SELECT DISTINCT
            d.contactid,
            d.contactFullName,
            d.recordname
        FROM contactdetails d
        WHERE d.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
          AND (d.isdeleted IS NULL OR d.isdeleted = 0)
          AND (
              LOWER(d.contactFullName) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.fullName)#">
              OR LOWER(d.recordname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.fullName)#">
          )
    </cfquery>

    <cfreturn result>
</cffunction>


<cffunction name="findByNameAndCompany" access="private" returntype="query" output="false"
    hint="Find contacts by name and company">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="fullName" type="string" required="true">
    <cfargument name="company" type="string" required="true">

    <cfquery name="result">
        SELECT DISTINCT
            d.contactid,
            d.contactFullName,
            d.recordname,
            ci.valueCompany AS matched_company
        FROM contactdetails d
        INNER JOIN contactitems ci ON ci.contactid = d.contactid
        WHERE d.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
          AND (d.isdeleted IS NULL OR d.isdeleted = 0)
          AND ci.valueCategory = 'Company'
          AND ci.itemStatus = 'Active'
          AND (ci.isDeleted IS NULL OR ci.isDeleted = 0)
          AND (
              LOWER(d.contactFullName) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.fullName)#">
              OR LOWER(d.recordname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.fullName)#">
          )
          AND LOWER(ci.valueCompany) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.company)#">
    </cfquery>

    <cfreturn result>
</cffunction>


<cffunction name="findByNameAndCity" access="private" returntype="query" output="false"
    hint="Find contacts by name and city">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="fullName" type="string" required="true">
    <cfargument name="city" type="string" required="true">

    <cfquery name="result">
        SELECT DISTINCT
            d.contactid,
            d.contactFullName,
            d.recordname,
            ci.valueCity AS matched_city
        FROM contactdetails d
        INNER JOIN contactitems ci ON ci.contactid = d.contactid
        WHERE d.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
          AND (d.isdeleted IS NULL OR d.isdeleted = 0)
          AND ci.valueCategory = 'Address'
          AND ci.itemStatus = 'Active'
          AND (ci.isDeleted IS NULL OR ci.isDeleted = 0)
          AND (
              LOWER(d.contactFullName) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.fullName)#">
              OR LOWER(d.recordname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.fullName)#">
          )
          AND LOWER(ci.valueCity) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.city)#">
    </cfquery>

    <cfreturn result>
</cffunction>


<!--- ========================================
      HELPER METHODS
     ======================================== --->

<cffunction name="addCandidate" access="private" returntype="void" output="false"
    hint="Add or update a candidate in the candidates struct">
    <cfargument name="candidates" type="struct" required="true">
    <cfargument name="contactid" type="numeric" required="true">
    <cfargument name="contactData" type="query" required="true">
    <cfargument name="matchType" type="string" required="true">
    <cfargument name="matchValue" type="string" required="true">
    <cfargument name="points" type="numeric" required="true">

    <cfset var key = arguments.contactid>

    <cfif structKeyExists(arguments.candidates, key)>
        <!--- Update existing candidate --->
        <cfset arguments.candidates[key].score += arguments.points>
        <cfset arrayAppend(arguments.candidates[key].reasons, arguments.matchType & " matches")>
        <cfset arguments.candidates[key].matchedFields[arguments.matchType] = arguments.matchValue>
    <cfelse>
        <!--- Add new candidate --->
        <cfset arguments.candidates[key] = {
            contactid: arguments.contactid,
            contactFullName: arguments.contactData.contactFullName,
            recordname: len(arguments.contactData.recordname) ? arguments.contactData.recordname : arguments.contactData.contactFullName,
            score: arguments.points,
            reasons: [arguments.matchType & " matches"],
            matchedFields: {}
        }>
        <cfset arguments.candidates[key].matchedFields[arguments.matchType] = arguments.matchValue>
    </cfif>
</cffunction>


<cffunction name="normalizePhoneForMatch" access="private" returntype="string" output="false"
    hint="Normalize phone to digits only for matching">
    <cfargument name="phone" type="string" required="true">

    <!--- Extract digits only --->
    <cfset var digits = reReplace(arguments.phone, "[^0-9]", "", "ALL")>

    <!--- Remove leading 1 from US numbers for matching --->
    <cfif len(digits) eq 11 and left(digits, 1) eq "1">
        <cfset digits = mid(digits, 2, 10)>
    </cfif>

    <cfreturn digits>
</cffunction>


<!--- ========================================
      CONTACT DETAIL LOOKUP
     ======================================== --->

<cffunction name="getContactDetails" access="public" returntype="struct" output="false"
    hint="Get full contact details for comparison display">
    <cfargument name="contactid" type="numeric" required="true">
    <cfargument name="userid" type="numeric" required="true">

    <cfset var result = {
        found: false,
        contactid: arguments.contactid,
        contactFullName: "",
        recordname: "",
        emails: [],
        phones: [],
        company: "",
        city: "",
        state: ""
    }>

    <!--- Get contact details --->
    <cfquery name="qContact">
        SELECT
            d.contactid,
            d.contactFullName,
            d.recordname
        FROM contactdetails d
        WHERE d.contactid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contactid#">
          AND d.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
          AND (d.isdeleted IS NULL OR d.isdeleted = 0)
    </cfquery>

    <cfif qContact.recordCount eq 0>
        <cfreturn result>
    </cfif>

    <cfset result.found = true>
    <cfset result.contactFullName = qContact.contactFullName>
    <cfset result.recordname = qContact.recordname>

    <!--- Get emails --->
    <cfquery name="qEmails">
        SELECT valuetext, valueType
        FROM contactitems
        WHERE contactid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contactid#">
          AND valueCategory = 'Email'
          AND itemStatus = 'Active'
          AND (isDeleted IS NULL OR isDeleted = 0)
    </cfquery>
    <cfloop query="qEmails">
        <cfset arrayAppend(result.emails, {value: qEmails.valuetext, type: qEmails.valueType})>
    </cfloop>

    <!--- Get phones --->
    <cfquery name="qPhones">
        SELECT valuetext, valueType
        FROM contactitems
        WHERE contactid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contactid#">
          AND valueCategory = 'Phone'
          AND itemStatus = 'Active'
          AND (isDeleted IS NULL OR isDeleted = 0)
    </cfquery>
    <cfloop query="qPhones">
        <cfset arrayAppend(result.phones, {value: qPhones.valuetext, type: qPhones.valueType})>
    </cfloop>

    <!--- Get company --->
    <cfquery name="qCompany">
        SELECT valueCompany, valueDepartment, valueTitle
        FROM contactitems
        WHERE contactid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contactid#">
          AND valueCategory = 'Company'
          AND itemStatus = 'Active'
          AND (isDeleted IS NULL OR isDeleted = 0)
          AND primary_yn = 'Y'
        LIMIT 1
    </cfquery>
    <cfif qCompany.recordCount gt 0>
        <cfset result.company = qCompany.valueCompany>
    </cfif>

    <!--- Get address --->
    <cfquery name="qAddress">
        SELECT valueCity, valueRegion
        FROM contactitems
        WHERE contactid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contactid#">
          AND valueCategory = 'Address'
          AND itemStatus = 'Active'
          AND (isDeleted IS NULL OR isDeleted = 0)
          AND primary_yn = 'Y'
        LIMIT 1
    </cfquery>
    <cfif qAddress.recordCount gt 0>
        <cfset result.city = qAddress.valueCity>
        <cfset result.state = qAddress.valueRegion>
    </cfif>

    <cfreturn result>
</cffunction>


<!--- ========================================
      SCORING CONFIGURATION
     ======================================== --->

<cffunction name="getMatchingRules" access="public" returntype="array" output="false"
    hint="Return the matching rules for documentation">

    <cfset var rules = [
        {
            name: "Email Match",
            field: "email",
            points: 50,
            description: "Exact match on email address (case-insensitive)"
        },
        {
            name: "Phone Match",
            field: "phone",
            points: 40,
            description: "Match on phone digits (ignores formatting)"
        },
        {
            name: "Name Match",
            field: "name",
            points: 30,
            description: "Exact match on full name or record name"
        },
        {
            name: "Name + Company",
            field: "name+company",
            points: 25,
            description: "Name matches and same company"
        },
        {
            name: "Name + City",
            field: "name+city",
            points: 15,
            description: "Name matches and same city"
        }
    ]>

    <cfreturn rules>
</cffunction>


<cffunction name="setThreshold" access="public" returntype="void" output="false"
    hint="Set the minimum score threshold for duplicate detection">
    <cfargument name="threshold" type="numeric" required="true">

    <cfset this.THRESHOLD_LOW = arguments.threshold>
</cffunction>


<cffunction name="getScoreDescription" access="public" returntype="string" output="false"
    hint="Get human-readable description of a match score">
    <cfargument name="score" type="numeric" required="true">

    <cfif arguments.score gte this.THRESHOLD_HIGH>
        <cfreturn "High confidence match">
    <cfelseif arguments.score gte this.THRESHOLD_MEDIUM>
        <cfreturn "Medium confidence match">
    <cfelseif arguments.score gte this.THRESHOLD_LOW>
        <cfreturn "Low confidence match">
    <cfelse>
        <cfreturn "Below threshold">
    </cfif>
</cffunction>

</cfcomponent>
