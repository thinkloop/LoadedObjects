<cfcomponent output="false">

	<!--- init metadata, plugins --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="ObjectPathPrefix" type="string" default="" hint="A prefix that will be inserted before all ObjectPaths. If all your BOs are in /model/bo then you could provide 'model.bo' here." />
		<cfargument name="PluginsPath" type="string" default="loadedobjects.plugins" hint="Dot-notation path to plugins folder relative to root." />

		<cfscript>
			var PluginsPath = Trim(arguments.PluginsPath);

			// get the absolute path of the plugins folder from the provided dot-notation path
			var PluginsPathAbsolute = ExpandPath(Replace(PluginsPath, '.', '/', 'all'));

			// read plugin sub-folder names from the file-system
			var PluginsFolderNames = DirectoryList(PluginsPathAbsolute, false, 'name');
			var currentIndex = 0;

			variables.ObjectPathPrefix = '';
			variables.LoadedObjectsMetadata = StructNew();
			variables.LoadedObjectsMetadata.ByPath = StructNew();
			variables.Plugins = StructNew();

			if (Len(arguments.ObjectPathPrefix)) {
				variables.ObjectPathPrefix = arguments.ObjectPathPrefix & '.';
			}

			// add base plugin manually because other plugins depend on it
			variables.Plugins['base'] = StructNew();
			variables.Plugins['base']['Mixin'] = CreateObject('component', 'core.base.mixin');
			variables.Plugins['base']['Service'] = CreateObject('component', 'core.base.service').init(this);

			// add collection plugin manually
			addPlugin('core.collection');

			// add source data plugin manually
			addPlugin('core.rawdata');
		</cfscript>

		<!--- loop through plugin subfolders and add each as a plugin --->
		<cfloop from="1" to="#ArrayLen(PluginsFolderNames)#" index="currentIndex">
			<cfset addPlugin(PluginsPath & '.' & PluginsFolderNames[ListFirst(currentIndex, '.')]) />
		</cfloop>

		<cfreturn this />
	</cffunction>

	<!--- new --->
	<cffunction name="new" access="public" output="false" returntype="any" hint="Create and return new loaded object.">
		<cfargument name="ObjectName" type="string" required="true" hint="The name of the business object (aka. the object-path minus any defined path-prefix)." />

		<cfscript>
			var BO = '';
			var MetaData = '';
			var currentPlugin = '';
			var ObjectName = arguments.ObjectName;
		</cfscript>

		<!--- create object instance --->
		<cfset BO = CreateObject('component', variables.ObjectPathPrefix & ObjectName) />

		<cfif not exists(ObjectName)>
			<cfset addLoadedObjectMetadata(BO) />
		</cfif>

		<!--- mixin plugins --->
		<cfscript>
			StructInsert(BO, 'mixinPlugin_LoadedObjects_278956238479', variables.mixin, true);
			BO.mixinPlugin_LoadedObjects_278956238479(this, ObjectName, variables.Plugins);
			StructDelete(BO, 'mixinPlugin_LoadedObjects_278956238479');
		</cfscript>

		<!--- return new object --->
		<cfreturn BO />
	</cffunction>

	<!--- get loaded object metadata --->
	<cffunction name="get" access="public" output="false" returntype="any" hint="Get an element from the metadata tree.">
		<cfargument name="ObjectName" type="string" default="" hint="The name of the business object (aka. the object-path minus any defined path-prefix). If no object name is provided, returns metadata for all objects." />
		<cfargument name="PropertyName" type="string" default="" hint="If no property name is provided, returns metadata for all properties of specified object." />
		<cfargument name="AttributeName" type="string" default="" hint="If no attribute name is provided, returns metadata for all attributes of specified property." />

		<cfscript>
			var LoadedObjectsMetadata = variables.LoadedObjectsMetadata.ByPath;
			var ObjectName = arguments.ObjectName;
			var ObjectPath = variables.ObjectPathPrefix & ObjectName;
			var PropertyName = arguments.PropertyName;
			var AttributeName = arguments.AttributeName;
			var ObjectType = '';
		</cfscript>

		<cfif Len(ObjectName)>
			<cfif Len(PropertyName)>
				<cfif Len(AttributeName)>

					<!--- if this is not the special 'default' attribute, return its value --->
					<cfif AttributeName neq 'Default'>
						<cfreturn LoadedObjectsMetadata[ObjectPath]['Properties'][PropertyName][AttributeName] />
					</cfif>

					<!--- if default value exists, return it --->
					<cfif StructKeyExists(LoadedObjectsMetadata[ObjectPath]['Properties'][PropertyName], 'Default')>
						<cfreturn LoadedObjectsMetadata[ObjectPath]['Properties'][PropertyName]['Default'] />
					</cfif>

					<!--- figure out default from type --->
					<cfset ObjectType = get(ObjectName, PropertyName, 'Type') />
					<cfswitch expression="#ObjectType#">
						<cfcase value="string,any,binary,variableName">
							<cfreturn '' />
						</cfcase>
						<cfcase value="numeric">
							<cfreturn 0 />
						</cfcase>
						<cfcase value="boolean">
							<cfreturn false />
						</cfcase>
						<cfcase value="date">
							<cfreturn '' />
						</cfcase>
						<cfcase value="struct">
							<cfreturn StructNew() />
						</cfcase>
						<cfcase value="array">
							<cfreturn ArrayNew(1) />
						</cfcase>
						<cfcase value="query">
							<cfreturn QueryNew('') />
						</cfcase>
						<cfcase value="uuid,guid">
							<cfreturn CreateUUID() />
						</cfcase>

						<!--- if nothing else matches, this must be a path to a cfc --->
						<cfdefaultcase>
							<cfreturn new(ObjectType) />
						</cfdefaultcase>
					</cfswitch>
				</cfif>
				<cfreturn LoadedObjectsMetadata[ObjectPath]['Properties'][PropertyName] />
			</cfif>
			<cfreturn LoadedObjectsMetadata[ObjectPath] />
		</cfif>

		<cfreturn LoadedObjectsMetadata />
	</cffunction>

	<!--- set loaded object metadata --->
	<cffunction name="set" access="public" output="false" returntype="any" hint="Set an element of the metadata tree.">
		<cfargument name="ObjectName" type="string" required="true" hint="The name of the business object (aka. the object-path minus any defined path-prefix)." />
		<cfargument name="PropertyName" type="string" required="true" />
		<cfargument name="AttributeName" type="string" required="true" />
		<cfargument name="Value" type="any" required="true" />

		<cfscript>
			var LoadedObjectsMetadata = variables.LoadedObjectsMetadata.ByPath;
			var ObjectName = arguments.ObjectName;
			var ObjectPath = variables.ObjectPathPrefix & ObjectName;
			var PropertyName = arguments.PropertyName;
			var AttributeName = arguments.AttributeName;
			var Value = arguments.Value;

			if (not exists(ObjectName, PropertyName, AttributeName)) {
				new(ObjectName);
			}

			LoadedObjectsMetadata[ObjectPath]['Properties'][PropertyName][AttributeName] = Value;
		</cfscript>

		<cfreturn this />
	</cffunction>

	<!--- exists loaded object metadata --->
	<cffunction name="exists" access="public" output="false" returntype="boolean">
		<cfargument name="ObjectName" type="string" default="" hint="The name of the business object (aka. the object-path minus any defined path-prefix). If none is provided, returns metadata for all objects." />
		<cfargument name="PropertyName" type="string" default="" hint="If no property name is provided, returns metadata for all properties of specified object." />
		<cfargument name="AttributeName" type="string" default="" hint="If no attribute name is provided, returns metadata for all attributes of specified property." />

		<cfset var collection = variables.LoadedObjectsMetadata.ByPath />
		<cfset var ObjectPath = variables.ObjectPathPrefix & arguments.ObjectName />

		<!--- object path --->
		<cfif not StructKeyExists(collection, ObjectPath)>
			<cfreturn false />
		<cfelseif not Len(arguments.PropertyName)>
			<cfreturn true />
		<cfelse>
			<cfset collection = collection[ObjectPath]['Properties'] />
		</cfif>

		<!--- property name--->
		<cfif not StructKeyExists(collection, arguments.PropertyName)>
			<cfreturn false />
		<cfelseif not Len(arguments.AttributeName)>
			<cfreturn true />
		<cfelse>
			<cfset collection = collection[arguments.PropertyName] />
		</cfif>

		<!--- attribute name - the attribute 'default' is special and should always return true --->
		<cfif arguments.AttributeName is 'Default' OR StructKeyExists(collection, arguments.AttributeName)>
			<cfreturn true />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>

	<!--- get child property name --->
	<cffunction name="getChildPropertyName" access="public" output="false" returntype="string">
		<cfargument name="ObjectName" type="string" required="true" hint="The name of the parent object that has a property that is a child object with its own properties." />
		<cfargument name="ChildPropertyName" type="string" required="true" hint="The name of the child property with its parent object name prepended to it (i.e. Account.ID = AccountID)." />

		<cfscript>
			var ObjectPath = variables.ObjectPathPrefix & arguments.ObjectName;
			var ChildPropertyName = arguments.ChildPropertyName;
			var ChildPropertyNames = variables.LoadedObjectsMetadata.ByPath[ObjectPath].ChildPropertyNames;
		</cfscript>

		<cfreturn ChildPropertyNames[ChildPropertyName] />
	</cffunction>

	<!--- exists child property --->
	<cffunction name="existsChildProperty" access="public" output="false" returntype="boolean">
		<cfargument name="ObjectName" type="string" default="" hint="The name of the parent object that has a property that is a child object with its own properties." />
		<cfargument name="ChildPropertyName" type="string" required="true" hint="The name of the child property with its parent object name prepended to it (i.e. Account.ID = AccountID)." />

		<cfscript>
			var ObjectPath = variables.ObjectPathPrefix & arguments.ObjectName;
			var ChildPropertyName = arguments.ChildPropertyName;
			var ChildPropertyNames = variables.LoadedObjectsMetadata.ByPath[ObjectPath].ChildPropertyNames;
		</cfscript>

		<cfreturn StructKeyExists(ChildPropertyNames, ChildPropertyName) />
	</cffunction>

	<!--- add plugin --->
	<cffunction name="addPlugin" access="public" output="false" returntype="any">
		<cfargument name="PluginPath" type="string" required="true" />
		<cfscript>
			var PluginPath = arguments.PluginPath;
			var PluginName = ListLast(PluginPath, '.');

			variables.Plugins[PluginName] = StructNew();
			variables.Plugins[PluginName]['Mixin'] = CreateObject('component', PluginPath & '.mixin');
			variables.Plugins[PluginName]['Service'] = CreateObject('component', PluginPath & '.service').init(this);

			// check for OnMissingMethod and add it to cache and delete it from mixin
			if (StructKeyExists(variables.Plugins[PluginName]['Mixin'], 'OnMissingMethod')) {
				getPlugin('Base').addOnMissingMethodFunction(variables.Plugins[PluginName]['Mixin']['OnMissingMethod']);
			}
		</cfscript>
		<cfreturn this />
	</cffunction>

	<!--- get plugin --->
	<cffunction name="getPlugin" access="public" output="false" returntype="any">
		<cfargument name="PluginName" type="string" required="true" />
		<cfreturn variables.Plugins[arguments.PluginName]['Service'] />
	</cffunction>

