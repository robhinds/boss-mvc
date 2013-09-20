component output="false"{

	/**
	 * Assumes all Controllers are created under /controllers (can be nested here) and iterates through
	 * all controller CFCs and instantiates them as singletons and adds them to application scope
	 */
	public void function initControllers(){
		initApplicationControllers();
		initFrameworkControllers();
	}
	
	/** initialise custom application controllers  **/
	private void function initApplicationControllers(){
		if (directoryExists( "#application.APPLICATION_ROOT#controllers" ) ){
			var local.controllersFound = directoryList( "#application.APPLICATION_ROOT#controllers", true, "path", "*.cfc" );
			for ( var local.controller in local.controllersFound ){
				local.controller = replaceNoCase( local.controller, "#application.APPLICATION_ROOT#", "", "ALL");
				local.controller = replaceNoCase( local.controller, "/", ".", "ALL" );
				local.controller = replaceNoCase( local.controller, "\", ".", "ALL" );
				local.controller = replaceNoCase( local.controller, ".cfc", "", "ALL" );
				local.controller = lCase( local.controller );
				application.framework.controllers[replace( local.controller, "controllers.", "" ) ] = createObject( "component", local.controller );
			}
		}
	}
	
	/** Core application controllers - only Error rendering so far **/
	private void function initFrameworkControllers(){
		application.framework.controllers['bossmvc.Errors'] = new controllers.Errors();
	}

	
	/**
	 * Loads all routing config in to the Router object in the application scope - this maps the
	 * URL patterns to controller methods to be called.
	 */
	public void function initRouting() {
		application.framework.router = new bossmvc.routing.Router();
	    if (application.annotateControllers){
			for (local.controllerName in application.framework.controllers){
				local.controllerMeta = getMetaData(application.framework.controllers[local.controllerName]);
				if ( structKeyExists( local.controllerMeta, "Controller" ) ){
					local.action = local.controllerName;
					local.rootUrlMapping = 	local.controllerMeta.controller == true ? "" : local.controllerMeta.controller;
					if ( structKeyExists( local.controllerMeta, "Functions" ) ){
						for ( local.func in local.controllerMeta.functions ){
							if ( structKeyExists( local.func, "Access" ) && local.func.access == "public" && structKeyExists( local.func, "RequestMapping" ) ){
								local.functionUrlMapping = 	local.func.requestMapping == true ? "" : local.func.requestMapping;
								application.framework.router.get( "#local.rootUrlMapping##local.functionUrlMapping#", { action = "#local.controllerName#.#local.func.name#" } );
							}
						}
					}
				}
			}
	    } else if (application.implicitControllers){
		    application.framework.router.get( "", { action = "home.default" } );
		    application.framework.router.get( "/user/:username", { action = "user.homepage" } );
	    }
	}
	
	
	/**
	 * Takes the current request and checks it against our defined patterns - if it finds a match then it calls
	 * the controller function (all controllers are already instantiated as singletons)
	 */
	public void function routeRequest() {
		var local.params = application.framework.router.resolveResource( "GET", CGI.PATH_INFO).resourceparams;
		var local.controllerName = local.params.action;
		var local.urlDepth = listLen( local.controllerName, "." );
		local.functionName = listGetAt(local.controllerName, local.urlDepth, "." );
		local.controllerName = listDeleteAt( local.controllerName,  local.urlDepth, ".");

		if ( structKeyExists( application, "framework" ) && structKeyExists( application.framework, "controllers" ) 
				&& structKeyExists( application.framework.controllers, local.controllerName ) ){
			var local.controller = application.framework.controllers[local.controllerName];
			var local.functionToInvoke = local.controller[local.functionName];
			local.functionToInvoke( local.params );
		} else {
			new bossmvc.exceptions.ServerSideException( "Controller Action Invalid: Could not find controller to match #local.controllerName# " );
		}
	}
	
}