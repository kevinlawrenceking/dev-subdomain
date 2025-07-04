<!--- This ColdFusion page processes audition submissions, handling various parameters and database interactions. --->

<cfparam name="new_isDeleted" default="0">
<cfparam name="new_contactid" default="">
<cfparam name="essence" default="" />
<cfparam name="vocaltype" default="" />
<cfparam name="rangename" default="" />
<cfparam name="referral" default="" />
<cfparam name="new_opencallname" default="" /> 
<cfparam name="NEW_OPENCALLID" default="0" /> 
<cfparam name="new_submitsiteid" default="" />
<cfparam name="dbug" default="YN" />

<!--- Include necessary query files for deletion and processing. --->
<cfinclude template="/include/qry/delete_287_1.cfm" />
<cfinclude template="/include/qry/delete_287_2.cfm" />
<cfinclude template="/include/qry/delete_287_3.cfm" />
<cfinclude template="/include/qry/delete_287_4.cfm" />
<cfinclude template="/include/qry/delete_287_5.cfm" />

<!--- Check if new_opencallname is provided and process accordingly. --->
<cfif #new_opencallname# is not "">
    <cfinclude template="/include/qry/findit2_287_6.cfm" />
    
    <cfif #findit2.recordcount# is "1">
        <cfset new_opencallid = findit2.opencallid />
    <cfelse>
        <cfinclude template="/include/qry/insert_287_7.cfm" />
        <cfset new_opencallid = result.generated_key />
    </cfif>
</cfif>

<!--- Process essence if provided. --->
<Cfif #essence# is not "">
    <cfloop list="#essence#" index="new_essence">
        <cfinclude template="/include/qry/findit_287_8.cfm" />
        
        <cfif #findit.recordcount# is "1">
            <cfset new_essenceid = findit.new_essenceid />
        <cfelse>
            <cfinclude template="/include/qry/insert_287_9.cfm" />
            
        </cfif>
        
        <cfinclude template="/include/qry/insert_287_10.cfm" />
    </cfloop>
</cfif>

<cfparam name="genre" default="" />

<!--- Process genre if provided. --->
<Cfif #genre# is not "">
    <cfloop list="#Genre#" index="new_genre">
        <cfinclude template="/include/qry/findit_287_11.cfm" />
        
        <cfif #findit.recordcount# is "1">
            <cfset new_audgenreid = findit.audgenreid />
            <cfinclude template="/include/qry/insert_287_12.cfm" />
        <cfelse>
            <cfinclude template="/include/qry/insert_287_13.cfm" />
     
            <cfinclude template="/include/qry/insert_287_14.cfm" />
        </cfif>
    </cfloop>
</cfif>

<!--- Process vocal type if provided. --->
<cfif #vocaltype# is not "">
    <cfinclude template="/include/qry/delete_287_15.cfm" />
    
    <cfloop list="#vocaltype#" index="new_vocaltypeid">
        <cfinclude template="/include/qry/insert_287_16.cfm" />
    </cfloop>
</cfif>

<!--- Process range name if provided. --->
<cfif #rangename# is not "">
    <cfinclude template="/include/qry/delete_287_4.cfm" />
    
    <cfloop list="#rangename#" index="new_rangeid">
        <cfinclude template="/include/qry/insert_287_18.cfm" />
    </cfloop>
</cfif>

<!--- Handle contact creation if new_audSourceID is 3 and referral is provided. --->
<cfif #new_audsourceid# is "" or #new_audsourceid# is "0">
<cfset new_contactid = 0 />
<cfset new_submitsiteid = 0 />
<cfset new_audsourceid = 0 />
<cfset new_opencallid = 0 />
</cfif>

