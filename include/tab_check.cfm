<!--- This ColdFusion page processes various parameters and determines the state of different expand variables based on the input values. --->

<cfset dbugz = "N" />

<cfparam name="t1" default="1" />
<cfparam name="t2" default="0" />
<cfparam name="t3" default="0" />
<cfparam name="t4" default="0" />

<!--- Check if t1 is not zero and adjust t1 if the sum of t1, t2, t3, and t4 equals 2 --->
<cfif #t1# is not "0">
    <cfif t1 + t2 + t3 + t4 eq 2>
        <cfset t1 = 0 />
    </cfif>
</cfif>

<cfparam name="contact_expand" default="true" />
<cfparam name="appointments_expand" default="false" />
<cfparam name="notes_expand" default="false" />
<cfparam name="relationship_expand" default="false" />

<cfset contact_expand = "false" />
<cfset appointments_expand = "false" />
<cfset notes_expand = "false" />
<cfset relationship_expand = "false" />

<!--- Save the current values of t1, t2, t3, and t4 for debugging purposes --->
<cfsavecontent variable="varcheck">
    <cfoutput>
        T1: #t1#<BR>
        T2: #t2#<BR>
        T3: #t3#<BR>
        T4: #t4#<BR>
    </cfoutput>
</cfsavecontent>

<!--- Debugging output if dbugz is set to "Y" --->
<cfif #dbugz# is "Y">
    <cfoutput>varcheck: #varcheck#<BR></cfoutput>
    <cfoutput>t1: #t1#<BR></cfoutput>
</cfif>

<!--- Determine which expand variable to set based on t1, t2, t3, and t4 values --->
<cfif t1 eq 1>
    <cfif #dbugz# is "Y">
        <cfoutput>t1: #t1#<BR></cfoutput>
    </cfif>
    <cfset contact_expand = "true" />
<cfelseif t2 eq 1>
    <cfset appointments_expand = "true" />
<cfelseif t3 eq 1>
    <cfset notes_expand = "true" />
<cfelseif t4 eq 1>
    <cfset relationship_expand = "true" />
</cfif>

<!--- If all t values are zero, set t1 to 1 --->
<cfif t1 + t2 + t3 + t4 eq 0>
    <cfset t1 = 1 />
</cfif>

<!--- Save the conditional check for debugging purposes --->
<cfsavecontent variable="varif">
    <cfoutput>
        IF: if #t1# is "0" and #t2# is "0" and #t3# is "0" and #t4# is "0"<BR>
    </cfoutput>
</cfsavecontent>

<!--- Check if all t values are zero and set contact_expand to true if so --->
<cfoutput>
    <cfif #t1# is "0" and #t2# is "0" and #t3# is "0" and #t4# is "0">
        <cfset contact_expand = "true" />
    </cfif>
</cfoutput>

<!--- Save the final values of t1, t2, t3, and t4 for debugging purposes --->
<cfsavecontent variable="varafter">
    <cfoutput>
        T1: #t1#<BR>
        T2: #t2#<BR>
        T3: #t3#<BR>
        T4: #t4#<BR>
    </cfoutput>
</cfsavecontent>

<!--- Debugging output if dbugz is set to "Y" --->
<cfif #dbugz# is "Y">
    <cfoutput>
        varif: #varif#<BR>
        varafter: #varafter#<BR>
        <p>notes_expand: #notes_expand#</p>
        <p>contact_expand: #contact_expand#</p>
    </cfoutput>
    <cfabort>
</cfif>
