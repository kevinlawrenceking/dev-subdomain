<cfset reportItemService = createObject("component", "services.ReportItemService")>
<cfset values_x = reportItemService.SELreportitems_24227(
    userid = userid,
    reportid = reports.reportid,
    itemdataset = dataset_x.itemdataset
)>