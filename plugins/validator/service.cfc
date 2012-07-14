<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Baz K. (bk@thinkloop.com) - 01/01/2008
Edited By: Baz K. (bk@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">

	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfset variables.Mixin=createObject('component', 'mixin') />
		<cfreturn this />
	</cffunction>

	<!--- validate property --->
	<cffunction name="validateProperty" access="public" output="false" returntype="struct">
		<cfargument name="BusinessObject" type="any" required="true" />
		<cfargument name="PropertyName" type="string" required="true" />
		<cfargument name="Required" type="boolean" required="false" />

		<cfscript>
			var BO = arguments.BusinessObject;

			var ObjectPath = BO.getLoadedObjectsBOPath();
			var PropertyName = arguments.PropertyName;
			var Required = arguments.Required;
			var DisplayName = BO.getLoadedObjectsMetadata(PropertyName, 'DisplayName');
			var Type = BO.getLoadedObjectsMetadata(PropertyName, 'Type');

			var Value = BO.get(PropertyName);
			var NullValue = BO.getLoadedObjectsMetadata(PropertyName, 'NullValue');

			var ValidationResult = '';
		</cfscript>

		<!--- null --->
		<cfif Required AND IsSimpleValue(Value) AND Value is NullValue>
			<cfreturn newValidationError(ObjectPath, PropertyName, 'Null', 'Please provide a #DisplayName#.') />
		</cfif>

		<!--- type --->
		<cfset ValidationResult = validateType(ObjectPath, PropertyName, DisplayName, Type, Value) />
		<cfif StructCount(ValidationResult)>
			<cfreturn ValidationResult />
		</cfif>

		<!--- allowed values: comma-delimited list of allowed values --->
		<cfif BO.existsLoadedObjectsMetadata(PropertyName, 'AllowedValues')>
			<cfset ValidationResult = validateAllowedValues(ObjectPath, PropertyName, DisplayName, Type, Value, BO.getLoadedObjectsMetadata(PropertyName, 'AllowedValues')) />
			<cfif StructCount(ValidationResult)>
				<cfreturn ValidationResult />
			</cfif>
		</cfif>

		<!--- min value --->
		<cfif BO.existsLoadedObjectsMetadata(PropertyName, 'MinValue')>
			<cfset ValidationResult = validateMinValue(ObjectPath, PropertyName, DisplayName, Type, Value, BO.getLoadedObjectsMetadata(PropertyName, 'MinValue')) />
			<cfif StructCount(ValidationResult)>
				<cfreturn ValidationResult />
			</cfif>
		</cfif>

		<!--- max value --->
		<cfif BO.existsLoadedObjectsMetadata(PropertyName, 'MaxValue')>
			<cfset ValidationResult = validateMaxValue(ObjectPath, PropertyName, DisplayName, Type, Value, BO.getLoadedObjectsMetadata(PropertyName, 'MaxValue')) />
			<cfif StructCount(ValidationResult)>
				<cfreturn ValidationResult />
			</cfif>
		</cfif>

		<!--- min value --->
		<cfif BO.existsLoadedObjectsMetadata(PropertyName, 'MinLength')>
			<cfset ValidationResult = validateMinLength(ObjectPath, PropertyName, DisplayName, Type, Value, BO.getLoadedObjectsMetadata(PropertyName, 'MinLength')) />
			<cfif StructCount(ValidationResult)>
				<cfreturn ValidationResult />
			</cfif>
		</cfif>

		<!--- min value --->
		<cfif BO.existsLoadedObjectsMetadata(PropertyName, 'MaxLength')>
			<cfset ValidationResult = validateMaxLength(ObjectPath, PropertyName, DisplayName, Type, Value, BO.getLoadedObjectsMetadata(PropertyName, 'MaxLength')) />
			<cfif StructCount(ValidationResult)>
				<cfreturn ValidationResult />
			</cfif>
		</cfif>

		<!--- TODO: MinScale/MaxScale (i.e. number of decimal places, a scale of 0 is an integer) ("Scale gt 0 AND find('.', Value) AND len(listgetat(Value, 2, '.')) gt Scale" >> Please ensure that #DisplayName# has less than #Scale# decimal place#iif(Scale gt 1, de('s'),'')#.) ("Scale is 0 AND find('.', Value)" >> Please ensure that #DisplayName# is an integer with no decimals.) --->
		<!--- TODO: ValidatorRegex: any regex that returns a boolean --->
		<!--- TODO: ValidatorExpression: any expression to evaluate at runtime (using the local context vars, funnctions, etc., I believe. --->

		<cfreturn StructNew() />
	</cffunction>

<!--- * * * * * * * * * * --->
<!--- * * * PRIVATE * * * --->
<!--- * * * * * * * * * * --->

	<!--- validate type --->
	<cffunction name="validateType" access="private" output="false" returntype="struct">
		<cfargument name="ObjectPath" type="string" required="true" />
		<cfargument name="PropertyName" type="string" required="true" />
		<cfargument name="DisplayName" type="string" required="true" />
		<cfargument name="Type" type="string" required="true" />
		<cfargument name="Value" type="any" required="true" />

		<cfscript>
			var ObjectPath = arguments.ObjectPath;
			var PropertyName = arguments.PropertyName;
			var DisplayName = arguments.DisplayName;
			var Type = arguments.Type;

			var Value = arguments.Value;
		</cfscript>

		<!--- type --->
		<cfswitch expression="#Type#">
			<cfcase value="string,variableName">
				<cfif not IsSimpleValue(Value)>
					<cfreturn newValidationError(ObjectPath, PropertyName, 'Type', 'Please provide a #DisplayName# in string format.') />
				</cfif>
			</cfcase>
			<cfcase value="numeric">
				<cfif not IsNumeric(Value)>
					<cfreturn newValidationError(ObjectPath, PropertyName, 'Type', 'Please provide a #DisplayName# in numeric format.') />
				</cfif>
			</cfcase>
			<cfcase value="boolean">
				<cfif not IsBoolean(Value)>
					<cfreturn newValidationError(ObjectPath, PropertyName, 'Type', 'Please select a preference for #DisplayName#.') />
				</cfif>
				<cfreturn StructNew() />
			</cfcase>
			<cfcase value="date">
				<cfif not IsDate(Value)>
					<cfreturn newValidationError(ObjectPath, PropertyName, 'Type', 'Please provide a #DisplayName# in date format.') />
				</cfif>
			</cfcase>
			<cfcase value="uuid">
				<cfif not IsValid('UUID', Value)>
					<cfreturn newValidationError(ObjectPath, PropertyName, 'Type', 'Please provide a #DisplayName# in UUID format.') />
				</cfif>
			</cfcase>
			<cfcase value="guid">
				<cfif not IsValid('GUID', Value)>
					<cfreturn newValidationError(ObjectPath, PropertyName, 'Type', 'Please provide a #DisplayName# in GUID format.') />
				</cfif>
			</cfcase>
			<cfcase value="struct">
				<cfif not IsStruct(Value)>
					<cfreturn newValidationError(ObjectPath, PropertyName, 'Type', 'Please ensure #DisplayName# is in struct format.') />
				</cfif>
			</cfcase>
			<cfcase value="array">
				<cfif not IsArray(Value)>
					<cfreturn newValidationError(ObjectPath, PropertyName, 'Type', 'Please ensure #DisplayName# is in array format.') />
				</cfif>
			</cfcase>
			<cfcase value="query">
				<cfif not IsQuery(Value)>
					<cfreturn newValidationError(ObjectPath, PropertyName, 'Type', 'Please ensure #DisplayName# is in query format.') />
				</cfif>
			</cfcase>
			<cfcase value="binary">
				<cfif not IsBinary(Value)>
					<cfreturn newValidationError(ObjectPath, PropertyName, 'Type', 'Please ensure #DisplayName# is in binary format.') />
				</cfif>
				<cfreturn StructNew() />
			</cfcase>
			<cfcase value="any">
				<!--- nothing to do, can be anything --->
			</cfcase>

			<!--- cfc --->
			<cfdefaultcase>
				<cfif not IsObject(Value) OR not IsInstanceOf(Value, Type)>
					<cfreturn newValidationError(ObjectPath, PropertyName, 'Type', 'Please ensure #DisplayName# is an object of type #Type#.') />
				</cfif>
			</cfdefaultcase>
		</cfswitch>

		<cfreturn StructNew() />
	</cffunction>

	<!--- allowed values --->
	<cffunction name="validateAllowedValues" access="private" output="false" returntype="struct">
		<cfargument name="ObjectPath" type="string" required="true" />
		<cfargument name="PropertyName" type="string" required="true" />
		<cfargument name="DisplayName" type="string" required="true" />
		<cfargument name="Type" type="string" required="true" />
		<cfargument name="Value" type="any" required="true" />
		<cfargument name="AllowedValues" type="string" required="true" />

		<cfscript>
			var ObjectPath = arguments.ObjectPath;
			var PropertyName = arguments.PropertyName;
			var DisplayName = arguments.DisplayName;
			var Type = arguments.Type;

			var Value = arguments.Value;
			var AllowedValues = arguments.AllowedValues;
		</cfscript>
		
		<cfif ListLen(AllowedValues)>
			<cfswitch expression="#Type#">
				<cfcase value="string,numeric,boolean,date,uuid,guid,variableName">
					<cfif not ListFindNoCase(AllowedValues, Value)>
						<cfreturn newValidationError(ObjectPath, PropertyName, 'AllowedValues', 'Please ensure #DisplayName# is one of these allowed values: #AllowedValues#') />
					</cfif>
				</cfcase>
			</cfswitch>
		</cfif>
		
		<cfreturn StructNew() />
	</cffunction>

	<!--- min value / max value--->
	<cffunction name="validateMinValue" access="private" output="false" returntype="struct">
		<cfargument name="ObjectPath" type="string" required="true" />
		<cfargument name="PropertyName" type="string" required="true" />
		<cfargument name="DisplayName" type="string" required="true" />
		<cfargument name="Type" type="string" required="true" />
		<cfargument name="Value" type="any" required="true" />
		<cfargument name="MinValue" type="any" required="true" />

		<cfscript>
			var ObjectPath = arguments.ObjectPath;
			var PropertyName = arguments.PropertyName;
			var DisplayName = arguments.DisplayName;
			var Type = arguments.Type;

			var Value = arguments.Value;
			var MinValue = arguments.MinValue;
		</cfscript>

		<cfswitch expression="#Type#">
			<cfcase value="string,numeric,variableName">
				<cfif Value lt MinValue>
					<cfreturn newValidationError(ObjectPath, PropertyName, 'MinValue', 'Please ensure #DisplayName# is greater than #MinValue#') />
				</cfif>
			</cfcase>
			<cfcase value="date">
				<cfif Value lt MinValue>
					<cfreturn newValidationError(ObjectPath, PropertyName, 'MinValue', 'Please ensure #DisplayName# is after #MinValue#') />
				</cfif>
			</cfcase>

			<!--- TODO: Add support for arrays, structs and queries using ArrayMin(Value), ArrayMin(StructSort(Value)), etc. --->
		</cfswitch>

		<cfreturn StructNew() />
	</cffunction>
	<cffunction name="validateMaxValue" access="private" output="false" returntype="struct">
		<cfargument name="ObjectPath" type="string" required="true" />
		<cfargument name="PropertyName" type="string" required="true" />
		<cfargument name="DisplayName" type="string" required="true" />
		<cfargument name="Type" type="string" required="true" />
		<cfargument name="Value" type="any" required="true" />
		<cfargument name="MaxValue" type="any" required="true" />

		<cfscript>
			var ObjectPath = arguments.ObjectPath;
			var PropertyName = arguments.PropertyName;
			var DisplayName = arguments.DisplayName;
			var Type = arguments.Type;

			var Value = arguments.Value;
			var MaxValue = arguments.MaxValue;
		</cfscript>

		<cfswitch expression="#Type#">
			<cfcase value="string,numeric,variableName">
				<cfif Value gt MaxValue>
					<cfreturn newValidationError(ObjectPath, PropertyName, 'MaxValue', 'Please ensure #DisplayName# is less than #MaxValue#') />
				</cfif>
			</cfcase>
			<cfcase value="date">
				<cfif Value gt MaxValue>
					<cfreturn newValidationError(ObjectPath, PropertyName, 'MaxValue', 'Please ensure #DisplayName# is before #MaxValue#') />
				</cfif>
			</cfcase>

			<!--- TODO: Add support for arrays, structs and queries using ArrayMax(Value), ArrayMax(StructSort(Value)), etc. --->
		</cfswitch>

		<cfreturn StructNew() />
	</cffunction>

	<!--- min length / max length --->
	<cffunction name="validateMinLength" access="private" output="false" returntype="struct">
		<cfargument name="ObjectPath" type="string" required="true" />
		<cfargument name="PropertyName" type="string" required="true" />
		<cfargument name="DisplayName" type="string" required="true" />
		<cfargument name="Type" type="string" required="true" />
		<cfargument name="Value" type="any" required="true" />
		<cfargument name="MinLength" type="any" required="true" />

		<cfscript>
			var ObjectPath = arguments.ObjectPath;
			var PropertyName = arguments.PropertyName;
			var DisplayName = arguments.DisplayName;
			var Type = arguments.Type;

			var Value = arguments.Value;
			var MinLength = arguments.MinLength;
		</cfscript>

		<cfswitch expression="#Type#">
			<cfcase value="string,numeric,variableName,date,uuid,guid">
				<cfif Len(Value) lt MinLength>
					<cfreturn newValidationError(ObjectPath, PropertyName, 'MinLength', 'Please ensure #DisplayName# is at least #MinLength# characters long.') />
				</cfif>
			</cfcase>
			<cfcase value="array">
				<cfif ArrayLen(Value) lt MinLength>
					<cfreturn newValidationError(ObjectPath, PropertyName, 'MinValue', 'Please ensure #DisplayName# has at least #MinValue# elements.') />
				</cfif>
			</cfcase>
			<cfcase value="struct">
				<cfif StructCount(Value) lt MinLength>
					<cfreturn newValidationError(ObjectPath, PropertyName, 'MinValue', 'Please ensure #DisplayName# has at least #MinValue# items.') />
				</cfif>
			</cfcase>
			<cfcase value="query">
				<cfif Value.Recordcount lt MinLength>
					<cfreturn newValidationError(ObjectPath, PropertyName, 'MinValue', 'Please ensure #DisplayName# has at least #MinValue# rows.') />
				</cfif>
			</cfcase>
		</cfswitch>

		<cfreturn StructNew() />
	</cffunction>
	<cffunction name="validateMaxLength" access="private" output="false" returntype="struct">
		<cfargument name="ObjectPath" type="string" required="true" />
		<cfargument name="PropertyName" type="string" required="true" />
		<cfargument name="DisplayName" type="string" required="true" />
		<cfargument name="Type" type="string" required="true" />
		<cfargument name="Value" type="any" required="true" />
		<cfargument name="MaxLength" type="any" required="true" />

		<cfscript>
			var ObjectPath = arguments.ObjectPath;
			var PropertyName = arguments.PropertyName;
			var DisplayName = arguments.DisplayName;
			var Type = arguments.Type;

			var Value = arguments.Value;
			var MaxLength = arguments.MaxLength;
		</cfscript>

		<cfswitch expression="#Type#">
			<cfcase value="string,numeric,variableName,date,uuid,guid">
				<cfif Len(Value) gt MaxLength>
					<cfreturn newValidationError(ObjectPath, PropertyName, 'MaxLength', 'Please ensure #DisplayName# is at most #MaxLength# characters long.') />
				</cfif>
			</cfcase>
			<cfcase value="array">
				<cfif ArrayLen(Value) gt MaxLength>
					<cfreturn newValidationError(ObjectPath, PropertyName, 'MaxValue', 'Please ensure #DisplayName# has at most #MaxValue# elements.') />
				</cfif>
			</cfcase>
			<cfcase value="struct">
				<cfif StructCount(Value) gt MaxLength>
					<cfreturn newValidationError(ObjectPath, PropertyName, 'MaxValue', 'Please ensure #DisplayName# has at most #MaxValue# items.') />
				</cfif>
			</cfcase>
			<cfcase value="query">
				<cfif Value.Recordcount gt MaxLength>
					<cfreturn newValidationError(ObjectPath, PropertyName, 'MaxValue', 'Please ensure #DisplayName# has at most #MaxValue# rows.') />
				</cfif>
			</cfcase>
		</cfswitch>

		<cfreturn StructNew() />
	</cffunction>

	<!--- new error --->
	<cffunction name="newValidationError" access="private" output="false" returntype="struct">
		<cfargument name="ObjectPath" type="string" required="true" />
		<cfargument name="PropertyName" type="string" required="true" />
		<cfargument name="ErrorType" type="string" required="true" />
		<cfargument name="Message" type="string" default="" />

		<cfscript>
			var ValidationError = StructNew();
			ValidationError.ObjectPath = arguments.ObjectPath;
			ValidationError.PropertyName = arguments.PropertyName;
			ValidationError.ErrorType = arguments.ErrorType;
			ValidationError.Code = arguments.ObjectPath & '.' & arguments.PropertyName & '.' & arguments.ErrorType;
			ValidationError.Message = arguments.Message;
		</cfscript>

		<cfreturn ValidationError />
	</cffunction>
</cfcomponent>