<!--- * * * * * * * * --->
<!--- * * PRIVATE * * --->
<!--- * * * * * * * * --->

	<!--- add loaded object --->
	<cffunction name="addLoadedObjectMetadata" access="private" output="false" returntype="any" hint="Use new() to add an object instead of this function.">
		<cfargument name="BO" type="any" required="true" hint="The business object to parse and add." />

		<cfscript>
			var BO = arguments.BO;
			var BOMetadata = GetMetaData(BO);

			var currentPropertyIndex = '';
			var currentProperty = '';
			var currentAttributeName = '';

			var currentChildPropertyIndex = '';
			var currentChildProperty = '';

			var ObjectMetadata = StructNew();
			var Properties = StructNew();
			var ChildPropertyNames = StructNew();
			var ChildObjectMetadata = '';

			ObjectMetadata.Name = ListLast(BOMetadata.Name, '.');
			ObjectMetadata.Path = BOMetadata.Name; // (i.e. objects.account)
			ObjectMetadata.FilePath = BOMetadata.Path; // (i.e. d:\web\objects\account.cfc)
			ObjectMetadata.Position = StructCount(variables.LoadedObjectsMetadata.ByPath) + 1;

			if (StructKeyExists(BOMetadata, 'DisplayName')) {
				ObjectMetadata.DisplayName = BOMetadata.DisplayName;
			}
			else {
				ObjectMetadata.DisplayName = ObjectMetadata.Name;
			}

			// display name
			ObjectMetadata.DisplayName = ObjectMetadata.Name;
			if (StructKeyExists(BOMetadata, 'DisplayName')) {
				ObjectMetadata.DisplayName = BOMetadata.DisplayName;
			}
		</cfscript>

		<!--- loop through properties and set metdata --->
		<cfif StructKeyExists(BOMetadata, 'Properties') AND isArray(BOMetadata.Properties)>
			<cfloop from="1" to="#ArrayLen(BOMetadata.Properties)#" index="currentPropertyIndex">
				<cfscript>
					currentProperty = BOMetadata.Properties[currentPropertyIndex];

					// add default attributes to metadata
					Properties[currentProperty.Name] = StructNew();
					Properties[currentProperty.Name]['Name'] = currentProperty.Name;
					Properties[currentProperty.Name]['DisplayName'] = currentProperty.Name;
					Properties[currentProperty.Name]['Type'] = 'string';
					// Properties[currentProperty.Name]['Default'] = ''; // 'default' is a basic attribute but we leave it blank to see later whether the user has set it
					Properties[currentProperty.Name]['NullValue'] = '';
					Properties[currentProperty.Name]['Position'] = currentPropertyIndex;
					//Properties[currentProperty.Name]['ReadOnly'] = False;
					Properties[currentProperty.Name]['IsObject'] = False;
				</cfscript>

				<!--- loop through and add real attributes, possibly overriding defaults set above --->
				<cfloop collection="#currentProperty#" item="currentAttributeName">
					<cfset Properties[currentProperty.Name][currentAttributeName] = currentProperty[currentAttributeName] />
				</cfloop>

				<!--- check if this property points to another object --->
				<cfswitch expression="#Properties[currentProperty.Name]['Type']#">
					<cfcase value="">
						<cfset Properties[currentProperty.Name]['Type'] = "String" />
					</cfcase>
					<cfcase value="string,any,binary,variableName,uuid,guid"></cfcase>
					<cfcase value="numeric,boolean,date"></cfcase>
					<cfcase value="struct,array,query"></cfcase>
					<cfdefaultcase>
						<cfset Properties[currentProperty.Name]['IsObject'] = true />

						<!--- get child object metadata (also creates it if it does not exist) --->
						<cfset ChildObjectMetadata = getMetadata(CreateObject('component', variables.ObjectPathPrefix & Properties[currentProperty.Name]['Type'])) />

						<!--- set child properties by prepending the child object name to each property name (i.e. Account.ID >> AccountID) --->
						<cfloop from="1" to="#ArrayLen(ChildObjectMetadata.Properties)#" index="currentChildPropertyIndex">
							<cfscript>
								currentChildProperty = ChildObjectMetadata.Properties[currentChildPropertyIndex];
								ChildPropertyNames[currentProperty.Name & currentChildProperty.Name] = currentChildProperty.Name;
							</cfscript>
						</cfloop>
					</cfdefaultcase>
				</cfswitch>
			</cfloop>
		</cfif>

		<!--- add to metadata collections --->
		<cfscript>
			ObjectMetadata.Properties = Properties;
			ObjectMetadata.ChildPropertyNames = ChildPropertyNames;
			variables.LoadedObjectsMetadata.ByPath[ObjectMetadata.Path] = ObjectMetadata;
		</cfscript>

		<cfreturn ObjectMetadata />
	</cffunction>

