<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Bassil Karam (bassil.karam@thinkloop.com) - 01/01/2008
Edited By: Bassil Karam (bassil.karam@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">

	<!--- output form --->
	<cffunction name="outputForm" access="public" output="false" type="string">
		<cfargument name="FormAction" type="string" />
		<cfargument name="FormMethod" type="string" />
		<cfargument name="SubmitValue" type="string" />

		<cfreturn getLoadedObjects().getPlugin('Form').outputForm(this, arguments.FormAction, arguments.FormMethod, arguments.SubmitValue) />
	</cffunction>

	<!--- output form field --->
	<cffunction name="outputFormField" access="public" output="false" type="string">
		<cfargument name="PropertyName" type="string" />

		<cfreturn getLoadedObjects().getPlugin('Form').outputFormField(this, arguments.PropertyName) />
	</cffunction>

	<!--- on Missing Method --->
	<cffunction name="onMissingMethod" access="public" output="false" returntype="any">
		<cfargument name="MissingMethodName" type="string" />
		<cfargument name="MissingMethodArguments" type="struct" />

		<cfset var Property="" />
		<cfset var KeyList="" />

		<!--- output --->
		<cfif left(arguments.missingMethodName, 6) is 'output'>
			<cfset Property=right(arguments.missingMethodName, len(arguments.missingMethodName) - 6) />
			<cfreturn output(Property) />
		</cfif>
	</cffunction>
</cfcomponent>