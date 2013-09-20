/**
 * Custom base Exception class to allow custom throwing of exceptions
 */
component output = "false" {
	public void function init (required String message, required String detail, String extendedInfo="", String errorCode=""){
	    throw( type="#getMetaData(this).name#", message="#arguments.message#", detail="#arguments.detail#", extendedInfo="#arguments.extendedInfo#", errorCode="#arguments.errorCode#");
	}
}
