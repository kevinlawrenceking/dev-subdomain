<cfset taoVersionService = createObject("component", "services.TaoVersionService")>
<cfset taoVersionService.INStaoversions(
    new_major = new_major,
    new_minor = new_minor,
    new_patch = new_patch,
    new_versionstatus = new_versionstatus,
    new_versiontype = new_versiontype,
    new_version = new_version,
    new_build = new_build,
    new_reviewDate = (new_reviewDate neq "") ? new_reviewDate : javaCast("null", ""),
    new_releaseDate = (new_releaseDate neq "") ? new_releaseDate : javaCast("null", ""),
    new_reviewtime = (new_reviewtime neq "") ? new_reviewtime : javaCast("null", ""),
    new_releasetime = (new_releasetime neq "") ? new_releasetime : javaCast("null", ""),
    new_hoursavail = (new_hoursavail neq "") ? numberformat(new_hoursavail, '9.99') : javaCast("null", "")
)>
