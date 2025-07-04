<!--- This ColdFusion page handles the display and submission of an event form in a modal dialog. --->

<script>
    $(document).ready(function() {
        <!--- Event listener for showing the modal and loading content ---> 
        $("#addeventtype").on("show.bs.modal", function(event) {
            <!--- Place the returned HTML into the selected element --->
            $(this).find(".modal-body").load("/include/addeventtype.cfm");
        });
    });
</script>

<div class="modal fade" id="event-modal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header py-3 px-4 border-bottom-0 d-block">
                <button type="button" class="close" data-bs-dismiss="modal" >
&times;</button>
                <h5 class="modal-title" id="modal-title">Event</h5>
            </div>
            <div class="modal-body p-4">
                <form class="needs-validation" name="event-form" id="form-event" novalidate>
                    <div class="row">
                        <div class="col-12">
                            <div class="form-group">
                                <label class="control-label">Title</label>
                                <input class="form-control" placeholder="Insert Appointment Title" type="text" name="eventTitle" id="eventTitle" required />
                                <div class="invalid-feedback"> Please enter a Title.</div>
                            </div>
                        </div>
                        <div class="col-12">
                            <div class="form-group">
                                <label class="control-label">Category</label>
                                <select class="form-control custom-select" name="category" id="event-category" required>
                                    <option value="bg-danger" selected>Danger</option>
                                    <option value="bg-success">Success</option>
                                    <option value="bg-primary">Primary</option>
                                    <option value="bg-info">Info</option>
                                    <option value="bg-dark">Dark</option>
                                    <option value="bg-warning">Warning</option>
                                </select>
                                <div class="invalid-feedback">Please select a valid event category</div>
                            </div>
                        </div>
                        <div class="form-group col-md-12">
                            <label for="eventDescription">Description</label>
                            <textarea class="form-control" type="text" id="eventDescription" name="eventDescription" placeholder="Description" rows="1"></textarea>
                            <div class="invalid-feedback">Please enter a Description.</div>
                        </div>
                        <div class="form-group col-md-12">
                            <label for="eventLocation">Location</label>
                            <input class="form-control" type="text" id="eventLocation" name="eventLocation" placeholder="Location" />
                            <div class="invalid-feedback">Please enter a Location.</div>
                        </div>
                        <div class="form-group col-md-6">
                            <label for="eventStart">Start Date</label>
                            <input class="form-control" id="eventStart" name="eventStart" type="date" />
                            <div class="invalid-feedback">Please choose a Start Date.</div>
                        </div>
                        <div class="form-group col-md-6">
                            <label for="eventTypeName">Type</label>
                            <select class="form-control" name="eventTypeName" id="eventTypeName">
                                <option value="Audition">Audition</option>
                                <option value="Booking">Booking</option>
                                <option value="CD Workshop / Class">CD Workshop / Class</option>
                                <option value="Class">Class</option>
                                <option value="Coaching">Coaching</option>
                                <option value="Event">Event</option>
                                <option value="Meeting">Meeting</option>
                                <option value="Phone call">Phone call</option>
                                <option value="Rehearsal">Rehearsal</option>
                            </select>
                            <div class="invalid-feedback">Please select a Type.</div>
                        </div>
                        <div class="form-group col-md-6">
                            <label for="eventStartTime">Start Time</label>
                            <input class="form-control" id="eventStartTime" name="eventStartTime" type="time" />
                            <div class="invalid-feedback">Please choose a Start Time.</div>
                        </div>
                        <div class="form-group col-md-6">
                            <label for="eventStopTime">End Time</label>
                            <input class="form-control" id="eventStopTime" name="eventStopTime" type="time" />
                            <div class="invalid-feedback">Please choose a End Time.</div>
                        </div>
                    </div>
                    <div class="row mt-2">
                        <div class="col-6">
                            <button type="button" class="btn btn-danger btn-sm" id="btn-delete-event">Delete</button>
                        </div>
                        <div class="col-6 text-right">
                            <button type="button" class="btn btn-light mr-1 btn-sm" data-bs-dismiss="modal">Close</button>
                            <button type="submit" class="btn btn-primary btn-sm waves-effect waves-light" id="btn-save-event">Save</button>
                        </div>
                    </div>
                </form>
            </div>
        </div> <!--- end modal-content --->
    </div> <!--- end modal dialog --->
</div>
