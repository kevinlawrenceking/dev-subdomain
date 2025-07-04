<!--- This ColdFusion page processes tags, checks for existing records, and handles orphan records. --->
<cfoutput>
    <cfparam name="tag" default=""/>

    <cfset mylist = "#tag#"/>

    <br>#mylist#
    <br>contactid:#contactid#
    <br>
</cfoutput>

<cfinclude template="/include/qry/delete_298_1.cfm" />

<!--- Check if the tag is not empty --->
<cfif #tag# is not "">
    <!--- Loop through each value in the myList --->
    <cfloop list="#myList#" index="new_valuetext">
        
        <cfinclude template="/include/qry/find_298_2.cfm" />
        
        <!--- Check if no records were found --->
        <cfif #find.recordcount# is "0">
            <cfinclude template="/include/qry/insert_tag_298_3.cfm" />
            <cfinclude template="/include/qry/find_298_2.cfm" />
        </cfif>
        
        <cfinclude template="/include/qry/insert_298_5.cfm" />
        
    </cfloop>
</cfif>

<cfinclude template="/include/qry/y_298_6.cfm" />

<!--- Loop through query results from y --->
<cfloop query="y">
    <cfinclude template="/include/qry/find_orphan_298_7.cfm" />

    <!--- Check if no orphan records were found --->
    <cfif #find_orphan.recordcount# is "0">
        <cfinclude template="/include/qry/d_298_8.cfm" />
    </cfif>
</cfloop>

<cfset script_name_include = "/include/#ListLast(GetCurrentTemplatePath(), "\")#"/>
<cfinclude template="/include/bigbrotherinclude.cfm"/>

<cflocation url="/app/contact/?contactid=#contactid#"/>

