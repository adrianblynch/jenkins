<cfscript>

param name="url.example" default="";

username = "anonymous";
token = "1796ebe2bb6f7ea071a5a07bcc0114fa";
serverURL = "http://jenkins:8080";
jobName = "API Test";

jenkins = new Jenkins(username, token, serverURL, jobName);

jenkins.loadConfig();
jenkins.setConfig(jenkins.getConfig());
jenkins.saveConfig();

param = jenkins.getParameter("AStringParam");
params = jenkins.getParameter("DupeStringParam");
params = jenkins.getParameters();

jenkins.updateParameter("AStringParam", now());

if (url.example EQ "getConfig") {

	header name="Content-Type" value="text/xml";

	echo(jenkins.getConfig());

} else if (url.example EQ "getDescription") {

	echo(jenkins.getJobName() & " - " & jenkins.getDescription());

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

</cfscript>