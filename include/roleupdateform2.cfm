<!--- This ColdFusion page processes audition submissions, handling various parameters and database interactions. --->

<!--- Form and URL parameter validation with cfparam --->
<cfparam name="form.new_audroleid" default="" />
<cfparam name="form.audprojectid" default="" />
<cfparam name="form.new_catid" default="" />
<cfparam name="form.secid" default="" />
<cfparam name="form.userid" default="" />
<cfparam name="form.new_audrolename" default="" />
<cfparam name="form.new_audroletypeid" default="" />
<cfparam name="form.new_charDescription" default="" />
<cfparam name="form.new_auddialectid" default="" />
<cfparam name="form.CustomDialect" default="" />
<cfparam name="form.new_audsourceid" default="" />
<cfparam name="form.new_submitsitename" default="" />
<cfparam name="form.genre" default="" />
<cfparam name="form.essence" default="" />
<cfparam name="form.vocaltype" default="" />
<cfparam name="form.rangename" default="" />
<cfparam name="form.referral" default="" />
<cfparam name="form.new_opencallname" default="" />
<cfparam name="url.focusid" default="" />

<!--- Assign local variables with proper scope qualification --->
<cfset local.new_audroleid = trim(form.new_audroleid) />
<cfset local.audprojectid = trim(form.audprojectid) />
<cfset local.new_catid = trim(form.new_catid) />
<cfset local.secid = trim(form.secid) />
<cfset local.userid = trim(form.userid) />
<cfset local.new_audrolename = trim(form.new_audrolename) />
<cfset local.new_audroletypeid = trim(form.new_audroletypeid) />
<cfset local.new_charDescription = trim(form.new_charDescription) />
<cfset local.new_auddialectid = trim(form.new_auddialectid) />
<cfset local.CustomDialect = trim(form.CustomDialect) />
<cfset local.new_audsourceid = trim(form.new_audsourceid) />
<cfset local.new_submitsitename = trim(form.new_submitsitename) />
<cfset local.genre = trim(form.genre) />
<cfset local.essence = trim(form.essence) />
<cfset local.vocaltype = trim(form.vocaltype) />
<cfset local.rangename = trim(form.rangename) />
<cfset local.referral = trim(form.referral) />
<cfset local.new_opencallname = trim(form.new_opencallname) />
<cfset local.focusid = trim(url.focusid) />

<!--- Additional processing parameters --->
<cfparam name="new_isDeleted" default="0">
<cfparam name="new_contactid" default="">
<cfparam name="NEW_OPENCALLID" default="0" /> 
<cfparam name="new_submitsiteid" default="" />
<cfparam name="dbug" default="YN" />

<!--- Use local variables for processing --->
<cfset new_audroleid = local.new_audroleid />
<cfset audprojectid = local.audprojectid />
<cfset new_catid = local.new_catid />
<cfset secid = local.secid />
<cfset userid = local.userid />
<cfset new_audrolename = local.new_audrolename />
<cfset new_audroletypeid = local.new_audroletypeid />
<cfset new_charDescription = local.new_charDescription />
<cfset new_auddialectid = local.new_auddialectid />
<cfset CustomDialect = local.CustomDialect />
<cfset new_audsourceid = local.new_audsourceid />
<cfset new_submitsitename = local.new_submitsitename />
<cfset genre = local.genre />
<cfset essence = local.essence />
<cfset vocaltype = local.vocaltype />
<cfset rangename = local.rangename />
<cfset referral = local.referral />
<cfset new_opencallname = local.new_opencallname />
<cfset focusid = local.focusid />

<!--- WO-5.1: Validate numeric inputs --->
<cfset new_audroleid = val(new_audroleid) />
<cfset audprojectid = val(audprojectid) />
<cfset new_catid = val(new_catid) />
<cfset secid = val(secid) />
<cfset userid = val(userid) />
<cfset new_audroletypeid = val(new_audroletypeid) />
<cfset new_audsourceid = val(new_audsourceid) />

<!--- WO-5.1: Guard against missing/invalid role id (stray GET, refresh replay, or bot).
      Without a valid role id there is nothing to update, and the destructive delete/update
      includes below must not run. Bail out cleanly instead of crashing or doing no-op writes. --->
<cfif new_audroleid LTE 0>
    <cfif audprojectid GT 0>
        <cflocation url="/app/audition/?audprojectid=#audprojectid#&secid=#secid#" addtoken="false" />
    <cfelse>
        <cflocation url="/app/" addtoken="false" />
    </cfif>
</cfif>

<!--- Include necessary query files for deletion and processing. --->
<cfinclude template="/include/qry/delete_287_1.cfm" />
<cfinclude template="/include/qry/delete_287_2.cfm" />
<cfinclude template="/include/qry/delete_287_3.cfm" />
<cfinclude template="/include/qry/delete_287_4.cfm" />
<cfinclude template="/include/qry/delete_287_5.cfm" />

<!--- Check if new_opencallname is provided and process accordingly. --->
<cfif len(new_opencallname) gt 0>
    <cfinclude template="/include/qry/findit2_287_6.cfm" />
    
    <cfif findit2.recordcount gt 0>
        <cfset new_opencallid = findit2.opencallid />
    <cfelse>
        <cfinclude template="/include/qry/insert_287_7.cfm" />
        <cfset new_opencallid = result.generated_key />
    </cfif>
</cfif>

