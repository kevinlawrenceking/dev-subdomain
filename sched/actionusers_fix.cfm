

<cfquery result="result"  name="u"  >
        SELECT * from taousers  
        </cfquery>

    <cfloop query="u">

        <cfquery result="result"  name="xs"  >
        SELECT actionid,actiondaysno,actiondaysrecurring from fuactions
        </cfquery>

        <cfloop query="xs">

<cfquery result="result"  name="find"  >
            SELECT * from actionusers where actionid = #xs.actionid# and userid = #u.userid#
            </cfquery>
            
            <cfif #find.recordcount# is "0">
            
                <cfquery result="result"  name="insert"  >
                    INSERT INTO `actionusers_tbl` (`actionid`,`userid`,`actiondaysno`<cfif #xs.actiondaysrecurring# is not "">,`actiondaysrecurring`</cfif>,`IsDeleted`) 
                    VALUES (#xs.actionid#, #u.userid#,#xs.actiondaysno#<cfif #xs.actiondaysrecurring# is not "">,#actiondaysrecurring#</cfif>, 0);
                </cfquery>
     
            </cfif>

        </cfloop>

</cfloop>

