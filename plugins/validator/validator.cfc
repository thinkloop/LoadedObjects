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

	<!--- validate property --->
	<cffunction name="validateProperty" access="public" output="false" returntype="struct">
		<cfargument name="BusinessObject" type="any" />
		<cfargument name="PropertyName" type="string" />

		<!--- init bo --->
		<cfset var BO=arguments.BusinessObject />

		<!--- get cf data type --->
		<cfset var CFDataType=BO.getMetaDataObject().getProperties().getAttribute(arguments.PropertyName, 'Type') />

		<!--- init validation result --->
		<cfset var ValidationResult="" />

		<!--- determine validation type --->
		<cfswitch expression="#CFDataType#">

			<!--- string --->
			<cfcase value="String,GUID">
				<cfset ValidationResult=validateString(BO, arguments.PropertyName) />
			</cfcase>

			<!--- Number --->
			<cfcase value="integer,float">
				<cfset ValidationResult=validateNumber(BO, arguments.PropertyName) />
			</cfcase>

			<!--- Boolean --->
			<cfcase value="Boolean">
				<cfset ValidationResult=validateBoolean(BO, arguments.PropertyName) />
			</cfcase>

			<!--- DateTime --->
			<cfcase value="Date">
				<cfset ValidationResult=validateDateTime(BO, arguments.PropertyName) />
			</cfcase>

			<!--- Binary --->
			<cfcase value="Binary">
				<cfset ValidationResult=validateBinary(BO, arguments.PropertyName) />
			</cfcase>

			<!--- if empty, throw error --->
			<cfcase value="">
				<cfthrow type="LoadedObjects.Validator" errorcode="LoadedObjects.Validator.UndefinedType" message="Could not validate #UCase(arguments.PropertyName)# because its type is undefined." detail="Ensure that the property has a type defined in the business object." />
			</cfcase>

			<!--- if unsupported type, throw error --->
			<cfdefaultcase>
				<cfthrow type="LoadedObjects.Validator" errorcode="LoadedObjects.Validator.InvalidType" message="Could not validate #UCase(arguments.PropertyName)# because the type #ucase(CFDataType)# is unsupported." detail="The LoadedObjects validation service must be updated to support this type." />
			</cfdefaultcase>
		</cfswitch>

		<cfreturn ValidationResult />
	</cffunction>

<!--- * * * * * * * * * * --->
<!--- * * * iPLUGIN * * * --->
<!--- * * * * * * * * * * --->
	
	<!--- get mixin --->
	<cffunction name="getMixin" access="public" output="false" returntype="any" hint="Returns an instance of an object whose methods will be mixed in to newly created business obejcts (it is the plugin's job to instantiate the mixin object at some point, probably in init())">
		<cfreturn variables.Mixin />
	</cffunction>
	
	<!--- list dependencies to other plugins --->
	<cffunction name="listDependenciesToOtherPlugins" access="public" output="false" returntype="string" hint="Returns a list of names of other plugins upon which this plugin is dependent">
		<cfreturn '' />
	</cffunction>
	
	<!--- list metadata properties --->
	<cffunction name="listMetaDataProperties" access="public" output="false" returntype="string" hint="Returns a list of names of properties that this plugin uses that are not inhereted from other plugins (some may be optional, some may be required)">
		<cfreturn '' />
	</cffunction>
	
