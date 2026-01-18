<cfset taoVersionService = createObject("component", "services.TaoVersionService")>
<cfset find = taoVersionService.SELtaoversions_24469(
    new_major = new_major,
    new_minor = new_minor,
    new_patch = new_patch,
    new_version = new_version,
    new_build = new_build
)>