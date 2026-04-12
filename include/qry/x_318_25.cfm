<cfinclude template="/include/perfcount.cfm" />
<cfset tagService = createObject("component", "services.TagService")>
<cfset x = tagService.SELtags()>