<cfinclude template="../../includes/sessionCheck.cfm">
<cfinclude template="../../includes/header.cfm">
<cfinclude template="receptionistSidebar.cfm">

<cfif  NOT structKeyExists(session,"user") OR session.user.role_id NEQ 3>
    <cflocation url="/MedicalManagementSystem/pages/error/unauthorized.cfm" addtoken="no">
</cfif>
<cfset service     = createObject("component","MedicalManagementSystem.components.ReceptionistDashboardService")>
<cfset appointments = service.getAppointments()>
<cfset patients    = service.getAllPatients()>
<cfset doctors     = service.getAllDoctors()>

<!--- SweetAlert2 --->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.all.min.js"></script>

<style>
    /* #loadingOverlay {
        display         : none;
        position        : fixed;
        inset           : 0;
        background      : rgba(255,255,255,.55);
        z-index         : 9999;
        align-items     : center;
        justify-content : center;
    }
    #loadingOverlay.show { display: flex; } */

    #appointmentsTable thead th {
        background-color: #7070db;
        color: #fff;
        font-weight: 600;
        font-size: 15px;
        letter-spacing: .4px;
        border-color: #9b96cf;
        white-space: nowrap;
    }
    #appointmentsTable tbody tr:hover {
        background-color: #f0f0ff;
    }
    #appointmentsTable tbody td {
        font-size: 15px;
        vertical-align: middle;
    }
    .dataTables_wrapper .dataTables_filter input {
        border: 1px solid #c7d2fe;
        border-radius: 6px;
        padding: 4px 10px;
        font-size: 15px;
    }
    .dataTables_wrapper .dataTables_length select {
        border: 1px solid #c7d2fe;
        border-radius: 6px;
        padding: 2px 8px;
        font-size: 15px;
    }
    .dataTables_wrapper .dataTables_paginate .paginate_button.current {
        background: #4f46e5 !important;
        color: #fff !important;
        border-radius: 5px;
        border: none !important;
    }
    .dataTables_wrapper .dataTables_paginate .paginate_button:hover {
        background: #e0e7ff !important;
        color: #4f46e5 !important;
        border: none !important;
        border-radius: 5px;
    }
    .dataTables_wrapper .dataTables_info {
        font-size: 15px;
        color: #6b7280;
    }
    .slot-badge {
        font-size: 15px;
        background: #e0e7ff;
        color: #4f46e5;
        border-radius: 4px;
        padding: 1px 6px;
        margin-left: 4px;
        vertical-align: middle;
    }
</style>

<!--- <div id="loadingOverlay">
    <div class="spinner-border text-primary" style="width:3rem;height:3rem;" role="status">
        <span class="visually-hidden">Loading…</span>
    </div>
</div> --->

