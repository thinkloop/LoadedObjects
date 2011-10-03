<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Bassil Karam (bassil.karam@thinkloop.com) - 01/01/2008
Edited By: Bassil Karam (bassil.karam@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">

	<!--- init: this will be run after all plugins have been mixed in, then removed from the final business object --->
	<cffunction name="init" access="public" output="false" returntype="void">
		<cfargument name="LoadedObjects" type="any" required="true" hint="A reference to the LoadedObjects frameworka automatically passed in by the framework." />
		<cfargument name="BusinessObjectName" type="string" required="true" hint="The name of the current business object, automatically passed in by the framework." />
		
		<cfset variables.LoadedObjects=arguments.LoadedObjects />
	</cffunction>

	<!--- get LoadedObjects --->
	<cffunction name="getLoadedObjects" access="public" output="false" returntype="any">
		<cfreturn variables.LoadedObjects />
	</cffunction>
	
	<!--- todo: since this frameowrk relies on mixins, cfdump'ing components won't show all the methods available in the component. This function allows a user to see the current api in a clear text format. The source data is populated while plugins are being mixed in. --->
	<cffunction name="getCurrentAPI" access="public" output="false" returntype="any">
		<cfreturn variables.CurrentAPI />
	</cffunction>
	
	<!--- dump --->
	<cffunction name="dump" output="true" returntype="any">
		<cfargument name="VariableName" type="string" default="variables" hint="name of any variable inside this component" />
		<cfargument name="Label" type="string" default="" />
		<cfargument name="Abort" type="boolean" default="true" />
		
		<cfset var VarToDump="" />
		<cfset var Content="" />

		<cfif len(arguments.VariableName) AND StructKeyExists(variables, arguments.VariableName)>
			<cfset VarToDump = variables[arguments.VariableName]  />
		<cfelse>
			<cfset VarToDump = variables  />			
		</cfif>
	
		<cfif arguments.Abort>
			<cfdump var="#VarToDump#" label="#arguments.Label#" expand="false" />
			<cfabort />
		<cfelse>
			<cfsavecontent variable="Content">
				<cfdump var="#VarToDump#" label="#arguments.Label#" expand="false" />
			</cfsavecontent>
			
			<cfreturn Content />
		</cfif>
		
	</cffunction>
</cfcomponent>