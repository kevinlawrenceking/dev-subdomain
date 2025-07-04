<!--- This ColdFusion page retrieves application, component, and page details based on a specific page ID. --->

<cfquery name="FindRefPage">
    <!--- Query to select application, component, and page details based on the provided page ID --->
    SELECT
        a.appname,
        a.appAuthor,
        c.compname,
        p.pgname,
        a.appId,
        a.appDescription,
        a.appLogoName,
        a.colorTopBar,
        a.colorLeftSideBar,
        a.mocktoday,
        a.mock_yn,
        c.compid,
        c.compDir,
        c.compTable,
        c.compowner,
        c.compIcon,
        c.menuYN,
        c.menuOrder,
        c.compInner,
        c.compRecordName,
        c.compActive,
        p.pgid,
        p.pgDir,
        p.pgTitle,
        p.pgHeading,
        p.pgFilename,
        p.datatables_YN,
        p.fullcalendar_YN,
        p.editable_YN,
        p.newdatatables_YN,
        p.pk
    FROM pgpages p
    INNER JOIN pgcomps c ON c.compID = p.compID
    INNER JOIN pgapps a ON a.appID = c.appid
    WHERE p.pgid = #ref_pgid#
</cfquery>