<div id="main">
    <header class="mb-3">
        <a href="#" class="burger-btn d-block d-xl-none">
            <i class="bi bi-justify fs-3"></i>
        </a>
    </header>

    <div class="page-heading d-flex justify-content-between align-items-center mb-3">
        <h3>Manage Appointments</h3>
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-0">
                <li class="breadcrumb-item">
                    <a href="/MedicalManagementSystem/pages/receptionist/receptionist_Account.cfm">
                        <i class="bi bi-person me-2"></i>My Account
                    </a>
                </li>
                <li class="breadcrumb-item">
                    <a href="/MedicalManagementSystem/pages/logout.cfm" class="text-danger">
                        <i class="bi bi-box-arrow-right me-2"></i>Logout
                    </a>
                </li>
            </ol>
        </nav>
    </div>

    <!--- Session flash --->
    <cfif structKeyExists(session,"successMessage")>
        <cfoutput>
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            #encodeForHTML(session.successMessage)#
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        </cfoutput>
        <cfset structDelete(session,"successMessage")>
    </cfif>

    <!--- ── BOOK / EDIT FORM ─────────────────────────────────────────── --->
    <div class="card border-0 shadow-sm mb-4">
        <div class="card-body fw-semibold">
            <i class="bi bi-calendar-plus me-2 text-primary"></i>
            <span id="formTitle">Book Appointment</span>
        </div>
        <div class="card-body">
            <form id="appointmentForm" autocomplete="off" novalidate>
                <input type="hidden" name="appointmentID" id="appointmentID">

                <div class="row g-3">
                    <div class="col-md-3">
                        <label class="form-label fw-semibold">
                            Patient <span class="text-danger">*</span>
                        </label>
                        <select name="patientID" id="patientID" class="form-select">
                            <option value=""> Select Patient </option>
                            <cfoutput query="patients">
                                <option value="#patient_id#">#encodeForHTML(full_name)#</option>
                            </cfoutput>
                        </select>
                        <div id="patientError" class="text-danger small mt-1"></div>
                    </div>

                    <div class="col-md-3">
                        <label class="form-label fw-semibold">
                            Doctor <span class="text-danger">*</span>
                        </label>
                        <select name="doctorID" id="doctorID" class="form-select">
                            <option value=""> Select Doctor </option>
                            <cfoutput query="doctors">
                                <option value="#doctor_id#">#encodeForHTML(full_name)#</option>
                            </cfoutput>
                        </select>
                        <div id="doctorError" class="text-danger small mt-1"></div>
                    </div>

                    <div class="col-md-2">
                        <label class="form-label fw-semibold">
                            Date <span class="text-danger">*</span>
                        </label>
                        <input type="date" name="appointmentDate" id="appointmentDate"
                               class="form-control">
                        <div id="dateError" class="text-danger small mt-1"></div>
                    </div>

                    <div class="col-md-2">
                        <label class="form-label fw-semibold">
                            Time <span class="text-danger">*</span>
                            
                        </label>
                        <select name="appointmentTime" id="appointmentTime" class="form-select">
                            <option value="">Select Time</option>
                        </select>
                        <span class="slot-badge">30 min slots</span>
                        <div id="timeError" class="text-danger small mt-1"></div>
                    </div>

                    <div class="col-md-2">
                        <label class="form-label fw-semibold">Remarks</label>
                        <input type="text" name="remarks" id="remarks"
                               class="form-control" maxlength="255" placeholder="Optional">
                    </div>

                    <div class="col-12 d-flex gap-2">
                        <button type="submit" id="submitBtn"
                                data-action="bookAppointment"
                                class="btn btn-success px-4">
                            <i class="bi bi-check-circle me-1"></i> Book Appointment
                        </button>
                        <button type="button" class="btn btn-secondary px-4"
                                onclick="resetForm()">
                            <i class="bi bi-arrow-counterclockwise me-1"></i> Reset
                        </button>
                    </div>
                </div>
            </form>
        </div>
    </div>

    <!--- ── APPOINTMENTS TABLE ───────────────────────────────────────── --->
    <div class="card border-0 shadow-sm">
        <div class="card-body fw-semibold">
            <i class="bi bi-calendar3 me-2 text-primary"></i>Upcoming Appointments
        </div>
        <div class="card-body">
            <div class="table-responsive">
                <table id="appointmentsTable"
                       class="table table-bordered table-hover align-middle">
                    <thead>
                        <tr>
                            <th>Sl No</th>
                            <th>Patient</th>
                            <th>Doctor</th>
                            <th>Date</th>
                            <th>Time</th>
                            <th>Status</th>
                            <th>Remarks</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <cfoutput query="appointments">
                        <tr data-id="#appointment_id#"
                            data-patient="#patient_id#"
                            data-doctor="#doctor_id#"
                            data-date="#dateFormat(appointment_datetime,'yyyy-mm-dd')#"
                            data-time="#timeFormat(appointment_datetime,'HH:mm')#"
                            data-remarks="#encodeForHTMLAttribute(remarks)#">
                            <td class="slno"></td>
                            <td>#encodeForHTML(patient_name)#</td>
                            <td>#encodeForHTML(doctor_name)#</td>
                            <td>#dateFormat(appointment_datetime,"dd-mmm-yyyy")#</td>
                            <td>#timeFormat(appointment_datetime,"hh:mm tt")#</td>
                            <td>
                                <cfswitch expression="#status_name#">
                                    <cfcase value="Booked">
                                        <span class="badge bg-primary">Booked</span>
                                    </cfcase>
                                    <cfcase value="Cancelled">
                                        <span class="badge bg-danger">Cancelled</span>
                                    </cfcase>
                                    <cfcase value="Completed">
                                        <span class="badge bg-success">Completed</span>
                                    </cfcase>
                                    <cfcase value="In Progress">
                                        <span class="badge bg-warning text-dark">In Progress</span>
                                    </cfcase>
                                    <cfdefaultcase>
                                        <span class="badge bg-secondary">
                                            #encodeForHTML(status_name)#
                                        </span>
                                    </cfdefaultcase>
                                </cfswitch>
                            </td>
                            <td>#encodeForHTML(remarks)#</td>
                            <td class="text-nowrap">
                                <button class="btn btn-primary btn-sm btn-edit">
                                    <i class="bi bi-pencil-square me-1"></i>Edit
                                </button>
                                <cfif status_name EQ "Cancelled">
                                    <button class="btn btn-success btn-sm btn-reactivate ms-1">
                                        <i class="bi bi-arrow-counterclockwise me-1"></i>Reactivate
                                    </button>
                                <cfelse>
                                    <button class="btn btn-warning btn-sm btn-cancel ms-1">
                                        <i class="bi bi-x-circle me-1"></i>Cancel
                                    </button>
                                </cfif>
                                <button class="btn btn-danger btn-sm btn-delete ms-1">
                                    <i class="bi bi-trash me-1"></i>Delete
                                </button>
                            </td>
                        </tr>
                        </cfoutput>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

