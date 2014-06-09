Jenkins.cfc
=======

Interact with Jenkins in your ColdFusion and Railo projects.

Notes
-----

- Built to work with Jenkins 1.500.
- Tested on Jenkins 1.500 and 1.564.
- Tested on Railo 4.2.1 with full null support, and localmode set to modern, hence the lack of var scoped variables.

Todo
----

- Change getStringParameterNode() to use better XML manipulation. The current nested loops approach is damn ugly!
- Get as many parametera as we can, starting with the single value ones.

Usage
-----

	jenkins = new lib.Jenkins(
		username = "JENKINS_USERNAME",
		token = "JENKINS_API_TOKEN",
		serverURL = "JEKINS_SERVER_URL"
	);

	// Build a job
	jenkins.setJob("NAME_OF_JOB_YOU_WISH_TO_BUILD");
	jenkins.build();

	// Get job description
	desc = jenkins.getDescription();

	// Get current value of a string parameter, myParam
	myParam = jenkins.getStringParameter("myParam");

	// Update the same string parameter
	updatedConfig = jenkins.updateStringParameter("myParam", "New value");
	jenkins.updateConfig(updatedConfig);

	// Check new parameter was saved
	updatedParam = jenkins.getStringParameter("myParam");

Also see index.cfm for runnable examples.
