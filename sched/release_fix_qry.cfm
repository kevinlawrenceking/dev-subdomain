
<cfquery  name="x"   result="result" >
INSERT INTO actorsbusinessoffice.#pgtable#
SELECT * FROM new_development.#pgtable# WHERE #pgid# NOT IN (SELECT #pgid# FROM actorsbusinessoffice.#pgtable#);
</cfquery>

 <cfdump var="#result#" />
