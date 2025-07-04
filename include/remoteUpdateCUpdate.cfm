<!--- This ColdFusion page processes and updates contact item information based on provided parameters. --->

<cfparam name="deleteitem" default="0" />
<cfparam name="valuetext" default="" />
<cfparam name="itemdate" default="" />
<cfparam name="new_countryname" default="" />
<cfparam name="new_regionname" default="" />
<cfparam name="countryid" default="" />
<cfparam name="old_countryid" default="" />
<cfparam name="old_region_id" default="" />
<cfparam name="region_id" default="" />

<!--- Check if the value type is Custom and custom type is not empty --->
<cfif #valuetype# is "Custom" and #customtype# is not "">
    <cfinclude template="/include/qry/insert_262_1.cfm" />
    <cfset new_typeid = typeresult.generatedkey />
    <cfoutput>
        <cfset valuetype = "#customtype#" />
    </cfoutput>
    <cfinclude template="/include/qry/insertx_262_2.cfm" />
</cfif>

<!--- Include country query and check if a country is found 
<cfinclude template="/include/qry/findcountry_199_4.cfm" />
<cfif #findcountry.recordcount# is "1">
    <cfset new_countryid = findcountry.countryname />
    <cfset old_countryid = findcountry.countryid />
</cfif>

<!--- Include region query and check if a region is found --->
<cfinclude template="/include/qry/findregion_262_4.cfm" />
<cfif #findregion.recordcount# is "1">
    <cfset new_region_id = findregion.regionname />
</cfif>
--->
<!--- Handle URL prefixing based on category ID for categories 4 and 5 --->
<cfif #catid# is "4">
    <cfset preurl = "https://" />
    <cfif #left(valuetext, 4)# is "http">
    <cfelse>
        <cfoutput>
            <cfset valuetext = "#preurl##valuetext#" />
        </cfoutput>
    </cfif>
</cfif>

<cfif #catid# is "5">
    <cfset preurl = "https://" />
    <cfif #left(valuetext, 4)# is "http">
    <cfelse>
        <cfoutput>
            <cfset valuetext = "#preurl##valuetext#" />
        </cfoutput>
    </cfif>
</cfif>

<!--- Include update queries for contact items --->
<cfinclude template="/include/qry/update_262_5.cfm" />
<cfinclude template="/include/qry/update2_262_6.cfm" />

<cfset script_name_include = "/include/#ListLast(GetCurrentTemplatePath(), " \")#" />

<!--- Redirect to the contact page with the specified contact ID --->
<cflocation url="/app/contact/?contactid=#contactid#" />

