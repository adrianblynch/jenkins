<cfscript>

param name="url.example" default="";

username = "anonymous";
token = "1796ebe2bb6f7ea071a5a07bcc0114fa";
serverURL = "http://jenkins:8080";
jobName = "API Test";
jenkins = new Jenkins(username, token, serverURL, jobName);

// The start of getting all param nodes in one go
// paramNodes = jenkins.getParameterNodes(xmlParse(jenkins.getConfig()));
// dump(paramNodes);
// params = jenkins.extractParameters(paramNodes);
// dump(params);

if (url.example EQ "getConfig") {

	config = jenkins.getConfig();

	header name="Content-Type" value="text/xml";

	echo(config);

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