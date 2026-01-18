<cfset reportItemService = createObject("component", "services.ReportItemService")>
<cfset reportItemService.INSreportitems(
    itemLabel = new_label_new,
    itemOrderNo = i,
    itemValueInt = new_itemValueInt,
    ID = new_id,
    itemDataset = new_itemDataSet
)>
