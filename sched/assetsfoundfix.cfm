

<cfquery result="result"  name="x">
SELECT DISTINCT pgdir FROM pgpages WHERE pgdir <> '';
</cfquery>

<cfloop query="x">

<cfquery result="result"  name="update">
            update pgfiles
            set filestatus = 'Confirmed'
            where id = '/app/#x.pgdir#/index.cfm'
and filestatus = 'Found'
</cfquery>

</cfloop>

