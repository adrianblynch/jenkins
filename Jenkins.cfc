component {

	config = "";

	function init(username, token, serverURL, jobName) {
		variables.username = username;
		variables.token = token;
		variables.serverURL = reReplaceNoCase(serverURL, "(https?://)", "\1#username#:#token#@");
		if (NOT isNull(jobName)) { // What does this do for scoping? Let's turn on hardcode scoping and deal with the lack of cascade!
			setJobName(jobName);
		}
	}

	function setJobName(jobName) {
		variables.jobName = jobName;
	}

	function getJobName() {
		return variables.jobName;
	}

	function getURL(path) {
		return "#variables.serverURL#/job/#variables.jobName#/#path#";
	}

	function build() {
		http url="#getURL('build')#";
	}

	function buildWithParameters(params = []) {

		u = getURL("buildWithParameters");

		http url="#u#" {

			for (param in params) {
				key = param.keyArray()[1];
				value = param[key];
				httpparam type="url" name="#key#" value="#value#";
			}

		}

	}

	function setConfig(config) {
		variables.config = isXML(config) ? toString(config) : config;
	}

	function getConfig() {
		http url="#getURL('config.xml')#";
		return cfhttp.fileContent;
	}

	function loadConfig() {
		http url="#getURL('config.xml')#";
		setConfig(cfhttp.fileContent);
	}

	function saveConfig() {

		http url="#getURL('config.xml')#" method="post" {
			httpparam type="body" value="#getConfig()#";
		}

		return cfhttp.status_code EQ "200";

	}

	function getParameter(name) {

		parameters = getParameters();
		params = [];

		for (param in parameters) {
			// We check all because there might be more than one param with the same name
			if (param.name EQ name) {
				params.append(param);
			}
		}

		return params.len() EQ 1 ? params[1] : params;

	}

	function getParameters() {

		parametersNode = getParameterNodes();

		params = [];


		for (node in parametersNode.xmlChildren) {

			param = {
				"name" = node.xmlChildren[1].xmlText,
				"description" = node.XmlChildren[2].xmlText,
				"type" = paramTypeMap[node.xmlName] ?: ""
			};

			if ([
				"hudson.model.StringParameterDefinition",
				"hudson.model.BooleanParameterDefinition",
				"hudson.model.TextParameterDefinition",
				"hudson.model.PasswordParameterDefinition"
			].findNoCase(node.xmlName)) {

				param["defaultValue"] = node.XmlChildren[3].xmlText;

			} else if (["hudson.model.ChoiceParameterDefinition"].findNoCase(node.xmlName)) {

				param["choices"] = [];

				for (choice in node.xmlChildren[3].xmlChildren[1].xmlChildren) {
					param.choices.append(choice.xmlText);
				}

			}

			params.append(param);

		}

		return params;

	}

	function getParameterNodes() {

		configXML = xmlParse(getConfig());

		for (node in configXML.project.XmlChildren) {

			if (node.XmlName EQ "properties") {

				for (node in node.XmlChildren) {

					if (node.XmlName EQ "hudson.model.ParametersDefinitionProperty") {

						for (node in node.XmlChildren) {

							if (node.XmlName EQ "parameterDefinitions") {
								return node;
							}

						}

						return null;

					}

				}

			}

		}


	}

	function updateParameter(name, value) {

		// Update basic parameters

		paramNodes = getParameterNodes();

		results = xmlSearch(paramNodes, "//parameterDefinitions")[1].xmlChildren;

		dump(results);

		for (param in results) {

			if (getParameterName(param) EQ name) {

				if (getMappedParameterType(param) EQ "string") {
					updateStringParameter(name, value);
				}

			}

		}

		dump(paramNodes);

	}

	function getMappedParameterType(any parameter) {

		paramTypeMap = {
			"hudson.model.StringParameterDefinition" = "string",
			"hudson.model.BooleanParameterDefinition" = "boolean",
			"hudson.model.TextParameterDefinition" = "text",
			"hudson.model.ChoiceParameterDefinition" = "choice",
			"hudson.model.PasswordParameterDefinition" = "password"
		};

		if (isXMLElem(parameter)) {
			return paramTypeMap[parameter.xmlName] ?: "";
		} else {
			return paramTypeMap[parameter] ?: "";
		}

	}

	function getParameterName(parameterNode) {
		return parameterNode.xmlChildren[1].xmlName;
	}

	function updateParameterChoices(name, choices) {
		// Update the choices of a choice parameter
	}

	function updateStringParameter(name, value, config = getConfig()) {

		xml = xmlParse(config);
		node = getStringParameterNode(name, xml);
		node.xmlText = value;

		return xml;

	}

	function setDescription(description) {
		variables.description = description;
	}

	function getDescription() {
		return description;
	}

	function loadDescription() {
		http url="#getURL('description')#";
		setDescription(cfhttp.fileContent);
	}

	function saveDescription(description = getDescription()) {

		http url="#getURL('submitDescription')#" method="post" {
			httpparam type="formfield" name="description" value="#description#";
		}

		return cfhttp.status_code EQ "200";

	}

	function parseResult(result) {
		return isXML(result) ? xmlParse(result) : (isJSON(result) ? deserializeJSON(result) : "");
	}

}
