<cfinclude template="../../includes/sessionCheck.cfm">
<cfinclude template="../../includes/header.cfm">
<cfinclude template="patientSidebar.cfm">


<cfif  NOT structKeyExists(session,"user") OR session.user.role_id NEQ 4>
    <cflocation url="/MedicalManagementSystem/pages/error/unauthorized.cfm" addtoken="no">
</cfif>

<cfset billService    = createObject("component","MedicalManagementSystem.components.PatientDashboardService")>
<cfset billingSummary = billService.getBillingSummary(session.user.user_id)>

<!--- SweetAlert2 --->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.all.min.js"></script>

<style>
    #billsTable thead th {
        background-color: #7070db;
        color: #fff;
        font-weight: 600;
        font-size: 15px;
        letter-spacing: .4px;
        border-color: #9b96cf;
        white-space: nowrap;
    }
    #billsTable tbody tr:hover {
        background-color: #f0f0ff;
    }
    #billsTable tbody td {
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
        font-size: 13px;
        color: #6b7280;
    }
</style>

<div id="main">

    <header class="mb-3">
        <a href="#" class="burger-btn d-block d-xl-none">
            <i class="bi bi-justify fs-3"></i>
        </a>
    </header>
    <div class="page-heading d-flex justify-content-between align-items-center mb-3">
        <h3>My Bills</h3>
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-0">
                <li class="breadcrumb-item">
                    <a href="/MedicalManagementSystem/pages/patients/patient_Account.cfm">
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

    <div class="card border-0 shadow-sm">
        <div class="card-body fw-semibold">
            <i class="bi bi-receipt me-2 text-primary"></i>Billing Records
        </div>
        <div class="card-body">
            <cfif billingSummary.recordCount EQ 0>
                <p class="text-muted mb-0">No billing records found.</p>
            <cfelse>
                <div class="table-responsive">
                    <table id="billsTable" class="table table-bordered table-hover align-middle">
                        <thead>
                            <tr>
                                <th>Sl No</th>
                                <th>Invoice No</th>
                                <th>Date</th>
                                <th>Consultation Fee</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfset counter = 0>
                            <cfoutput query="billingSummary">
                                <cfset counter++>
                                <tr>
                                    <td>#counter#</td>
                                    <td><span class="fw-bold">#encodeForHTML(invoice_no)#</span></td>
                                    <td>#dateFormat(bill_date,"dd-mmm-yyyy")#</td>
                                    <td>
                                        <i class="bi bi-currency-rupee"></i>#numberFormat(total_amount,"__.00")#
                                    </td>
                                </tr>
                            </cfoutput>
                        </tbody>
                    </table>
                </div>
            </cfif>
        </div>
    </div>

</div>

<cfinclude template="../../includes/footer.cfm">

<script>
$(document).ready(function () {
    $('#billsTable').DataTable({
        pageLength: 5,
        order:      [[2, 'desc']],
        columnDefs: [{ orderable: false, targets: [0] }],
        language: {
            emptyTable: 'No billing records found.',
            search:     '<i class="bi bi-search me-1"></i>Search:',
            lengthMenu: 'Show _MENU_ entries',
            info:       'Showing _START_ to _END_ of _TOTAL_ bills',
            paginate: {
                previous: '&lsaquo;',
                next:     '&rsaquo;'
            }
        }
    });
});
</script>