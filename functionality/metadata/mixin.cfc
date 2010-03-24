<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Bassil Karam (bassil.karam@thinkloop.com) - 01/01/2008
Edited By: Bassil Karam (bassil.karam@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">

	<!--- init - this will be run after all plugins have been mixed in, then removed from the final business object --->
	<cffunction name="init" access="public" output="false" returntype="void">
		<cfargument name="LoadedObjects" type="any" required="true" hint="LoadedObjects object passed automatically by plugin manager" />
		<cfargument name="BusinessObjectName" type="string" required="true" hint="Automatically passed in by plugin manager" />
		
		<cfset variables.MetaData=variables.LoadedObjects.getMetaDataObject(arguments.BusinessObjectName) />
				
		<cfif StructKeyExists(variables, 'setDependencies')>
			<cfset setDependencies(variables.MetaData.getDependencies()) />
		</cfif>
	</cffunction>
	
	<!--- get meta data object --->
	<cffunction name="getMetaDataObject" access="public" output="false" returntype="any">
		<cfreturn variables.MetaData />
	</cffunction>
</cfcomponent>