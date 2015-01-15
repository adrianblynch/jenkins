Jenkins.cfc
=======

Interact with Jenkins in your ColdFusion and Railo projects.

Notes
-----

- Originally built to work with Jenkins 1.500.
- Tested on Jenkins 1.500 and 1.564.
- Tested on Railo 4.2.1 with full null support, and localmode set to modern, hence the lack of var scoped variables.

Todo
----

- Look at adding complex parameters to the list of those we can edit
- Full update of choice parameters
- Add project?

Basic usage
-----

	jenkins = new lib.Jenkins(
		username = "JENKINS_USERNAME",
		token = "JENKINS_API_TOKEN",
		serverURL = "JEKINS_SERVER_URL"
	);

	// Build a project
	jenkins.setProject("NAME_OF_JOB_YOU_WISH_TO_PLAY_WITH");
	jenkins.build();

See index.cfm for more complex examples.
