<cfscript>

/*
	The following examples act on three projects:
		- API Test - No params
		- API Test - One param
			- String param: Param One
		- API Test - With params
			- String param: AStringParam
			- Choice param: AChoiceParam - Choice 1, Choice 2, Choice 3
			- Boolean param: ABooleanParam
			- Text param: ATextParam
			- Password param: APasswordParam
			- String param: ADupeStringParam
			- String param: ADupeStringParam

	No real error checking is included below to keep the examples clearer.
*/

username = "anonymous";
token = "1796ebe2bb6f7ea071a5a07bcc0114fa";
serverURL = "http://jenkins:8080";

jenkins = new Jenkins(username, token, serverURL);

//////////////
// Building //
//////////////

// When no params are needed
jenkins.setProjectName("API Test - No params").build();

// With one param using its default value
jenkins.setProjectName("API Test - One param").buildwithParameters();

// With one param changing it from the default value
jenkins.setProjectName("API Test - One param").buildwithParameters([{"Param One" = "Change from the default"}]);

////////////////
// Parameters //
////////////////

// Load the config of a project with more params
jenkins.setProjectName("API Test - With params").loadConfig();

// Get all params
dump(jenkins.getParameters());

// Get all params by type
dump(jenkins.getParameters("string"));

// Get one param by name
dump(jenkins.getParameter("ABooleanParam"));

// Get first duplicate param by name
dump(jenkins.getParameter("ADupeStringParam"));

// Get all duplicate params by name
dump(jenkins.getParameter("ADupeStringParam", "all"));

// Update a parameter's default value
dump(jenkins.getParameter("ATextParam"));
jenkins.updateParameter("ATextParam", "A new value as of #now()#");
dump(jenkins.getParameter("ATextParam"));

// Save the updated parameter
jenkins.saveConfig();

// Get the config again and check the change was saved - Or go see the project in Jenkins!
jenkins.loadConfig();
dump(jenkins.getParameter("ATextParam"));

/////////////////
// Other stuff //
/////////////////

// Get description
dump("Description before = " & jenkins.getDescription());

// Update the description
jenkins.updateDescription(jenkins.getDescription() & " - " & now());

// Save the updated description
jenkins.saveConfig();

// Reload and check the save was successful - Or go see the project in Jenkins!
jenkins.loadConfig();
dump("Description after = " & jenkins.getDescription());

// View config as XML
// header name="Content-Type" value="text/xml";
// content reset="true";
// echo(jenkins.getConfig());abort;

abort;

if (url.example EQ "getConfig") {



} else if (url.example EQ "getDescription") {

	echo(jenkins.getJobName() & " - " & jenkins.getDescription());

} else if (url.example EQ "getAllParams") {

	params = jenkins.getParameters();

	dump(var = params, label = "All #jenkins.getJobName()# parameters");

} else if (url.example EQ "getStringParam") {

	stringParam = "AStringParam";
	echo(stringParam & " = " & jenkins.getStringParameter(stringParam));

} else if (url.example EQ "getChoiceParams") {

	choiceParam = "AChoiceParam";
	echo(choiceParam & " = " & jenkins.getChoiceParameters(choiceParam));

} else {

	examples = [
		{link = "Get description", href = "?example=getDescription"},
		{link = "Get config", href = "?example=getConfig"},
		{link = "Get all parameters", href = "?example=getAllParams"},
		{link = "Get string parameter", href = "?example=getStringParam"},
		{link = "Get choice parameters", href = "?example=getChoiceParams"}
	];

	echo("<h1>Jenkins.cfc</h1>");
	echo("<h2>Examples</h2>");

	echo("<ul>");
	for (ex in examples) {
		echo("<li><a href='#ex.href#'>#ex.link#</a></li>");
	}
	echo("</ul>");

}

/*
paramName = "AStringParam";
dump("Before: " & jenkins.getParameter(paramName).defaultValue);
jenkins.updateParameter(paramName, "Default value of #paramName# - #now()#");
dump("After: " & jenkins.getParameter(paramName).defaultValue);

paramName = "ATextParam";
dump("Before: " & jenkins.getParameter(paramName).defaultValue);
jenkins.updateParameter(paramName, "Default value of #paramName# - #now()#");
dump("After: " & jenkins.getParameter(paramName).defaultValue);

paramName = "APasswordParam";
dump("Before: " & jenkins.getParameter(paramName).defaultValue);
jenkins.updateParameter(paramName, "Default value of #paramName# - #now()#");
dump("After: " & jenkins.getParameter(paramName).defaultValue);

paramName = "ABooleanParam";
dump("Before: " & jenkins.getParameter(paramName).defaultValue);
jenkins.updateParameter(paramName, randRange(0, 1) EQ 1);
dump("After: " & jenkins.getParameter(paramName).defaultValue);

// By default, only the first param of a given name is returned
paramName = "ADupeStringParam";
dump(jenkins.getParameter(paramName));
dump("Before: " & jenkins.getParameter(paramName, "one").defaultValue);
jenkins.updateParameter(paramName, "Default value of #paramName# - #now()#", "one");
dump("After: " & jenkins.getParameter(paramName).defaultValue);

// All params named [paramName] will be returned - Update them all
paramName = "ADupeStringParam";
dump(var = jenkins.getParameter(paramName, "all"), label = "All #paramName# values");
jenkins.updateParameter(paramName, "Default value of #paramName# - #now()#", "all");
dump(var = jenkins.getParameter(paramName, "all"), label = "All #paramName# values");

// Choice params - What to do?
paramName = "AChoiceParam";
choices = jenkins.getParameter(paramName).choices;
//dump(choices);
choices = choices.map(function(choice) {
	return choice.reverse();
});
//dump(choices);
jenkins.updateParameter(paramName, choices);
jenkins.saveConfig();

jenkins.saveConfig();
*/

</cfscript>