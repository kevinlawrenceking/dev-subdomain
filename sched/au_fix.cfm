

<cfquery result="result"  name="d"  >
        update actionusers_tbl set isdeleted = 1
</cfquery>

<cfquery result="result"  name="u"  >
 SELECT max(id) as new_id,actionid,userid
                         FROM actionusers_tbl
                         
                         GROUP BY actionid,userid
                         
                        HAVING COUNT(*) > 1
                        ORDER BY userid,actionid
        </cfquery>

<cfloop query="u">

        <cfquery result="result"  name="xs"  >
        update actionusers_tbl set isdeleted = 0 where id = #u.new_id#
        </cfquery>

 <cfoutput>
 
        #u.new_id# activated<BR>
 </cfoutput>
    </cfloop>

