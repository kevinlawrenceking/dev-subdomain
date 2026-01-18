<cfcomponent displayname="AuditionMediaTypeService"  > 
<cffunction output="false" name="SELaudmediatypes" access="public" returntype="query">
    <cfquery name="result">
        SELECT * 
        FROM audmediatypes 
        WHERE mediatypeid IN (9, 10, 11)
    </cfquery>
    <cfreturn result>
</cffunction>

<cffunction output="false" name="SELaudmediatypes_23753" access="public" returntype="query">
    <cfargument name="mediaTypeIds" type="array" required="true">
  <cfquery name="result">
        SELECT mediatypeid, mediatype
        FROM audmediatypes
        WHERE mediatypeid IN (
            <cfloop array="#arguments.mediaTypeIds#" index="id">
                <cfqueryparam value="#id#" cfsqltype="CF_SQL_INTEGER" />
                <cfif id neq arrayLast(arguments.mediaTypeIds)>,</cfif>
            </cfloop>
        )
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction name="getMediaTypes" access="public" returntype="query" output="false">
    <cfargument name="mediaTypeIds" type="array" required="true">

<!--- Convert the array to a comma-delimited list --->
    <cfset var mediaTypeList = arrayToList(arguments.mediaTypeIds)>

<!--- Execute the query --->
    <cfquery name="result" >
        SELECT mediatypeid, mediatype
        FROM audmediatypes
        WHERE mediatypeid IN (<cfqueryparam value="#mediaTypeList#" cfsqltype="CF_SQL_INTEGER" list="true">)
    </cfquery>

<!--- Return the query result --->
    <cfreturn result>
</cffunction>
 
<cffunction output="false" name="SEL_Media_types_material" access="public" returntype="query">


<!--- Execute the query --->
    <cfquery name="queryResult" >
        SELECT mediatypeid, mediatype 
        FROM audmediatypes 
        WHERE mediatype <> 'Headshot' 
        AND isdeleted = 0

        ORDER BY mediatype
    </cfquery>

<!--- Return the result --->
    <cfreturn queryResult>
</cffunction>

<cffunction output="false" name="SELaudmediatypes_24198" access="public" returntype="query">

    <cfquery name="queryResult" >
        SELECT mediatypeid, mediatype 
        FROM audmediatypes 
        WHERE mediatype <> 'Headshot' 
        AND isdeleted = 0
   
    </cfquery>
    <cfreturn queryResult>
</cffunction>

<cffunction output="false" name="INSaudmediatypes" access="public" returntype="numeric">
    <cfargument name="new_mediaType" type="string" required="true">
    <cfargument name="new_isDeleted" type="boolean" required="true">
    <cfquery result="result">
        INSERT INTO audmediatypes (mediaType, isDeleted)
        VALUES (
            <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#trim(arguments.new_mediaType)#">,
            <cfqueryparam cfsqltype="CF_SQL_BIT" value="#arguments.new_isDeleted#">
        )
    </cfquery>
    <cfreturn result.generatedKey>
</cffunction>

<cffunction output="false" name="UPDaudmediatypes" access="public" returntype="void">
    <cfargument name="new_mediaType" type="string" required="true">
    <cfargument name="new_isDeleted" type="boolean" required="true">
    <cfargument name="new_mediaTypeID" type="numeric" required="true">

<!--- Update media type in database --->
    <cfquery result="result">
        UPDATE audmediatypes 
        SET 
            mediaType = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#trim(arguments.new_mediaType)#">,
            isDeleted = <cfqueryparam cfsqltype="CF_SQL_BIT" value="#arguments.new_isDeleted#">
        WHERE 
            mediaTypeID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_mediaTypeID#">
    </cfquery>
</cffunction>

</cfcomponent>