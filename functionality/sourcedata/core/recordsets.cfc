<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Bassil Karam (bassil.karam@thinkloop.com) - 07/06/2008
Edited By: Bassil Karam (bassil.karam@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">

	<!--- generate query --->
	<cffunction name="generateQuery" access="public" output="false" returntype="query">
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
	
	<!--- generate array of structs --->
	<cffunction name="generateArrayOfStructs" access="public" output="false" returntype="array">
		
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
	
	<!--- generate array of typed structs --->
	<cffunction name="generateArrayOfTypedStructs" access="public" output="false" returntype="array">
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
	
	<!--- generate struct of structs --->
	<cffunction name="generateStructOfStructs" access="public" output="false" returntype="struct">
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
</cfcomponent>