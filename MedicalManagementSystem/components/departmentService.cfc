<cfcomponent output="false">

    <!--- Get All Departments --->
    <cffunction name="getAllDepartments" access="public" returntype="query">
        <cfquery name="qDepartments" datasource="mms_db">
            SELECT dept_id, dept_name, description, is_active, created_at
            FROM DEPARTMENTS
            ORDER BY dept_id DESC
        </cfquery>
        <cfreturn qDepartments>
    </cffunction>

    <!--- Add new department --->
    <cffunction name="addDepartmentAjax" access="remote" returntype="struct" returnformat="json" output="false">
        <cfargument name="dept_name"   type="string" required="true">
        <cfargument name="description" type="string" required="false" default="">

        <cfset var result   = {} >
        <cfset var deptName = trim(arguments.dept_name) >

        <!--- Validation --->
        <cfif len(deptName) LT 3>
            <cfset result.SUCCESS = false >
            <cfset result.MESSAGE = "Department name must be at least 3 characters." >
            <cfreturn result >
        </cfif>

        <cfif NOT reFind("^[A-Za-z ]+$", deptName)>
            <cfset result.SUCCESS = false >
            <cfset result.MESSAGE = "Department name must contain only alphabets." >
            <cfreturn result >
        </cfif>

        <cftry>
            
        <!--- Duplicate Check --->
        <cfquery name="qCheckDept" datasource="mms_db">
            SELECT dept_id, is_active, description, created_at
            FROM DEPARTMENTS
            WHERE dept_name = <cfqueryparam value="#deptName#" cfsqltype="cf_sql_nvarchar">
        </cfquery>

        <!--- CASE 1: Active duplicate --->
        <cfif qCheckDept.recordCount GT 0 AND qCheckDept.is_active EQ 1>
            <cfset result.SUCCESS   = false >
            <cfset result.errorType = "duplicate" >
            <cfset result.MESSAGE   = "Department already exists." >
            <cfreturn result >
        </cfif>

        <!--- CASE 2: Inactive duplicate → Reactivate --->
        <cfif qCheckDept.recordCount GT 0 AND qCheckDept.is_active EQ 0>

            <cfquery datasource="mms_db">
                UPDATE DEPARTMENTS
                SET is_active = 1,
                    description = <cfqueryparam value="#trim(arguments.description)#" cfsqltype="cf_sql_nvarchar">
                WHERE dept_id = <cfqueryparam value="#qCheckDept.dept_id#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfset var securityService = createObject("component","MedicalManagementSystem.components.SecurityService")>

            <cfset result.SUCCESS     = true >
            <cfset result.MESSAGE     = "Department reactivated successfully." >
            <cfset result.DEPT_ID     = qCheckDept.dept_id >
            <cfset result.ENC_DEPT_ID = securityService.encryptID(qCheckDept.dept_id) >
            <cfset result.DEPT_NAME   = deptName >
            <cfset result.DESCRIPTION = trim(arguments.description) >
            <cfset result.CREATED_AT  = dateFormat(qCheckDept.created_at, "dd-mmm-yyyy") >

            <cfreturn result>
        </cfif>

            <!--- Insert --->
            <cfquery name="qInsert" datasource="mms_db">
                INSERT INTO DEPARTMENTS (dept_name, description, is_active, created_at)
                OUTPUT INSERTED.dept_id, INSERTED.created_at
                VALUES (
                    <cfqueryparam value="#deptName#" cfsqltype="cf_sql_nvarchar">,
                    <cfqueryparam value="#trim(arguments.description)#" cfsqltype="cf_sql_nvarchar">,
                    1,
                    GETDATE()
                )
            </cfquery>

            <cfset result.SUCCESS     = true >
            <cfset result.MESSAGE     = "Department added successfully." >
            <cfset result.DEPT_ID = qInsert.dept_id >
            <cfset var securityService = createObject("component","MedicalManagementSystem.components.SecurityService")>
            <cfset result.ENC_DEPT_ID = securityService.encryptID(qInsert.dept_id)>
            <cfset result.DEPT_NAME   = deptName >
            <cfset result.DESCRIPTION = trim(arguments.description) >
            <cfset result.CREATED_AT  = dateFormat(qInsert.created_at, "dd-mmm-yyyy") >

            <cfcatch type="any">
                <cfset result.SUCCESS = false >
                <cfset result.MESSAGE = "Something went wrong while adding department." >
            </cfcatch>

        </cftry>

        <cfreturn result >
    </cffunction>


    <!--- edit department --->
    <cffunction name="editDepartmentAjax" access="remote" returntype="struct" returnformat="json" output="false">
        <cfargument name="enc_dept_id"     type="string" required="true">
        <cfargument name="dept_name"   type="string"  required="true">
        <cfargument name="description" type="string"  required="false" default="">

        <cfset var result   = {}>
        <cfset var securityService = createObject("component","MedicalManagementSystem.components.SecurityService")>
        <cfset var deptName = trim(arguments.dept_name)>

        <!--- Validation --->
        <cfif len(deptName) LT 3>
            <cfset result.SUCCESS = false>
            <cfset result.MESSAGE = "Department name must be at least 3 characters.">
            <cfreturn result>
        </cfif>

        <cfif NOT reFind("^[A-Za-z ]+$", deptName)>
            <cfset result.SUCCESS = false >
            <cfset result.MESSAGE = "Department name must contain only alphabets.">
            <cfreturn result >
        </cfif>

        <cftry>
            <cfset deptid = securityService.decryptID(arguments.enc_dept_id)>
            <!--- Duplicate Check (exclude current id) --->
            <cfquery name="qDuplicate" datasource="mms_db">
                SELECT dept_id
                FROM DEPARTMENTS
                WHERE dept_name = <cfqueryparam value="#deptName#" cfsqltype="cf_sql_nvarchar">
                AND is_active = 1
                AND dept_id != <cfqueryparam value="#deptid#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfif qDuplicate.recordCount GT 0>
                <cfset result.SUCCESS   = false >
                <cfset result.errorType = "duplicate" >
                <cfset result.MESSAGE   = "Department already exists." >
                <cfreturn result >
            </cfif>

            <!--- Update --->
            <cfquery datasource="mms_db">
                UPDATE DEPARTMENTS
                SET dept_name   = <cfqueryparam value="#deptName#" cfsqltype="cf_sql_nvarchar">,
                    description = <cfqueryparam value="#trim(arguments.description)#" cfsqltype="cf_sql_nvarchar">
                WHERE dept_id   = <cfqueryparam value="#deptid#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfset result.SUCCESS = true >
            <cfset result.MESSAGE = "Department updated successfully."/>

            <cfcatch type="any">
                <cfset result.SUCCESS = false >
                <cfset result.MESSAGE = "Something went wrong while updating department." >
            </cfcatch>

        </cftry>

        <cfreturn result>
    </cffunction>

