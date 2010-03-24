<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Bassil Karam (bassil.karam@thinkloop.com) - 01/01/2008
Edited By: Bassil Karam (bassil.karam@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">
	
	<!--- init - this will be run after all plugins have been mixed in, then removed from the final business object --->
	<cffunction name="init" access="public" output="false" returntype="void">
		<cfscript>
			variables.Constraints='';
		</cfscript>
	</cffunction>
	
	<!--- get constraints --->
	<cffunction name="getConstraints" access="public" output="false" returntype="any">
		<cfif not isObject(variables.Constraints)>
			<cfset variables.Constraints=getLoadedObjects().getPlugin('Constraints').newInstance() />
		</cfif>
		
		<cfreturn variables.Constraints />
	</cffunction>
</cfcomponent>