</div>

<cfinclude template="../../includes/footer.cfm">

<script>
$(document).ready(function () {

    var BASE        = '/MedicalManagementSystem/components/ReceptionistDashboardService.cfc';
    var selectedRow = null;

    // ── Generate 30-min time slots ────────────────────────
    function buildTimeSlots(selectedVal) {
        var opts = '<option value=""> Select Time </option>';
        for (var h = 0; h < 24; h++) {
            ['00', '30'].forEach(function (m) {
                var hh  = (h < 10 ? '0' : '') + h;
                var val = hh + ':' + m;
                var ampm = h < 12 ? 'AM' : 'PM';
                var h12  = h % 12 === 0 ? 12 : h % 12;
                var label = (h12 < 10 ? '0' : '') + h12 + ':' + m + ' ' + ampm;
                var sel  = (val === selectedVal) ? ' selected' : '';
                opts += '<option value="' + val + '"' + sel + '>' + label + '</option>';
            });
        }
        return opts;
    }

    $('#appointmentTime').html(buildTimeSlots(''));

    // ── Min date = today ──────────────────────────────────
    $('#appointmentDate').attr('min', new Date().toISOString().split('T')[0]);

    // ── SweetAlert2 helper ────────────────────────────────
    function swAlert(icon, title, text) {
        return Swal.fire({
            icon:               icon,
            title:              title,
            text:               text,
            confirmButtonColor: '#4f46e5',
            timer:              icon === 'success' ? 2500 : undefined,
            timerProgressBar:   icon === 'success'
        });
    }

    function swConfirm(title, text, confirmColor, confirmText) {
        return Swal.fire({
            title:              title,
            text:               text,
            icon:               'question',
            showCancelButton:   true,
            confirmButtonColor: confirmColor || '#4f46e5',
            cancelButtonColor:  '#6c757d',
            confirmButtonText:  confirmText  || 'Yes',
            cancelButtonText:   'Cancel'
        });
    }

    // ── Overlay ───────────────────────────────────────────
    // function showOverlay() { $('#loadingOverlay').addClass('show'); }
    // function hideOverlay()  { $('#loadingOverlay').removeClass('show'); }

    // ── Clear inline errors ───────────────────────────────
    function clearErrors() {
        $('#patientError,#doctorError,#dateError,#timeError').text('');
        $('#patientID,#doctorID,#appointmentDate,#appointmentTime')
            .removeClass('is-invalid');
    }

    // ── DataTable ─────────────────────────────────────────
    var table = $('#appointmentsTable').DataTable({
        pageLength:  5,
        order:       [[3, 'asc']],
        columnDefs: [
            { orderable: false, targets: [0, 7] }
        ],
        language: {
            emptyTable: 'No upcoming appointments found.',
            search:     '<i class="bi bi-search me-1"></i>Search:',
            lengthMenu: 'Show _MENU_ entries',
            info:       'Showing _START_ to _END_ of _TOTAL_ appointments',
            paginate: {
                previous: '&lsaquo;',
                next:     '&rsaquo;'
            }
        }
    });

    // Dynamic serial numbering
    table.on('order.dt search.dt draw.dt', function () {
        table.column(0, { search: 'applied', order: 'applied' })
             .nodes().each(function (cell, i) {
                 cell.innerHTML = i + 1;
             });
    }).draw();

    // ── Form submit (Book / Update) ───────────────────────
    $('#appointmentForm').on('submit', function (e) {
        e.preventDefault();
        clearErrors();

        var patient = $('#patientID').val();
        var doctor  = $('#doctorID').val();
        var date    = $('#appointmentDate').val();
        var time    = $('#appointmentTime').val();
        var ok      = true;

        if (!patient) {
            $('#patientID').addClass('is-invalid');
            $('#patientError').text('Please select a patient.');
            ok = false;
        }
        if (!doctor) {
            $('#doctorID').addClass('is-invalid');
            $('#doctorError').text('Please select a doctor.');
            ok = false;
        }
        if (!date) {
            $('#appointmentDate').addClass('is-invalid');
            $('#dateError').text('Please select a date.');
            ok = false;
        }
        if (!time) {
            $('#appointmentTime').addClass('is-invalid');
            $('#timeError').text('Please select a time slot.');
            ok = false;
        }
        if (!ok) return;

        var action = $('#submitBtn').data('action');
        if (action === 'updateAppointment' && !$('#appointmentID').val()) {
            swAlert('error', 'Error', 'No appointment selected for update.');
            return;
        }

        // showOverlay();
        $('#submitBtn').prop('disabled', true);

        $.ajax({
            url:      BASE + '?method=' + action + '&returnformat=json',
            type:     'POST',
            data:     $(this).serialize(),
            dataType: 'json',
            success: function (res) {
                // hideOverlay();
                $('#submitBtn').prop('disabled', false);

                var success = res.success || res.SUCCESS;
                var message = res.message || res.MESSAGE || '';

                if (!success) {
                    swAlert('error', 'Failed', message || 'Operation failed.');
                    return;
                }

                if (action === 'updateAppointment' && selectedRow) {
                    var patientText = $('#patientID option:selected').text();
                    var doctorText  = $('#doctorID option:selected').text();
                    var dateVal     = $('#appointmentDate').val();
                    var timeVal     = $('#appointmentTime').val();
                    var remarksVal  = $('#remarks').val();

                    // Format date for display
                    var d      = new Date(dateVal);
                    var months = ['Jan','Feb','Mar','Apr','May','Jun',
                                  'Jul','Aug','Sep','Oct','Nov','Dec'];
                    var dateDisplay = ('0'+d.getDate()).slice(-2) + '-'
                                    + months[d.getMonth()] + '-' + d.getFullYear();

                    // Format time for display
                    var parts = timeVal.split(':');
                    var hh    = parseInt(parts[0]);
                    var mm    = parts[1];
                    var ampm  = hh >= 12 ? 'PM' : 'AM';
                    var h12   = hh % 12 === 0 ? 12 : hh % 12;
                    var timeDisplay = (h12 < 10 ? '0' : '') + h12 + ':' + mm + ' ' + ampm;

                    selectedRow.data([
                        '',
                        patientText,
                        doctorText,
                        dateDisplay,
                        timeDisplay,
                        '<span class="badge bg-primary">Booked</span>',
                        remarksVal,
                        selectedRow.data()[7]
                    ]).draw(false);
                }

                resetForm();

                if (action === 'bookAppointment') {
                    Swal.fire({
                        icon:               'success',
                        title:              'Booked!',
                        text:               message,
                        confirmButtonColor: '#4f46e5',
                        timer:              1800,
                        timerProgressBar:   true
                    }).then(function () {
                        location.reload();
                    });
                } else {
                    swAlert('success', 'Updated!', message);
                }
            },
            error: function (xhr) {
                // hideOverlay();
                $('#submitBtn').prop('disabled', false);
                swAlert('error', 'Server Error',
                    'Something went wrong (' + xhr.status + '). Please try again.');
            }
        });
    });

    // Edit button
    $('#appointmentsTable').on('click', '.btn-edit', function () {
        selectedRow = table.row($(this).closest('tr'));
        var row     = $(this).closest('tr');
        editAppointment(
            row.data('id'),
            row.data('patient'),
            row.data('doctor'),
            row.data('date'),
            row.data('time'),
            row.data('remarks')
        );
    });

    //  Cancel button 
    $('#appointmentsTable').on('click', '.btn-cancel', function () {
        var $btn = $(this);
        selectedRow = table.row($btn.closest('tr'));

        swConfirm('Cancel Appointment?',
                  'This appointment will be marked as Cancelled.',
                  '#dc3545', 'Yes, cancel it')
        .then(function (result) {
            if (!result.isConfirmed) return;
            doAction('cancelAppointment', $btn.closest('tr').data('id'));
        });
    });

    //  Reactivate button 
    $('#appointmentsTable').on('click', '.btn-reactivate', function () {
        var $btn = $(this);
        selectedRow = table.row($btn.closest('tr'));

        swConfirm('Reactivate Appointment?',
                  'This appointment will be set back to Booked.',
                  '#198754', 'Yes, reactivate')
        .then(function (result) {
            if (!result.isConfirmed) return;
            doAction('reactivateAppointment', $btn.closest('tr').data('id'));
        });
    });

    //  Delete button 
    $('#appointmentsTable').on('click', '.btn-delete', function () {
        var $btn = $(this);
        selectedRow = table.row($btn.closest('tr'));

        Swal.fire({
            title:              'Delete Appointment?',
            text:               'This action cannot be undone.',
            icon:               'warning',
            showCancelButton:   true,
            confirmButtonColor: '#dc3545',
            cancelButtonColor:  '#6c757d',
            confirmButtonText:  'Yes, delete',
            cancelButtonText:   'Cancel'
        }).then(function (result) {
            if (!result.isConfirmed) return;
            doAction('deleteAppointment', $btn.closest('tr').data('id'));
        });
    });

    //  Shared action (cancel / reactivate / delete) 
    function doAction(method, id) {
        if (!id) {
            swAlert('error', 'Error', 'Could not read appointment ID.');
            return;
        }
        // showOverlay();
        $.ajax({
            url:      BASE + '?method=' + method + '&returnformat=json',
            type:     'POST',
            data:     { appointmentID: id },
            dataType: 'json',
            success: function (res) {
                // hideOverlay();
                var success = res.success || res.SUCCESS;
                var message = res.message || res.MESSAGE || '';

                if (!success) {
                    swAlert('error', 'Failed', message || 'Operation failed.');
                    return;
                }

                var tr = selectedRow.node();

                if (method === 'cancelAppointment') {
                    $(tr).find('.badge')
                        .attr('class', 'badge bg-danger')
                        .text('Cancelled');
                    $(tr).find('.btn-cancel').replaceWith(
                        '<button class="btn btn-success btn-sm btn-reactivate ms-1">'
                        + '<i class="bi bi-arrow-counterclockwise me-1"></i>Reactivate</button>'
                    );
                }

                if (method === 'reactivateAppointment') {
                    $(tr).find('.badge')
                        .attr('class', 'badge bg-primary')
                        .text('Booked');
                    $(tr).find('.btn-reactivate').replaceWith(
                        '<button class="btn btn-warning btn-sm btn-cancel ms-1">'
                        + '<i class="bi bi-x-circle me-1"></i>Cancel</button>'
                    );
                }

                if (method === 'deleteAppointment') {
                    selectedRow.remove().draw();
                }

                swAlert('success', 'Done!', message);
            },
            error: function (xhr) {
                // hideOverlay();
                swAlert('error', 'Server Error',
                    method + ' failed (' + xhr.status + '). Please try again.');
            }
        });
    }

    //  Clear is-invalid on change 
    $('#patientID,#doctorID,#appointmentDate,#appointmentTime').on('change', function () {
        $(this).removeClass('is-invalid');
    });

});

