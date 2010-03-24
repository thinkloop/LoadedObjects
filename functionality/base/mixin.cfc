<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Bassil Karam (bassil.karam@thinkloop.com) - 01/01/2008
Edited By: Bassil Karam (bassil.karam@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">

	<!--- init: this will be run after all plugins have been mixed in, then removed from the final business object --->
	<cffunction name="init" access="public" output="false" returntype="void">
		<cfargument name="LoadedObjects" type="any" required="true" hint="Automatically passed in by plugin manager" />
		<cfargument name="BusinessObjectName" type="string" required="true" hint="Automatically passed in by plugin manager" />
		
		<cfset variables.LoadedObjects=arguments.LoadedObjects />
	</cffunction>

	<!--- get LoadedObjects --->
	<cffunction name="getLoadedObjects" access="public" output="false" returntype="any">
		<cfreturn variables.LoadedObjects />
	</cffunction>
	
	<!--- get api: since this frameowrk relies on mixins, cfdump'ing components won't show all the methods available in the component. This function allows a user to see the current api in a clear text format. The source data is populated while plugins are being mixed in. --->
	<cffunction name="getAPI" access="public" output="false" returntype="any">
		<cfreturn variables.API />
	</cffunction>
	
	<!--- dump --->
	<cffunction name="dump" output="true" returntype="any">
		<cfargument name="Variable" type="any" default="" />
		<cfargument name="Label" type="string" default="" />
		<cfargument name="Abort" type="boolean" default="true" />
		
		<cfset var Content="" />
		
		<cfif isSimpleValue(arguments.Variable) AND not len(arguments.Variable)>
			<cfset arguments.Variable=variables />
		</cfif>
		
		<cfif arguments.Abort>
			<cfdump var="#arguments.Variable#" label="#arguments.Label#" expand="false" />
			<cfabort />
		
		<cfelse>
			<cfsavecontent variable="Content">
				<cfdump var="#arguments.Variable#" label="#arguments.Label#" expand="false" />
			</cfsavecontent>
			
			<cfreturn Content />
		</cfif>
	</cffunction>
</cfcomponent>