component output = "false" {

	public Router function init ( ) {
		if ( !structKeyExists( application, "framework" ) || !structKeyExists( application.framework, "router" )){
			variables.urlMappings = [];
			application.framework.router = this;
		}
		return application.framework.router;
	}


	/**
	 * Functions to define all the URL mappings
	 */
	public Router function delete ( String resourceUri,  Struct resourceParams = structNew() ) {
		variables.buildResourceConfiguration ( "DELETE", arguments.resourceUri, arguments.resourceParams );
		return( this );
	}
	public Router function get ( String resourceUri, Struct resourceParams = structNew() ) {
		variables.buildResourceConfiguration ( "GET", arguments.resourceUri, arguments.resourceParams );
		return( this );
	}
	public Router function post ( String resourceUri, Struct resourceParams = structNew() ) {
		variables.buildResourceConfiguration ( "POST", arguments.resourceUri, arguments.resourceParams );
		return( this );
	}
	public Router function put ( String resourceUri, Struct resourceParams = structNew() ) {
		variables.buildResourceConfiguration ( "PUT", arguments.resourceUri, arguments.resourceParams );
		return( this );
	}


	/**
	 * Function that expects a HTTP method and a URL and it will attempt to match the URL
	 * against a valid mapping
	 */
	public function resolveResource ( String httpMethod = "GET", String resourceUri ) {
		if ( arguments.resourceUri.endsWith("/") ) arguments.resourceUri = len(arguments.resourceUri) > 1 ? left(arguments.resourceUri,len(arguments.resourceUri)-1) : '';
		for ( var local.mapping in variables.urlMappings ) {
			if ( local.mapping.httpMethod == arguments.httpMethod ) {
				var local.matcher = local.mapping.compiledResource.pattern.matcher( javaCast( "string", arguments.resourceUri ) );
				if ( local.matcher.find() ) {
					var local.resolution = {
						httpMethod = arguments.httpMethod,
						resourceUri = arguments.resourceUri,
						resourceParams = duplicate( local.mapping.resourceParams )
					};
					
					var local.urlVariableNames = local.mapping.compiledResource.urlVariableNames;
					var local.urlVariablesCount = local.mapping.compiledResource.urlVariablesCount;

					// If there are variable sections of the URL, capture the values that have been defined and 
					// pass them back with the structure
					for ( var local.urlVariablesIndex=1; local.urlVariablesIndex <= local.urlVariablesCount; local.urlVariablesIndex++ ) {
						var local.urlVariableName = local.urlVariableNames[ local.urlVariablesIndex ];
						var local.urlVariableValue = local.matcher.group( javaCast( "int", local.urlVariablesIndex ) );
						local.resolution.resourceParams[ local.urlVariableName ] = local.urlVariableValue;
					}

					return( local.resolution );
				}
			}
		}

		//Nothing found, so 404
		new bossmvc.exceptions.NotFoundException( "URL provided did not match any of the configured URL mappings defined" );
	}


	/**
	 * Util function that builds the URL mappings along with the compiled URL regex
	 */
	private void function buildResourceConfiguration ( String httpMethod, String resourceUri, Struct resourceParams ) {
		// Compile the resource.
		var local.compiledResource = variables.compileResourcePattern ( arguments.resourceUri );
		
		// Create a new resource configuration.
		var local.mapping = {
			httpMethod = arguments.httpMethod,
			compiledResource = local.compiledResource,
			resourceParams = arguments.resourceParams
		};

		// Store the new configuration.
		arrayAppend( variables.urlMappings, local.mapping );
	}


	/**
	 * Util function that turns the provided URL mapping in to a compiled REGEX pattern 
	 * including the expected variable names
	 */
	private Struct function compileResourcePattern ( String resourceUri ) {
		//The names of any variable sections in the URL definition
		var local.urlVariableNames = [];
		
		//Extract all variable sections - preceeded with a ":" (maybe introduce "#" so we can define numeric/string variables)
		//To do that, we just repate the code block below with a "#" and make the regex replacements more specific
		var local.urlVariables = reMatch( ":[^/]+", arguments.resourceUri );
		var local.resourcePattern = ("^" & arguments.resourceUri & "$");
		// Now, let's replace each URL variable
		for ( var local.variable in local.urlVariables ) {
			// Get the variable name by taking everything after the ":"
			arrayAppend( local.urlVariableNames, listLast( local.variable, ":" ) );
			// Re-create the Reg-ex by replacing our variable token with a catch-all regex (up until the next "/")
			local.resourcePattern = replace( local.resourcePattern, local.variable, "([^/]+)", "one" );
		}
		
		//Jam the end result into a struct defining what is going on..
		var local.compiledResource = {
			urlVariableNames = local.urlVariableNames,
			urlVariablesCount = arrayLen( local.urlVariableNames ),
			pattern = createObject( "java", "java.util.regex.Pattern" ).compile( javaCast( "string", local.resourcePattern ) ),
			rawDefinition = arguments.resourceUri
		};

		return( local.compiledResource );
	}
}