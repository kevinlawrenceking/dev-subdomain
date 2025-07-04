<!--- This ColdFusion page processes project information and updates the database accordingly. --->

<cfparam name="new_isDeleted" default="0"/>
<cfparam name="new_projName" default=""/>
<cfparam name="new_projDescription" default=""/>
<cfparam name="new_audSubCatID" default=""/>
<cfparam name="new_unionID" default=""/>
<cfparam name="new_networkID" default=""/>
<cfparam name="new_toneID" default=""/>
<cfparam name="new_contractTypeID" default=""/>
<cfparam name="new_contactid" default=""/>
<cfparam name="isdirect" default="0"/>
<cfparam name="isredirect" default="0"/>
<cfparam name="isbooked" default="0"/>
<cfparam name="ispin" default="0"/>
<cfparam name="isfix" default="N"/>

<cfinclude template="/include/qry/y_308_1.cfm" />

<CFOUTPUT>RECORDz: #Y.RECORDCOUNT#</CFOUTPUT>

<!--- Loop through query results ---> 
<cfloop query="y">
    <cfset new_status = "Valid" />
    
    <cfoutput>
        new_status: #new_status#
    </cfoutput>
    
    <cfinclude template="/include/qry/find_308_2.cfm" />

    <!--- Check if the record is unique ---> 
    <cfif find.recordcount is not "0">
        its unique!<BR>
        <cfset new_status="Invalid" />
        <CFOUTPUT>#NEW_STATUS#<br></CFOUTPUT>
        <cfinclude template="/include/qry/err_308_3.cfm" />
    </cfif>

    <!--- Validate project name ---> 
    <cfif y.projname is "">
        <cfset new_status="Invalid" />
        PROJNAME IS empty<br>
        <cfinclude template="/include/qry/err_308_4.cfm" />
    </cfif>

    <!--- Validate role name ---> 
    <cfif y.audrolename is "">
        <cfset new_status="Invalid" />
        ROLE NAME IS empty<br>
        <cfinclude template="/include/qry/err_308_5.cfm" />
    </cfif>

    <!--- Check if fix is required ---> 
    <cfif isfix is "Y">
        <cfinclude template="/include/qry/findcat_308_6.cfm" />
        
        <!--- Validate category count ---> 
        <cfif findcat.recordcount is not "1">
            <cfset new_status="Invalid" />
            CATEGORY INVALID<br>
            <cfinclude template="/include/qry/err_308_7.cfm" />
        </cfif>
    </cfif>

    <cfinclude template="/include/qry/findsource_308_8.cfm" />

    <!--- Validate source count ---> 
    <cfif findsource.recordcount is not "1">
        <cfset new_status="Invalid" />
        <cfinclude template="/include/qry/err_308_9.cfm" />
    </cfif>

    <cfinclude template="/include/qry/update_308_10.cfm" />
</cfloop>

<!--- Check if fix is required for additional processing ---> 
<cfif isfix is "Y">
    <cfinclude template="/include/qry/x_308_11.cfm" />
<cfelse>
    <cfinclude template="/include/qry/x_308_12.cfm" />
</cfif>

