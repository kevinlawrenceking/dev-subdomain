<!--- This ColdFusion page processes updates to a record and logs changes. --->
<cfinclude template="rpg_load.cfm" />

<cfparam name="OldValue" default="" />
<cfparam name="Recordname" default="" />
<cfparam name="NewValue" default="" />
<cfparam name="updatename" default="" />
<cfparam name="updateusername" default="" />
<cfparam name="recid" default="0" />
<cfparam name="updatedetails" default="" />
<cfparam name="loginname" default="" />
<cfparam name="isdeleted" default="0" />
<cfparam name="new_isDeleted" default="0" />
<cfparam name="t1" default="0" />
<cfparam name="t2" default="0" />
<cfparam name="t3" default="0" />
<cfparam name="t4" default="0" />
<cfparam name="contactid" default="0" />

<cfoutput>
    <!--- Set user and company parameters for output --->
    <cfparam name="userid" default="#userid#" />
    <cfparam name="compid" default="#rpg_compid#" />
    <cfparam name="compTable" default="#rpg_comptable#" />
    <cfparam name="recname" default="#fid#" />
    <cfparam name="compName" default="#rpg_compname#" />
    
    userid: #userid#<BR>
    compid: #rpg_compid#<BR>
    comptable: #rpg_comptable#<BR>
    recname: #fid#<BR>
    compname: #rpg_compname#<BR>
</cfoutput>

<cfloop query="rpgupdate">
    <!--- Loop through rpgupdate query to process each record --->
    <cfif #rpgupdate.fname# is not "#fid#">
        <cfoutput>
            <cfset fname = "#rpgupdate.Fname#" />
            <cfset ftype = "#rpgupdate.ftype#" />
            fname: #rpgupdate.Fname#<BR>
            ftype: #rpgupdate.ftype#<BR>
            
            <cfif #ftype# is "integer">
                <cfset fsqltype = "CF_SQL_INTEGER" />
            <cfelseif #ftype# is "text">
                <cfset fsqltype = "CF_SQL_VARCHAR" />
            <cfelseif #ftype# is "date">
                <cfset fsqltype = "CF_SQL_DATE" />
            <cfelseif #ftype# is "datetime">
                <cfset fsqltype = "CF_SQL_TIMESTAMP" />
            <cfelseif #ftype# is "time">
                <cfset fsqltype = "CF_SQL_TIME" />
            <cfelseif #ftype# is "bit">
                <cfparam name="new_#FNAME#" default="0" />
                <cfset fsqltype = "CF_SQL_BIT" />
            </cfif>
        </cfoutput>

        <cfinclude template="/include/qry/FindOld_266_1.cfm" />

        <cfset recordname = FindOld.recordname />
        <cfoutput>
            Find old query: Select c.#fname# as OldValue,
            recordname
            from #compTable# c #compInner#
            WHERE c.#recname# = #recid#<BR>
            recordname: #recordname#<BR>
            
            <cfset NewValue = "#EVALUATE('new_#FNAME#')#" />
            <cfset OldValue = "#FindOld.OldValue#" />
            <cfset updatedname = "#rpgupdate.updatename#" />
            fname: #fname#<BR>
            Newvalue: #Newvalue#<BR>
            oldvalue: #oldvalue#<BR>
            updatename: #updatename#<BR>
        </cfoutput>

        <cfoutput>
            <cfset updateusername = "#updateusername#" />
            updateusername: #updateusername#<BR>

            <cfif "#oldvalue#" is "">
                <cfset oldvalue = "NULL" />
            </cfif>

            <cfif "#newvalue#" is "">
            <cfif RPGUpdate.updatetype is "delete">
            <cfset newvalue = 0 />
            <cfelse>
                <cfset newvalue = "NULL" />
                </cfif>
            </cfif>
            
            <cfset updatedetails = "<span style='color: ##406E8E;font-weight:400;'>#oldvalue#</span> to <span style='color: ##406E8E;font-weight:400;'>#newvalue#</span>" />
            updatedetails: #updatedetails#<BR>
        </cfoutput>

        <cfif oldvalue neq newvalue>
            <cfif #newvalue# is "NULL">
            <cfelse>
                <cfoutput>
                    UPDATE #compTable#<BR>
                    Set #fname# = #newvalue#<BR>
                    where #recname# ="#recid#"<BR>
                </cfoutput>
                
                <cfinclude template="/include/qry/update_266_2.cfm" /> 
                <cfinclude template="/include/qry/INSERT_266_3.cfm" />	
                
                <cfoutput>
                    INSERT INTO updatelog (oldValue, NewValue, recordname, updatename, recid, compid, userid, updatedetails)
                    VALUES (#oldvalue#,
                            #newvalue#,
                            #recordname#,
                            #updatename#,
                            #recid#,
                            #compid#,
                            #userid#,
                            #updatedetails#)
                </cfoutput>
            </cfif>
        </cfif>
    </cfif>
</cfloop>

<cfoutput>
    <cfif #isdefined('dbug')#>
        <cfabort>
    </cfif>

    <cfif #details_pgid#is not "">
        <cfinclude template="/include/qry/Finddetails_266_4.cfm" />
        <cfset returnpage = "/app/#Finddetails.pgdir#/?recid=#details_recid#&contactid=#contactid#&t1=#t1#&t2=#t2#&t3=#t3#&t4=#t4#" />
    <cfelse>
        <cfset returnpage = "/app/#rpg_compDir#/?recid=#recid#&contactid=#contactid#&t1=#t1#&t2=#t2#&t3=#t3#&t4=#t4#" />
    </cfif>
</cfoutput>

<cflocation url="#returnpage#" />
