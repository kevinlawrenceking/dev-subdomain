$(document).ready(function() {
    $("#basic-datatable").DataTable({
       scrollY: "700px",
        scrollCollapse: !0,
        language: {
            paginate: {
                previous: "<i class='mdi mdi-chevron-left'>",
                next: "<i class='mdi mdi-chevron-right'>"
            }
        },
        drawCallback: function() {
            $(".dataTables_paginate > .pagination").addClass("pagination-rounded")
        }
    });
    var a = $("#datatable-buttons").DataTable({
        lengthChange: !1,
        buttons: [{
            extend: "copy",
            className: "btn-light"
        }, {
            extend: "print",
            className: "btn-light"
        }, {
            extend: "pdf",
            className: "btn-light"
        }],
        language: {
            paginate: {
                previous: "<i class='mdi mdi-chevron-left'>",
                next: "<i class='mdi mdi-chevron-right'>"
            }
        },
        drawCallback: function() {
            $(".dataTables_paginate > .pagination").addClass("pagination-rounded")
        }
    });

});

$(document).ready(function() {
    $("#events-datatable").DataTable({
       scrollY: "350px",
           paging: false,
        responsive: true,
        scrollCollapse: !0,
        language: {
            paginate: {
                previous: "<i class='mdi mdi-chevron-left'>",
                next: "<i class='mdi mdi-chevron-right'>"
            }
        },
        drawCallback: function() {
            $(".dataTables_paginate > .pagination").addClass("pagination-rounded")
        }
    });
    var a = $("#datatable-buttons").DataTable({
        lengthChange: !1,
        buttons: [{
            extend: "copy",
            className: "btn-light"
        }, {
            extend: "print",
            className: "btn-light"
        }, {
            extend: "pdf",
            className: "btn-light"
        }],
        language: {
            paginate: {
                previous: "<i class='mdi mdi-chevron-left'>",
                next: "<i class='mdi mdi-chevron-right'>"
            }
        },
        drawCallback: function() {
            $(".dataTables_paginate > .pagination").addClass("pagination-rounded")
        }
    });

});






$(document).ready(function() {
    $("#contacts-datatable").DataTable({
       scrollY: "700px",
        scrollCollapse: !0,
        language: {
            paginate: {
                previous: "<i class='mdi mdi-chevron-left'>",
                next: "<i class='mdi mdi-chevron-right'>"
            }
        },
        drawCallback: function() {
            $(".dataTables_paginate > .pagination").addClass("pagination-rounded")
        }
    });
    var a = $("#datatable-buttons").DataTable({
        lengthChange: !1,
        buttons: [{
            extend: "copy",
            className: "btn-light"
        }, {
            extend: "print",
            className: "btn-light"
        }, {
            extend: "pdf",
            className: "btn-light"
        }],
        language: {
            paginate: {
                previous: "<i class='mdi mdi-chevron-left'>",
                next: "<i class='mdi mdi-chevron-right'>"
            }
        },
        drawCallback: function() {
            $(".dataTables_paginate > .pagination").addClass("pagination-rounded")
        }
    });

});