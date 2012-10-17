<cfcomponent output="false">

	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfreturn this />
	</cffunction>

	<!--- set --->
	<cffunction name="set" access="public" output="false" returntype="any">
		<cfargument name="BO" type="any" required="true" />
		<cfargument name="PropertyName" type="string" required="true" />
		<cfargument name="Value" type="any" required="true" />
		<cfargument name="RowNum" type="numeric" required="true" />

		<cfscript>
			var BO = arguments.BO;
			var PropertyName = arguments.PropertyName;
			var Value = arguments.Value;
			var HasBeenSet = BO.getHasBeenSet();
			var CurrentRow = Max(1, arguments.RowNum);

			var ChildObject = '';
			var ChildObjectName = '';
			var ChildPropertyName = '';
		</cfscript>

		<!--- if property does not exist, check if child object property exists --->
		<cfif not BO.existsLoadedObjectsMetadata(PropertyName)>
			<cfthrow type="LoadedObjects" errorcode="LoadedObjects.Set.UndefinedProperty" message="Could not set property '#UCase(PropertyName)#' in component '#UCase(BO.getLoadedObjectsBOPath())#'." detail="Ensure that the property is defined, and that it is spelled correctly." />
		</cfif>

		<!--- set the value --->
		<cfset setRaw(BO, PropertyName, Value, CurrentRow) />

		<!--- mark has been set --->
		<cfset HasBeenSet[CurrentRow][PropertyName] = true />

		<!--- make sure totalrows is good --->
		<cfif CurrentRow gt BO.getTotalRows()>
			<cfset BO.setTotalRows(CurrentRow) />
		</cfif>

		<cfreturn BO />
	</cffunction>

	<!--- get --->
	<cffunction name="get" access="public" output="false" returntype="any">
		<cfargument name="BO" type="any" required="true" />
		<cfargument name="PropertyName" type="string" required="true" />
		<cfargument name="RowNum" type="numeric" required="true" />

		<cfscript>
			var BO = arguments.BO;
			var PropertyName = arguments.PropertyName;
			var HasBeenSet = BO.getHasBeenSet();
			var RawValue = '';
			var CurrentRow = Max(1, arguments.RowNum);

			var ChildObject = '';
			var ChildObjectName = '';
			var ChildPropertyName = '';
		</cfscript>

		<!--- if property does not exist, check if it is trying to call a property on a child object --->
		<cfif not BO.existsLoadedObjectsMetadata(PropertyName)>
			<cfthrow type="LoadedObjects" errorcode="LoadedObjects.Get.UndefinedProperty" message="Could not get property '#UCase(PropertyName)#' from component '#UCase(BO.getLoadedObjectsBOPath())#'." detail="Ensure that the property is defined, and that it is spelled correctly." />
		</cfif>

		<!--- if property has never run through the set routine, set it now to itself so that the raw value is processed --->
		<cfif not hasBeenSetProperty(BO, PropertyName, CurrentRow)>
			<cfif existsRaw(BO, PropertyName, CurrentRow)>
				<cfset RawValue = getRaw(BO, PropertyName, CurrentRow) />
			<cfelse>
				<cfset RawValue = BO.getLoadedObjectsMetadata(PropertyName, 'Default') />
			</cfif>

			<!--- if property is child object, see if raw data from parent could be used to populate it --->
			<cfif BO.getLoadedObjectsMetadata(PropertyName, 'IsObject')>
				<cfset RawValue.setRawData(getRawWithoutPrefix(BO, PropertyName, CurrentRow)) />
			</cfif>

			<!--- set the value manually here rather than using set() to avoid recursive stack overflow when overriding setters and need to call their getters to check the value --->
			<cfset setRaw(BO, PropertyName, RawValue, CurrentRow) />
			<cfset HasBeenSet[CurrentRow][PropertyName] = true />
		</cfif>

		<cfreturn getRaw(BO, PropertyName, CurrentRow) />
	</cffunction>

	<!--- is --->
	<cffunction name="is" access="public" output="false" returntype="boolean">
		<cfargument name="BO" type="any" required="true" />
		<cfargument name="PropertyName" type="string" required="true" />

		<cfscript>
			var BO = arguments.BO;
			var PropertyName = arguments.PropertyName;
		</cfscript>

		<cfif not existsLoadedObjectsMetadata(PropertyName)>
			<cfthrow type="LoadedObjects" errorcode="LoadedObjects.isNullValue.UndefinedProperty" message="The function #CustomFunctionName# does not exist, and property '#(PropertyName)#' could not be found." />
		</cfif>

		<cfreturn get(BO, PropertyName) neq getLoadedObjectsMetadata(PropertyName, 'NullValue') />
	</cffunction>

	<!--- loop --->
	<cffunction name="loop" access="public" output="false" returntype="boolean">
		<cfargument name="BO" type="any" required="true" />
		<cfargument name="Direction" type="string" default="forward" hint="Can be: forward, reverse" />

		<cfscript>
			var BO = arguments.BO;
			var Direction = arguments.Direction;
			var CurrentRow = BO.getCurrentRow(false);
			var TotalNumRows = BO.getTotalRows();
		</cfscript>

		<cfif TotalNumRows lte 0>
			<cfreturn False />
		</cfif>

		<!--- reverse --->
		<cfif Direction is 'Reverse'>

			<!--- if current row is bad, restart loop --->
			<cfif CurrentRow lt 1 OR CurrentRow gt TotalNumRows>
				<cfset BO.setCurrentRow(TotalNumRows) />
				<cfreturn True />

			<!--- if next record exists, increment row, return true --->
			<cfelseif CurrentRow gt 1>
				<cfset BO.setCurrentRow(CurrentRow - 1) />
				<cfreturn True />

			<!--- otherwise reset current row, return false --->
			<cfelse>
				<cfset BO.setCurrentRow(0) />
				<cfreturn False />
			</cfif>

		<!--- forward --->
		<cfelse>

			<!--- if current row is bad, restart loop --->
			<cfif CurrentRow lt 1 OR CurrentRow gt TotalNumRows>
				<cfset BO.setCurrentRow(1) />
				<cfreturn True />

			<!--- if next record exists, increment current row, return true --->
			<cfelseif CurrentRow lt TotalNumRows>
				<cfset BO.setCurrentRow(CurrentRow + 1) />
				<cfreturn True />

			<!--- otherwise reset current row, return false --->
			<cfelse>
				<cfset BO.setCurrentRow(0) />
				<cfreturn False />
			</cfif>
		</cfif>

		<cfreturn False />
	</cffunction>

	<!--- get all values for all properties --->
	<cffunction name="getAll" access="public" output="false" returntype="struct">
		<cfargument name="BO" type="any" required="true" />
		<cfargument name="RowNum" type="numeric" required="true" />

		<cfscript>
			var BO = arguments.BO;
			var CurrentRow = arguments.RowNum;

			var Properties = BO.getLoadedObjectsMetadata().Properties;
			var ReturnStruct = StructNew();
			var currentPropertyName = '';
		</cfscript>

		<cfloop collection="#Properties#" item="currentPropertyName">
			<cfset ReturnStruct[currentPropertyName] = BO.get(currentPropertyName, CurrentRow) />
		</cfloop>

		<cfreturn ReturnStruct />
	</cffunction>

	<!--- set all values from provided raw data--->
	<cffunction name="setAll" access="public" output="false" returntype="any">
		<cfargument name="BO" type="any" required="true" />
		<cfargument name="RawData" type="any" required="true" hint="Can be a struct or a query or an array of structs" />

		<cfscript>
			var BO = arguments.BO;
			var RawData = arguments.RawData;
		</cfscript>

		<!--- if is struct --->
		<cfif isStruct(RawData)>
			<cfreturn setAllFromStruct(BO, RawData) />

		<!--- array of structs, set each row --->
		<cfelseif isArray(RawData)>
			<cfreturn setAllFromArrayOfStructs(BO, RawData) />

		<!--- if is query --->
		<cfelseif isQuery(RawData)>
			<cfreturn setAllFromQuery(BO, RawData) />

		<!--- otherwise error --->
		<cfelse>
			<cfthrow type="LoadedObjects" errorcode="LoadedObjects.SetAll.InvalidRawData" />
		</cfif>

		<cfreturn BO />
	</cffunction>

	<!--- set all from struct --->
	<cffunction name="setAllFromStruct" access="private" output="false" returntype="any">
		<cfargument name="BO" type="any" required="true" />
		<cfargument name="StructData" type="struct" required="true" />

		<cfscript>
			var BO = arguments.BO;
			var StructData = arguments.StructData;

			var currentPropertyName = '';
		</cfscript>

		<cfloop collection="#StructData#" item="currentPropertyName">
			<cftry>
				<cfset BO.set(currentPropertyName, StructData[currentPropertyName]) />
				<cfcatch type="LoadedObjects"><!--- do nothing ---></cfcatch>
			</cftry>
		</cfloop>

		<cfreturn BO />
	</cffunction>

	<!--- set all from array of structs --->
	<cffunction name="setAllFromArrayOfStructs" access="private" output="false" returntype="any">
		<cfargument name="BO" type="any" required="true" />
		<cfargument name="ArrayData" type="array" required="true" />

		<cfscript>
			var BO = arguments.BO;
			var ArrayData = arguments.ArrayData;

			var currentIndex = '';
		</cfscript>

		<cfloop from="1" to="#ArrayLen(ArrayData)#" index="currentIndex">
			<cfif IsStruct(ArrayData[currentIndex])>
				<cfset BO.setCurrentRow(currentIndex) />
				<cfset setAllFromStruct(BO, ArrayData[currentIndex]) />
			</cfif>
		</cfloop>

		<cfreturn BO />
	</cffunction>

	<!--- set all from query --->
	<cffunction name="setAllFromQuery" access="private" output="false" returntype="any">
		<cfargument name="BO" type="any" required="true" />
		<cfargument name="QueryData" type="query" required="true" />

		<cfscript>
			var BO = arguments.BO;
			var QueryData = arguments.QueryData;
			var Properties = QueryData.ColumnList;

			var currentPropertyName = '';
			var currentIndex = 0;
		</cfscript>

		<cfloop query="QueryData">
			<cfset currentIndex = currentIndex + 1 />
			<cfloop list="#Properties#" index="currentPropertyName">
				<cftry>
					<cfset BO.setCurrentRow(currentIndex) />
					<cfset BO.set(currentPropertyName, QueryData[currentPropertyName]) />
					<cfcatch type="LoadedObjects"><!--- do nothing ---></cfcatch>
				</cftry>
			</cfloop>
		</cfloop>

		<cfreturn BO />
	</cffunction>

	<!--- set raw data --->
	<cffunction name="setRawData" access="public" output="false" returntype="any">
		<cfargument name="BO" type="any" required="true" />
		<cfargument name="RawData" type="any" default="" hint="Can be a struct, a struct of structs, a query, or an array of structs - defaults to an empty struct of structs." />

		<cfscript>
			var BO = arguments.BO;
			var RawData = arguments.RawData;
			var DataManager = BO.getRawDataManager();

			BO.setCurrentRow(0);
			BO.clearHasBeenSet();
		</cfscript>

		<cfif IsQuery(RawData)>
			<cfif IsObject(DataManager) AND IsQuery(DataManager.getRawData())>
				<cfset DataManager.init(RawData) />
			<cfelse>
				<cfset DataManager = createObject('component', 'types.query').init(RawData) />
			</cfif>
		<cfelseif IsArray(RawData) AND ArrayLen(RawData) AND IsStruct(RawData[1])>
			<cfif IsObject(DataManager) AND IsArray(DataManager.getRawData())>
				<cfset DataManager.init(RawData) />
			<cfelse>
				<cfset DataManager = createObject('component', 'types.arrayofstructs').init(RawData) />
			</cfif>
		<cfelseif IsStruct(RawData)>

			<!--- if rawdata is a single struct representing a single row, put it in a parent struct collection --->
			<cfif not StructKeyExists(RawData, '1')>
				<cfset RawData = { 1 = RawData } />
			</cfif>

			<cfif IsObject(DataManager) AND IsArray(DataManager.getRawData())>
				<cfset DataManager.init([RawData]) />
			<cfelse>
				<cfset DataManager = createObject('component', 'types.structofstructs').init(RawData) />
			</cfif>
		<cfelse>
			<cfif IsObject(DataManager) AND IsArray(DataManager.getRawData())>
				<cfset DataManager.init([StructNew()]) />
			<cfelse>
				<cfset DataManager = createObject('component', 'types.structofstructs').init({1 = StructNew()}) />
			</cfif>
		</cfif>

		<cfset BO.setTotalRows(DataManager.numRows()) />
		<cfset BO.setRawDataManager(DataManager) />

		<cfreturn BO />
	</cffunction>

