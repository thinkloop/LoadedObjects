<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Baz K. (bk@thinkloop.com) - 01/01/2008
Edited By: Baz K. (bk@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">

	<!--- init - this will be run after all plugins have been mixed in, then removed from the final business object --->
	<cffunction name="init" access="public" output="false" returntype="void">
		<cfscript>
			variables.SimpleDB=StructNew();
		</cfscript>
	</cffunction>

	<!--- select --->
	<cffunction name="select" access="public" output="false" returntype="any">
		<cfargument name="SelectExpression" type="string" required="true" />
		<cfreturn getLoadedObjects().getPlugin('SimpleDB').select(this, arguments.SelectExpression) />
	</cffunction>
	
	<!--- save --->
	<cffunction name="save" access="public" output="false" returntype="any">
		<cfreturn this />
	</cffunction>
	
	<!--- delete --->
	<cffunction name="delete" access="public" output="false" returntype="any">
		<cfreturn this />
	</cffunction>
</cfcomponent>