<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Bassil Karam (bassil.karam@thinkloop.com) - 01/01/2008
Edited By: Bassil Karam (bassil.karam@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">

	<!--- init - this will be run after all plugins have been mixed in, then removed from the final business object --->
	<cffunction name="init" access="public" output="false" returntype="void">
		<cfscript>
			variables.googledatastore=StructNew();
		</cfscript>
	</cffunction>

	<!--- save --->
	<cffunction name="save" access="public" output="false" returntype="any">
		<cfreturn getLoadedObjects().getPlugin('DAO').save(this) />
	</cffunction>

	<!--- read --->
	<cffunction name="read" access="public" output="false" returntype="any">
		<cfargument name="GoogleKey" type="string" default="" hint="Google key.">
		<cfreturn getLoadedObjects().getPlugin('DAO').read(this, arguments.GoogleKey) />
	</cffunction>

	<!--- update --->
	<cffunction name="update" access="public" output="false" returntype="any">
		<cfreturn getLoadedObjects().getPlugin('DAO').update(this) />
	</cffunction>

	<!--- delete --->
	<cffunction name="delete" access="public" output="false" returntype="any">
		<cfreturn getLoadedObjects().getPlugin('DAO').delete(this) />
	</cffunction>

</cfcomponent>