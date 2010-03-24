<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Bassil Karam (bassil.karam@thinkloop.com) - 01/01/2008
Edited By: Bassil Karam (bassil.karam@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">

	<!--- init - this will be run after all plugins have been mixed in, then removed from the final business object --->
	<cffunction name="init" access="public" output="false" returntype="void">
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

	<!--- on missing method service (runs onmissingmethods from plugins until it reaches one that returns a value, which is then returned back to the caller. --->
	<cffunction name="onMissingMethodService" access="public" output="false" returntype="any">
		<cfargument name="MissingMethodName" type="string" />
		<cfargument name="MissingMethodArguments" type="struct" />
		
		<cfscript>
			var OnMissingMethodFunctions=getLoadedObjects().getPlugin('onMissingMethod').getOnMissingMethodFunctions();
			var current=StructNew();
			current.FunctionInstance='';
			current.ReturnValue='';
		</cfscript>

		<cfloop array="#OnMissingMethodFunctions#" index="current.FunctionInstance">
			<cfset current.ReturnValue=current.FunctionInstance(arguments.MissingMethodName, arguments.MissingMethodArguments) />
			<cfif isDefined('current.ReturnValue')>
				<cfreturn current.ReturnValue />
			</cfif>
		</cfloop>

		<!--- maybe throw error here if nothing is returned in the loop? --->
		<cfthrow message="The method #UCase(MissingMethodName)# was not found in component #UCase(getMetaDataObject().getName())#" />
	</cffunction>
	
	<!--- on missing method (this is separate so that users can specify custom onMM functionality in their objects and still refer to the service above) --->
	<cffunction name="onMissingMethod" access="public" output="false" returntype="any">
		<cfargument name="MissingMethodName" type="string" />
		<cfargument name="MissingMethodArguments" type="struct" />

		<cfreturn onMissingMethodService(argumentCollection=arguments) />
	</cffunction>
</cfcomponent>