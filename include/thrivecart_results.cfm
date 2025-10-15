<!---
    PURPOSE: Display ThriveCart order results with filtering and status update capability
    AUTHOR: Kevin King
    DATE: 2025-09-12
    PARAMETERS: select_status, select_plan, select_product
    DEPENDENCIES: DataTables, Bootstrap
--->

<cfparam name="select_status" default="%" />
<cfparam name="select_plan" default="%" />
<cfparam name="select_product" default="%" />

<!--- Include supporting queries --->
<cfinclude template="/include/qry/thrivecart_results.cfm" />

<div class="row">
  <div class="col-12">
    <div class="card">
      <div class="card-body">
        <h4 class="header-title">ThriveCart Order Results</h4>
        
        <form action="/app/thrivecart-results/" method="get">
          <div class="row">
            <!--- Status Filter --->
            <div class="form-group col-md-4">
              <label for="select_status">Status</label>
              <select class="form-control" name="select_status" id="select_status" onchange="this.form.submit()">
                <option value="%" <cfif select_status EQ "%">selected</cfif>>All Statuses</option>
                <cfoutput query="statuses">
                  <option value="#status#" <cfif status EQ select_status>selected</cfif>>#status#</option>
                </cfoutput>
              </select>
            </div>
            
            <!--- Plan Filter --->
            <div class="form-group col-md-4">
              <label for="select_plan">Payment Plan</label>
              <select class="form-control" name="select_plan" id="select_plan" onchange="this.form.submit()">
                <option value="%" <cfif select_plan EQ "%">selected</cfif>>All Plans</option>
                <cfoutput query="plans">
                  <option value="#planName#" <cfif planName EQ select_plan>selected</cfif>>#planName#</option>
                </cfoutput>
              </select>
            </div>
            
            <!--- Product Filter --->
            <div class="form-group col-md-4">
              <label for="select_product">Product</label>
              <select class="form-control" name="select_product" id="select_product" onchange="this.form.submit()">
                <option value="%" <cfif select_product EQ "%">selected</cfif>>All Products</option>
                <cfoutput query="products">
                  <option value="#BaseProductLabel#" <cfif BaseProductLabel EQ select_product>selected</cfif>>#BaseProductLabel#</option>
                </cfoutput>
              </select>
            </div>
          </div>
        </form>

        <!--- Table Output --->
        <table id="thrivecart-datatable" class="table table-striped table-bordered dt-responsive nowrap w-100">
          <thead>
            <tr>
              <th>Order ID</th>
              <th>Order Date</th>
              <th>Customer Name</th>
              <th>Email</th>
              <th>Product</th>
              <th>Payment Plan</th>
              <th>Status</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody>
            <cfoutput query="results">
              <tr id="row-#id#">
                <td>#id#</td>
                <td>#dateFormat(orderdate, "mm/dd/yyyy")#</td>
                <td>#CustomerFirst# #CustomerLast#</td>
                <td>#CustomerEmail#</td>
                <td>#BaseProductLabel#</td>
                <td>#planName#</td>
                <td>
                  <select class="form-control status-select" data-id="#id#" data-current="#status#">
                    <option value="Pending" <cfif status EQ "Pending">selected</cfif>>Pending</option>
                    <option value="Emailed" <cfif status EQ "Emailed">selected</cfif>>Emailed</option>
                    <option value="Completed" <cfif status EQ "Completed">selected</cfif>>Completed</option>
                    <option value="Cancelled" <cfif status EQ "Cancelled">selected</cfif>>Cancelled</option>
                  </select>
                </td>
                <td>
                  <button type="button" class="btn btn-sm btn-primary save-status" data-id="#id#" style="display:none;">
                    <i class="mdi mdi-content-save"></i> Save
                  </button>
                  <button type="button" class="btn btn-sm btn-secondary cancel-status" data-id="#id#" style="display:none;">
                    <i class="mdi mdi-cancel"></i> Cancel
                  </button>
                </td>
              </tr>
            </cfoutput>
          </tbody>
        </table>

        <!--- DataTables Script --->
        <script>
          $(document).ready(function () {
            // Initialize DataTable
            $('#thrivecart-datatable').DataTable({
              responsive: false,
              pageLength: 25,
              order: [[1, 'desc']], // Sort by order date descending
              language: {
                paginate: {
                  previous: "<i class='mdi mdi-chevron-left'>",
                  next: "<i class='mdi mdi-chevron-right'>"
                }
              },
              drawCallback: function () {
                $(".dataTables_paginate > .pagination").addClass("pagination-rounded");
              }
            });
            
            // Handle status select change
            $('.status-select').on('change', function() {
              const $select = $(this);
              const currentValue = $select.data('current');
              const newValue = $select.val();
              const id = $select.data('id');
              
              if (currentValue !== newValue) {
                // Show save/cancel buttons
                $select.closest('tr').find('.save-status, .cancel-status').show();
              } else {
                // Hide save/cancel buttons
                $select.closest('tr').find('.save-status, .cancel-status').hide();
              }
            });
            
            // Handle save button click
            $('.save-status').on('click', function() {
              const $btn = $(this);
              const id = $btn.data('id');
              const $select = $btn.closest('tr').find('.status-select');
              const newStatus = $select.val();
              
              // Disable buttons during save
              $btn.prop('disabled', true);
              $btn.html('<i class="mdi mdi-loading mdi-spin"></i> Saving...');
              
              $.ajax({
                url: '/include/update_thrivecart_status.cfm',
                method: 'POST',
                data: {
                  id: id,
                  status: newStatus
                },
                success: function(response) {
                  if (response.success) {
                    // Update the current value
                    $select.data('current', newStatus);
                    // Hide buttons
                    $btn.closest('tr').find('.save-status, .cancel-status').hide();
                    // Reset button text
                    $btn.html('<i class="mdi mdi-content-save"></i> Save').prop('disabled', false);
                    
                    // Show success message
                    toastr.success('Status updated successfully!');
                  } else {
                    toastr.error('Error updating status: ' + response.message);
                    // Reset button
                    $btn.html('<i class="mdi mdi-content-save"></i> Save').prop('disabled', false);
                  }
                },
                error: function() {
                  toastr.error('Error updating status');
                  // Reset button
                  $btn.html('<i class="mdi mdi-content-save"></i> Save').prop('disabled', false);
                }
              });
            });
            
            // Handle cancel button click
            $('.cancel-status').on('click', function() {
              const $btn = $(this);
              const $select = $btn.closest('tr').find('.status-select');
              const currentValue = $select.data('current');
              
              // Reset select to current value
              $select.val(currentValue);
              // Hide buttons
              $btn.closest('tr').find('.save-status, .cancel-status').hide();
            });
          });
        </script>

      </div>
    </div>
  </div>
</div>
