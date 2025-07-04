<cfcomponent displayname="NotificationsService" hint="Handles operations for Notifications table (alerts)" >

    <cffunction name="addNotifications" access="public" returntype="numeric" output="false" hint="Adds a notification to the notifications table.">
        <!--- Arguments --->
        <cfargument name="subtitle" type="string" required="true" hint="The subtitle of the notification.">
        <cfargument name="userid" type="numeric" required="true" hint="The ID of the user to whom the notification belongs.">
        <cfargument name="notifUrl" type="string" required="true" hint="The URL associated with the notification.">
        <cfargument name="notifTitle" type="string" required="true" hint="The title of the notification.">
        <cfargument name="notifType" type="string" required="true" hint="The type of notification.">
        <cfargument name="contactid" type="numeric" required="true" hint="The contact ID related to the notification.">
        <cfargument name="isRead" type="boolean" required="true" default="0" hint="Whether the notification is read or not.">

        <!--- Insert query --->
        <cfquery name="Insert" result="result">
            INSERT INTO `notifications` (
                `subtitle`, 
                `userid`, 
                `notifUrl`, 
                `notifTitle`, 
                `notifType`, 
                `contactid`, 
                `read`
            )
            VALUES (
                <cfqueryparam value="#arguments.subtitle#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="#arguments.notifUrl#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="#arguments.notifTitle#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="#arguments.notifType#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="#arguments.isRead#" cfsqltype="CF_SQL_BIT">
            )
        </cfquery>

        <!--- Return the generated key for the inserted notification --->
        <cfreturn result.generatedKey>
    </cffunction>

</cfcomponent>