<!--- soft delete/ active-inactive --->
    <cffunction name="toggleStatus" access="remote" returntype="struct" returnformat="json" output="false">
    <cfargument name="enc_id"     type="string" required="yes">
    <cfargument name="new_status" type="string" required="false" default="">

    <cfset var securityService = createObject("component","MedicalManagementSystem.components.SecurityService")>
    <cfset var result = { SUCCESS=false, MESSAGE="" }>

    <cftry>
        <cfset var deptID = securityService.decryptID(arguments.enc_id)>

        <!--- Get current status --->
        <cfquery name="qDept" datasource="mms_db">
            SELECT is_active FROM DEPARTMENTS
            WHERE dept_id = <cfqueryparam value="#deptID#" cfsqltype="cf_sql_integer">
        </cfquery>

        <cfset var newStatusInt = (qDept.is_active EQ 1) ? 0 : 1>

        <!--- Block inactivation if dept has active doctors --->
        <cfif newStatusInt EQ 0>
            <cfquery name="qCheck" datasource="mms_db">
                SELECT COUNT(*) AS doctorCount
                FROM   DOCTORS d
                JOIN   USERS u ON d.user_id = u.user_id
                WHERE  d.dept_id  = <cfqueryparam value="#deptID#" cfsqltype="cf_sql_integer">
                AND    d.is_active = 1
                AND    u.is_active = 1
            </cfquery>

            <cfif qCheck.doctorCount GT 0>
                <cfset result.MESSAGE = "Cannot deactivate. This department has #qCheck.doctorCount# active doctor(s) assigned to it.">
                <cfreturn result>
            </cfif>
        </cfif>

        <cfquery datasource="mms_db">
            UPDATE DEPARTMENTS
            SET is_active = <cfqueryparam value="#newStatusInt#" cfsqltype="cf_sql_integer">
            WHERE dept_id = <cfqueryparam value="#deptID#"       cfsqltype="cf_sql_integer">
        </cfquery>

        <cfset result.SUCCESS    = true>
        <cfset result.NEW_STATUS = (newStatusInt EQ 1) ? "Active" : "Inactive">
        <cfset result.MESSAGE    = "Status updated successfully.">

    <cfcatch type="any">
        <cfset result.SUCCESS = false>
        <cfset result.MESSAGE = cfcatch.message>
    </cfcatch>
    </cftry>

    <cfreturn result>
</cffunction>

</cfcomponent>