<!--- * * * * * * * --->
<!--- * * MIXIN * * --->
<!--- * * * * * * * --->

	<!--- mixin --->
	<cffunction name="mixin" access="public" returntype="void" hint="I will be mixed into another object and run in the context of that object.">
		<cfargument name="LoadedObjects" type="any" required="true" />
		<cfargument name="LoadedObjectsPath" type="string" required="true" />
		<cfargument name="Plugins" type="struct" required="true" />

		<cfscript>
			var Plugins = arguments.Plugins;
			var currentPluginName = '';
			var currentPlugin = '';
			var currentMixin = '';
			var currentFunctionMetaData = '';
			var currentInit = '';
			var ObjectPath = arguments.LoadedObjectsPath;
			var inits = ArrayNew(1);
			var onMMinit = '';
		</cfscript>

		<!--- loop through each mixin --->
		<cfloop collection="#Plugins#" item="currentPluginName">
			<cfscript>
				currentPlugin = Plugins[currentPluginName];
				currentMixin = currentPlugin.Mixin;
			</cfscript>

			<!--- loop through functions --->
			<cfloop array="#getMetaData(currentMixin).functions#" index="currentFunctionMetaData">

				<!--- if function is init, don't mix it in, save it to run later --->
				<cfif currentFunctionMetaData.Name is 'init'>
					<cfscript>

						// if this is not Base, save init to run later
						if (currentPluginName neq 'Base') {
							ArrayAppend(inits, currentMixin[currentFunctionMetaData.Name]);
						}

						// if this is Base, run init now
						else {
							onMMinit = currentMixin[currentFunctionMetaData.Name];
						}
					</cfscript>

				<!--- if function is onMissingMethod, don't mix it unless it's from base --->
				<cfelseif currentFunctionMetaData.Name is 'onMissingMethod' AND currentPluginName neq 'Base'>

				<!--- otherwise mix it in without overwriting user defined functions with the same names) --->
				<cfelse>
					<cfscript>
						if (not StructKeyExists(this, currentFunctionMetaData.Name) AND not StructKeyExists(variables, currentFunctionMetaData.Name)) {
							StructInsert(this, currentFunctionMetaData.Name, currentMixin[currentFunctionMetaData.Name], false);
							StructInsert(variables, currentFunctionMetaData.Name, currentMixin[currentFunctionMetaData.Name], false);
						}
					</cfscript>
				</cfif>
			</cfloop>
		</cfloop>

		<!--- run all cached inits (with OnMissingMethod first) --->
		<cfset ArrayPrepend(inits, onMMinit) />
		<cfloop array="#inits#" index="currentInit">
			<cfscript>
				StructInsert(variables, 'init_LoadedObjects1133557799AAQAASXMMHGFDADSF', currentInit);
				init_LoadedObjects1133557799AAQAASXMMHGFDADSF(arguments.LoadedObjects, arguments.LoadedObjectsPath);
				StructDelete(variables, 'init_LoadedObjects1133557799AAQAASXMMHGFDADSF');
			</cfscript>
		</cfloop>
	</cffunction>
</cfcomponent>