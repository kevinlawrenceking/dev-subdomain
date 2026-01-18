

<cfquery result="result"  name="update">
    update `pgfiles`
    set filestatus =
    <cfqueryparam cfsqltype="cf_sql_varchar" value="Missing" />
    where filestatus =  <cfqueryparam cfsqltype="cf_sql_varchar" value="Found" />
</cfquery>

<cfoutput>
    <cfset cal_root_dir="c:\home\theactorsoffice.com\wwwroot\#host#-subdomain\" />
    <cfset cal_root_url="https://#host#.theactorsoffice.com/" />
</cfoutput>

<cfdirectory action="list" directory="#cal_root_dir#" recurse="true" name="pgitems" >

    <cfloop query="pgitems">
        <cfoutput>

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
            select Id,#prefix#status from `pg#prefix#s`
            where #prefix#name =
            
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#Name#" /> and #prefix#directory =
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#Directory#" />
        </cfquery>

        <cfif #find.recordcount# is "0">

            <cfquery result="result"  name="insert">
                INSERT INTO `pg#prefix#s` (`#prefix#Name`,`#prefix#Directory`, `#prefix#status`, `#prefix#size`, `#prefix#DateLastModified`, `#prefix#Ext`, `ID`,`PARENTID`)

                VALUES
                (
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#Name#" />
                ,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#Directory#" />
                ,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#status#" />
                ,
                <cfqueryparam cfsqltype="cf_sql_integer" value="#size#" />
                ,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#DateLastModified#" />
                ,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#Ext#" />
                ,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#ID#" />
                                ,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#PARENTID#" />
                )
            </cfquery>

            <cfelse>
                
                   <cfif #prefix# is "file">
                       
                <cfset id=find.ID />
                <cfset new_filestatus=find.filestatus />

<cfquery result="result"  name="update">
                    UPDATE `pg#prefix#s`

set `#prefix#status` =
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="Found" />
                    where id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#id#" /> 
                </cfquery>

<cfoutput> UPDATE `pg#prefix#s`  set `#prefix#status` = 'Found' where id = '#id#'<BR></cfoutput>

</cfif>

</cfif>

    </cfloop>

