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

echo("<h1>Jenkins.cfc</h1>");
echo("<h2>Examples</h2>");

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

</cfscript>