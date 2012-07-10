<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Baz K. (bk@thinkloop.com) - 01/01/2008
Edited By: Baz K. (bk@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">

	<!--- init - this will be run after all plugins have been mixed in, then removed from the final business object --->
	<cffunction name="init" access="public" output="false" returntype="void">
		<cfscript>
			variables.LoadedObjects.Validator = StructNew();
			variables.LoadedObjects.Validator.Errors = StructNew();
		</cfscript>
	</cffunction>

	<!--- validate ---->
	<cffunction name="validate" access="public" output="false" returntype="any">
		<cfargument name="RequiredProperties" type="string" default="" hint="List of required properties that need to be validated. If neither RequiredProperties nor OptionalProperties are specified, validate all properties based on 'required' metadata, otherwise as optional." />
		<cfargument name="OptionalProperties" type="string" default="" hint="List of optional properties that need to be validated. If neither RequiredProperties nor OptionalProperties are specified, validate all properties based on 'required' metadata, otherwise as optional. " />

		<cfscript>
			var Validator = getLoadedObjectsPlugin('Validator');

			var RequiredProperties = arguments.RequiredProperties;
			var OptionalProperties = arguments.OptionalProperties;

			var currentProperty = '';

			clearValidationErrors();
		</cfscript>
		
		<!--- if no properties were provided, validate all properties based on 'required' metadata, otherwise as 'optional' --->
		<cfif not Len(RequiredProperties) AND not Len(OptionalProperties)>
			<cfloop list="#listLoadedObjectsPropertyNames()#" index="currentProperty">
				<cfset validateProperty(currentProperty, existsLoadedObjectsMetadata(currentProperty, 'Required') AND getLoadedObjectsMetadata(currentProperty, 'Required')) />
			</cfloop>
			<cfreturn this />
		</cfif>

		<!--- validate all required properties --->
		<cfloop list="#RequiredProperties#" index="currentProperty">
			<cfset validateProperty(currentProperty, true) />
		</cfloop>

		<!--- validate all optional properties --->
		<cfloop list="#OptionalProperties#" index="currentProperty">
			<cfset validateProperty(currentProperty, false) />
		</cfloop>

		<cfreturn this />
	</cffunction>

	<!--- validate property --->
	<cffunction name="validateProperty" access="public" output="false" returntype="any">
		<cfargument name="PropertyName" type="string" required="true" />
		<cfargument name="Required" type="boolean" default="false" />

		<cfscript>
			var Errors = variables.LoadedObjects.Validator.Errors;
			var PropertyName = arguments.PropertyName;
			var Required = arguments.Required;
			
			var CustomFunctionName = 'validate#PropertyName#';
			var CustomFunction = '';
			var ValidationResult = '';
		</cfscript>

		<!--- if a real function exists, use it --->
		<cfif existsFunction(CustomFunctionName)>
			<cfset CustomFunction = variables[CustomFunctionName] />
			<cfset CustomFunction(PropertyName, Required) />

		<!--- if property is defined in property list, validate it --->
		<cfelseif listFindNoCase(listLoadedObjectsPropertyNames(), PropertyName)>

			<!--- validate --->
			<cfset ValidationResult = getLoadedObjectsPlugin('Validator').validateProperty(this, PropertyName, Required) />
			
			<cfif StructCount(ValidationResult)>
				<cfset Errors[PropertyName] = ValidationResult />
			</cfif>
		<!--- otherwise, throw error --->
		<cfelse>
			<cfthrow 
				type="LoadedObjects" 
				errorcode="LoadedObjects.ValidateProperty.UndefinedProperty" 
				message="Could not validate property #UCase(PropertyName)# because it was not found in component #UCase(getLoadedObjectsBOPath())#" 
				detail="Ensure that the property is defined, and that it is spelled correctly." />
		</cfif>

		<cfreturn this />
	</cffunction>

	<!--- has validation errors --->
	<cffunction name="hasValidationErrors" access="public" output="false" returntype="boolean">
		<cfargument name="PropertyNamesList" type="string" default="" hint="List of property names to check for errors. If none are provided, checks for all errors." />
		
		<cfscript>
			var PropertyNamesList = arguments.PropertyNamesList;
			var Errors = variables.LoadedObjects.Validator.Errors;
			var currentPropertyName = '';
		</cfscript>
		
		<!--- if there are no errors at all, return false --->
		<cfif not IsStruct(Errors) OR not StructCount(Errors)>
			<cfreturn false />
		</cfif>
		
		<!--- if no specific properties were provided, if there are any errors return true --->
		<cfif not Len(PropertyNamesList)>
			<cfreturn StructCount(Errors) />
		</cfif>
		
		<!--- loop through properties, if any are invalid return true --->
		<cfloop list="#PropertyNamesList#" index="currentPropertyName">
			<cfif StructKeyExists(Errors, currentPropertyName)>
				<cfreturn true />
			</cfif>
		</cfloop>
		
		<cfreturn false />
	</cffunction>

	<!--- get validation errors --->
	<cffunction name="getValidationErrors" access="public" output="false" returntype="struct">
		<cfargument name="PropertyNamesList" type="string" default="" hint="List of properties to return errors for. If none are provided, returns all errors." />
		
		<cfscript>
			var PropertyNamesList = arguments.PropertyNamesList;
			var Errors = variables.LoadedObjects.Validator.Errors;
			var ReturnStruct = StructNew();
			var currentPropertyName = '';
		</cfscript>		
		
		<!--- if no specific properties were provided, return all errors --->
		<cfif not Len(PropertyNamesList)>
			<cfreturn Errors />
		</cfif>
		
		<!--- loop through properties, if any are invalid return true --->
		<cfloop list="#PropertyNamesList#" index="currentPropertyName">
			<cfif StructKeyExists(Errors, currentPropertyName)>
				<cfset ReturnStruct[currentPropertyName] = Errors[currentPropertyName] />
			</cfif>			
		</cfloop>
		
		<cfreturn ReturnStruct />
	</cffunction>

	<!--- clear validation errors --->
	<cffunction name="clearValidationErrors" access="public" output="false" returntype="any">
		<cfargument name="PropertyNamesList" type="string" default="" hint="List of properties to clear errors for. If none are provided, clears all errors." />

		<cfscript>
			var PropertyNamesList = arguments.PropertyNamesList;
			var currentPropertyName = '';
		</cfscript>		
		
		<!--- if no specific properties were provided, return all errors --->
		<cfif not Len(PropertyNamesList)>
			<cfset variables.LoadedObjects.Validator.Errors = StructNew() />
		</cfif>
		
		<!--- loop through properties, if any are invalid return true --->
		<cfloop list="#PropertyNamesList#" index="currentPropertyName">
			<cfset StructDelete(Errors, currentPropertyName, false) />	
		</cfloop>
						
		<cfreturn this />
	</cffunction>

	<!--- on Missing Method --->
	<cffunction name="onMissingMethod" access="public" output="false" returntype="any">
		<cfargument name="MissingMethodName" type="string" />
		<cfargument name="MissingMethodArguments" type="struct" />
		
		<cfscript>
			var MissingMethodName = arguments.MissingMethodName;
			var MissingMethodArguments = arguments.MissingMethodArguments;
			
			var ValidatePrefix = 'validate';
			var PropertyName = '';
			var ValidationResult = '';
		</cfscript>

		<!--- validate --->
		<cfif Len(MissingMethodName) gt Len(ValidatePrefix) AND Left(MissingMethodName, Len(ValidatePrefix)) is ValidatePrefix>
			<cfset PropertyName = Right(MissingMethodName, Len(MissingMethodName) - Len(ValidatePrefix)) />
			<cfinvoke method="validateProperty" returnvariable="ValidationResult" argumentcollection="#missingMethodArguments#">
				<cfinvokeargument name="PropertyName" value="#PropertyName#" />
			</cfinvoke>
			<cfreturn ValidationResult />	
		</cfif>
	</cffunction>
</cfcomponent>