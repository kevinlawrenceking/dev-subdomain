
<cfparam name="select_userid" default="793" />

<cfset n=0 />
<cfset dsn = "abo" />
<cfset dbug = "Y"  />

<cfquery result="result" datasource="#dsn#" name="z" maxrows="5">
    select * from taousers where userid = #select_userid#  
</cfquery>

<Cfif #dbug# is "Y"><cfoutput>select * from taousers where imdbid is null order by userid desc<BR /></cfoutput></Cfif>
<cfloop query="z">

<cfset select_userid = z.userid />
    
    <Cfif #dbug# is "Y"> <cfoutput><h1>#z.userfirstname# #z.userlastname#</h1></cfoutput><BR /></cfif>

<cfset n=0 />

<cfquery result="result" datasource="#dsn#" name="x">
    select sitetypename,sitetypedescription from sitetypes_master
</cfquery>

<cfloop query="x">

    <cfquery result="result" datasource="#dsn#" name="find">
        Select * from sitetypes_user
        where sitetypename = '#x.sitetypename#' and userid = #select_userid#
    </cfquery>
    
    <cfif #dbug# is "y">
    <cfoutput>  Select * from sitetypes_user
        where sitetypename = '#x.sitetypename#' and userid = #select_userid# - #find.recordcount#<br/></cfoutput>
    
    </cfif>

<cfif #find.recordcount# is "0">
        <cfoutput>
            <cfset n=#n# + 1 />
            <cfif #n# is "1" and #dbug# is "Y">
                <h3>SiteTypes</h3>
            </cfif>
        </cfoutput>
        <cfquery result="result" datasource="#dsn#" name="insert">
            INSERT INTO `sitetypes_user` (`siteTypeName`, `siteTypeDescription`, `userid`)
            VALUES ('#x.sitetypename#','#x.sitetypedescription#',#select_userid#);
        </cfquery>
  <cfif #dbug# is "y">
        <cfoutput>
            
              INSERT INTO `sitetypes_user` (`siteTypeName`, `siteTypeDescription`, `userid`)
            VALUES ('#x.sitetypename#','#x.sitetypedescription#',#select_userid#);<br/>

Sitetypes_user added: #x.sitetypename#<br />
        </cfoutput>
        </cfif>
    </cfif>

</cfloop>

<cfquery result="result" datasource="#dsn#" name="x">
    select
    s.id
    ,s.sitename
    ,s.siteURL
    ,s.siteicon
    ,s.sitetypeid
    ,t.sitetypename
    FROM sitelinks_master s INNER JOIN sitetypes_master t ON t.sitetypeid = s.siteTypeid
    ORDER BY s.sitename
</cfquery>

<cfloop query="x">

    <cfquery result="result" datasource="#dsn#" name="find">
        Select sitetypeid from sitetypes_user
        where sitetypename = '#x.sitetypename#' and userid = #select_userid#
    </cfquery>

     <cfif #dbug# is "Y">
<cfoutput>Select sitetypeid from sitetypes_user
    where sitetypename = '#x.sitetypename#' and userid = #select_userid# (#find.recordcount#)<br/></cfoutput></cfif>

    <cfif #find.recordcount# is "1">

<cfoutput>
            <cfset n=#n# + 1 />
            <cfif #n# is "1">
                <h3>sitelinks_user</h3>
            </cfif>
        </cfoutput>

        <cfset new_sitetypeid=find.sitetypeid />
        
        <cfif #dbug# is "y">
        <cfoutput><h3>new_sitetypeid: #new_sitetypeid#</h3></cfoutput>
    </cfif>
        <cfquery result="result" datasource="#dsn#" name="find2">
            Select * from sitelinks_user where sitename = '#x.sitename#' and userid = #select_userid#
        </cfquery>
        
        <cfif #dbug# is "y">
<cfoutput>Select * from sitelinks_user where sitename = '#x.sitename#' and userid = #select_userid#<br/>

<h3>find2 recordcount: #find2.recordcount#</h3>
    
    </cfoutput>
            
        </cfif>
        <cfif #find2.recordcount# is "0">
            
            <cfif #dbug# is "y"></cfif>
<Cfoutput>     INSERT INTO `sitelinks_user_tbl` (`siteName`,`siteURL`,`siteicon`,`siteTypeid`,`userid`)
                VALUES ('#x.sitename#','#x.siteurl#','#x.siteicon#', #new_sitetypeid#, #select_userid#)<br/></cfoutput>
            
        </cfif>
            <cfquery result="result" datasource="#dsn#" name="insert">
                INSERT INTO `sitelinks_user_tbl` (`siteName`,`siteURL`,`siteicon`,`siteTypeid`,`userid`)
                VALUES ('#x.sitename#','#x.siteurl#','#x.siteicon#', #new_sitetypeid#, #select_userid#)
            </cfquery>

            <cfif #dbug# is "Y">

                <CFOUTPUT> sitelinks_user_tbl: #x.sitename# added</CFOUTPUT><br />

            </cfif>

        </cfif>

</cfloop>

<cfquery result="result" datasource="#dsn#" name="update">
            update taousers set imdbid = 0 where userid = #select_userid#
        </cfquery>

</cfloop>

