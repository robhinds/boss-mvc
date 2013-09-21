/**
 * Component to support rendering views
 **/ 
component output="true" {

	public void function render( viewConfig, modelData ){
		var local.model = arguments.modelData;
		if ( !structKeyExists( arguments.viewConfig, "renderer" ) ){	//If no renderer defined, we will use CF templating
			if ( structKeyExists( arguments.viewConfig, "include" ) ){	//If "includes" then render those before main template
				for ( var local.viewComponent in arguments.viewConfig.include){
					var local.templatePath = replace( arguments.viewConfig.include[ local.viewComponent ], ".", "/", "ALL" );
					saveContent variable="local.#local.viewComponent#" {
						include "/views/#local.templatePath#.cfm";
					}
				}
			}

			//Now render main template
				var local.tpl = replace( arguments.viewConfig.template, ".", "/", "ALL" );
			saveContent variable="local.pageOutput" {
				include "/views/#local.tpl#.cfm";
			}
			
			writeOutput( local.pageOutput );
		}
	}
}