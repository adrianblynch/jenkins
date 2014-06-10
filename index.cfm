<cfscript>

param name="url.example" default="";

username = "anonymous";
token = "1796ebe2bb6f7ea071a5a07bcc0114fa";
serverURL = "http://jenkins:8080";
jobName = "API Test";

jenkins = new Jenkins(username, token, serverURL, jobName);

jenkins.loadConfig();

if (url.example EQ "getConfig") {

	header name="Content-Type" value="text/xml";
	content reset="true";
	echo(jenkins.getConfig());

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