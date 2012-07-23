<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Baz K. (bk@thinkloop.com) - 01/01/2008
Edited By: Baz K. (bk@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">

	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfreturn this />
	</cffunction>

	<!--- list collection values --->
	<cffunction name="listCollectionValues" access="public" output="false" returntype="string">
		<cfargument name="BO" type="any" required="true" />
		<cfargument name="PropertyName" type="string" required="true" hint="Property/column name" />

		<cfscript>
			var BO = arguments.BO;
			var PropertyNameList = '';
			var PropertyName = arguments.PropertyName;
		</cfscript>

		<cfloop condition="#BO.loop()#">
			<cfset PropertyNameList = ListAppend(PropertyNameList, BO.get(PropertyName)) />
		</cfloop>

		<cfreturn PropertyNameList />
	</cffunction>
</cfcomponent>