

<cfquery result="result"  name="update">
    update `pgfiles`
    set filestatus =
    <cfqueryparam cfsqltype="cf_sql_varchar" value="Missing" />
    where filestatus =  <cfqueryparam cfsqltype="cf_sql_varchar" value="Found" />
</cfquery>

<cfoutput>
    <cfset cal_root_dir="c:\home\theactorsoffice.com\wwwroot\#host#-subdomain\" />
    <cfset cal_root_url="https://dev.theactorsoffice.com/" />
</cfoutput>

<cfdirectory action="list" directory="#cal_root_dir#" recurse="true" name="pgitems" >

    <cfloop query="pgitems">
        <cfoutput>
           <h3>#Directory#</h3>
          
            <cfset prefix="#pgitems.type#" />
            <cfset type="#pgitems.type#" />
         
            <cfset name="#pgitems.name#" />
            <cfset directory="#pgitems.Directory#" />
            <cfset status="Found" />
            <cfset size="#numberformat(pgitems.size,'99999')#" />
            <cfset DateLastModified="#pgitems.DateLastModified#" />
            <cfset ID_a ="#replace('#Directory#','c:\home\theactorsoffice.com\wwwroot\#host#-subdomain','','All')#" />
            <cfset ID ="#replace('#ID_a#','\','/','All')#/#name#" />
        </cfoutput>
        
               <cfif #name# contains ".">
              <cfset Ext = listLast(name,".")>
                  <cfelse>
                      <cfset ext = "" />
                    </cfif>

<cfset PARENTID = ListDeleteAt(ID, ListLen(ID, "/"), "/")>

<cfquery result="result"  name="find">    
                 update `pg#prefix#s`
                    set #prefix#status = 'Found'
            where id = '#id#' and #prefix#status <> 'Confirmed'
                </cfquery>

    </cfloop>

