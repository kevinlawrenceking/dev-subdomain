<!--- This ColdFusion page handles the logic for updating records based on user input and displays relevant information. --->

<cfinclude template="/include/qry/Finddetails_185_1.cfm" />   
<cfinclude template="/include/qry/FindResults_185_2.cfm" />   
<cfinclude template="/include/qry/FindKey_185_3.cfm" />

<!--- Set primary key and comptable variables from included queries --->
<cfset primary_key = findkey.fname />
<cfset comptable = FindResults.comptable />

<cfoutput>
    <!--- Generate page location and display various values --->
    <cfset pg_loc = "/app/#Finddetails.pgdir#/?recid=#parent_id#" />
    pg_loc: #pg_loc#<BR>
    mode: #mode#<BR>
    pgid: #pgid#<BR>
    parent recid : #parent_id#<BR>
    Child pgid: #rpgid#<BR>
    Child rec: #recid#<BR>
    current_val: #current_val#<BR>
    Table: #FindResults.comptable#<br>
    Primary key: #primary_key#<BR>

    <!--- Determine desired value based on mode --->
    <cfif #mode# is "up">
        <cfset desired_val = current_val - 1>
    <cfelse>
        <cfset desired_val = current_val + 1>       
    </cfif>

    Desired val: #desired_val#<BR>
    Fieldname: #fname#<BR>
    find query: select #primary_key# from #comptable# where #fname# = #desired_val# limit 1 <BR>
    SQL1: update #comptable# set #fname# = #desired_val# where #primary_key# = #recid#<BR>
</cfoutput>   

<cfinclude template="/include/qry/find_185_4.cfm" /> 

<!--- Set desired_recid from find query results --->
<cfset desired_recid = find.primary_key />

<cfoutput>
    <!--- Display desired_recid and SQL update statement --->
    desired_recid: #desired_recid#<BR>
    SQL2: update #comptable# set #fname# = #current_val# where #primary_key# = #desired_recid#<BR>          
</cfoutput>

<cfinclude template="/include/qry/sql1_185_5.cfm" /> 
<cfinclude template="/include/qry/sq2_185_6.cfm" /> 

<!--- Redirect to the generated page location --->
<cflocation url="#pg_loc#" />
