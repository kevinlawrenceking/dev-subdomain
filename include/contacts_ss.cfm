<cfcontent reset="true">

<cfset listColumns = "`contactid`,`col1`,`col2`,`col3`,`col4`,`col5`" />
<cfset sIndexColumn = "contactid" />
<cfparam name="draw" default="1" type="integer" />
<cfparam name="start" default="0" type="integer" />
<cfparam name="length" default="10" type="integer" />
<cfparam name="search" default="" type="string" />
 <cfparam name="uploadid" default="0" type="integer" />
<cfif structKeyExists(form, "search[value]") and len(form["search[value]"]) gt 0>
    <cfset search = form["search[value]"]>
</cfif>

<!--- WO-5B: Validate dynamic table name --->
<cfif NOT reFindNoCase("^[a-z_][a-z0-9_]{0,63}$", trim(contacts_table))>
    <cflog file="contacts_ss" text="BLOCKED: invalid table name contacts_table='#htmlEditFormat(contacts_table)#'" />
    <cfabort>
</cfif>

<!--- Data set after filtering --->

<cfquery result="result"  name="qFiltered" >
SELECT contactid,col1,col2,col2b,col3,col4,col5,userid, hlink
    from #contacts_table#

WHERE userid = <Cfqueryparam value="#userid#" cfsqltype="CF_SQL_INTEGER" />

<cfif #isdefined('bytag')#>
    <cfif #bytag# is not "">
    and contactid in (SELECT contactid from contactitems  WHERE valuetype = 'tags' AND itemstatus = 'active' AND valuetext=<cfqueryparam cfsqltype="cf_sql_varchar" value="#bytag#" /> )
    </cfif>
    </cfif>

<cfif #isdefined('byimport')#>
    <cfif #byimport# is not "">
    and contactid in (
        SELECT contactid FROM contactsimport WHERE uploadid = <cfqueryparam value="#byimport#" cfsqltype="CF_SQL_INTEGER" />
        UNION
        SELECT created_contactid FROM import_v3_rows WHERE job_id = <cfqueryparam value="#byimport#" cfsqltype="CF_SQL_INTEGER" /> AND created_contactid IS NOT NULL
    )
    </cfif>
    </cfif>

<cfif #isdefined('bylike')#>

and col1 like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#bylike#%" />
    </cfif>

<cfif #uploadid# is not "0">
    and contactid in (SELECT contactid FROM contactsimport WHERE uploadid = <cfqueryparam value="#uploadid#" cfsqltype="cf_sql_integer">)

</cfif>

<cfif len(trim(search))>

<cfif #trim(search)# is "no system">
    and contactid NOT IN (SELECT contactid FROM contacts_ss_followup WHERE userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer">) AND contactid NOT IN (SELECT contactid FROM contacts_ss_maint WHERE userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer">) AND contactid NOT IN (SELECT contactid FROM contacts_ss_target WHERE userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer">)

<cfelse>
AND
    (
    <cfloop list="#listColumns#" index="thisColumn">
    <cfif thisColumn neq listFirst(listColumns)>
    OR
    </cfif>
    #thisColumn# LIKE <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="%#trim(search)#%" />   
    </cfloop>
    )

</cfif>

</cfif>
<cfif structKeyExists(form, "order[0][column]") and val(form["order[0][column]"]) gt 0>
    ORDER BY

<cfif form["order[0][column]"] eq '1'>
    col1 <cfif form["order[0][dir]"] eq 'desc'>desc</cfif>
    </cfif>

<cfif form["order[0][column]"] eq '2'>
    col1 <cfif form["order[0][dir]"] eq 'desc'>desc</cfif>
    </cfif>

<cfif form["order[0][column]"] eq '3'>
    col2b <cfif form["order[0][dir]"] eq 'desc'>desc</cfif>
    </cfif>

<cfif form["order[0][column]"] eq '4'>
    col3 <cfif form["order[0][dir]"] eq 'desc'>desc</cfif>
    </cfif>

<cfif form["order[0][column]"] eq '5'>
    col4 <cfif form["order[0][dir]"] eq 'desc'>desc</cfif>
    </cfif>

<cfif form["order[0][column]"] eq '6'>
    col5 <cfif form["order[0][dir]"] eq 'desc'>desc</cfif>
    </cfif>   
</cfif>
</cfquery>

<!--- Total data set length --->
<cfquery result="result"  dbtype="query" name="qCount">
SELECT COUNT(#sIndexColumn#) as total
FROM   qFiltered
</cfquery>

<cfif qFiltered.recordcount gt 0>
    <cfset recordsTotal=#qCount.total#>
<cfelse>
    <cfset recordsTotal=0>
</cfif>
 <cfset n= 0 />
<!---
Output
--->

{"draw": <cfoutput>#val(draw)#</cfoutput>,
"recordsTotal": <cfoutput>#recordsTotal#</cfoutput>,
"recordsFiltered": <cfoutput>#qFiltered.recordCount#</cfoutput>,
"data":
<cfif qFiltered.recordcount gt 0>
[
<cfloop query="qFiltered" startrow="#val(start+1)#">
<cfoutput>
    <cfset n = #n# + 1 />
   <cfif n LTE val(length)>
    <cfif currentRow gt (start+1)>,</cfif>
    [

"#SerializeJSON(qFiltered.contactid)#",
    #SerializeJSON(qFiltered.hlink)#,
     #SerializeJSON(qFiltered.col2b)#,
     #SerializeJSON(qFiltered.col5)#,
     #SerializeJSON(qFiltered.col3)# ,
        #SerializeJSON(qFiltered.col4)#
    ]</cfif>
</cfoutput></cfloop> ]
<cfelse>
    ""
</cfif>
 }
