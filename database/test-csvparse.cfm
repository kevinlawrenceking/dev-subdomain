<cfsilent>
<!--- TEST UTILITY - DELETE AFTER QA.
      Runs the FIXED parseCSVLine algorithm on the double-quote trap lines and dumps the
      parsed fields, so you can confirm correct tokenization independent of the importer,
      ColdFusion's template cache, or any previously-parsed job.
      Usage: /database/test-csvparse.cfm --->
<cfinclude template="/database/admin-guard.cfm">

<cffunction name="parseCSVLine" access="private" returntype="array" output="false">
    <cfargument name="line" type="string" required="true">
    <cfargument name="delimiter" type="string" required="true">
    <cfset var result = []>
    <cfset var inQuotes = false>
    <cfset var currentField = "">
    <cfset var chars = arguments.line.toCharArray()>
    <cfset var i = 1>
    <cfset var charLen = arrayLen(chars)>
    <cfset var skipNext = false>
    <cfloop from="1" to="#charLen#" index="i">
        <cfif skipNext><cfset skipNext = false><cfcontinue></cfif>
        <cfset var c = chars[i]>
        <cfif c eq '"'>
            <cfif inQuotes and i lt charLen and chars[i+1] eq '"'>
                <cfset currentField &= '"'>
                <cfset skipNext = true>
            <cfelse>
                <cfset inQuotes = not inQuotes>
            </cfif>
        <cfelseif c eq arguments.delimiter and not inQuotes>
            <cfset arrayAppend(result, trim(currentField))>
            <cfset currentField = "">
        <cfelse>
            <cfset currentField &= c>
        </cfif>
    </cfloop>
    <cfset arrayAppend(result, trim(currentField))>
    <cfreturn result>
</cffunction>

<cfset samples = [
    'QA Trap,Davey,qa.trap@example.com,5550101,Acme Talent,Agent,"Female. Turns to ""zany chaos"", and she dreams big. VERIFY-FULL-NOTE-END-CONTACTS-LEAD"',
    '06/22/2026,QA Project,Davey,Television,Self Tape,Casey,Director,N,N,N,N,"Logline with a ""quoted"" phrase, and a comma.","CharDesc turns to ""zany chaos"", and she dreams big. CHARDESC-END-LEAD","Note turns to ""zany chaos"", and she dreams big. VERIFY-FULL-NOTE-END-AUDITION-LEAD"'
]>
</cfsilent>
<cfcontent type="text/plain; charset=utf-8" reset="true"><cfoutput>
=== Fixed parseCSVLine output (each field on its own line) ===

<cfloop array="#samples#" index="s">
--- INPUT ---
#s#

--- PARSED FIELDS ---
<cfset fields = parseCSVLine(s, ",")>
<cfloop from="1" to="#arrayLen(fields)#" index="fi">[#fi#] (len=#len(fields[fi])#) #fields[fi]#
</cfloop>
=========================================================

</cfloop>
PASS criteria:
 - Contact row: 7 fields; field [7] ends with "VERIFY-FULL-NOTE-END-CONTACTS-LEAD".
 - Audition row: 14 fields; field [13] ends "CHARDESC-END-LEAD"; field [14] ends "VERIFY-FULL-NOTE-END-AUDITION-LEAD".
 - The "zany chaos" comma must NOT create extra fields.
</cfoutput>
