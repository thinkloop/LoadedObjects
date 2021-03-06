<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Baz K. (bk@thinkloop.com) - 01/01/2008
Edited By: Baz K. (bk@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">

	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="Datasource" />

		<cfscript>
			variables.Datasource=arguments.Datasource;
		</cfscript>

		<cfreturn this />
	</cffunction>

	<!--- create --->
	<cffunction name="create" access="public" output="false" returntype="boolean">
		<cfargument name="SQLInput" type="struct" hint="Struct of structs of some meta data and current values for easy data retrieval" />
		<cfargument name="TableName" hint="Name of table in string format." />
		<cfargument name="CreateProperties" type="string" hint="Comma-separated list of properties to update" />
		<cfargument name="IsAutoGeneratedPrimaryKey" type="boolean" default="false" />

		<cfreturn True />
	</cffunction>

	<!--- read ---->
	<cffunction name="read" access="public" output="false" returntype="query">
		<cfargument name="SQLInput" type="struct" hint="Struct of structs of some meta data and current values for easy data retrieval" />
		<cfargument name="TableName" type="string" hint="Name of table in db" />
		<cfargument name="ReadProperties" type="string" hint="Comma-separated list of properties to read" />
		<cfargument name="FilterProperties" type="string" hint="Comma-separated list of properties to filter by" />

		<cfreturn QueryNew(arguments.ReadProperties) />
	</cffunction>

	<!--- update --->
	<cffunction name="update" access="public" output="false" returntype="boolean">
		<cfargument name="SQLInput" type="struct" hint="Struct of structs of some meta data and current values for easy data retrieval" />
		<cfargument name="TableName" hint="Name of table in string format." />
		<cfargument name="UpdateProperties" type="string" hint="Comma-separated list of properties to update" />
		<cfargument name="FilterProperties" type="string" hint="Comma-separated list of properties to filter by" />

		<cfreturn True />
	</cffunction>

	<!--- delete --->
	<cffunction name="delete" access="public" output="false" returntype="boolean">
		<cfargument name="SQLInput" type="struct" hint="Struct of structs of some meta data and current values for easy data retrieval" />
		<cfargument name="TableName" hint="Name of table in string format." />
		<cfargument name="FilterProperties" type="string" hint="Comma-separated list of properties to filter by" />

		<cfreturn True />
	</cffunction>

	<!--- exists ---->
	<cffunction name="exists" access="public" output="false" returntype="boolean">
		<cfargument name="SQLInput" type="struct" hint="Struct of structs of some meta data and current values for easy data retrieval" />
		<cfargument name="TableName" hint="Name of table in string format." />
		<cfargument name="FilterProperties" type="string" hint="Comma-separated list of properties to filter by" />

		<cfreturn False />
	</cffunction>

<!--- * * * * * * * * * * * * --->
<!--- * * * * PRIVATE * * * * --->
<!--- * * * * * * * * * * * * --->

	<!--- get Datasource --->
	<cffunction name="getDatasource" access="private" output="false" returntype="struct">
		<cfreturn variables.Datasource />
	</cffunction>
</cfcomponent>