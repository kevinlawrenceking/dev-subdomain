

<cfquery result="result"  name="U" maxrows="50">
    select  
    u.userid
    ,u.recordname
    ,u.userFirstName
    ,u.userLastName
    ,u.userEmail
    ,u.contactid
    ,u.userRole
    FROM taousers u
    where u.isdeleted = 0 and u.userid = 483
    order by u.userid desc
</cfquery>

<cfloop query="U">
    
    <cfset select_userid = U.userid />

    <cfinclude template="user_setup_core.cfm" />

<cfquery result="result"  name="Update">
    update taousers set issetup = 1 where userid = #select_userid#
    </cfquery>

</cfloop>
