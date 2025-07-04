

$(document).ready(function() {
    $("#contacts-datatable").DataTable({
        scrollY:        "350px",
        scrollCollapse: true,
        paging:         false,

        responsive: true,
        searching: true,
        language: {
              search: "_INPUT_",
        searchPlaceholder: "Search Contacts...",
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

$(document).ready(function () {             
  $('.dataTables_filter input[type="search"]').css(
     {'width':'150px','display':'inline-block'}
  );
});


  
      