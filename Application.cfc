component output="false" extends="BossApplication"{

	this.name = "BOSS MVC";
	this.sessionmanagement = true;
    this.sessiontimeout = createTimeSpan(0,0,30,0);
	this.enablerobustexception  = "yes";
	
	//Controller discovery config:
	application.annotateControllers = true;	//At startup we will scan the .cfcs inside "/controllers" andd look for annotated files
	application.configControllers = false;	//URL patterns will be loaded explicitly from a config file


	/**
	 * Run on application start (well first request after starting the application).
	 * Sets the application root location variable and initialises the controller & routings for later use.
	 */
	public void function onApplicationStart(){
		application.APPLICATION_ROOT = getDirectoryFromPath(getCurrentTemplatePath());
		initControllers();
		initRouting();
		initViews();
	}

	
	/**
	 * Called on every request - routes the incoming request to the correct controller
	 */
	public void function onRequestStart(required string TargetPage) {
		try{
			routeRequest();
		} catch ( Any e ) {
			switch ( e.type ){
				case "bossmvc.exceptions.NotFoundException":
					application.framework.controllers["bossmvc.Errors"].e404( e );
					break;
				default:
					application.framework.controllers["bossmvc.Errors"].e500( e );
			}
		}
	}
	
}