<!--- contacts_gallery.cfm - Query contacts for gallery card display --->
<!--- Depends on: contacts_table, bytag, byimport, gallerysearch, userid --->

<!--- Validate dynamic table name --->
<cfif NOT reFindNoCase("^[a-z_][a-z0-9_]{0,63}$", trim(contacts_table))>
    <cflog file="contacts_gallery" text="BLOCKED: invalid table name contacts_table='#htmlEditFormat(contacts_table)#'" />
    <cfabort>
</cfif>

<cfquery name="galleryContacts">
    SELECT contactid, col1, col2b, col3, col4, col5, hlink
    FROM #contacts_table#
    WHERE userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer" />

    <cfif isDefined('bytag') and bytag neq "">
        AND contactid IN (
            SELECT contactid FROM contactitems
            WHERE valuetype = 'tags' AND itemstatus = 'active'
            AND valuetext = <cfqueryparam cfsqltype="cf_sql_varchar" value="#bytag#" />
        )
    </cfif>

    <cfif isDefined('byimport') and byimport neq "">
        AND contactid IN (
            SELECT contactid FROM contactsimport WHERE uploadid = <cfqueryparam value="#byimport#" cfsqltype="cf_sql_integer" />
            UNION
            SELECT created_contactid FROM import_v3_rows WHERE job_id = <cfqueryparam value="#byimport#" cfsqltype="cf_sql_integer" /> AND created_contactid IS NOT NULL
        )
    </cfif>

    <cfif isDefined('gallerysearch') and len(trim(gallerysearch))>
        AND (
            col1 LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#trim(gallerysearch)#%" />
            OR col3 LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#trim(gallerysearch)#%" />
            OR col4 LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#trim(gallerysearch)#%" />
            OR col5 LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#trim(gallerysearch)#%" />
        )
    </cfif>

    ORDER BY col1
</cfquery>
