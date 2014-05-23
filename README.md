Jenkins.cfc
=======

Interact with Jenkins in your ColdFusion and Railo projects.

Notes

- Built to work with Jenkins 1.5.x.
- Tested on Railo 4.2.1 with full null support, and localmode set to modern, hence the lack of var scoped variables.

Todo

- Change getStringParameterNode() to use better XML manipulation. The current nested loops approach is damn ugly!

Usage

	jenkins = new lib.Jenkins(
		username = "JENKINS_USERNAME",
		token = "JENKINS_API_TOKEN",
		serverURL = "JEKINS_SERVER_URL"
	);

	// Build a job

	jenkins.setJob("NAME_OF_JOB_YOU_WISH_TO_BUILD");
	jenkins.build();

	jobName = "NAME_OF_JOB";
	paramName = "Codes";

	jenkins.setJob(jobName);

	currentParamValue = jenkins.getStringParameter(paramName)

	if (request.act EQ "addSiteCode") {

		if (NOT listFind(currentParamValue, request.newParamItem, " ")) {
			newParamValue = listAppend(currentParamValue, request.newParamItem, " ");
			newConfig = jenkins.updateStringParameter(paramName, newParamValue);
			jenkins.updateConfig(newConfig);
			location url="#cgi.script_name#";
		}

	}