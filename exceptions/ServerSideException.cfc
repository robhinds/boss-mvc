component output="false" extends="BossException" {

	public NotFoundException function init ( String extendedInfo="" ) {
		super.init( "Server Side Error", "Unexpected exeption occured in the server", arguments.extendedInfo, "e500" );
		return this;
	}

}