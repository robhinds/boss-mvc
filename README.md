boss-mvc
========

A lightweight ColdFusion MVC framework.

This all started whilst drinking vodka and coding one evening, so it is still very much in its early stages of life. At the moment all it does is handles routing incoming requests to controllers; it still needs to have all the infrastructure added to handle rendering views (the plan is to include mustache server & client side templating as an option for views).

At the moment, it is dead simple to configure, just grab the framework and create a controller as follows (it assumes that there will be a directory in the root of your webapp called controllers)

/controllers/Home.cfc:
```coldfusion
/**
 * @Controller
 **/
component output = "false"  {

	/**
	 * @RequestMapping
	 **/
	public void function default( Struct resourceParams="" ){
		writeDump("Hello, Home Page!");
		abort;
	}
	
	/**
	 * @RequestMapping /about-us
	 **/
	public void function aboutUs( Struct resourceParams="" ){
		writeDump("Hello, About us Page!");
		abort;
	}
}
```

The above code will direct all requests to the application root ("/") to the default() function, and requests to "/about-us" to the aboutUs() function - Simple right?  The @Controller and @RequestMapping annotations define the URL patterns to match - In this case, @Controller specifies no URL pattern, neither does @RequestMapping on the default function, so this gets mapped to the root.

You can also have variable sections of the URL:
/controllers/User.cfc
```coldfusion
/**
 * @Controller /user
 **/
component output = "false"  {

	/**
	 * @RequestMapping /:username
	 **/
	public void function default( Struct resourceParams="" ){
		writeDump("Hello, #arguments.resourceParams.username#!");
		abort;
	}

}
```

In the above example, you can see that @Controller and @RequestMapping have a URL pattern defined. You will also note the @RequestMapping has a ":" before username - this indicates a variable section of the URL. This code will handle requests that hit the URL /user/rob etc - Any named variable section of the URL will be available  to the controller function in teh resourceParams struct (as seen above). 
