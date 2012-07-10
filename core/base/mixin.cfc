<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Baz K. (bk@thinkloop.com) - 01/01/2008
Edited By: Baz K. (bk@thinkloop.com) - 07/06/2008
* * --->
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

	<!--- get loaded objects --->
	<cffunction name="getLoadedObjects" access="public" output="false" returntype="any">
		<cfreturn variables.LoadedObjects.FW />
	</cffunction>
	
	<!--- get loaded objects name --->
	<cffunction name="getLoadedObjectsBOPath" access="public" output="false" returntype="string">
		<cfreturn variables.LoadedObjects.BOPath />
	</cffunction>	
	
	<!--- get loaded objects metadata --->
	<cffunction name="getLoadedObjectsMetadata" access="public" output="false" returntype="any">
		<cfargument name="PropertyName" type="string" default="" hint="If no property name is provided, returns metadata for all properties of specified object." />
		<cfargument name="AttributeName" type="string" default="" hint="If no attribute name is provided, returns metadata for all attributes of specified property." />
		<cfreturn variables.LoadedObjects.FW.get(variables.LoadedObjects.BOPath, arguments.PropertyName, arguments.AttributeName) />
	</cffunction>
	
	<!--- list loaded objects property name --->
	<cffunction name="listLoadedObjectsPropertyNames" access="public" output="false" returntype="string">
		<cfreturn StructKeyList(getLoadedObjectsMetadata().Properties) />
	</cffunction>	
	
	<!--- exists loaded object metadata --->
	<cffunction name="existsLoadedObjectsMetadata" access="public" output="false" returntype="boolean">
		<cfargument name="PropertyName" type="string" default="" hint="If no property name is provided, returns metadata for all properties of specified object." />
		<cfargument name="AttributeName" type="string" default="" hint="If no attribute name is provided, returns metadata for all attributes of specified property." />
		<cfreturn variables.LoadedObjects.FW.exists(variables.LoadedObjects.BOPath, arguments.PropertyName, arguments.AttributeName) />
	</cffunction>
	
	<!--- get loaded objects plugin --->
	<cffunction name="getLoadedObjectsPlugin" access="public" output="false" returntype="any">
		<cfargument name="PluginName" type="string" required="true" />
		<cfreturn variables.LoadedObjects.FW.getPlugin(arguments.PluginName) />
	</cffunction>	
	
	
	<!--- exists Function --->
	<cffunction name="existsFunction" access="public" output="false" returntype="boolean">
		<cfargument name="FunctionName" type="string" />
		<cfif StructKeyExists(variables, arguments.FunctionName)>
			<cfreturn True />
		<cfelse>
			<cfreturn False />
		</cfif>
	</cffunction>

	<!--- on missing method (this is separate so that users can specify custom OMM functionality in their objects and still refer to the service above) --->
	<cffunction name="onMissingMethod" access="public" output="false" returntype="any">
		<cfargument name="MissingMethodName" type="string" />
		<cfargument name="MissingMethodArguments" type="struct" />

		<cfreturn doOnMissingMethod(argumentCollection = arguments) />
	</cffunction>
	
	<!--- do on missing method: runs onmissingmethods from plugins until it reaches one that returns a value, which is then returned back to the caller. --->
	<cffunction name="doOnMissingMethod" access="public" output="false" returntype="any">
		<cfargument name="MissingMethodName" type="string" />
		<cfargument name="MissingMethodArguments" type="struct" />
		
		<cfscript>
			var OnMissingMethodFunctions = variables.LoadedObjects.FW.getPlugin('Base').getOnMissingMethodFunctions();
			var current=StructNew();
			current.FunctionInstance='';
			current.ReturnValue='';
		</cfscript>

		<cfloop array="#OnMissingMethodFunctions#" index="current.FunctionInstance">
			<cfset current.ReturnValue = current.FunctionInstance(arguments.MissingMethodName, arguments.MissingMethodArguments) />
		
			<cfif isDefined('current.ReturnValue')>
				<cfreturn current.ReturnValue />
			</cfif>
		</cfloop>

		<cfthrow message="The method #UCase(MissingMethodName)# was not found." />
	</cffunction>
</cfcomponent>