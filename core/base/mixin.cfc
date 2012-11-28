<cfcomponent output="false">

	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="LoadedObjectsFW" type="any" required="true" hint="Reference to the main LoadedObjects fw instance (i.e. instance of /loadedobjects/loadedobjects.cfc)." />
		<cfargument name="LoadedObjectsBOPath" type="string" required="true" hint="Dot-notation path to the BO being init'ed that LoadedObjects used to look it up." />

		<cfscript>
			variables.LoadedObjects = StructNew();
			variables.LoadedObjects.FW = arguments.LoadedObjectsFW;
			variables.LoadedObjects.BOPath = arguments.LoadedObjectsBOPath;
		</cfscript>

		<cfreturn this />
	</cffunction>

<!--- * * * * * * *--->
<!--- * * CORE * * --->
<!--- * * * * * * *--->

	<!--- get loaded objects --->
	<cffunction name="getLoadedObjects" access="public" output="false" returntype="any">
		<cfreturn variables.LoadedObjects.FW />
	</cffunction>

	<!--- get loaded objects bo path --->
	<cffunction name="getLoadedObjectsBOPath" access="public" output="false" returntype="string">
		<cfreturn variables.LoadedObjects.BOPath />
	</cffunction>

	<!--- new --->
	<cffunction name="new" access="public" output="false" returntype="any" hint="Returns a new empty object of the same type.">
		<cfreturn variables.LoadedObjects.FW.new(getLoadedObjectsBOPath()) />
	</cffunction>

<!--- * * * * * * * * *--->
<!--- * * METADATA * * --->
<!--- * * * * * * * * *--->

	<!--- get loaded objects metadata --->
	<cffunction name="getLoadedObjectsMetadata" access="public" output="false" returntype="any">
		<cfargument name="PropertyName" type="string" default="" hint="If no property name is provided, returns metadata for all properties of specified object." />
		<cfargument name="AttributeName" type="string" default="" hint="If no attribute name is provided, returns metadata for all attributes of specified property." />
		<cfreturn variables.LoadedObjects.FW.get(variables.LoadedObjects.BOPath, arguments.PropertyName, arguments.AttributeName) />
	</cffunction>

	<!--- exists loaded object metadata --->
	<cffunction name="existsLoadedObjectsMetadata" access="public" output="false" returntype="boolean">
		<cfargument name="PropertyName" type="string" default="" hint="If no property name is provided, returns metadata for all properties of specified object." />
		<cfargument name="AttributeName" type="string" default="" hint="If no attribute name is provided, returns metadata for all attributes of specified property." />
		<cfreturn variables.LoadedObjects.FW.exists(variables.LoadedObjects.BOPath, arguments.PropertyName, arguments.AttributeName) />
	</cffunction>


	<!--- get loaded objects child property name --->
	<cffunction name="getLoadedObjectsChildPropertyName" access="public" output="false" returntype="string">
		<cfargument name="ChildPropertyName" type="string" required="true" hint="The name of the child property with its parent object name prepended to it (i.e. Account.ID = AccountID)." />
		<cfreturn variables.LoadedObjects.FW.getChildPropertyName(variables.LoadedObjects.BOPath, arguments.ChildPropertyName) />
	</cffunction>

	<!--- exists loaded objects child property --->
	<cffunction name="existsLoadedObjectsChildProperty" access="public" output="false" returntype="boolean">
		<cfargument name="ChildPropertyName" type="string" required="true" hint="The name of the child property with its parent object name prepended to it (i.e. Account.ID = AccountID)." />
		<cfreturn variables.LoadedObjects.FW.existsChildProperty(variables.LoadedObjects.BOPath, arguments.ChildPropertyName) />
	</cffunction>

	<!--- list loaded objects property name --->
	<cffunction name="listLoadedObjectsPropertyNames" access="public" output="false" returntype="string">
		<cfargument name="FilterByAttributes" type="struct" default="#StructNew()#" hint="A struct of attribute names and values to filter the properties by. A * acts as a wildcard in the string.">
		<cfreturn getLoadedObjectsPlugin('Base').listLoadedObjectsPropertyNames(this, arguments.FilterByAttributes) />
	</cffunction>

<!--- * * * * * * * * --->
<!--- * * PLUGINS * * --->
<!--- * * * * * * * * --->

	<!--- get loaded objects plugin --->
	<cffunction name="getLoadedObjectsPlugin" access="public" output="false" returntype="any">
		<cfargument name="PluginName" type="string" required="true" />
		<cfreturn variables.LoadedObjects.FW.getPlugin(arguments.PluginName) />
	</cffunction>

<!--- * * * * * * * --->
<!--- * * UTILS * * --->
<!--- * * * * * * * --->

	<!--- exists Function --->
	<cffunction name="existsFunction" access="public" output="false" returntype="boolean">
		<cfargument name="FunctionName" type="string" />
		<cfif StructKeyExists(variables, arguments.FunctionName)>
			<cfreturn True />
		<cfelse>
			<cfreturn False />
		</cfif>
	</cffunction>

<!--- * * * * * * * * * * * * * --->
<!--- * * ON MISSING METHOD * * --->
<!--- * * * * * * * * * * * * * --->

	<!--- on missing method: runs onmissingmethods from plugins until it reaches one that returns a value, which is then returned back to the caller. --->
	<cffunction name="onMissingMethod" access="public" output="false" returntype="any">
		<cfargument name="MissingMethodName" type="string" />
		<cfargument name="MissingMethodArguments" type="struct" />

		<cfscript>
			var OnMissingMethodFunctions = '';

			var MissingMethodName = arguments.MissingMethodName;
			var MissingMethodArguments = arguments.MissingMethodArguments;
			var MissingMethodNameLength = Len(MissingMethodName);

			var currentFunctionInstance = '';
			var currentReturnValue = '';

//			var DisplayPrefix = 'display';
//			var DisplayPrefixLength = Len(DisplayPrefix);
		</cfscript>

		<!--- display
		<cfif MissingMethodNameLength gt DisplayPrefixLength AND Left(MissingMethodName, DisplayPrefixLength) is DisplayPrefix>
			<cfset PropertyName = Right(MissingMethodName, MissingMethodNameLength - DisplayPrefixLength) />
			<cfreturn display(PropertyName) />
		</cfif>
		--->

		<!--- loop through all on missing methods from other plugins --->
		<cfset OnMissingMethodFunctions = getLoadedObjectsPlugin('Base').getOnMissingMethodFunctions() />
		<cfloop array="#OnMissingMethodFunctions#" index="currentFunctionInstance">
			<cfset currentReturnValue = currentFunctionInstance(MissingMethodName, MissingMethodArguments) />

			<cfif isDefined('currentReturnValue')>
				<cfreturn currentReturnValue />
			</cfif>
		</cfloop>

		<cfthrow message="The method #UCase(MissingMethodName)# was not found in component #UCase(getLoadedObjectsBOPath())#." />
	</cffunction>
</cfcomponent>