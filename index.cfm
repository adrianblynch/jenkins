<cfscript>

param name="url.example" default="";

username = "anonymous";
token = "1796ebe2bb6f7ea071a5a07bcc0114fa";
serverURL = "http://jenkins:8080";
jobName = "Start Railo Express";
jenkins = new Jenkins(username, token, serverURL, jobName);

jenkins.setJobName(jobName);

if (url.example EQ "getConfig") {

	config = jenkins.getConfig();

	header name="Content-Type" value="text/xml";

	echo(config);

} else if (url.example EQ "getDescription") {

	echo(jenkins.getJobName() & " - " & jenkins.getDescription());

} else {

	examples = [
		{link = "Get description", href = "?example=getDescription"},
		{link = "Get config", href = "?example=getConfig"}
	];

	for (ex in examples) {
		echo("<ul>");
		echo("<li><a href='#ex.href#'>#ex.link#</a></li>");
		echo("</ul>");
	}

}

</cfscript>