//  Edit appointment (outside ready — called from inline) 
function editAppointment(id, patient, doctor, date, time, remarks) {
    if (!id) {
        Swal.fire({
            icon: 'error', title: 'Error',
            text: 'Could not read appointment data.',
            confirmButtonColor: '#4f46e5'
        });
        return;
    }

    // Rebuild slots with current time selected
    var opts = '<option value="">— Select Time —</option>';
    for (var h = 0; h < 24; h++) {
        ['00', '30'].forEach(function (m) {
            var hh  = (h < 10 ? '0' : '') + h;
            var val = hh + ':' + m;
            var ampm = h < 12 ? 'AM' : 'PM';
            var h12  = h % 12 === 0 ? 12 : h % 12;
            var label = (h12 < 10 ? '0' : '') + h12 + ':' + m + ' ' + ampm;
            var sel   = (val === time) ? ' selected' : '';
            opts += '<option value="' + val + '"' + sel + '>' + label + '</option>';
        });
    }
    $('#appointmentTime').html(opts);

    $('#appointmentID').val(id);
    $('#patientID').val(String(patient));
    $('#doctorID').val(String(doctor));
    $('#appointmentDate').val(date);
    $('#remarks').val(remarks || '');

    $('#submitBtn')
        .data('action', 'updateAppointment')
        .html('<i class="bi bi-floppy me-1"></i> Update Appointment')
        .removeClass('btn-success').addClass('btn-warning');

    $('#formTitle')
        .html('<i class="bi bi-pencil-square me-2 text-warning"></i>Update Appointment');

    $('html,body').animate({
        scrollTop: $('#appointmentForm').offset().top - 80
    }, 400);
}

