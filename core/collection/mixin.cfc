<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Baz K. (bk@thinkloop.com) - 01/01/2008
Edited By: Baz K. (bk@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">

	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfscript>
			variables.LoadedObjects.Collection = StructNew();
		</cfscript>
		<cfreturn this />
	</cffunction>

	<!--- list values --->
	<cffunction name="listCollectionValues" access="public" output="false" returntype="string">
		<cfargument name="PropertyName" type="string" required="true" hint="Property/column name" />
		<cfreturn getLoadedObjectsPlugin('Collection').listCollectionValues(this, arguments.PropertyName) />
	</cffunction>

	<!--- TODO: sum(property:string) - use ArraySum I think --->

	<!--- TODO: avg(property:string) - use ArrayAvg I think --->

	<!--- TODO: min(property:string) --->

	<!--- TODO: max(property:string) --->

	<!--- TODO: count(property:string) --->

	<!--- seek: returns snapshot of data at first row whose property matches given value, without moving the cursor. This was intended for use with primary keys.
	<cffunction name="seek" access="public" output="false" returntype="struct">
		<cfargument name="PropertyName" type="string" required="true" />
		<cfargument name="Value" type="any" required="true" />

		<cfset var ReturnStruct = StructNew() />
		<cfloop condition="#loop()#">
			<cfif get(arguments.PropertyName) is arguments.Value>
				<cfset ReturnStruct = variables.BO.getAll() />
				<cfbreak />
			</cfif>
		</cfloop>

		<cfset setCurrentRow(1) />
		<cfreturn ReturnStruct />
	</cffunction>
	--->
</cfcomponent>