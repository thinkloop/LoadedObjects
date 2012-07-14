<cfcomponent output="false">

	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfscript>
			variables.LoadedObjects.RawData = StructNew();
			variables.LoadedObjects.RawData.Manager = '';
			variables.LoadedObjects.RawData.CurrentRow = 0;
			variables.LoadedObjects.RawData.HasBeenSet = StructNew();

			setRawData();
			clearHasBeenSet();
		</cfscript>
		<cfreturn this />
	</cffunction>

<!--- * * * * * * * * * *--->
<!--- * * PROPERTIES * * --->
<!--- * * * * * * * * * *--->

	<!--- set --->
	<cffunction name="set" access="public" output="false" returntype="any">
		<cfargument name="PropertyName" type="string" required="true" />
		<cfargument name="Value" type="any" required="true" />

		<cfscript>
			var Service = getLoadedObjectsPlugin('RawData');

			var PropertyName = arguments.PropertyName;
			var Value = arguments.Value;

			var CustomFunctionName = 'set#PropertyName#';
			var CustomFunction = '';
		</cfscript>

		<!--- if a real function exists, use it --->
		<cfif existsFunction(CustomFunctionName)>
			<cfset CustomFunction = variables[CustomFunctionName] />
			<cfreturn CustomFunction(Value) />
		</cfif>

		<cfset Service.set(this, PropertyName, Value) />
		
		<cfreturn this />
	</cffunction>

	<!--- get --->
	<cffunction name="get" access="public" output="false" returntype="any">
		<cfargument name="PropertyName" type="string" required="true" />

		<cfscript>
			var Service = getLoadedObjectsPlugin('RawData');

			var PropertyName = arguments.PropertyName;

			var CustomFunctionName = 'get#PropertyName#';
			var CustomFunction = '';
		</cfscript>

		<!--- if a real function exists, use it --->
		<cfif existsFunction(CustomFunctionName)>
			<cfset CustomFunction = variables[CustomFunctionName] />
			<cfreturn CustomFunction() />
		</cfif>

		<cfreturn Service.get(this, PropertyName) />
	</cffunction>

	<!--- set value: convenience function so that BO's can easily get/set properties when overriding - don't use this unless you HAVE to --->
	<cffunction name="setValue" access="public" output="false" returntype="any">
		<cfargument name="PropertyName" type="string" required="true" />
		<cfargument name="Value" type="any" required="true" />
		<cfreturn getLoadedObjectsPlugin('RawData').set(this, arguments.PropertyName, arguments.Value) />
	</cffunction>

	<!--- get value: convenience function so that BO's can easily get/set properties when overriding - don't use this unless you HAVE to --->
	<cffunction name="getValue" access="public" output="false" returntype="any">
		<cfargument name="PropertyName" type="string" required="true" />
		<cfreturn getLoadedObjectsPlugin('RawData').get(this, arguments.PropertyName) />
	</cffunction>

	<!--- is null --->
	<cffunction name="is" access="public" output="false" returntype="boolean">
		<cfargument name="PropertyName" type="string" />

		<cfscript>
			var Service = getLoadedObjectsPlugin('RawData');

			var PropertyName = arguments.PropertyName;

			var CustomFunctionName = 'is#PropertyName#';
			var CustomFunction = '';
		</cfscript>

		<!--- if a real function exists, use it --->
		<cfif existsFunction(CustomFunctionName)>
			<cfset CustomFunction = variables[CustomFunctionName] />
			<cfreturn CustomFunction() />
		</cfif>

		<cfreturn Service.is(this, PropertyName) />
	</cffunction>

<!--- * * * * * * *--->
<!--- * * LOOP * * --->
<!--- * * * * * * *--->

	<!--- loop --->
	<cffunction name="loop" access="public" output="false" returntype="boolean">
		<cfargument name="Direction" type="string" default="forward" hint="Can be: forward, reverse" />
		<cfreturn getLoadedObjectsPlugin('RawData').loop(this, arguments.Direction) />
	</cffunction>

	<!--- current row --->
	<cffunction name="getCurrentRow" access="public" output="false" returntype="numeric" hint="Returns the current row">
		<cfargument name="Sanitized" type="boolean" default="true" hint="When true, ensures that a valid row number is returned. When false, may return a zero for a row number. Default is true. This was introduced so that loop() could work, by always incrementing by 1." />
		<cfscript>
			var RowNumber = variables.LoadedObjects.RawData.CurrentRow;
			var Sanitized = arguments.Sanitized;
			
			if (not Sanitized AND RowNumber lte 0) {
				return 0;
			}
			
			if (RowNumber lt 1) {
				return 1;
			}

			return RowNumber;
		</cfscript>
	</cffunction>
	<cffunction name="setCurrentRow" access="public" output="false" returntype="any" hint="Value should be zero (which returns 1 from the getter by default), unless we are in the middle of looping.">
		<cfargument name="RowNumber" type="numeric" required="true" />
		<cfset variables.LoadedObjects.RawData.CurrentRow = arguments.RowNumber />
		<cfreturn this />
	</cffunction>

	<!--- num rows --->
	<cffunction name="numRows" access="public" output="false" returntype="numeric">
		<cfreturn getRawDataManager().numRows() />
	</cffunction>

	<!--- has rows --->
	<cffunction name="hasRows" access="public" output="false" returntype="boolean">
		<cfreturn getRawDataManager().numRows() gt 0 />
	</cffunction>

