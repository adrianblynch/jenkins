component {

	config = "";

	function init(username, token, serverURL, projectName) {
		variables.username = username;
		variables.token = token;
		variables.serverURL = reReplaceNoCase(serverURL, "(https?://)", "\1#username#:#token#@");
		if (NOT isNull(projectName)) {
			setProjectName(projectName);
		}
		return this;
	}

	function setProjectName(projectName) {
		variables.projectName = projectName;
		return this;
	}

	function getProjectName() {
		return variables.projectName;
	}

	function setConfig(config) {
		variables.config = isXML(config) ? toString(config) : config;
		return this;
	}

	function getConfig() {
		return config;
	}

	function loadConfig() {
		http url="#getURL('config.xml')#";
		setConfig(cfhttp.fileContent);
		return cfhttp.status_code EQ 200;
	}

	function saveConfig() {

		http url="#getURL('config.xml')#" method="post" {
			httpparam type="body" value="#getConfig()#";
		}

		return cfhttp.status_code EQ 200;

	}

	function getURL(path) {
		return "#variables.serverURL#/job/#variables.projectName#/#path#";
	}

	function build() {
		http url="#getURL('build')#";
		return isBuildSuccessful(cfhttp.status_code);
	}

	function buildWithParameters(params = []) {

		http url="#getURL('buildWithParameters')#" {

			for (param in params) {
				key = param.keyArray()[1];
				value = param[key];
				httpparam type="url" name="#key#" value="#value#";
			}

		}

		return isBuildSuccessful(cfhttp.status_code);

	}

	function isBuildSuccessful(statusCode) {
		// NOTE: Since 1.519 201 is returned instead of 302 for a successfully created job
		return [201, 302].find(statusCode) GT 0;
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

	function getParameters(type) {

		params = [];

		for (node in getParameterNodes().xmlChildren) {

			nodeType = getMappedParameterType(node) ?: "";

			if (isNull(type) OR (NOT isNull(type) AND type EQ nodeType)) {

				param = {
					"name" = node.xmlChildren[1].xmlText,
					"description" = node.XmlChildren[2].xmlText,
					"type" = nodeType
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

	function updateDescription(description) {
		config = xmlParse(getConfig());
		config.project.description.xmlText = description;
		setConfig(config);
		return this;
	}

	function getDescription() {
		return xmlParse(config).project.description.xmlText;
	}

	function saveDescription(description = getDescription()) {

		http url="#getURL('submitDescription')#" method="post" {
			httpparam type="formfield" name="description" value="#description#";
		}

		return cfhttp.status_code EQ "200";

	}

}
