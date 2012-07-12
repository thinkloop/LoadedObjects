<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Baz K. (bk@thinkloop.com) - 01/01/2008
Edited By: Baz K. (bk@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">

	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfset variables.OnMissingMethodFunctions = ArrayNew(1) />
		<cfreturn this />
	</cffunction>

	<!--- list loaded objects property name --->
	<cffunction name="listLoadedObjectsPropertyNames" access="public" output="false" returntype="string">
		<cfargument name="BO" type="any" required="true" />
		<cfargument name="FilterByAttributes" type="struct" default="#StructNew()#" hint="A struct of attribute names and values to filter the properties by. A * acts as a wildcard in the string.">

		<cfscript>
			var BO = arguments.BO;
			var FilterByAttributes = arguments.FilterByAttributes;
			var PropertiesMetadata = BO.getLoadedObjectsMetadata().Properties;
			var PropertyNamesList = '';

			var currentPropertyName = '';
			var currentAttributeName = '';
			var currentAttributeValue = '';

			var IsPropertyTrue = '';
		</cfscript>

		<cfif not IsStruct(FilterByAttributes) OR not StructCount(FilterByAttributes)>
			<cfreturn StructKeyList(PropertiesMetadata) />
		</cfif>

		<cfloop collection="#PropertiesMetadata#" item="currentPropertyName">
			<cfset IsPropertyTrue = true />
			<cfloop collection="#FilterByAttributes#" item="currentAttributeName">
				<cfif not BO.existsLoadedObjectsMetadata(currentPropertyName, currentAttributeName)>
					<cfset IsPropertyTrue = false />
					<cfbreak />
				</cfif>
				<cfset currentAttributeValue = FilterByAttributes[currentAttributeName] />
				<cfif FindNoCase('*', currentAttributeValue)>
					<cfif not ReFindNoCase('^#ReplaceNoCase(currentAttributeValue, "*", ".*", "all")#$', BO.getLoadedObjectsMetadata(currentPropertyName, currentAttributeName))>
						<cfset IsPropertyTrue = false />
						<cfbreak />
					</cfif>
				<cfelse>
					<cfif not currentAttributeValue is BO.getLoadedObjectsMetadata(currentPropertyName, currentAttributeName)>
						<cfset IsPropertyTrue = false />
						<cfbreak />
					</cfif>
				</cfif>
			</cfloop>
			<cfif IsPropertyTrue>
				<cfset PropertyNamesList = ListAppend(PropertyNamesList, currentPropertyName) />
			</cfif>
		</cfloop>

		<cfreturn PropertyNamesList />
	</cffunction>
	
	<!--- add on missing method --->
	<cffunction name="addOnMissingMethodFunction" access="public" output="false" returntype="any">
		<cfargument name="OnMMFunction" type="any" hint="An instance of an OnMM function" />
		<cfset ArrayAppend(variables.OnMissingMethodFunctions, arguments.OnMMFunction) />
		<cfreturn this />
	</cffunction>

	<!--- get on missing method functions --->
	<cffunction name="getOnMissingMethodFunctions" access="public" output="false" returntype="array">
		<cfreturn variables.OnMissingMethodFunctions />
	</cffunction>
</cfcomponent>