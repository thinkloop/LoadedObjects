<cfcomponent output="false">

	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="RawData" type="array"  required="true" />

		<cfscript>
			variables.RawData = arguments.RawData;
		</cfscript>

		<cfreturn this />
	</cffunction>

	<!--- set raw --->
	<cffunction name="setRaw" access="public" output="false" returntype="any">
		<cfargument name="PropertyName" type="string" required="true" />
		<cfargument name="Value" type="any" required="true" />
		<cfargument name="RowNum" type="numeric" required="true" />
		<cfset variables.RawData[arguments.RowNum][arguments.PropertyName] = arguments.Value />
		<cfreturn this />
	</cffunction>

	<!--- get raw --->
	<cffunction name="getRaw" access="public" output="false" returntype="any">
		<cfargument name="PropertyName" type="string" required="true" />
		<cfargument name="RowNum" type="numeric" required="true" />
		<cfreturn variables.RawData[arguments.RowNum][arguments.PropertyName] />
	</cffunction>

	<!--- exists column --->
	<cffunction name="existsColumn" access="public" output="false" returntype="boolean">
		<cfargument name="PropertyName" type="string" required="true" />
		<cfargument name="RowNum" type="string" required="true" />
		<cfreturn StructKeyExists(variables.RawData[arguments.RowNum], arguments.PropertyName) />
	</cffunction>

	<!--- add row --->
	<cffunction name="addRow" access="public" output="false" returntype="any">
		<cfset ArrayAppend(variables.RawData, StructNew()) />
		<cfreturn this />
	</cffunction>

	<!--- num rows --->
	<cffunction name="numRows" access="public" output="false" returntype="numeric">
		<cfreturn ArrayLen(variables.RawData) />
	</cffunction>

	<!--- get raw data --->
	<cffunction name="getRawData" access="public" output="false" returntype="array">
		<cfreturn variables.RawData />
	</cffunction>
</cfcomponent>