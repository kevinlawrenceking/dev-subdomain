

<cfquery result="result"  name="x"  >
 SELECT min(notid) as new_notid,actionid,userid,suid
                         FROM funotifications
                         
                         GROUP BY actionid,userid,suid
                         
                        HAVING COUNT(*) > 1
                        ORDER BY actionid,userid,suid
</cfquery>

<cfloop query="x">
<cfquery result="result"  name="rr"  >
update funotifications_tbl
                         
set isdeleted = 1 where notid = #x.new_notid#

</cfquery>

</cfloop>

<cfquery result="result"  name="de"  >
update actionusers_tbl
set isdeleted = 1
</cfquery>

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
        
