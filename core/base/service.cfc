<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Baz K. (bk@thinkloop.com) - 01/01/2008
Edited By: Baz K. (bk@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">

	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfset variables.OnMissingMethodFunctions = ArrayNew(1) />
		<cfreturn this />
	</cffunction>
	
	<!--- add on missing method --->
	<cffunction name="addOnMissingMethodFunction" access="public" output="false" returntype="any">
		<cfargument name="OnMMFunction" type="any" hint="An instance of an OnMM function" />
		<cfset ArrayAppend(variables.OnMissingMethodFunctions, arguments.OnMMFunction) />
		<cfreturn this />
	</cffunction>
	
	<!--- get on missing method functions --->
	<cffunction name="getOnMissingMethodFunctions" access="public" output="false" returntype="array">
		<cfreturn variables.OnMissingMethodFunctions />
	</cffunction>
</cfcomponent>