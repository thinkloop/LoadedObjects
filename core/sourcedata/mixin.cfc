<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Baz K. (bk@thinkloop.com) - 01/01/2008
Edited By: Baz K. (bk@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">
	
	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="any" hint="Set source data by supplying a query or an array-of-structs.">
		<cfscript>
			setSourceData(StructNew());
		</cfscript>
		<cfreturn this />
	</cffunction>	

	<!--- set source data from raw data --->
	<cffunction name="setSourceData" access="public" output="false" returntype="any" hint="Returns source data based on what raw data was supplied.">
		<cfargument name="Raw" type="any" required="true" hint="struct or query or array-of-structs" />
		
		<cfset variables.LoadedObjects.SourceData = '' />
		
		<cfif isQuery(arguments.Raw)>
			<cfset variables.LoadedObjects.SourceData = createObject('component', 'types.query').init(this, arguments.Raw) />
		<cfelseif isArray(arguments.Raw)>
			<cfset variables.LoadedObjects.SourceData = createObject('component', 'types.arrayofstructs').init(this, arguments.Raw) />
		<cfelseif isStruct(arguments.Raw)>
			<cfset variables.LoadedObjects.SourceData = createObject('component', 'types.arrayofstructs').init(this, [arguments.Raw]) />
		<cfelse>
			<cfthrow type="LoadedObjects" errorcode="LoadedObjects.seSourceData.InvalidType" message="Could not set 'SOURCEDATA' because RAW is not of a supported type." detail="Ensure that the provided recordset is a a struct, query or array-of-structs." />
		</cfif>
		
		<cfreturn this />
	</cffunction>
	
	<!--- get source data --->
	<cffunction name="getSourceData" access="public" output="false" returntype="any">
		<cfreturn variables.LoadedObjects.SourceData />
	</cffunction>
		
<!--- * * * * * * * * *--->
<!--- * * INSTANCE * * --->
<!--- * * * * * * * * *--->

	<!--- set --->
	<cffunction name="set" access="public" output="false" returntype="any">
		<cfargument name="PropertyName" type="string" required="true" />
		<cfargument name="Value" type="any" required="true" />

		<cfset var CustomFunctionName = "set#arguments.PropertyName#" />
		<cfset var CustomFunction = "" />

		<!--- if a real function exists, use it --->
		<cfif existsFunction(CustomFunctionName)>		
			<cfset CustomFunction = variables[CustomFunctionName] />
			<cfset CustomFunction(arguments.Value) />

		<!--- otherwise, set it --->
		<cfelse>	
			<cfset getSourceData().set(arguments.PropertyName, arguments.Value) />
		</cfif>

		<cfreturn this />
	</cffunction>

	<!--- get --->
	<cffunction name="get" access="public" output="false" returntype="any">
		<cfargument name="PropertyName" type="string" required="true" />

		<cfset var CustomFunctionName="get#arguments.PropertyName#" />
		<cfset var CustomFunction="" />

		<!--- if a real function exists, use it --->
		<cfif existsFunction(CustomFunctionName)>
			<cfset CustomFunction=variables[CustomFunctionName] />		
			<cfreturn CustomFunction() />

		<!--- get property from source data (see abstract_type for this logic) --->
		<cfelse>
			<cfreturn getSourceData().get(arguments.PropertyName) />
		</cfif>	
	</cffunction>
	
	<!--- is null --->
	<cffunction name="is" access="public" output="false" returntype="boolean">
		<cfargument name="PropertyName" type="string" />

		<cfset var CustomFunctionName = "is#arguments.PropertyName#" />
		<cfset var CustomFunction = "" />

		<!--- if a real function exists, use it --->
		<cfif existsFunction(CustomFunctionName)>
			<cfset CustomFunction = variables[CustomFunctionName] />
			<cfreturn CustomFunction() />

		<!--- if property is defined in PropertyList, find out if it is null --->
		<cfelseif existsLoadedObjectsMetadata(arguments.PropertyName)>
			<cfreturn get(arguments.PropertyName) neq getLoadedObjectsMetadata(arguments.PropertyName, 'NullValue') />

		<!--- otherwise, throw error --->
		<cfelse>
			<cfthrow type="LoadedObjects" errorcode="LoadedObjects.isNullValue.UndefinedProperty" message="The function #CustomFunctionName# does not exist, and property '#(arguments.PropertyName)#' could not be found." />
		</cfif>
	</cffunction>
	
	<!--- display --->
	<cffunction name="display" access="public" output="false" returntype="any">
		<cfargument name="PropertyName" type="string" />

		<cfset var CustomFunctionName = "display#arguments.PropertyName#" />
		<cfset var CustomFunction = "" />

		<!--- if a real function exists, use it --->
		<cfif existsFunction(CustomFunctionName)>
			<cfset CustomFunction = variables[CustomFunctionName] />
			<cfreturn CustomFunction() />

		<!--- otherwise, get display name --->
		<cfelse>
			<cfreturn getLoadedObjectsMetadata(arguments.PropertyName, 'DisplayName') />
		</cfif>
	</cffunction>	
			
<!--- * * * * * * * * * *--->
<!--- * * COLLECTION * * --->
<!--- * * * * * * * * * *--->

	<!--- loop --->
	<cffunction name="loop" access="public" output="false" returntype="boolean">
		<cfargument name="Direction" type="string" default="forward" hint="Can be: forward, reverse" />		
		<cfreturn getSourceData().loop(arguments.Direction) />
	</cffunction>
	
	<!--- current row  --->
	<cffunction name="getCurrentRow" access="public" output="false" returntype="numeric" hint="Returns the current row">
		<cfreturn getSourceData().getCurrentRow() />
	</cffunction>
	
	<!--- num rows --->
	<cffunction name="numRows" access="public" output="false" returntype="numeric">
		<cfreturn getSourceData().numRows() />
	</cffunction>	
		
	<!--- has rows --->
	<cffunction name="hasRows" access="public" output="false" returntype="boolean">
		<cfreturn getSourceData().numRows() gt 0 />
	</cffunction>
	
	<!--- seek: moves the cursor to a specific row based on a value of a given property. If the value is not unique within the sourcedata, it will move to the first instance of the value. This was intended for use with primary keys. --->
	<cffunction name="seek" access="public" output="false" returntype="struct">
		<cfargument name="PropertyName" type="string" required="true" />
		<cfargument name="Value" type="any" required="true" />
		
		<cfreturn getSourceData().seek(arguments.PropertyName, arguments.Value) />
	</cffunction>
			
	<!--- list property values --->
	<cffunction name="listPropertyValues" access="public" output="false" returntype="string">
		<cfargument name="PropertyName" type="string" required="true" hint="Property/column name" />
		<cfset PropertyNameList = '' />
		<cfloop condition="#loop()#">
			<cfset ListAppend(PropertyNameList, get(arguments.PropertyName)) />
		</cfloop>
		<cfreturn PropertyNameList />
	</cffunction>
		
	<!--- get all properties --->
	<cffunction name="getAll" access="public" output="false" returntype="struct">

		<cfscript>
			var collection = getLoadedObjectsMetadata().Properties;
			var ReturnStruct = StructNew();
			var currentPropertyName = '';
		</cfscript>
		
		<!--- set all properties to default --->
		<cfloop collection="#collection#" item="currentPropertyName">
			<cfset ReturnStruct[currentPropertyName] = get(currentPropertyName) />
		</cfloop>
		
		<cfreturn ReturnStruct />
	</cffunction>	
	
	<!--- set all properties --->
	<cffunction name="setAll" access="public" output="false" returntype="any">
		<cfargument name="Memento" type="any" required="true" hint="Can be a struct or a query or an array of structs" />
		<cfargument name="Row" type="numeric" default="1" hint="Specifies which row of the query or array of structs to use to populate the object" />

		<cfscript>
			var collection = getLoadedObjectsMetadata().Properties;
			var StructToPopulate = '';
			var QueryColumns = '';
			var currentPropertyName = '';
		</cfscript>

		<!--- if is struct or array of structs --->
		<cfif isStruct(arguments.Memento) OR isArray(arguments.Memento)>
			
			<!--- if is struct, use it --->
			<cfif isStruct(arguments.Memento)>
				<cfset StructToPopulate = arguments.Memento />

			<!--- if is array get the struct out --->
			<cfelse>
				<cfset StructToPopulate = arguments.Memento[arguments.Row]>
			</cfif>
		
			<!--- loop through this object's properties and set values from struct  --->
			<cfloop collection="#collection#" item="currentPropertyName">
				<cfif StructKeyExists(StructToPopulate, currentPropertyName)>			
					<cfset set(currentPropertyName, StructToPopulate[currentPropertyName]) />
				</cfif>
			</cfloop>

		<!--- if is query --->
		<cfelseif isQuery(arguments.Memento)>
			<cfset QueryColumns = arguments.Memento.ColumnList />

			<!--- loop through this object's properties and set values from struct  --->
			<cfloop collection="#collection#" item="currentPropertyName">
				<cfif listFindNoCase(QueryColumns, currentPropertyName)>
					<cfset set(currentPropertyName, arguments.Memento[currentPropertyName][arguments.Row]) />
				</cfif>
			</cfloop>

		<!--- otherwise error --->
		<cfelse>
			<cfthrow />
		</cfif>

		<cfreturn this />
	</cffunction>	
	
	<!--- clear --->
	<cffunction name="clear" access="public" output="false" returntype="any" hint="Sets all properties to defaults">
		
		<cfscript>
			var collection = getLoadedObjectsMetadata().Properties;
			var currentPropertyName = '';
		</cfscript>
		
		<!--- init source data --->
		<cfif not isObject(getSourceData())>
			<cfset setSourceData(StructNew()) />			
		</cfif>
		
		<!--- set all properties to default --->
		<cfloop collection="#collection#" item="currentPropertyName">
			<cfset set(currentPropertyName, getLoadedObjectsMetadata(currentPropertyName, 'Default')) />
		</cfloop>

		<cfreturn this />
	</cffunction>
		
	<!--- raw --->
	<cffunction name="raw" access="public" output="false" returntype="any">
		<cfreturn getSourceData().raw() />
	</cffunction>
		
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
			var DisplayPrefix = 'display';
			var IsPrefix = 'is';
			
			var GetPrefixLength = Len(GetPrefix);
			var SetPrefixLength = Len(SetPrefix);
			var DisplayPrefixLength = Len(DisplayPrefix);
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

		<!--- display --->
		<cfelseif MissingMethodNameLength gt DisplayPrefixLength AND Left(MissingMethodName, DisplayPrefixLength) is DisplayPrefix>
			<cfset PropertyName = Right(MissingMethodName, MissingMethodNameLength - DisplayPrefixLength) />
			<cfreturn display(PropertyName) />
			
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