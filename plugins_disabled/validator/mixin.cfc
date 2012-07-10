<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Baz K. (bk@thinkloop.com) - 01/01/2008
Edited By: Baz K. (bk@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">

	<!--- init - this will be run after all plugins have been mixed in, then removed from the final business object --->
	<cffunction name="init" access="public" output="false" returntype="void">
		<cfscript>
			variables.Validator=structnew();
			clearValidationErrors();
		</cfscript>
	</cffunction>

	<!--- validate ---->
	<cffunction name="validate" access="public" output="false" returntype="any" hint="Validates the data of the INPUT struct based on type, length, null, etc.">
		<cfargument name="PropertyList" type="string" default="" />

		<!--- init final property list --->
		<cfset var FinalPropertyList=arguments.PropertyList />

		<!--- init loop indexes --->
		<cfset var currentProperty="" />
		<cfset var currentError="" />

		<!--- if porperty list is undefined, use all properties --->
		<cfif not len(FinalPropertyList)>
			<cfset FinalPropertyList=getMetaDataObject().getProperties().listPropertyNames() />
		</cfif>

		<!--- validate each property and save results --->
		<cfloop list="#FinalPropertyList#" index="currentProperty">
			<cfset validateProperty(currentProperty)/>
		</cfloop>

		<cfreturn this />
	</cffunction>

	<!--- validate property --->
	<cffunction name="validateProperty" access="public" output="false" returntype="any">
		<cfargument name="PropertyName" type="string" />

		<cfset var CustomFunctionName="validate#arguments.PropertyName#" />
		<cfset var CustomFunction="" />
		<cfset var ValidationResult="" />

		<!--- if a real function exists, use it --->
		<cfif existsFunction(CustomFunctionName)>
			<cfset CustomFunction=variables[CustomFunctionName] />
			<cfset CustomFunction(arguments.PropertyName) />

		<!--- if property is defined in property list, validate it --->
		<cfelseif listFindNoCase(getMetaDataObject().getProperties().listPropertyNames(), arguments.PropertyName)>
		
			<!--- validate --->
			<cfset ValidationResult=getLoadedObjects().getPlugin('Validator').validateProperty(this, arguments.PropertyName) />
			
			<!--- add error to collection --->
			<cfset addValidationError(ValidationResult.ErrorCode, ValidationResult.Message) />

		<!--- otherwise, throw error --->
		<cfelse>
			<cfthrow type="LoadedObjects" errorcode="LoadedObjects.ValidateProperty.UndefinedProperty" message="Could not validate property #ucase(arguments.PropertyName)# because it was not found in component #ucase(getMetaDataObject().getLoadedObjectsBOPath())#" detail="Ensure that the property is defined, and that it is spelled correctly." />
		</cfif>

		<cfreturn this />
	</cffunction>

	<!--- has validation errors --->
	<cffunction name="hasValidationErrors" access="public" output="false" returntype="boolean">
		<cfif isQuery(variables.Validator.ValidationErrors) AND variables.Validator.ValidationErrors.recordcount gte 1>
			<cfreturn True />
		<cfelse>
			<cfreturn False />
		</cfif>
	</cffunction>

	<!--- get validation errors --->
	<cffunction name="getValidationErrors" access="public" output="false" returntype="query">
		<cfreturn variables.Validator.ValidationErrors />
	</cffunction>

	<!--- clear validation errors --->
	<cffunction name="clearValidationErrors" access="public" output="false" returntype="any">

		<cfset variables.Validator.ValidationErrors=QueryNew('ErrorCode,Message') />

		<cfreturn this />
	</cffunction>

	<!--- add validation error --->
	<cffunction name="addValidationError" access="public" output="false" returntype="any">
		<cfargument name="ErrorCode" type="string" default="" />
		<cfargument name="Message" type="string" default="" />
		
		<!--- trim error code --->
		<cfset arguments.ErrorCode=trim(arguments.ErrorCode) />
		
		<!--- add to validation errors --->
		<cfif len(arguments.ErrorCode)>
			<cfscript>
				QueryAddRow(variables.Validator.ValidationErrors);
				QuerySetCell(variables.Validator.ValidationErrors, 'ErrorCode', arguments.ErrorCode);
				QuerySetCell(variables.Validator.ValidationErrors, 'Message', arguments.Message);
			</cfscript>
		</cfif>

		<cfreturn this />
	</cffunction>	

	<!--- on Missing Method --->
	<cffunction name="onMissingMethod" access="public" output="false" returntype="any">
		<cfargument name="MissingMethodName" type="string" />
		<cfargument name="MissingMethodArguments" type="struct" />

		<cfset var Property="" />
		<cfset var KeyList="" />

		<!--- validate --->
		<cfif left(arguments.MissingMethodName, 8) is 'validate'>
			<cfset Property=right(arguments.MissingMethodName, len(arguments.MissingMethodName) - 8) />
			<cfreturn validateProperty(Property) />
		</cfif>
	</cffunction>
</cfcomponent>