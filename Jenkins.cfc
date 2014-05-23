component {

	debugURL = "http://127.0.0.1:8888/jenkins-dump.cfm";

	function init(username, token, serverURL, job) {
		variables.username = username;
		variables.token = token;
		variables.serverURL = reReplaceNoCase(serverURL, "(https?://)", "\1#username#:#token#@");
		if (NOT isNull(job)) { // What does this do for scoping? Let's turn on hardcode scoping and deal with the lack of cascade!
			setJob(job);
		}
	}

	function setJob(job) {
		variables.job = job;
	}

	function getURL(path) {
		return "#variables.serverURL#/job/#variables.job#/#path#";
	}

	function build() {
		u = getJobURL("build");
		http url="#u#";
	}

	function buildWithParameters(params = []) {

		u = getJobURL("buildWithParameters");

		http url="#u#" {

			for (param in params) {
				key = param.keyArray()[1];
				value = param[key];
				httpparam type="url" name="#key#" value="#value#";
			}

		}

	}

	function getConfig() {

		u = getJobURL("config.xml");

		http url="#u#";

		return cfhttp.fileContent;
	}

	function updateConfig(xml) {

		if (isXML(xml)) {
			xml = toString(xml);
		}

		u = getJobURL("config.xml");

		http url="#u#" method="post" {
			httpparam type="body" value="#xml#";
		}

		return cfhttp.status_code EQ "200";

	}

	function getStringParameterNode(name, configXML) {

		// XPath might be a better way of getting to the node we want to change
		/*
			propertiesNode = xmlSearch(xml, "/project/properties/hudson.model.ParametersDefinitionProperty/parameterDefinitions/hudson.model.StringParameterDefinition[name[text()='Codes']]/defaultValue");
			//dump(propertiesNode);
			propertiesNode[1].XmlText = "asdf";
			//dump(propertiesNode);
			propertiesValue = propertiesNode[1].XmlText;
			//dump(propertiesValue);
		*/

		for (node in configXML.project.XmlChildren) {
			if (node.XmlName EQ "properties") {
				for (node in node.XmlChildren) {
					if (node.XmlName EQ "hudson.model.ParametersDefinitionProperty") {
						for (node in node.XmlChildren) {
							if (node.XmlName EQ "parameterDefinitions") {
								for (node in node.XmlChildren) {
									if (node.XmlChildren[1].XmlText EQ name) { // Direct access because I'm sick of looping!
										return node.XmlChildren[3];
									}
								}
								return null; // We didn't find one
							}
						}
					}
				}
			}
		}

	}

	function getStringParameter(name, config) {

		if (isNull(config)) {
			config = getConfig();
		}

		xml = xmlParse(config);
		node = getStringParameterNode(name, xml);

		return NOT isNull(node) ? node.XmlText : null;

	}

	function updateStringParameter(name, value, config) {

		if (isNull(config)) {
			config = getConfig();
		}

		xml = xmlParse(config);
		node = getStringParameterNode(name, xml);
		node.XmlText = value;

		return xml;

	}

	function getParameters() {

		u = getJobURL("api/json?tree=actions[parameterDefinitions[defaultParameterValue[value],description,name,type]]");

		http url="#u#";

		for (item in parseResult(cfhttp.fileContent).actions) {
			if (item.keyArray()[1] EQ "parameterDefinitions") {
				return item.parameterDefinitions;
			}
		}

	}

	function parseResult(result) {
		return isXML(result) ? xmlParse(result) : (isJSON(result) ? deserializeJSON(result) : "");
	}

	function getDescription() {

		u = getJobURL("description");

		http url="#u#";

		return cfhttp.fileContent;

	}

	function updateDescription(description) {

		u = getJobURL("submitDescription");

		http url="#u#" method="post" {
			httpparam type="formfield" name="description" value="#description#";
		}

	}

}
