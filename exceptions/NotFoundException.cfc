component output="false" extends="BossException" {

	public NotFoundException function init ( String extendedInfo="" ) {
		super.init( "Page Not Found", "I still haven't found, what I'm looking for..", arguments.extendedInfo, "e404" );
		return this;
	}

}