//  Reset form 
function resetForm() {
    $('#appointmentForm')[0].reset();
    $('#appointmentID').val('');

    // Rebuild blank slots
    var opts = '<option value="">— Select Time —</option>';
    for (var h = 0; h < 24; h++) {
        ['00', '30'].forEach(function (m) {
            var hh  = (h < 10 ? '0' : '') + h;
            var val = hh + ':' + m;
            var ampm = h < 12 ? 'AM' : 'PM';
            var h12  = h % 12 === 0 ? 12 : h % 12;
            var label = (h12 < 10 ? '0' : '') + h12 + ':' + m + ' ' + ampm;
            opts += '<option value="' + val + '">' + label + '</option>';
        });
    }
    $('#appointmentTime').html('<option value="">— Select Time —</option>' + opts);

    $('#submitBtn')
        .data('action', 'bookAppointment')
        .html('<i class="bi bi-check-circle me-1"></i> Book Appointment')
        .removeClass('btn-warning').addClass('btn-success');

    $('#formTitle')
        .html('<i class="bi bi-calendar-plus me-2 text-primary"></i>Book Appointment');

    $('#patientError,#doctorError,#dateError,#timeError').text('');
    $('#patientID,#doctorID,#appointmentDate,#appointmentTime').removeClass('is-invalid');
}

const toggleBtn = document.getElementById('sidebarToggle');
const sidebar   = document.querySelector('.sidebar-wrapper');
toggleBtn.addEventListener('click', () => {
    sidebar.classList.toggle('hide-sidebar');
});
</script>