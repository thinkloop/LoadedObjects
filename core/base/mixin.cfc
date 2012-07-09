<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Baz K. (bk@thinkloop.com) - 01/01/2008
Edited By: Baz K. (bk@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">
	
	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="LoadedObjects" type="any" required="true" />
		<cfargument name="LoadedObjectsBOPath" type="string" required="true" />
	
		<cfscript>
			variables.LoadedObjects = arguments.LoadedObjects;
			variables.LoadedObjectsBOPath = arguments.LoadedObjectsBOPath;
		</cfscript>
		
		<cfreturn this />
	</cffunction>	

	<!--- get loaded objects --->
	<cffunction name="getLoadedObjects" access="public" output="false" returntype="any">
		<cfreturn variables.LoadedObjects />
	</cffunction>
	
	<!--- get path --->
	<cffunction name="getPath" access="public" output="false" returntype="string">
		<cfreturn variables.LoadedObjectsBOPath />
	</cffunction>	
	
	<!--- get loaded objects metadata --->
	<cffunction name="getLoadedObjectsMetadata" access="public" output="false" returntype="any">
		<cfargument name="PropertyName" type="string" default="" hint="If no property name is provided, returns metadata for all properties of specified object." />
		<cfargument name="AttributeName" type="string" default="" hint="If no attribute name is provided, returns metadata for all attributes of specified property." />
		<cfreturn variables.LoadedObjects.get(variables.LoadedObjectsBOPath, arguments.PropertyName, arguments.AttributeName) />
	</cffunction>
	
	<!--- exists loaded object metadata --->
	<cffunction name="existsLoadedObjectsMetadata" access="public" output="false" returntype="boolean">
		<cfargument name="PropertyName" type="string" default="" hint="If no property name is provided, returns metadata for all properties of specified object." />
		<cfargument name="AttributeName" type="string" default="" hint="If no attribute name is provided, returns metadata for all attributes of specified property." />
		<cfreturn variables.LoadedObjects.exists(variables.LoadedObjectsBOPath, arguments.PropertyName, arguments.AttributeName) />
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
			var OnMissingMethodFunctions = variables.LoadedObjects.getPlugin('core.Base').getOnMissingMethodFunctions();
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