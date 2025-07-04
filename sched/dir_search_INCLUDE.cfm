<cfset host = "app" />
<cfset dsn = "abo" />

<cfoutput>
    <cfset cal_root_dir="c:\home\theactorsoffice.com\wwwroot\app-subdomain\include\" />
    <cfset cal_root_url="https://app.theactorsoffice.com/" />
</cfoutput>

<cfdirectory action="list" directory="#cal_root_dir#" recurse="false" name="pgitems" >

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
            select Id from `pg#prefix#s`
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
                <cfset id=find.ID />

                <cfquery result="result"  name="update">
                    UPDATE `pg#prefix#s`

                    set `#prefix#Name` =
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#Name#" />
                    , `#prefix#Directory` =
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#Directory#" />
                    , `#prefix#status` =
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#status#" />
                    , `#prefix#size` =
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#size#" />
                    , `#prefix#DateLastModified` =
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#DateLastModified#" />
       
                    , `#prefix#Ext` =
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#Ext#" />
                    
                    ,`ID` = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ID#" />
 
                    ,`PARENTID` = <cfqueryparam cfsqltype="cf_sql_varchar" value="#PARENTID#" />
                    
                    where id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#id#" />
                </cfquery>

</cfif>

    </cfloop>

