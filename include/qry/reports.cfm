<!--- This ColdFusion page handles the generation and management of user reports, including checking for existing reports, inserting new ones, and calculating statistics based on user input. --->

<cfparam name="new_rangeid" default="1" />
<cfparam name="customstart" default="#DateFormat(Now(), 'yyyy-mm-dd')#" />
<cfparam name="customend" default="#DateFormat(Now(), 'yyyy-mm-dd')#" />
<cfparam name="new_audsourceid" default="1" />
<cfparam name="anchortag" default="" />
<cfparam name="new_audcatid" default="1" />
<cfparam name="refreshdata_yn" default="y" />

<cfif DatePart("yyyy", customstart) EQ 2022>
    <cfset customstart = DateFormat(Now(), 'yyyy-mm-dd')>
</cfif>

<cfif DatePart("yyyy", customstart) EQ 2025>
    <cfset custocustomstartmend = DateFormat(Now(), 'yyyy-mm-dd')>
</cfif>

<!--- Check if reports exist for the user --->
<cfinclude template="/include/qry/reportcheck_524_1.cfm" />

<cfif #reportcheck.recordcount# is "0">
    <!--- If no reports exist, retrieve user information and available reports --->
    <cfinclude template="/include/qry/u_524_2.cfm" />

    <cfloop query="u">
        <cfinclude template="/include/qry/x_524_3.cfm" />

        <cfloop query="x">
            <cfinclude template="/include/qry/find_524_4.cfm" />

            <cfif #find.recordcount# is "0">
                <!--- Insert new report for the user if it does not exist --->
                <cfinclude template="/include/qry/insert_524_5.cfm" />
            </cfif>
        </cfloop>
    </cfloop>
</cfif>

<!--- Retrieve report items for the user --->
<cfinclude template="/include/qry/finditems_524_6.cfm" />

<cfif #finditems.recordcount# is "0">
    <!--- Redirect to refresh reports if no items found --->
    <CFLOCATION addtoken="false" url="/include/reportsRefresh.cfm?anchortag=#anchortag#&new_rangeid=#new_rangeid#&new_audcatid=#new_audcatid#&new_audsourceid=#new_audsourceid#">
</cfif>

<cfset reportdate="" />

<!--- Retrieve report ranges --->
<cfinclude template="/include/qry/ranges_524_7.cfm" />

<cfinclude template="/include/qry/rangeselected_524_8.cfm" />

<cfif #new_rangeid# is "7" AND #customstart# is not "" AND #customend# is not "">
    <!--- Set custom range start and end if specified --->
    <cfset new_rangestart = customstart />
    <cfset new_rangeend = customend />
<cfelse>
    <!--- Use selected range start and end if no custom range is provided --->
    <cfset new_rangestart = rangeselected.rangestart />
    <cfset new_rangeend = rangeselected.rangeend />
</cfif>

<cfif #new_rangeid# is "1">
    <cfset rangedisplay = "All dates" />
<cfelse>
    <cfoutput>
        <cfset rangedisplay = "#dateformat('#new_rangestart#', 'MM/d/YY')#-#dateformat('#new_rangeend#', 'MM/d/YY')#" />
    </cfoutput>
</cfif>

<!--- Retrieve user reports --->
<cfinclude template="/include/qry/reports_524_9.cfm" />

<!--- Retrieve statistics for specific report types --->
<cfinclude template="/include/qry/stats_524_10.cfm" />

<!--- Retrieve available categories --->
<cfinclude template="/include/qry/categories_524_11.cfm" />

<!--- Retrieve specific report ratios --->
<cfinclude template="/include/qry/ratio_13_524_12.cfm" />

<cfinclude template="/include/qry/ratio_17_524_13.cfm" />

<cfif #ratio_13.recordcount# is "1" AND #ratio_17.recordcount# is "1">
    <!--- Calculate book ratio if both ratios are found --->
    <cfset new_item_13 = ratio_13.item_13 />
    <cfset new_item_17 = ratio_17.item_17 />
    
    <cfif #new_item_17# is not "0">
        <cfscript>
            bookratio = new_item_13 / new_item_17 * 100;
        </cfscript>
    <cfelse>
        <cfset bookratio = 0 />
    </cfif>
<cfelse>
    <cfset bookratio = 0 />
</cfif>

