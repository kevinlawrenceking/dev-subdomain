<!--- This ColdFusion page handles user data display and provides a link for sharing user information. --->
<cfparam name="contact_expand" default="true" />
<cfparam name="a" default="0" />
<cfparam name="d" default="0" />
<cfparam name="s" default="0" />

<cfparam name="contactcheckvisible" default="false" />
<cfparam name="maintenance_expand" default="false" />
<cfparam name="bytag" default="" />
<cfparam name="target_expand" default="false" />
<cfparam name="followup_expand" default="false" />
<cfparam name="all_expand" default="false" />
<cfparam name="pgaction" default="view" />

<!--- Check if session variable 'pgaction' is defined; if not, set it to 'view' --->
<cfif NOT isdefined('session.pgaction')>
    <cfset session.pgaction = "view">
</cfif>

<!--- Include the query template for user data --->
<cfinclude template="/include/qry/x_291_1.cfm" />

<div class="row">
    <div class="col-lg-12">
        <div class="card mb-3">
            <div class="card-body">
                <!--- Loop through the query results and output user information with a share link --->
                <cfloop query="x">
                    <cfoutput>
                        #x.userfirstname# #x.userlastname#: 
                        <A HREF="https://#host#.theactorsoffice.com/share/?u=#left(passwordhash,10)#">
                            https://#host#.theactorsoffice.com/share/?u=#left(passwordhash,10)#
                        </A><BR/>
                    </cfoutput>
                </cfloop>
            </div>
        </div>
    </div>
</div> <!--- end row ---> 

</div> <!--- container --->
