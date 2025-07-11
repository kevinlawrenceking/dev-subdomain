<script>
  let selectedReminder = {};

  function loadReminders() {
    const showInactive = $("#showInactive").is(":checked") ? 1 : 0;

    $('#remindersTable').DataTable({
      destroy: true,
      ajax: {
        url: "/include/get_reminders.cfm",
        data: {
          showInactive: showInactive,
          currentid: <cfoutput>#contactid#</cfoutput>,
          userid: <cfoutput>#userid#</cfoutput>
        },
        dataSrc: function (json) {
          injectReminderModals(json);
          return json;
        }
      },
      columns: [
        {
          data: "id",
          render: function (data, type, row) {
            if (row.status === "Pending") {
              return `
                <button class="btn btn-success btn-sm mark-complete" data-id="${data}" data-status="Completed" data-text="${row.reminder_text}" title="Mark Complete">
                  <i class="fas fa-check"></i>
                </button>
                <button class="btn btn-secondary btn-sm mark-skip" data-id="${data}" data-status="Skipped" data-text="${row.reminder_text}" title="Skip">
                  <i class="fas fa-circle-minus"></i>
                </button>
              `;
            } else {
              return "-";
            }
          }
        },
        { data: "contactid", visible: false },
        { data: "contactfullname", visible: <cfoutput>#contactVisibilty#</cfoutput> },
        { data: "notStartDatef" },
        { data: "notEndDatef" },
        {
          data: "reminder_text",
          render: function (data, type, row) {
            const modalId = `action${row.id}-modal`;
            return `
              ${data}
              <a href="#" title="Click for details" data-bs-toggle="modal" data-bs-target="#${modalId}">
                <i class="fas fa-info-circle ms-2 text-info"></i>
              </a>
            `;
          }
        },
        { data: "status" },
        {
          data: null,
          render: function (data, type, row) {
            const systemModalId = `system${row.suid}-modal`;
            return `
              ${row.system_type}
              <a href="#" title="Click for system details" data-bs-toggle="modal" data-bs-target="#${systemModalId}">
                <i class="fas fa-info-circle ms-2 text-muted"></i>
              </a>
            `;
          }
        }
      ],
      language: {
        emptyTable: showInactive
          ? "No completed or skipped reminders"
          : "You have no active reminders"
      },
      initComplete: function () {
        const api = this.api();

        // Dropdown filter columns
        const dropdownColumns = [2, 5, 6, 7]; // Contact, Reminder, Status, Type

        dropdownColumns.forEach(function (colIdx) {
          const column = api.column(colIdx);
          const select = $('<select class="form-select form-select-sm"><option value="">All</option></select>')
            .appendTo($('#remindersTable thead tr:eq(1) th').eq(colIdx).empty())
            .on('change', function () {
              const val = $.fn.dataTable.util.escapeRegex($(this).val());
              column.search(val ? '^' + val + '$' : '', true, false).draw();
            });

          column.data().unique().sort().each(function (d) {
            if (d) {
              select.append('<option value="' + d + '">' + d + '</option>');
            }
          });
        });
      }
    });
  }

  function injectReminderModals(data) {
    let html = '';
    data.forEach(row => {
      html += `
        <div id="action${row.id}-modal" class="modal fade" tabindex="-1" role="dialog" aria-hidden="true">
          <div class="modal-dialog">
            <div class="modal-content">
              <div class="modal-header">
                <h4 class="modal-title">${row.reminder_text}</h4>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
              </div>
              <div class="modal-body">
                <h5>${row.action_details}</h5>
                <p>${row.action_info}</p>
              </div>
            </div>
          </div>
        </div>

        <div id="system${row.suid}-modal" class="modal fade" tabindex="-1" role="dialog" aria-hidden="true">
          <div class="modal-dialog">
            <div class="modal-content">
              <div class="modal-header">
                <h4 class="modal-title">${row.recordname}</h4>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
              </div>
              <div class="modal-body">
                <h5>Description</h5>
                <p>${row.systemdescript}</p>
                <p><strong>Start Date:</strong> ${row.sustartDate}</p>
                ${row.suenddate ? `<p><strong>Completed:</strong> ${row.suenddate}</p>` : ''}
              </div>
            </div>
          </div>
        </div>
      `;
    });
    $("#modalContainer").html(html);
  }

  $(document).ready(function () {
    // Insert second header row for filters
    $('#remindersTable thead').append('<tr id="filterRow"></tr>');
    $('#remindersTable thead tr:eq(0) th').each(function () {
      $('#filterRow').append(`<th>${$(this).text()}</th>`);
    });

    loadReminders();

    $("#showInactive").change(function () {
      loadReminders();
    });

    $('#remindersTable').on('click', '.mark-complete, .mark-skip', function () {
      selectedReminder = {
        id: $(this).data('id'),
        status: $(this).data('status'),
        text: $(this).data('text')
      };

      $("#confirmReminderText").text(
        `Are you sure you want to mark "${selectedReminder.text} reminder" as ${selectedReminder.status}?`
      );

      const confirmModal = new bootstrap.Modal(document.getElementById('confirmReminderModal'));
      confirmModal.show();
    });

    $('#confirmReminderButton').click(function () {
      $.post("/include/complete_not_ajax.cfm", {
        notid: selectedReminder.id,
        notstatus: selectedReminder.status
      }, function () {
        loadReminders();
        bootstrap.Modal.getInstance(document.getElementById('confirmReminderModal')).hide();
      });
    });
  });
</script>