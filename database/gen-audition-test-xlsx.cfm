<cfsilent>
<!--- TEST UTILITY - DELETE AFTER QA.
      Generates a real .xlsx audition-import test file (cfspreadsheet expects a binary
      workbook, not CSV) with a >500-char note containing a double-quote trap, and streams
      it as a download. Upload the downloaded file through the normal audition importer.
      Usage: /database/gen-audition-test-xlsx.cfm --->
<cfinclude template="/database/admin-guard.cfm">

<cfset headers = ["projDate","projName","audRoleName","audcatsubname","audsource","cdfirstname","cdlastname","callback_yn","redirect_yn","pin_yn","booked_yn","projDescription","charDescription","note"]>

<cfset noteText = "Female. Seeking talent 16-18 (must look 14-15). Theatrical, impulsive and an out-and-out goof; everything she touches turns to ""zany chaos"", and she dreams big. As such, she often skips the ""thinking it through"" step, in favor of diving straight in. An only child of older parents, she tends toward being a people pleaser, but this works at odds with her desire to make a splash, so she is desperate to fit in only by standing out. She is not afraid of looking like a nut, and will loudly make a fool of herself to protect a friend. Ultimately the most generous, selfless, brave kid you will ever meet, with killer taste in friends. VERIFY-FULL-NOTE-END-AUDITION-LEAD">

<cfset charDescText = "Female. Seeking talent 16-18 (must look 14-15). Theatrical and an out-and-out goof; everything she touches turns to ""zany chaos"", and she dreams big. CHARDESC-END-LEAD">

<cfset rowVals = [
    "06/22/2026", "QA Quote Trap Project", "Davey", "Television", "Self Tape",
    "Casey", "Director", "N", "N", "N", "N",
    "Logline with a ""quoted"" phrase, and a comma after it.",
    charDescText, noteText
]>

<cfset sheet = spreadsheetNew("Sheet1", true)>
<cfloop from="1" to="#arrayLen(headers)#" index="c">
    <cfset spreadsheetSetCellValue(sheet, headers[c], 1, c)>
</cfloop>
<cfloop from="1" to="#arrayLen(rowVals)#" index="c">
    <cfset spreadsheetSetCellValue(sheet, rowVals[c], 2, c)>
</cfloop>

<cfset xlsxBinary = spreadsheetReadBinary(sheet)>
</cfsilent>
<cfheader name="Content-Disposition" value="attachment; filename=qa_auditions_quote_trap.xlsx">
<cfcontent type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" variable="#xlsxBinary#" reset="true">
