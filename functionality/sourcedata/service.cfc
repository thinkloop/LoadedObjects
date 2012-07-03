<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Bassil Karam (bassil.karam@thinkloop.com) - 01/01/2008
Edited By: Bassil Karam (bassil.karam@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">

	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfset variables.Mixin=createObject('component', 'mixin') />
		<cfreturn this />
	</cffunction>
	
	<!--- get mixin --->
	<cffunction name="getMixin" access="public" output="false" returntype="any" hint="Returns an instance of an object whose methods will be mixed in to newly created business obejcts (it is the plugin's job to instantiate the mixin object at some point, probably in init())">
		<cfreturn variables.Mixin />
	</cffunction>
	
	<!--- list dependencies to other plugins --->
	<cffunction name="listDependenciesToOtherPlugins" access="public" output="false" returntype="string" hint="Returns a list of names of other plugins upon which this plugin is dependent">
		<cfreturn '' />
	</cffunction>
	
	<!--- list metadata properties: the metadata properties that this plugin expects or uses --->
	<cffunction name="listMetaDataProperties" access="public" output="false" returntype="string" hint="Returns a list of names of properties that this plugin uses that are not inhereted from other plugins (some may be optional, some may be required)">
		<cfreturn '' />
	</cffunction>
	
	<!--- source data --->
	<cffunction name="setSourceData" access="public" output="false" returntype="any" hint="Set source data by supplying a query or an array-of-structs.">
		<cfargument name="BO" type="any" required="true" />
		<cfargument name="SourceData" type="any" required="true" hint="struct or query or array-of-structs" />

		<cfset var EmptyArrayOfStructs = ArrayNew(1) />

		<!--- instantiate the right object for a query or array-of-structs --->
		<cfif isQuery(arguments.SourceData)>
			<cfreturn createObject('component', 'types.query').init(arguments.BO, arguments.SourceData) />
		<cfelseif isArray(arguments.SourceData)>
			<cfreturn createObject('component', 'types.arrayofstructs').init(arguments.BO, arguments.SourceData) />
		<cfelseif isStruct(arguments.SourceData)>
			<cfset ArrayAppend(EmptyArrayOfStructs, arguments.SourceData) />
			<cfreturn createObject('component', 'types.arrayofstructs').init(arguments.BO, EmptyArrayOfStructs) />
		<cfelse>
			<cfthrow type="LoadedObjects" errorcode="LoadedObjects.seSourceData.InvalidType" message="Could not set 'SOURCEDATA' because the provided type is not supported." detail="Ensure that the provided recordset is a a struct, query or array-of-structs." />
		</cfif>
	</cffunction>	
</cfcomponent>