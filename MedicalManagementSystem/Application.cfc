component {

    this.name              = "MedicalManagementSystem";
    this.sessionManagement = true;
    this.sessionTimeout = createTimeSpan( 1, 0, 0, 0 );

    function onApplicationStart() {
        return true;
    }

    function onSessionStart() {
        session.started = now();
    }

    function onSessionEnd(sessionScope, appScope) {
        
    }

    function onRequestStart(targetPage) {
        return true;
    }

}