<!--- * * * * * * * --->
<!--- * * UTILS * * --->
<!--- * * * * * * * --->

	<!--- has been set property --->
	<cffunction name="hasBeenSetProperty" access="private" output="false" returntype="boolean">
		<cfargument name="BO" type="any" required="true" />
		<cfargument name="PropertyName" type="string" required="true" />
		<cfargument name="RowNum" type="numeric" required="true" />

		<cfscript>
			var BO = arguments.BO;
			var PropertyName = arguments.PropertyName;
			var CurrentRow = arguments.RowNum;

			var HasBeenSet = BO.getHasBeenSet();
		</cfscript>

		<cfreturn StructKeyExists(HasBeenSet, CurrentRow) AND StructKeyExists(HasBeenSet[CurrentRow], PropertyName) AND HasBeenSet[CurrentRow][PropertyName] />
	</cffunction>

<!--- * * * * * * * * * * *--->
<!--- * * DATA MANAGER * * --->
<!--- * * * * * * * * * * *--->

	<!--- set raw --->
	<cffunction name="setRaw" access="private" output="false" returntype="any">
		<cfargument name="BO" type="any" required="true" />
		<cfargument name="PropertyName" type="string" required="true" />
		<cfargument name="Value" type="any" required="true" />
		<cfargument name="RowNum" type="numeric" required="true" />
		<cfset arguments.BO.getRawDataManager().setRaw(arguments.PropertyName, arguments.Value, arguments.RowNum) />
		<cfreturn this />
	</cffunction>

	<!--- get raw --->
	<cffunction name="getRaw" access="private" output="false" returntype="any">
		<cfargument name="BO" type="any" required="true" />
		<cfargument name="PropertyName" type="string" required="true" />
		<cfargument name="RowNum" type="numeric" required="true" />
		<cfreturn arguments.BO.getRawDataManager().getRaw(arguments.PropertyName, arguments.RowNum) />
	</cffunction>

	<!--- exists raw --->
	<cffunction name="existsRaw" access="private" output="false" returntype="boolean">
		<cfargument name="BO" type="any" required="true" />
		<cfargument name="PropertyName" type="string" required="true" />
		<cfargument name="RowNum" type="numeric" required="true" />
		<cfreturn arguments.BO.getRawDataManager().existsRaw(arguments.PropertyName, arguments.RowNum) />
	</cffunction>

	<!--- get raw without prefix --->
	<cffunction name="getRawWithoutPrefix" access="private" output="false" returntype="struct">
		<cfargument name="BO" type="any" required="true" />
		<cfargument name="Prefix" type="string" required="true" />
		<cfargument name="RowNum" type="numeric" required="true" />
		<cfreturn arguments.BO.getRawDataManager().getRawWithoutPrefix(arguments.Prefix, arguments.RowNum) />
	</cffunction>
</cfcomponent>