<Cfif #new_audsourceid# is "1">
<cfset new_submitsiteid = 0 />
<cfset new_opencallid = 0 />
</cfif>
<cfif #new_audSourceID# is "3">
<cfset new_submitsiteid = 0 />
<cfset new_opencallid = 0 />
    <cfif #referral# is not "">
        <cfinclude template="/include/qry/findg_287_19.cfm" />
        
        <cfif #findg.recordcount# is "1">
            <cfset new_contactid = findg.contactid />
        <cfelse>
            <cfoutput>
                <cfset numelements = listlen(referral, " ")>
                <cfif numelements is 2>
                    <cfset firstname = listfirst(referral, " ")>
                    <cfset lastname = listlast(referral, " ")>
                <cfelseif numelements gte 3>
                    <cfset firstname = listgetat(referral, 1, " ") & " " & listgetat(referral, 2, " ")>
                    <cfset lastname = right(referral, len(referral) - len(firstname) - 1)>
                <cfelse>
                    <cfset firstname = referral>
                    <cfset lastname = ''>
                </cfif>
            </cfoutput>
            
            <cfinclude template="/include/qry/add_287_20.cfm" />
            <cfset new_contactid = result.generated_key />
            
            <cfset select_userid = userid />
            <cfset select_contactid = new_contactid />
            <cfinclude template="/include/folder_setup.cfm" />
        </cfif>
        <cfelse>
        <cfset new_contactid = 0 />
    </cfif>
</cfif>

<!--- Handle submissions if new_audSourceID is 2. --->
<cfif #new_audSourceID# is "2">
    <cfinclude template="/include/qry/find_subsite_287_21.cfm" />
    <cfset new_contactid = 0 />
<cfset new_opencallid = 0 />
    
    <cfif #find_subsite.recordcount# is "1">
        <cfset new_submitsiteid = find_subsite.new_submitsiteid />
        <cfset new_catlist = find_subsite.new_catlist />
        
        <cfif #dbug# is "Y">
            <cfoutput>
                new_submitsiteid: #new_submitsiteid#<BR>
                new_catlist: #new_catlist#<BR>
            </cfoutput>
        </cfif>
        
        <cfif "#new_catlist#" contains "#new_catid#">
            <cfset new_catlist = new_catlist />
        <cfelse>
            <cfoutput>
                <cfset new_catlist = "#new_catlist#,#new_catid#" />
            </cfoutput>
            
            <cfif #dbug# is "Y">
                <cfoutput>
                    new_catlist: #new_catlist#<BR>
                </cfoutput>
            </cfif>
        
            <cfinclude template="/include/qry/update_287_22.cfm" />
            <cfif #dbug# is "Y">
                <cfoutput>
                    update audsubmitsites_user
                    set catlist = '#new_catlist#'
                    WHERE submitsiteid = #new_submitsiteid#<BR>
                </cfoutput>
            </cfif>
        </cfif>
    <cfelse>
        <cfinclude template="/include/qry/add_287_23.cfm" />
        
        <cfif #dbug# is "Y">
            <cfoutput>
                INSERT INTO `audsubmitsites_user_tbl` (`submitsiteName`, `userid`, `catlist`)
                VALUES ('#trim(new_submitsitename)#', #userid#, '#new_catid#')<BR>
            </cfoutput>
        </cfif>
        
        <cfset new_submitsiteid = sub.generated_key />
        
        <cfif #dbug# is "Y">
            <cfoutput>
                new_submitsiteid: #new_submitsiteid#<BR>
            </cfoutput>
        </cfif>
    </cfif>
</cfif>



<!--- Debugging output if dbug is enabled. --->
<cfif #dbug# is "Y">
    <cfabort>
</cfif>

<!--- Handle custom dialect processing if applicable. --->
<cfif #new_audDialectID# is "CustomDialect">
    <cfif #CustomDialect# is not "">  
        <cfinclude template="/include/qry/insert_287_24.cfm" />
    <cfelse>
        <cfset new_dialectid = old_dialectid />
    </cfif>
</cfif> 

<!--- Update audition roles. --->
<cfinclude template="/include/qry/audroles_upd_287_25.cfm" />

<cfparam name="focusid" default="" />

<!--- Determine return URL based on focusid. --->
<cfif #focusid# is "">
    <cfoutput>
        <cfset returnurl = "/app/audition/?audprojectid=#audprojectid#&secid=#secid#" />
    </cfoutput>
<cfelse>
    <cfoutput>
        <cfset returnurl = "/app/audition/?audprojectid=#audprojectid#&secid=#secid#&focusid=#focusid#" />
    </cfoutput>
</cfif>

<cflocation url="#returnurl#">

