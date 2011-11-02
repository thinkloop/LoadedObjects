<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Bassil Karam (bassil.karam@thinkloop.com) - 01/01/2008
Edited By: Bassil Karam (bassil.karam@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">

	<!--- init - this will be run after all plugins have been mixed in, then removed from the final business object --->
	<cffunction name="init" access="public" output="false" returntype="void">
		<cfscript>
			variables.JavaLoader=createObject("component", "core.javaloader.JavaLoader");
		</cfscript>
	</cffunction>

	<!--- get javaloader --->
	<cffunction name="getJavaLoader" access="public" output="false" returntype="any">		
		<cfreturn variables.JavaLoader />
	</cffunction>
</cfcomponent>