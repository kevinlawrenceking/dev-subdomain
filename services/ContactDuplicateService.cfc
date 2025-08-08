<!---
    PURPOSE: Contact duplicate detection and merging service
    AUTHOR: Kevin King
    DATE: 2025-08-07
    DEPENDENCIES: Application datasource, ContactItemService
--->

<cfcomponent displayname="ContactDuplicateService" hint="Handles contact duplicate detection and merging operations">

    <cffunction name="init" access="public" returntype="ContactDuplicateService">
        <cfreturn this />
    </cffunction>

    <!--- Find potential duplicates by name --->
    <cffunction name="findDuplicatesByName" access="public" returntype="query">
        <cfargument name="userid" type="numeric" required="true" />
        
        <cfquery name="qDuplicatesByName" datasource="#application.dsn#">
            SELECT 
                contactfirst,
                contactlast,
                userid,
                COUNT(*) as duplicate_count,
                GROUP_CONCAT(contactid ORDER BY contactid) as contact_ids
            FROM contactdetails 
            WHERE isdeleted = <cfqueryparam value="0" cfsqltype="cf_sql_bit" />
              AND userid = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer" />
              AND contactfirst IS NOT NULL 
              AND contactlast IS NOT NULL
              AND TRIM(contactfirst) != ''
              AND TRIM(contactlast) != ''
            GROUP BY contactfirst, contactlast, userid 
            HAVING COUNT(*) > 1 
            ORDER BY duplicate_count DESC, contactlast, contactfirst
        </cfquery>
        
        <cfreturn qDuplicatesByName />
    </cffunction>

    <!--- Find potential duplicates by email --->
    <cffunction name="findDuplicatesByEmail" access="public" returntype="query">
        <cfargument name="userid" type="numeric" required="true" />
        
        <cfquery name="qDuplicatesByEmail" datasource="#application.dsn#">
            SELECT 
                ci.valuetext as email,
                cd.userid,
                COUNT(DISTINCT cd.contactid) as duplicate_count,
                GROUP_CONCAT(DISTINCT cd.contactid ORDER BY cd.contactid) as contact_ids,
                GROUP_CONCAT(DISTINCT CONCAT(cd.contactfirst, ' ', cd.contactlast) ORDER BY cd.contactid SEPARATOR '|') as contact_names
            FROM contactitems ci
            INNER JOIN contactdetails cd ON ci.contactid = cd.contactid
            INNER JOIN itemcategories ic ON ci.catid = ic.catid
            WHERE cd.isdeleted = <cfqueryparam value="0" cfsqltype="cf_sql_bit" />
              AND cd.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer" />
              AND ic.valueCategory = 'Email'
              AND ci.valuetext IS NOT NULL
              AND TRIM(ci.valuetext) != ''
              AND ci.valuetext LIKE '%@%'
            GROUP BY ci.valuetext, cd.userid 
            HAVING COUNT(DISTINCT cd.contactid) > 1 
            ORDER BY duplicate_count DESC, ci.valuetext
        </cfquery>
        
        <cfreturn qDuplicatesByEmail />
    </cffunction>

    <!--- Get detailed contact information for specific contacts --->
    <cffunction name="getContactDetails" access="public" returntype="query">
        <cfargument name="contactIds" type="string" required="true" />
        <cfargument name="userid" type="numeric" required="true" />
        
        <cfquery name="qContactDetails" datasource="#application.dsn#">
            SELECT 
                cd.*,
                DATE_FORMAT(cd.timestamp, '%Y-%m-%d %H:%i:%s') as created_date
            FROM contactdetails cd
            WHERE cd.contactid IN (<cfqueryparam value="#arguments.contactIds#" cfsqltype="cf_sql_varchar" list="true" />)
              AND cd.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer" />
              AND cd.isdeleted = <cfqueryparam value="0" cfsqltype="cf_sql_bit" />
            ORDER BY cd.timestamp ASC
        </cfquery>
        
        <cfreturn qContactDetails />
    </cffunction>

    <!--- Get contact items (email, phone, etc.) for specific contacts --->
    <cffunction name="getContactItems" access="public" returntype="query">
        <cfargument name="contactIds" type="string" required="true" />
        
        <cfquery name="qContactItems" datasource="#application.dsn#">
            SELECT 
                ci.*,
                ic.valueCategory,
                ic.catid
            FROM contactitems ci
            INNER JOIN itemcategories ic ON ci.catid = ic.catid
            WHERE ci.contactid IN (<cfqueryparam value="#arguments.contactIds#" cfsqltype="cf_sql_varchar" list="true" />)
            ORDER BY ci.contactid, ic.valueCategory, ci.itemid
        </cfquery>
        
        <cfreturn qContactItems />
    </cffunction>

    <!--- Merge two contacts --->
    <cffunction name="mergeContacts" access="public" returntype="struct">
        <cfargument name="primaryContactId" type="numeric" required="true" />
        <cfargument name="duplicateContactId" type="numeric" required="true" />
        <cfargument name="mergeData" type="struct" required="true" />
        <cfargument name="userid" type="numeric" required="true" />
        
        <cfset var result = {success: false, message: ""} />
        
        <cftry>
            <cftransaction>
                <!--- Update primary contact with merged data --->
                <cfquery datasource="#application.dsn#">
                    UPDATE contactdetails 
                    SET 
                        contactfirst = <cfqueryparam value="#arguments.mergeData.contactfirst#" cfsqltype="cf_sql_varchar" />,
                        contactlast = <cfqueryparam value="#arguments.mergeData.contactlast#" cfsqltype="cf_sql_varchar" />,
                        contactfullname = <cfqueryparam value="#arguments.mergeData.contactfullname#" cfsqltype="cf_sql_varchar" />,
                        contactpronoun = <cfqueryparam value="#arguments.mergeData.contactpronoun#" cfsqltype="cf_sql_varchar" null="#not len(trim(arguments.mergeData.contactpronoun))#" />,
                        contactbirthday = <cfqueryparam value="#arguments.mergeData.contactbirthday#" cfsqltype="cf_sql_date" null="#not isDate(arguments.mergeData.contactbirthday)#" />,
                        contactmeetingdate = <cfqueryparam value="#arguments.mergeData.contactmeetingdate#" cfsqltype="cf_sql_date" null="#not isDate(arguments.mergeData.contactmeetingdate)#" />,
                        contactmeetingloc = <cfqueryparam value="#arguments.mergeData.contactmeetingloc#" cfsqltype="cf_sql_varchar" null="#not len(trim(arguments.mergeData.contactmeetingloc))#" />,
                        refer_contact_id = <cfqueryparam value="#arguments.mergeData.refer_contact_id#" cfsqltype="cf_sql_integer" null="#not len(trim(arguments.mergeData.refer_contact_id))#" />,
                        newsletter_yn = <cfqueryparam value="#arguments.mergeData.newsletter_yn#" cfsqltype="cf_sql_varchar" />,
                        googlealert_yn = <cfqueryparam value="#arguments.mergeData.googlealert_yn#" cfsqltype="cf_sql_varchar" />,
                        socialmedia_yn = <cfqueryparam value="#arguments.mergeData.socialmedia_yn#" cfsqltype="cf_sql_varchar" />
                    WHERE contactid = <cfqueryparam value="#arguments.primaryContactId#" cfsqltype="cf_sql_integer" />
                      AND userid = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer" />
                </cfquery>

                <!--- Move contact items from duplicate to primary --->
                <cfquery datasource="#application.dsn#">
                    UPDATE contactitems 
                    SET contactid = <cfqueryparam value="#arguments.primaryContactId#" cfsqltype="cf_sql_integer" />
                    WHERE contactid = <cfqueryparam value="#arguments.duplicateContactId#" cfsqltype="cf_sql_integer" />
                      AND itemid NOT IN (
                          SELECT itemid FROM (
                              SELECT ci2.itemid 
                              FROM contactitems ci1
                              INNER JOIN contactitems ci2 ON ci1.catid = ci2.catid 
                                  AND ci1.valuetext = ci2.valuetext
                              WHERE ci1.contactid = <cfqueryparam value="#arguments.primaryContactId#" cfsqltype="cf_sql_integer" />
                                AND ci2.contactid = <cfqueryparam value="#arguments.duplicateContactId#" cfsqltype="cf_sql_integer" />
                          ) as duplicates
                      )
                </cfquery>

                <!--- Move notes from duplicate to primary --->
                <cfquery datasource="#application.dsn#">
                    UPDATE contactnotes 
                    SET contactid = <cfqueryparam value="#arguments.primaryContactId#" cfsqltype="cf_sql_integer" />
                    WHERE contactid = <cfqueryparam value="#arguments.duplicateContactId#" cfsqltype="cf_sql_integer" />
                </cfquery>

                <!--- Move appointments from duplicate to primary --->
                <cfquery datasource="#application.dsn#">
                    UPDATE events 
                    SET eventid = <cfqueryparam value="#arguments.primaryContactId#" cfsqltype="cf_sql_integer" />
                    WHERE eventid = <cfqueryparam value="#arguments.duplicateContactId#" cfsqltype="cf_sql_integer" />
                </cfquery>

                <!--- Move relationship systems from duplicate to primary --->
                <cfquery datasource="#application.dsn#">
                    UPDATE fusystemusers 
                    SET contactid = <cfqueryparam value="#arguments.primaryContactId#" cfsqltype="cf_sql_integer" />
                    WHERE contactid = <cfqueryparam value="#arguments.duplicateContactId#" cfsqltype="cf_sql_integer" />
                </cfquery>

                <!--- Move notifications from duplicate to primary --->
                <cfquery datasource="#application.dsn#">
                    UPDATE funotifications 
                    SET contactid = <cfqueryparam value="#arguments.primaryContactId#" cfsqltype="cf_sql_integer" />
                    WHERE contactid = <cfqueryparam value="#arguments.duplicateContactId#" cfsqltype="cf_sql_integer" />
                </cfquery>

                <!--- Move tags from duplicate to primary --->
                <cfquery datasource="#application.dsn#">
                    UPDATE tagsuser 
                    SET contactid = <cfqueryparam value="#arguments.primaryContactId#" cfsqltype="cf_sql_integer" />
                    WHERE contactid = <cfqueryparam value="#arguments.duplicateContactId#" cfsqltype="cf_sql_integer" />
                      AND tagid NOT IN (
                          SELECT tagid FROM (
                              SELECT tu2.tagid 
                              FROM tagsuser tu1
                              INNER JOIN tagsuser tu2 ON tu1.tagid = tu2.tagid
                              WHERE tu1.contactid = <cfqueryparam value="#arguments.primaryContactId#" cfsqltype="cf_sql_integer" />
                                AND tu2.contactid = <cfqueryparam value="#arguments.duplicateContactId#" cfsqltype="cf_sql_integer" />
                          ) as duplicate_tags
                      )
                </cfquery>

                <!--- Mark duplicate contact as deleted --->
                <cfquery datasource="#application.dsn#">
                    UPDATE contactdetails 
                    SET isdeleted = <cfqueryparam value="1" cfsqltype="cf_sql_bit" />
                    WHERE contactid = <cfqueryparam value="#arguments.duplicateContactId#" cfsqltype="cf_sql_integer" />
                      AND userid = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer" />
                </cfquery>

                <cfset result.success = true />
                <cfset result.message = "Contacts merged successfully" />
            </cftransaction>

            <cfcatch type="any">
                <cfset result.success = false />
                <cfset result.message = "Error merging contacts: " & cfcatch.message />
            </cfcatch>
        </cftry>
        
        <cfreturn result />
    </cffunction>

</cfcomponent>
