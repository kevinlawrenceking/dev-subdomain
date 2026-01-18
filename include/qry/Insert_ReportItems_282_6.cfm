<cfset reportItemService = createObject("component", "services.ReportItemService")>
<cfset new_itemid = reportItemService.INSreportitems_24233(
    newLabel = report_4_loop.new_label,
    itemOrderNo = i,
    newID = new_id,
    newItemDataSet = report_4_loop.new_itemDataSet,
    userID = int(userid)
)>