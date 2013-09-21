/**
 * Component to support rendering views
 **/ 
component output="true" {

	public void function render( viewConfig, modelData ){
		if ( !structKeyExists( arguments.viewConfig, "renderer" ) ){	//If no renderer defined, we will use CF templating
			if ( structKeyExists( arguments.viewConfig, "includes" ) ){	//If "includes" then render those before main template
				for ( var local.viewComponent in arguments.viewConfig.includes){
					saveContent variable="local.#local.viewComponent#" {
						var local.templatePath = replace( arguments.viewConfig.includes[ local.viewComponent ], ".", "/", "ALL" );
						include "#application.APPLICATION_ROOT#views/#local.templatePath#.cfm";
					}
				}
			}
			//Now render main template
			saveContent variable="local.pageOutput" {
				var local.tpl = replace( arguments.viewConfig.template, ".", "/", "ALL" );
				include "#application.APPLICATION_ROOT#views/#local.tpl#.cfm";
			}
			
			writeOutput( local.pageOutput );
		}
	}
}