<!--- Loop through another query result ---> 
<cfloop query="x">
    <cfset new_projdate = this.formatDate(x.projdate) />

    <!--- Validate project date ---> 
    <cfif IsDate(new_projdate)>
        <cfset new_projdate = x.projdate>
    <cfelse>
        <cfset new_projdate = Now()>
    </cfif>

    <cfset cdfullname = x.cdfirstname & " " & x.cdlastname />
    <cfinclude template="/include/qry/findcd_308_13.cfm" />

    <!--- Check if contact exists ---> 
    <cfif findcd.recordcount is "0" and cdfirstname is not "">
        <cfoutput>contact not found, adding...<BR></cfoutput>
        <cfinclude template="/include/qry/INScontactDetails.cfm" />
        
        <cfset new_contactid=contactid />
        <cfset select_userid=userid />
        <cfset select_contactid=new_contactid />
        <cfset cdtype="Casting Director" />
        <cfoutput>new contactid: #new_contactid#<BR></cfoutput>
        <cfinclude template="/include/folder_setup.cfm" />
        <cfinclude template="/include/qry/insert_28_2.cfm" />
    <cfelse>
        <cfset new_contactid=0 />
    </cfif>

    <cfset new_status="Added" />
    <cfoutput>
        result: added - #new_contactid#
        <br>
    </cfoutput>

    <cfset select_userid=userid />
    <cfset select_contactid=new_contactid />
    <cfinclude template="/include/folder_setup.cfm" />

    <cfset new_projName=trim(x.projname) />
    <cfset new_audrolename=trim(x.audrolename) />

    <cfif isfix is "Y">
        <cfset new_audsubcatid=x.audsubcatid />
    <cfelse>
        <cfif x.audcatname is not "">
            <cfinclude template="/include/qry/find_subcat_308_16.cfm" />
            <!--- Validate subcategory count ---> 
            <cfif find_subcat.recordcount is "1">
                subcat found<BR>
                <cfset new_audsubcatid=find_subcat.audsubcatid />
            </cfif>
        </cfif>
    </cfif>

    <cfset iscallback=0 />
    <cfset isredirect=0 />
    <cfset ispin=0 />
    <cfset isbooked=0 />

    <!--- Set flags based on conditions ---> 
    <cfif x.callback_yn is "Y">
        <cfset iscallback=1 />
    </cfif>

    <cfif x.redirect_yn is "Y">
        <cfset isredirect=1 />
    </cfif>

    <cfif x.pin_yn is "Y">
        <cfset ispin=1 />
    </cfif>

    <cfif x.booked_yn is "Y">
        <cfset isbooked=1 />
    </cfif>

    <cfset new_projDescription=x.projDescription />
    <cfset new_charDescription=x.charDescription />
    <cfset new_audRoleName=x.audRoleName />

    <cfif isfix is "Y">
        <cfset new_audsubcatid=x.audsubcatid />
    <cfelse>
        <cfif x.audcatname is not "">
            <cfinclude template="/include/qry/find_cat_308_17.cfm" />
            <cfoutput>SELECT * FROM audcategories WHERE audcatname = '#x.audcatname#' and isdeleted is false<BR></cfoutput>
            <cfif find_cat.recordcount eq 1>
                <cfset new_audcatid=find_cat.audcatid />
                <cfinclude template="/include/qry/find_subcat_308_18.cfm" />
                <cfoutput>SELECT * FROM audsubcategories WHERE audcatid = #new_audcatid# and audsubcatname = '#x.audsubcatname#'<BR /></cfoutput>
                <cfif find_subcat.recordcount is "1">
                    <cfset new_audsubcatid=find_subcat.audsubcatid />
                    <cfoutput>new_audsubcatid: #find_subcat.audsubcatid#<BR></cfoutput>
                </cfif>
            </cfif>
        </cfif>
    </cfif>

    here<BR>
    <cfinclude template="/include/qry/audprojects_ins_308_19.cfm" />
    <cfset audprojectid=new_audprojectid />
    <cfoutput>new audprojectid: #new_audprojectid#<BR/></cfoutput>

    <cfif x.audsource is not "">
        <cfinclude template="/include/qry/find_source_308_20.cfm" />
        <cfif find_source.recordcount eq 1>
            <cfset new_audsourceid=find_source.audsourceid />
        </cfif>
    </cfif>

    <cfif new_audRoleName is "">
        <cfset new_audRoleName = "Unknown" />
    </cfif>

    <cfinclude template="/include/qry/audroles_ins_308_21.cfm" />

    <cfif x.note is not "">
        <cfinclude template="/include/qry/InsertNote_308_22.cfm" />
    </cfif>

    <cfinclude template="/include/qry/update_contact_308_23.cfm" />
</cfloop>