<!--- * * * * * * * * * * --->
<!--- * * * PRIVATE * * * --->
<!--- * * * * * * * * * * --->

	<!--- validate String --->
	<cffunction name="validateString" access="private" output="false" returntype="struct">
		<cfargument name="BusinessObject" type="any" />
		<cfargument name="PropertyName" type="string" />

		<!--- set basic attributes --->
		<cfscript>
			var BO=arguments.BusinessObject;
			var MetaData=BO.getMetaDataObject();
			var ObjectName=BO.getMetaDataObject().getName();
			
			var Name=arguments.PropertyName;
			var DisplayName=MetaData.getProperties().getAttribute(Name, 'DisplayName');
			var Value=BO.get(Name);
			
			var Required=MetaData.getProperties().getAttribute(Name, 'Required');
			var isNullValue=BO.is(Name);
			var MinValue=MetaData.getProperties().getAttribute(Name, 'MinValue');
			var MaxValue=MetaData.getProperties().getAttribute(Name, 'MaxValue');
		</cfscript>

		<!--- init return error --->
		<cfset var Error=createError() />

		<!--- validate value is simple --->
		<cfif not isSimpleValue(Value)>
			<cfset Error.ErrorCode="#ObjectName#.#Name#.Type" />
			<cfset Error.Message="Please provide a valid #DisplayName# in string format." />

		<!--- null is allowed --->
		<cfelseif isNullValue AND not Required>

		<!--- validate value is provided --->
		<cfelseif isNullValue AND Required>
			<cfset Error.ErrorCode="#ObjectName#.#Name#.Required" />
			<cfset Error.Message="Please provide a value for #DisplayName#." />

		<!--- validate same min/max values --->
		<cfelseif MinValue is MaxValue AND len(Value) neq MinValue>
			<cfset Error.ErrorCode="#ObjectName#.#Name#.Length.MinMaxValue" />
			<cfset Error.Message="Please ensure that #DisplayName# is exactly #MinValue# character#iif(MinValue gt 1, de('s'),'')# long." />
			
		<!--- validate min value --->
		<cfelseif len(Value) lt MinValue>
			<cfset Error.ErrorCode="#ObjectName#.#Name#.Length.MinValue" />
			<cfset Error.Message="Please ensure that #DisplayName# is at least #MinValue# character#iif(MinValue gt 1, de('s'),'')# long." />

		<!--- validate max value --->
		<cfelseif len(Value) gt MaxValue>
			<cfset Error.ErrorCode="#ObjectName#.#Name#.Length.MaxValue" />
			<cfset Error.Message="Please ensure that #DisplayName# is at most #MaxValue# characters long." />
		</cfif>

		<cfreturn Error />
	</cffunction>

	<!--- validate Number --->
	<cffunction name="validateNumber" access="private" output="false" returntype="struct">
		<cfargument name="BusinessObject" type="any" />
		<cfargument name="PropertyName" type="string" />

		<!--- set basic attributes --->
		<cfscript>
			var BO=arguments.BusinessObject;
			var MetaData=BO.getMetaDataObject();
			var ObjectName=BO.getMetaDataObject().getName();
			
			var Name=arguments.PropertyName;
			var DisplayName=MetaData.getProperties().getAttribute(Name, 'DisplayName');
			var Value=BO.get(Name);
			
			var Required=MetaData.getProperties().getAttribute(Name, 'Required');
			var isNullValue=BO.is(Name);
			var MinValue=MetaData.getProperties().getAttribute(Name, 'MinValue');
			var MaxValue=MetaData.getProperties().getAttribute(Name, 'MaxValue');
			var Scale=MetaData.getProperties().getAttribute(Name, 'Scale');
		</cfscript>

		<!--- init return error --->
		<cfset var Error=createError() />

		<!--- validate value is simple --->
		<cfif not isSimpleValue(Value)>
			<cfset Error.ErrorCode="#ObjectName#.#Name#.Type" />
			<cfset Error.Message="Please provide a valid #DisplayName# in numerical format." />

		<!--- null is allowed --->
		<cfelseif isNullValue AND not Required>

		<!--- null is not allowed --->
		<cfelseif isNullValue AND Required>
			<cfset Error.ErrorCode="#ObjectName#.#Name#.Required" />
			<cfset Error.Message="Please provide a value for #DisplayName#." />

		<!--- validate value is numeric --->
		<cfelseif not isNumeric(Value)>
			<cfset Error.ErrorCode="#ObjectName#.#Name#.Type" />
			<cfset Error.Message="Please provide a valid #DisplayName# in numerical format." />

		<!--- validate min value --->
		<cfelseif Value lt MinValue>
			<cfset Error.ErrorCode="#ObjectName#.#Name#.MinValue" />
			<cfset Error.Message="Please ensure that #DisplayName# is more than #numberformat(MinValue)#." />

		<!--- validate max value --->
		<cfelseif Value gt MaxValue>
			<cfset Error.ErrorCode="#ObjectName#.#Name#.MaxValue" />
			<cfset Error.Message="Please ensure that #DisplayName# is less than #numberformat(MaxValue)#." />

		<!--- validate integer --->
		<cfelseif Scale is 0 AND find('.', Value)>
			<cfset Error.ErrorCode="#ObjectName#.#Name#.Integer" />
			<cfset Error.Message="Please ensure that #DisplayName# is an integer with no decimals." />

		<!--- validate decimal places --->
		<cfelseif Scale gt 0 AND find('.', Value) AND len(listgetat(Value, 2, '.')) gt Scale>
			<cfset Error.ErrorCode="#ObjectName#.#Name#.Scale" />
			<cfset Error.Message="Please ensure that #DisplayName# has less than #Scale# decimal place#iif(Scale gt 1, de('s'),'')#." />
		</cfif>

		<cfreturn Error />
	</cffunction>

	<!--- validate Boolean --->
	<cffunction name="validateBoolean" access="private" output="false" returntype="struct">
		<cfargument name="BusinessObject" type="any" />
		<cfargument name="PropertyName" type="string" />

		<!--- set basic attributes --->
		<cfscript>
			var BO=arguments.BusinessObject;
			var MetaData=BO.getMetaDataObject();
			var ObjectName=BO.getMetaDataObject().getName();
			var Name=arguments.PropertyName;
			var DisplayName=MetaData.getProperties().getAttribute(Name, 'DisplayName');
			var Value=BO.get(arguments.PropertyName);
			var Required=MetaData.getProperties().getAttribute(Name, 'Required');
			var isNullValue=BO.is(Name);
		</cfscript>

		<!--- init return error --->
		<cfset var Error=createError() />

		<!--- validate value is simple --->
		<cfif not isSimpleValue(Value)>
			<cfset Error.ErrorCode="#ObjectName#.#Name#.Type" />
			<cfset Error.Message="Please ensure that the value of '#DisplayName#' is 1 or 0." />

		<!--- null is allowed --->
		<cfelseif isNullValue AND not Required>

		<!--- null is not allowed --->
		<cfelseif isNullValue AND Required>
			<cfset Error.ErrorCode="#ObjectName#.#Name#.Required" />
			<cfset Error.Message="Please provide a value for #DisplayName#." />

		<!--- validate value --->
		<cfelseif Value neq 0 AND Value neq 1>
			<cfset Error.ErrorCode="#ObjectName#.#Name#.Value" />
			<cfset Error.Message="Please ensure that the value of '#DisplayName#' is 1 or 0." />
		</cfif>

		<cfreturn Error />
	</cffunction>

	<!--- validate date time --->
	<cffunction name="validateDateTime" access="private" output="false" returntype="struct">
		<cfargument name="BusinessObject" type="any" />
		<cfargument name="PropertyName" type="string" />

		<!--- set basic attributes --->
		<cfscript>
			var BO=arguments.BusinessObject;
			var MetaData=BO.getMetaDataObject();
			var ObjectName=BO.getMetaDataObject().getName();
			var Name=arguments.PropertyName;
			var DisplayName=MetaData.getProperties().getAttribute(Name, 'DisplayName');
			var Value=BO.get(arguments.PropertyName);
			var Required=MetaData.getProperties().getAttribute(Name, 'Required');
			var isNullValue=BO.is(Name);
			var MinValue=MetaData.getProperties().getAttribute(Name, 'MinValue');
			var MaxValue=MetaData.getProperties().getAttribute(Name, 'MaxValue');
		</cfscript>

		<!--- init return error --->
		<cfset var Error=createError() />

		<!--- validate value is simple --->
		<cfif not isSimpleValue(Value)>
			<cfset Error.ErrorCode="#ObjectName#.#Name#.Type" />
			<cfset Error.Message="Please provide a valid #DisplayName# in string format." />

		<!--- null is allowed --->
		<cfelseif isNullValue AND not Required>

		<!--- null is not allowed --->
		<cfelseif isNullValue AND Required>
			<cfset Error.ErrorCode="#ObjectName#.#Name#.Required" />
			<cfset Error.Message="Please provide a value for #DisplayName#." />

		<!--- validate value is date --->
		<cfelseif not isDate(Value)>
			<cfset Error.ErrorCode="#ObjectName#.#Name#.Type" />
			<cfset Error.Message="Please provide a valid #DisplayName# in proper date format." />

		<!--- validate min value --->
		<cfelseif Value lt MinValue>
			<cfset Error.ErrorCode="#ObjectName#.#Name#.MinValue" />
			<cfset Error.Message="Please ensure that #DisplayName# is greater than #dateformat(MinValue, 'medium')#." />

		<!--- validate max value --->
		<cfelseif Value gt MaxValue>
			<cfset Error.ErrorCode="#ObjectName#.#Name#.MaxValue" />
			<cfset Error.Message="Please ensure that #DisplayName# is less than #dateformat(MaxValue, 'medium')#." />
		</cfif>

		<cfreturn Error />
	</cffunction>

	<!--- create error --->
	<cffunction name="createError" access="private" output="false" returntype="struct">
		<cfscript>
			var Error=structnew();
			Error.ErrorCode='';
			Error.Message='';
		</cfscript>

		<cfreturn Error />
	</cffunction>

	<!--- create error collection --->
	<cffunction name="createErrorCollection" access="private" output="false" returntype="query">
		<cfreturn QueryNew('ErrorCode,Message') />
	</cffunction>

	<!--- add error to collection --->
	<cffunction name="addErrorToCollection" access="private" output="false" returntype="query">
		<cfargument name="ErrorCollection" type="query" />
		<cfargument name="ErrorStruct" type="struct" />

		<cfif len(arguments.ErrorStruct.ErrorCode)>
			<cfscript>
				QueryAddRow(arguments.ErrorCollection, 1);
				QuerySetCell(arguments.ErrorCollection, 'ErrorCode', arguments.ErrorStruct.ErrorCode);
				QuerySetCell(arguments.ErrorCollection, 'Message', arguments.ErrorStruct.Message);
			</cfscript>
		</cfif>

		<cfreturn arguments.ErrorCollection />
	</cffunction>
</cfcomponent>