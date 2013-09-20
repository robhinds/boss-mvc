/**
 * Controller that handles the rendering of error pages
 */
component output = "false" {

	public void function e404( required Any e ){
		writeDump("uh oh");
		writeDump(e);
		abort;
	}
	
	public void function e500( required Any e ){
		writeDump(e);
		abort;
	}

}