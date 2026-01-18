 

<cfquery result="result" name="x"  >
SELECT  d.contactid
 ,min(su.sustartdate) AS new_dateadded

FROM contactdetails_tbl d 

INNER JOIN fusystemusers su ON su.contactid = d.contactid

WHERE d.contactStatus = 'Active'
AND d.isdeleted = 0 
AND d.dateadded IS null
AND  su.systemID in (3,4)
		
GROUP BY d.contactid
		
ORDER BY d.contactid
</cfquery>

<cfloop query="x">
    
    <cfset new_contactid = x.contactid />
    
    <cfset new_dateadded = x.new_dateadded />
   
    <cfquery result="result" name="setHashedPassword"  >
    UPDATE contactdetails_tbl
    SET dateadded = <cfqueryparam cfsqltype="cf_sql_date" value="#new_dateadded#" />
    WHERE contactid = <cfqueryparam cfsqltype="integer" value="#new_contactid#" />
    </cfquery>
    
    <cfoutput>
      #new_contactid# added add date #dateformat(new_dateadded)#<BR/>
    </cfoutput>

</cfloop>

<cfquery result="result" name="y"  >
SELECT  d.contactid
 ,min(e.eventstart) AS new_dateadded

FROM contactdetails_tbl d 

inner join events e on e.contactid = d.contactid

inner join contactitems i on i.contactid = d.contactid
inner join tags_user tu on((convert(tu.tagname using utf8) = i.valueText))
WHERE d.contactStatus = 'Active'
AND d.isdeleted = 0 
AND d.dateadded IS null
and e.eventstart is not null
and e.eventstatus = 'Completed'
and e.eventtypename in ('Meeting','Audition')
and tu.tagtype = 'C'
GROUP BY d.contactid
		
ORDER BY d.contactid
</cfquery>

<cfloop query="y">
    
    <cfset new_contactid = y.contactid />
    
    <cfset new_dateadded = y.new_dateadded />
   
    <cfquery result="result" name="setHashedPassword"  >
    UPDATE contactdetails_tbl
    SET dateadded = <cfqueryparam cfsqltype="cf_sql_date" value="#new_dateadded#" />
    WHERE contactid = <cfqueryparam cfsqltype="integer" value="#new_contactid#" />
    </cfquery>
    
    <cfoutput>
      #new_contactid# added add date #dateformat(new_dateadded)#<BR/>
    </cfoutput>

</cfloop>

