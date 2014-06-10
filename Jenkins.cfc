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
		return config;
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

	function getParameter(name, scope = "one") {

		parameters = getParameters();
		params = [];

		for (param in parameters) {
			// We check all because there might be more than one param with the same name
			if (param.name EQ name) {
				if (scope EQ "one") {
					return param;
				} else {
					params.append(param);
				}
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
				"type" = getMappedParameterType(node) ?: ""
			};

			if ([
				"string",
				"boolean",
				"text",
				"password"
			].findNoCase(param.type)) {

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

	function getParameterNodes(config = xmlParse(getConfig())) {

		for (node in config.project.XmlChildren) {

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

	function updateParameter(name, any value, scope = "one") {

		// Update basic parameters

		config = config = xmlParse(variables.config);

		nodes = xmlSearch(
			getParameterNodes(config),
			"//parameterDefinitions"
		)[1].xmlChildren;

		for (node in nodes) {

			if (getParameterName(node) EQ name) {

				if (["string", "boolean", "text", "password"].find(getMappedParameterType(node))) {

					node.xmlChildren[3].xmlText = value;

					if (scope EQ "one") {
						break;
					}

				} else if (getMappedParameterType(node) EQ "choice") {

					choiceElements = node.xmlChildren[3].xmlChildren[1].xmlChildren;

					// FOR NOW: Three choices, three changes
					// TODO: Need to remove all choices and add new ones
					// MAYBE: xmlElemNew() is the way to do it
					choiceElements.each(function(choiceElement, i) {
						choiceElement.xmlText = value[i];
					});

				}

			}

		}

		setConfig(config);

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

	function getParameterName(node) {
		return node.xmlChildren[1].xmlText;
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
