<CFINCLUDE template="/include/remote_load.cfm" />

<cfquery name="activeversions"  datasource="#dsn#"  >
SELECT 
v.verid as id
,CONCAT(v.major,'.',v.minor,'.',v.patch,'.',v.version,'.',v.build, ' - ',v.versiontype) AS Name
,v.versionstatus 



 FROM taoversions v
 WHERE v.versionstatus = 'Pending'
 ORDER BY v.major,v.minor,v.patch,v.version,v.build
 </cfquery>   