<!--- Process essence if provided. --->
<cfif len(essence) gt 0>
    <cfloop list="#essence#" index="new_essence">
        <cfinclude template="/include/qry/findit_287_8.cfm" />
        
        <cfif findit.recordcount gt 0>
            <cfset new_essenceid = findit.new_essenceid />
        <cfelse>
            <cfinclude template="/include/qry/insert_287_9.cfm" />
            
        </cfif>
        
        <cfinclude template="/include/qry/insert_287_10.cfm" />
    </cfloop>
</cfif>

<cfparam name="genre" default="" />

<!--- Process genre if provided. --->
<cfif len(genre) gt 0>
    <cfloop list="#genre#" index="new_genre">
        <cfinclude template="/include/qry/findit_287_11.cfm" />
        
        <cfif findit.recordcount gt 0>
            <cfset new_audgenreid = findit.audgenreid />
            <cfinclude template="/include/qry/insert_287_12.cfm" />
        <cfelse>
            <cfinclude template="/include/qry/insert_287_13.cfm" />
     
            <cfinclude template="/include/qry/insert_287_14.cfm" />
        </cfif>
    </cfloop>
</cfif>

<!--- Process vocal type if provided. --->
<cfif len(vocaltype) gt 0>
    <cfinclude template="/include/qry/delete_287_15.cfm" />
    
    <cfloop list="#vocaltype#" index="new_vocaltypeid">
        <cfinclude template="/include/qry/insert_287_16.cfm" />
    </cfloop>
</cfif>

<!--- Process range name if provided. --->
<cfif len(rangename) gt 0>
    <cfinclude template="/include/qry/delete_287_4.cfm" />
    
    <cfloop list="#rangename#" index="new_rangeid">
        <cfinclude template="/include/qry/insert_287_18.cfm" />
    </cfloop>
</cfif>

<!--- Handle contact creation if new_audSourceID is 3 and referral is provided. --->
<cfif len(new_audsourceid) eq 0 or new_audsourceid eq "0">
    <cfset new_contactid = 0 />
    <cfset new_submitsiteid = 0 />
    <cfset new_audsourceid = 0 />
    <cfset new_opencallid = 0 />
</cfif>

<cfif new_audsourceid eq "1">
    <cfset new_submitsiteid = 0 />
    <cfset new_opencallid = 0 />
</cfif>

<cfif new_audsourceid eq "3">
    <cfset new_submitsiteid = 0 />
    <cfset new_opencallid = 0 />
    
    <cfif len(referral) gt 0>
        <cfinclude template="/include/qry/findg_287_19.cfm" />
        
        <cfif findg.recordcount gt 0>
            <cfset new_contactid = findg.contactid />
        <cfelse>
            <cfoutput>
                <cfset numelements = listlen(referral, " ")>
                <cfif numelements eq 2>
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
<cfif new_audsourceid eq "2">
    <cfinclude template="/include/qry/find_subsite_287_21.cfm" />
    <cfset new_contactid = 0 />
    <cfset new_opencallid = 0 />
    
    <cfif find_subsite.recordcount gt 0>
        <cfset new_submitsiteid = find_subsite.new_submitsiteid />
        <cfset new_catlist = find_subsite.new_catlist />
        
        <cfif dbug eq "Y">
            <cfoutput>
                new_submitsiteid: #new_submitsiteid#<BR>
                new_catlist: #new_catlist#<BR>
            </cfoutput>
        </cfif>
        
        <cfif listFind(new_catlist, new_catid)>
            <cfset new_catlist = new_catlist />
        <cfelse>
            <cfoutput>
                <cfset new_catlist = "#new_catlist#,#new_catid#" />
            </cfoutput>
            
            <cfif dbug eq "Y">
                <cfoutput>
                    new_catlist: #new_catlist#<BR>
                </cfoutput>
            </cfif>
        
            <cfinclude template="/include/qry/update_287_22.cfm" />
            <cfif dbug eq "Y">
                <cfoutput>
                    update audsubmitsites_user
                    set catlist = '#new_catlist#'
                    WHERE submitsiteid = #new_submitsiteid#<BR>
                </cfoutput>
            </cfif>
        </cfif>
    <cfelse>
        <cfinclude template="/include/qry/add_287_23.cfm" />
        
        <cfif dbug eq "Y">
            <cfoutput>
                INSERT INTO `audsubmitsites_user_tbl` (`submitsiteName`, `userid`, `catlist`)
                VALUES ('#trim(new_submitsitename)#', #userid#, '#new_catid#')<BR>
            </cfoutput>
        </cfif>
        
        <cfset new_submitsiteid = sub.generated_key />
        
        <cfif dbug eq "Y">
            <cfoutput>
                new_submitsiteid: #new_submitsiteid#<BR>
            </cfoutput>
        </cfif>
    </cfif>
</cfif>



<!--- Debugging output if dbug is enabled. --->
<cfif dbug eq "Y">
    <cfabort>
</cfif>

<!--- Handle custom dialect processing if applicable. --->
<cfif new_auddialectid eq "CustomDialect">
    <cfif len(CustomDialect) gt 0>  
        <cfinclude template="/include/qry/insert_287_24.cfm" />
    <cfelse>
        <cfset new_dialectid = old_dialectid />
    </cfif>
</cfif> 

<!--- Update audition roles. --->
<cfinclude template="/include/qry/audroles_upd_287_25.cfm" />

<!--- Determine return URL based on focusid. --->
<cfif len(focusid) eq 0>
    <cfoutput>
        <cfset returnurl = "/app/audition/?audprojectid=#audprojectid#&secid=#secid#" />
    </cfoutput>
<cfelse>
    <cfoutput>
        <cfset returnurl = "/app/audition/?audprojectid=#audprojectid#&secid=#secid#&focusid=#focusid#" />
    </cfoutput>
</cfif>

<cflocation url="#returnurl#">

