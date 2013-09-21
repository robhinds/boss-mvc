boss-mvc
========

A lightweight ColdFusion MVC framework.

This all started whilst drinking vodka and coding one evening, so it is still very much in its early stages of life.  (the plan is to include mustache server & client side templating as a primary option for views).



Controllers:
--------
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
	public Array function default( Struct resourceParams="" ){
		return [ "homepage" ];
	}
}
```

The above code will direct all requests to the application root ("/") to the default() function. The URL pattern for either the @Controller or @RequestMapping can be left blank (or populated) - the values provided are concatenated to produce the URL mapping for a function.



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
	public Array function default( Struct resourceParams="" ){
		return [ "userpage" ];
	}
}
```

In the above example, you can see that @Controller and @RequestMapping have a URL pattern defined. You will also note the @RequestMapping has a ":" before username - this indicates a variable section of the URL. This code will handle requests that hit the URL /user/rob etc - Any named variable section of the URL will be available  to the controller function in teh resourceParams struct (as seen above). 



Views:
--------

View definition and resolution is also real simple (hopefully). Firstly, you can define a view layout by name - this defines a named view and CFM template, along with any templates that make up the overall view. This is all configured in JSON notation.

At startup, the framework scans the /views directory for any "*.config" files - any it finds it loads up, and then the views defined will be available for use in the application.

/views/view-layout.config:
```json
[
	{
		"name": "homepage",
		"template": "home.pagetemplate",
		"include": {
			"header": "home.header",
			"body": "home.body",
			"footer": "home.footer"
		}
	},
	{
		"name": "userpage",
		"template": "user.pagetemplate",
		"include": {
			"header": "user.header",
			"body": "user.body",
			"footer": "user.footer"
		}
	}
]
```

The above defines two views, "homepage" & "userpage" - both are made up of similar components. The convention for the templates is relative to the /views directory, and uses "." instead of "/"  (e.g. "template": "user.pagetemplate"  will expect a file /views/user/pagetemplate.cfm ).

As you can hopefully work out from the above, the "homepage" view is based on /views/home/pagetemplate.cfm and is made up of the three templates /views/home/header.cfm, body.cfm, footer.cfm.

All nested templates are simply placed in the local scope (for the template being rendered), so our pagetemplate cfm looks like this:

/views/home/pagetemplate.cfm:
```html
<html lang="en">
	<cfoutput>#local.header#</cfoutput>
	<body>
		<cfoutput>#local.body#</cfoutput>
		<cfoutput>#local.footer#</cfoutput>
	</body>
</html>
```


Once we have built a view definition, and have created our templates, a controller simply has to return the viewname as the first argument of an array. If we look again at our Home controller:

/controllers/Home.cfc:
```coldfusion
/**
 * @Controller
 **/
component output = "false"  {

	/**
	 * @RequestMapping
	 **/
	public Array function default( Struct resourceParams="" ){
		return [ "homepage" ];
	}
}
```

We see that we just want to render the "homepage" view for all requests. Simple controller & simple view composition. Pretty boss.


Models:
--------

Obviously, most of the time we will want to pass data (in the form of a model) to our views for rendering, this is also really simple!

We have seen that in the controller, if there are variable names in the URL that is passed to the controller function in the arguments.resourceParams struct - That data is also automatically passed through to the view template, but can be supplemented by any data accessed in the controller.

Let's look again at out User controller, but lets say we want to pass some additional data to the view for rendering:

/controllers/User.cfc:
```coldfusion
/**
 * @Controller /user
 **/
component output = "false"  {

	/**
	 * @RequestMapping /:username
	 **/
	public Array function default( Struct resourceParams="" ){
		return [ "userpage", { greeting: "Yo!"} ];
	}
}
```

This time, we are returning a second element in the array - this is a Struct of the model data, this Struct could contain any data you have fetched in the controller that you want to pass to your view template for rendering. As we have a variable URL section (username) and are passing some model data back to the view, both of these can be used.

/views/user/body.cfm:
```html
<h1><cfoutput>#local.model.greeting#</cfoutput> <cfoutput>#local.model.username#</cfoutput>!</h1>
```

The URL variable sections and the returned model data are all available to the templates in "local.model".