<!--- * * * * * * * * * *--->
<!--- * * RawData * * --->
<!--- * * * * * * * * * *--->

	<!--- get all --->
	<cffunction name="getAll" access="public" output="false" returntype="struct">
		<cfreturn getLoadedObjectsPlugin('RawData').getAll(this) />
	</cffunction>

	<!--- set all --->
	<cffunction name="setAll" access="public" output="false" returntype="any">
		<cfargument name="RawData" type="any" required="true" hint="Can be a struct or a query or an array of structs" />
		<cfargument name="Row" type="numeric" default="1" hint="Specifies which row of the query or array of structs to use to populate the object" />
		<cfreturn getLoadedObjectsPlugin('RawData').setAll(this, arguments.RawData, arguments.Row) />
	</cffunction>

	<!--- get raw data --->
	<cffunction name="getRawData" access="public" output="false" returntype="any">
		<cfreturn getRawDataManager().getRawData() />
	</cffunction>

	<!--- set raw data --->
	<cffunction name="setRawData" access="public" output="false" returntype="any" hint="Set appropriate raw data manager based on provided raw type.">
		<cfargument name="RawData" type="any" default="" hint="Struct or query or array-of-structs" />
		<cfset variables.LoadedObjects.RawData.Manager = getLoadedObjectsPlugin('RawData').createRawData(this, arguments.RawData) />
		<cfreturn this />
	</cffunction>

	<!--- get raw data manager --->
	<cffunction name="getRawDataManager" access="public" output="false" returntype="any">
		<cfreturn variables.LoadedObjects.RawData.Manager />
	</cffunction>

<!--- * * * * * * * * * * *--->
<!--- * * HAS BEEN SET * * --->
<!--- * * * * * * * * * * *--->

	<!--- get has been set --->
	<cffunction name="getHasBeenSet" access="public" output="false" returntype="struct">
		<cfreturn variables.LoadedObjects.RawData.HasBeenSet />
	</cffunction>
	
	<!--- clear has been set --->
	<cffunction name="clearHasBeenSet" access="public" output="false" returntype="any">
		<cfset variables.LoadedObjects.RawData.HasBeenSet = StructNew() />
		<cfreturn this />
	</cffunction>	

<!--- * * * * * * * * * * * * * --->
<!--- * * ON MISSING METHOD * * --->
<!--- * * * * * * * * * * * * * --->

	<!--- onMissingMethod: provides generic get/set/isnull functionality without having to write out the functions --->
	<cffunction name="onMissingMethod" access="public" output="false" returntype="any" hint="Provides generic get/set/is functionality without having to write out the functions">
		<cfargument name="MissingMethodName" type="string" />
		<cfargument name="MissingMethodArguments" type="struct" />

		<cfscript>
			var MissingMethodName = arguments.MissingMethodName;
			var MissingMethodArguments = arguments.MissingMethodArguments;
			var MissingMethodNameLength = Len(MissingMethodName);

			var PropertyName = '';
			var KeyList = '';
			var ReturnVal = '';

			var GetPrefix = 'get';
			var SetPrefix = 'set';
			var IsPrefix = 'is';

			var GetPrefixLength = Len(GetPrefix);
			var SetPrefixLength = Len(SetPrefix);
			var IsPrefixLength = Len(IsPrefix);
		</cfscript>

		<!--- get --->
		<cfif MissingMethodNameLength gt GetPrefixLength AND Left(MissingMethodName, GetPrefixLength) is GetPrefix>
			<cfset PropertyName = Right(MissingMethodName, MissingMethodNameLength - GetPrefixLength) />
			<cfreturn get(PropertyName) />

		<!--- set --->
		<cfelseif MissingMethodNameLength gt SetPrefixLength AND Left(MissingMethodName, SetPrefixLength) is SetPrefix>
			<cfset PropertyName = Right(MissingMethodName, MissingMethodNameLength - SetPrefixLength) />
			<cfset KeyList = StructKeyList(MissingMethodArguments) />

			<cfif ListLen(KeyList)>
				<cfreturn set(PropertyName, MissingMethodArguments[listfirst(KeyList)]) />
			<cfelse>
				<cfreturn set(PropertyName, '') />
			</cfif>

		<!--- is (null) --->
		<cfelseif MissingMethodNameLength gt IsPrefixLength AND Left(MissingMethodName, IsPrefixLength) is IsPrefix>
			<cfset PropertyName = Right(MissingMethodName, MissingMethodNameLength - IsPrefixLength) />
			<cfinvoke method="is" returnvariable="ReturnVal">
				<cfinvokeargument name="PropertyName" value="#PropertyName#" />
			</cfinvoke>
			<cfreturn ReturnVal />
		</cfif>
	</cffunction>

</cfcomponent>