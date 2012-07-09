<cfcomponent output="false">
	
	<!--- init metadata, plugins --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="ObjectPathPrefix" type="string" default="" hint="A prefix that will be inserted before all ObjectPaths. If all your BOs are in /model/bo then you could provide 'model.bo' here." />
		<cfargument name="PluginsPath" type="string" default="plugins" hint="Optional dot-notation path to plugins folder." />
		
		<cfscript>
			variables.ObjectPathPrefix = '';
			variables.LoadedObjectsMetadata = StructNew();
			variables.LoadedObjectsMetadata.ByPath = StructNew();
			variables.Plugins = StructNew();
			
			if (Len(arguments.ObjectPathPrefix)) {					
				variables.ObjectPathPrefix = arguments.ObjectPathPrefix & '.';
			}
			
			// add base plugin manually because adding the other plugins relies on it
			variables.Plugins['core.base'] = StructNew();
			variables.Plugins['core.base']['Mixin'] = CreateObject('component', 'core.base.mixin');
			variables.Plugins['core.base']['Service'] = CreateObject('component', 'core.base.service').init(this);
			
			// add source data plugin
			addPlugin('core.sourcedata');
		</cfscript>
		
		<cfreturn this />
	</cffunction>
		
	<!--- new --->
	<cffunction name="new" access="public" output="false" returntype="any" hint="Create and return new loaded object.">
		<cfargument name="ObjectPath" type="string" required="true" hint="Dot-path to object excluding the ObjectPathPrefix, unless IgnoreObjectPathPrefix is true." />
		
		<cfscript>
			var BO = '';
			var MetaData = '';
			var currentPlugin = '';
			var ObjectPath = arguments.ObjectPath;
		</cfscript>

		<!--- create object instance --->
		<cfset BO = CreateObject('component', variables.ObjectPathPrefix & ObjectPath) />

		<cfif not exists(ObjectPath)>
			<cfset addLoadedObject(BO) />
		</cfif>

		<!--- mixin plugins --->
		<cfscript>
			StructInsert(BO, 'mixinPlugin_LoadedObjects_278956238479', variables.mixin, true);
			BO.mixinPlugin_LoadedObjects_278956238479(this, ObjectPath, variables.Plugins);
			StructDelete(BO, 'mixinPlugin_LoadedObjects_278956238479');
		</cfscript>
		
		<!--- return new object --->
		<cfreturn BO />
	</cffunction>
	
	<!--- add loaded object --->
	<cffunction name="addLoadedObject" access="public" output="false" returntype="any">
		<cfargument name="BO" type="any" required="true" hint="The business object to parse/add." />
	
		<cfscript>
			var BO = arguments.BO;
			var BOMetadata = GetMetaData(BO);
			
			var currentPropertyIndex = '';
			var currentProperty = '';
			var currentAttributeName='';
			
			var LoadedObjectsMetaData = StructNew();
			var LoadedObjectsProperties = StructNew();
			
			LoadedObjectsMetaData.Name = ListLast(BOMetadata.Name, '.');
			LoadedObjectsMetaData.Path = BOMetadata.Name; // (i.e. objects.account)
			LoadedObjectsMetaData.FilePath = BOMetadata.Path; // (i.e. d:\web\objects\account.cfc)
			LoadedObjectsMetaData.Position = StructCount(variables.LoadedObjectsMetadata.ByPath) + 1;
			
			// display name
			LoadedObjectsMetaData.DisplayName = LoadedObjectsMetaData.Name;
			if (StructKeyExists(BOMetadata, 'DisplayName')) {
				LoadedObjectsMetaData.DisplayName = BOMetadata.DisplayName;
			}
		</cfscript>
	
		<!--- loop through properties and set metdata --->
		<cfif StructKeyExists(BOMetadata, 'Properties') AND isArray(BOMetadata.Properties)>
			<cfloop from="1" to="#ArrayLen(BOMetadata.Properties)#" index="currentPropertyIndex">
				<cfscript>
					currentProperty = BOMetadata.Properties[currentPropertyIndex];
					
					// add default attributes to metadata
					LoadedObjectsProperties[currentProperty.Name] = StructNew();
					LoadedObjectsProperties[currentProperty.Name]['Name'] = currentProperty.Name;
					LoadedObjectsProperties[currentProperty.Name]['DisplayName'] = currentProperty.Name;
					LoadedObjectsProperties[currentProperty.Name]['Type'] = 'string';
					// LoadedObjectsProperties[currentProperty.Name]['Default'] = ''; // 'default' is a basic attribute but we leave it blank to see later whether the user has set it
					LoadedObjectsProperties[currentProperty.Name]['NullValue'] = '';
					LoadedObjectsProperties[currentProperty.Name]['Position'] = currentPropertyIndex;
					//LoadedObjectsProperties[currentProperty.Name]['ReadOnly'] = False;
				</cfscript>
				
				<!--- loop through and add real attributes, possibly overriding defaults set above --->
				<cfloop collection="#currentProperty#" item="currentAttributeName">
					<cfset LoadedObjectsProperties[currentProperty.Name][currentAttributeName] = currentProperty[currentAttributeName] />
				</cfloop>

				<!--- check for relationship to another object
				<cfif ListFindNoCase(StructKeyList(arguments.BusinessObjects), MetadataProperties.get('Type'))>
					<cfset MetadataProperties.setAttribute('LoadedObjectsType', MetadataProperties.get('Type')) />
				</cfif>
				--->
			</cfloop>
		</cfif>

		<!--- add to metadata collections --->
		<cfscript>
			LoadedObjectsMetaData.Properties = LoadedObjectsProperties;
			variables.LoadedObjectsMetadata.ByPath[LoadedObjectsMetaData.Path] = LoadedObjectsMetaData;
		</cfscript>

		<cfreturn LoadedObjectsMetaData />
	</cffunction>
	
	<!--- get loaded object metadata --->
	<cffunction name="get" access="public" output="false" returntype="any" hint="May return a struct, or may return another object type if AttributeName is specified">
		<cfargument name="ObjectPath" type="string" default="" hint="If no object name is provided, returns metadata for all objects." />
		<cfargument name="PropertyName" type="string" default="" hint="If no property name is provided, returns metadata for all properties of specified object." />
		<cfargument name="AttributeName" type="string" default="" hint="If no attribute name is provided, returns metadata for all attributes of specified property." />
		
		<cfscript>
			var ObjectPath = arguments.ObjectPath;
			var ObjectPathPlusPrefix = variables.ObjectPathPrefix & ObjectPath;
			var PropertyName = arguments.PropertyName;
			var AttributeName = arguments.AttributeName;
			var ObjectType = '';
		</cfscript>
				
		<cfif Len(ObjectPath)>
			<cfif Len(PropertyName)>
				<cfif Len(AttributeName)>
					
					<!--- if this is not the special 'default' attribute, return its value --->
					<cfif AttributeName neq 'Default'>
						<cfreturn variables.LoadedObjectsMetadata.ByPath[ObjectPathPlusPrefix]['Properties'][PropertyName][AttributeName] />
					</cfif>
					
					<!--- if default value exists, return it --->
					<cfif exists(ObjectPath, PropertyName, 'Default')>
						<cfreturn variables.LoadedObjectsMetadata.ByPath[ObjectPathPlusPrefix]['Properties'][PropertyName]['Default'] />
					</cfif>
					
					<!--- figure out default from type --->
					<cfset ObjectType = get(ObjectPath, PropertyName, 'Type') />
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
				<cfreturn variables.LoadedObjectsMetadata.ByPath[ObjectPathPlusPrefix]['Properties'][PropertyName] />
			</cfif>
			<cfreturn variables.LoadedObjectsMetadata.ByPath[ObjectPathPlusPrefix] />
		</cfif>
		
		<cfreturn variables.LoadedObjectsMetadata.ByPath />
	</cffunction>
	
	<!--- exists loaded object metadata --->
	<cffunction name="exists" access="public" output="false" returntype="boolean">
		<cfargument name="ObjectPath" type="string" default="" hint="If no object name is provided, returns metadata for all objects." />
		<cfargument name="PropertyName" type="string" default="" hint="If no property name is provided, returns metadata for all properties of specified object." />
		<cfargument name="AttributeName" type="string" default="" hint="If no attribute name is provided, returns metadata for all attributes of specified property." />
		
		<cfset var collection = variables.LoadedObjectsMetadata.ByPath />
		<cfset var ObjectPath = variables.ObjectPathPrefix & arguments.ObjectPath />
				
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
				
		<!--- attribute name--->
		<cfif not StructKeyExists(collection, arguments.AttributeName)>
			<cfreturn false />
		<cfelse>
			<cfreturn true />
		</cfif>
	</cffunction>
		
	<!--- get plugin --->
	<cffunction name="getPlugin" access="public" output="false" returntype="any">
		<cfargument name="PluginName" type="string" required="true" />
		<cfreturn variables.Plugins[arguments.PluginName]['Service'] />
	</cffunction>
	
	<!--- add plugin --->
	<cffunction name="addPlugin" access="public" output="false" returntype="any">
		<cfargument name="PluginPath" type="string" required="true" />
		<cfscript>
			var PluginPath = arguments.PluginPath;
			
			variables.Plugins[PluginPath] = StructNew();
			variables.Plugins[PluginPath]['Mixin'] = CreateObject('component', PluginPath & '.mixin');
			variables.Plugins[PluginPath]['Service'] = CreateObject('component', PluginPath & '.service').init(this);
			
			// check for OnMissingMethod and add it to cache and delete it from mixin
			if (StructKeyExists(variables.Plugins[PluginPath]['Mixin'], 'OnMissingMethod')) {
				getPlugin('core.Base').addOnMissingMethodFunction(variables.Plugins[PluginPath]['Mixin']['OnMissingMethod']);
			}
		</cfscript>	
		<cfreturn this />
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
						if (currentPluginName neq 'core.Base') {
							ArrayAppend(inits, currentMixin[currentFunctionMetaData.Name]);
						}
						
						// if this is Base, run init now
						else {
							onMMinit = currentMixin[currentFunctionMetaData.Name];
						}
					</cfscript>
					
				<!--- if function is onMissingMethod, don't mix it unless it's from base --->
				<cfelseif currentFunctionMetaData.Name is 'onMissingMethod' AND currentPluginName neq 'core.Base'>
										
				<!--- otherwise mix it in without overwriting user defined functions with the same names) --->
				<cfelse>
					<cfscript>
						StructInsert(this, currentFunctionMetaData.Name, currentMixin[currentFunctionMetaData.Name], false);
						StructInsert(variables, currentFunctionMetaData.Name, currentMixin[currentFunctionMetaData.Name], false);
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
	
	<!--- inject (NOT VERY USEFUL BECAUSE MIXIN() ITSELF NEEDS TO USE IT, WHICH MEANS THIS HAS TO BE MIXED IN ITSELF ANYWAY)
	<cffunction name="inject" access="public" returntype="void" hint="Temporarily injects and runs a mixin into an object">
		<cfargument name="LoadedObject" type="any" required="true" hint="Instance of the object into which the MixinFunction will be injected." />
		<cfargument name="MixinFunction" type="any" required="true" hint="Instance of the function that will be injected into LoadedObject." />
		<cfargument name="Overwrite" type="boolean" default="true" />
		<cfargument name="Args" type="struct" default="" hint="Optional argument collection to pass into MixinFunction." />
		
		<cfscript>
			StructInsert(LoadedObject, 'mixinFunction_LoadedObjects_278956238479_VFSDGGHJLSDVASD', arguments.MixinFunction, arguments.Overwrite);
			LoadedObject.mixinFunction_LoadedObjects_278956238479_VFSDGGHJLSDVASD(argumentCollection = arguments.Args);
			StructDelete(LoadedObject, 'mixinFunction_LoadedObjects_278956238479_VFSDGGHJLSDVASD');				
		</cfscript>
	</cffunction>	
	--->
</cfcomponent>