<!--- This ColdFusion page dynamically generates insert queries for tables matching a specific pattern and saves them to files. --->

<cfinclude template="/include/qry/y_536_1.cfm" />

<cfloop query="y">
    <!--- Loop through each table found in the query. --->

    <cfset comptable = y.new_comptable /> 

    <cfinclude template="/include/qry/allfields_536_2.cfm" />  
    
    <cfinclude template="/include/qry/x_536_3.cfm" />  
    
    <cfinclude template="/include/qry/findp_536_4.cfm" />  

    <cfset recid = findp.field />
    
    <cfsavecontent variable="stuff"> 
        <cfoutput>
            <!--- Generate the insert query for the current table. --->
            #chr(60)#cfinclude template="/include/remote_load.cfm" /#chr(62)##chr(10)##chr(13)#
            #chr(10)##chr(13)#
            <cfloop query="x">
                <!--- Loop through each field in the filtered fields. --->
                <cfif #x.type# IS "bit(1)">
                    #chr(60)#cfparam name="new_#x.field#" default="0" /#chr(62)##chr(10)##chr(13)#
                <cfelse>
                    #chr(60)#cfparam name="new_#x.field#" default="#x.default#" /#chr(62)##chr(10)##chr(13)#
                </cfif>
            </cfloop>
            #chr(10)##chr(13)#
            #chr(60)#cfquery name="#comptable#_ins" result="result" #chr(62)##chr(13)#  
            INSERT INTO #comptable#  (#chr(10)##chr(13)#
            <cfloop query="x">
                <cfif #x.currentrow# IS NOT "1">,#chr(10)##chr(13)#</cfif>#x.field#
            </cfloop>)
            #chr(10)##chr(13)#VALUES (#chr(10)##chr(13)#
            <cfloop query="x">
                <!--- Prepare each value for the insert statement. --->
                <cfscript>
                    origText = x.type;
                    newText = reReplaceNoCase(origText, "\([0-9]*\).*$", "", "all");
                </cfscript>
                <cfset new_maxvalue = "#replace('#x.type#', '#newText#', '')#" />
                <cfset new_maxvalue = "#replace('#new_maxvalue#', '(', '')#" />
                <cfset new_maxvalue = "#replace('#new_maxvalue#', ')', '')#" />
                <cfset new_maxvalue = "#trim(new_maxvalue)#" />
                <cfinclude template="/include/qry/find_536_5.cfm" />
                <cfif #x.currentrow# IS NOT "1">,#chr(10)##chr(13)#</cfif>
                #chr(60)#cfqueryparam cfsqltype="#find.cfparam#" value="#chr(35)#new_#x.field##chr(35)#" 
                <cfif #new_maxvalue# IS NOT "" AND #find.cfparam# IS "CF_SQL_VARCHAR">maxlength="#new_maxvalue#"</cfif> 
                null="#chr(35)#NOT len(trim(new_#x.field#))#chr(35)#" /#chr(62)#
            </cfloop>#chr(10)##chr(13)#);
            #chr(60)#/cfquery#chr(62)##chr(10)##chr(13)#
            #chr(10)##chr(13)#
            #chr(60)#cfset new_#recid# = result.GENERATEDKEY /#chr(62)#
        </cfoutput>
    </cfsavecontent>

    <cfoutput>
        <cfset page_dir = "C:\home\theactorsoffice.com\wwwroot\#host#-subdomain\include\qry\xxx#comptable#_ins.cfm" />
    </cfoutput>

    <cffile action="write" file="#page_dir#" nameconflict="overwrite" output="#TRIM(stuff)#" />
</cfloop>

