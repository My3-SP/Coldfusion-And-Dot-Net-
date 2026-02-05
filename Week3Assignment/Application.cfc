component 
{
	this.Name = "Week 3 Assignment";
	this.applicationTimeout=createTimespan(1,0,0,0);
	this.sessionManagement=true;
	this.sessionTimeout=createTimespan(0,0,30,0);

	function onApplicationStart()
	{
		application.appStartTime=now();
		return true;
	}
	function onServerStart() 
	{
        return true;
    }

	
    function onRequestStart(targetPage)
	{
		if (!structKeyExists(session, "userStatus")) 
		{
            session.userStatus = "Guest";
        }
        return true;
    }
	
	function onError(exception,eventName)
	{
		writeOutput("Error!!: "& exception.message);
	}
}