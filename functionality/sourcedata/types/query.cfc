<!--- * * (coldfusion comments are completely stripped out at compile time, and have zero impact on performance)
Created By: Bassil Karam (bassil.karam@thinkloop.com) - 01/01/2008
Edited By: Bassil Karam (bassil.karam@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">
	<cfproperty name="SourceData" type="array" hint="The primary source data." />

	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="SourceData" type="array" required="true" />
		<cfscript>
			variables.i=structnew();
			variables.i.SourceData = arguments.SourceData;
			variables.i.Query = '';
			variables.i.ArrayOfStructs = '';
			variables.i.ArrayOfTypedStructs = '';
			variables.i.StructOfStructs = '';
		</cfscript>

		<cfreturn this />
	</cffunction>

	<!--- seek --->
	<cffunction name="seek" access="public" output="false" returntype="struct">
		<cfargument name="Row" type="numeric" required="true" />
		<cfreturn variables.i.SourceData[arguments.Row] />
	</cffunction>

	<!--- count rows --->
	<cffunction name="countRows" access="public" output="false" returntype="numeric">
		<cfreturn ArrayLen(variables.i.SourceData) />
	</cffunction>

	<!--- get source data --->
	<cffunction name="getSourceData" access="public" output="false" returntype="array">
		<cfreturn variables.i.SourceData />
	</cffunction>

<!--- * * * * * * * * --->
<!--- * RECORDSETS * --->
<!--- * * * * * * * * --->

	<!--- get query --->
	<cffunction name="getQuery" access="public" output="false" returntype="query">
		<cfset var PropertiesList='' />
		<cfset var current=StructNew() />

		<!--- if query does not exist, create it (and save it for performance, in case it is needed again later) --->
		<cfif not isQuery(variables.i.Query)>
			<cfset PropertiesList=variables.i.BO.getBOMetaData().listProperties() />
			<cfset variables.i.Query=QueryNew(PropertiesList) />

			<!--- loop through source query --->
			<cfloop condition="loop()">
				<cfset QueryAddRow(variables.i.Query) />

				<!--- loop through each property and get its value --->
				<cfloop list="#PropertiesList#" index="current.Column">
					<cfset QuerySetCell(variables.i.Query, current.Column, variables.i.get(current.Column)) />
				</cfloop>
			</cfloop>
		</cfif>

		<cfreturn variables.i.Query />
	</cffunction>

	<!--- get array of structs --->
	<cffunction name="getArrayOfStructs" access="public" output="false" returntype="array">

		<!--- if array of structs does not exist, create it (and save it for performance, in case it is needed again later) --->
		<cfif not isArray(variables.i.ArrayOfStructs)>
			<cfset variables.i.ArrayOfStructs=ArrayNew(1) />

			<!--- loop through source data --->
			<cfloop condition="loop()">
				<cfset ArrayAppend(variables.i.ArrayOfStructs, variables.i.BO.getMemento()) />
			</cfloop>
		</cfif>

		<cfreturn variables.i.ArrayOfStructs />
	</cffunction>

	<!--- get array of typed structs --->
	<cffunction name="getArrayOfTypedStructs" access="public" output="false" returntype="array">
		<cfset var Type=variables.i.BO.getBOMetaData().getPath() />
		<cfset var current=StructNew() />

		<!--- if array of typed structs does not exist, create it (and save it for performance, in case it is needed again later) --->
		<cfif not isArray(variables.i.ArrayOfTypedStructs)>
			<cfset variables.i.ArrayOfTypedStructs=ArrayNew(1) />

			<!--- loop through source data --->
			<cfloop condition="loop()">
				<cfset current.Struct=variables.i.BO.getMemento() />
				<cfset current.Struct['___Type___']=Type />
				<cfset ArrayAppend(FinalArray, current.Struct) />
			</cfloop>
		</cfif>

		<cfreturn variables.i.ArrayOfTypedStructs />
	</cffunction>

	<!--- get struct of structs --->
	<cffunction name="getStructOfStructs" access="public" output="false" returntype="struct">
		<cfargument name="StructKey" type="string" required="true" hint="MAKE SURE THE *VALUE* OF THE STRUCT KEY CAN BE USED TO NAME A VARIABLE!" />

		<cfset var current=StructNew() />

		<!--- if array of structs does not exist, create it (and save it for performance, in case it is needed again later) --->
		<cfif not isStruct(variables.i.StructOfStructs)>
			<cfset variables.i.StructOfStructs=StructNew() />

			<!--- loop through source data --->
			<cfloop condition="loop()">
				<cfset current.Struct=variables.i.BO.getMemento() />
				<cfset variables.i.StructOfStructs[current.Struct[arguments.StructKey]]=currentStruct />
			</cfloop>
		</cfif>

		<cfreturn variables.i.StructOfStructs />
	</cffunction>

<!--- * * * * * * * * --->
<!--- * AGGREGATES * --->
<!--- * * * * * * * * --->

	<!--- TODO: sum(property:string) - use ArraySum I think --->

	<!--- TODO: avg(property:string) - use ArrayAvg I think --->

	<!--- TODO: min(property:string) --->

	<!--- TODO: max(property:string) --->

	<!--- TODO: count(property:string) --->

	<!--- list property values: create a list of values from every row of a given property --->
	<cffunction name="listPropertyValues" access="public" output="false" returntype="string">
		<cfargument name="Property" type="string" required="true" />

		<cfset var FinalList="" />

		<cfloop condition="loop()">
			<cfset FinalList=ListAppend(FinalList, variables.BO.get(arguments.Property) />
		</cfloop>

		<cfreturn FinalList />
	</cffunction>
</cfcomponent>