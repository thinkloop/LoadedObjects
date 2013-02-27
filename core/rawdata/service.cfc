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

		<!--- if property does not exist, throw --->
		<cfif not BO.existsLoadedObjectsMetadata(PropertyName)>
			<cfthrow type="LoadedObjects" errorcode="LoadedObjects.Set.UndefinedProperty" message="Could not set property '#UCase(PropertyName)#' in component '#UCase(BO.getLoadedObjectsBOPath())#'." detail="Ensure that the property is defined, and that it is spelled correctly." />
		</cfif>

		<!--- set the value --->
		<cfset setRaw(BO, PropertyName, Value, CurrentRow) />

		<!--- mark has been set --->
		<cfset HasBeenSet[CurrentRow][PropertyName] = true />

		<!--- make sure totalrows is good
		<cfif CurrentRow gt BO.getTotalRows()>
			<cfset BO.setTotalRows(CurrentRow) />
		</cfif>
--->
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

				<!--- if property is child object, see if raw data from parent could be used to populate it --->
				<cfif BO.getLoadedObjectsMetadata(PropertyName, 'IsObject')>
					<cfset RawValue.setRawData(getRawWithoutPrefix(BO, PropertyName, CurrentRow)) />
				</cfif>
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
		<cfargument name="StartRow" type="number" default="0" hint="The row num to start looping from. 0 ignores this property and starts from beginning." />
		<cfargument name="EndRow" type="number" default="0" hint="Last row num to stop looping at. 0 loops entire collection." />

		<cfscript>
			var BO = arguments.BO;
			var Direction = arguments.Direction;
			var StartRow = arguments.StartRow;
			var EndRow = arguments.EndRow;
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
				<cfif StartRow gte 1 AND StartRow lte TotalNumRows>
					<cfset BO.setCurrentRow(StartRow) />
				<cfelse>
					<cfset BO.setCurrentRow(TotalNumRows) />
				</cfif>
				<cfreturn True />

			<!--- if next record exists, increment row, return true --->
			<cfelseif CurrentRow gt 1 AND (EndRow lte 0 OR CurrentRow gt EndRow)>
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
				<cfif StartRow gte 1 AND StartRow lte TotalNumRows>
					<cfset BO.setCurrentRow(StartRow) />
				<cfelse>
					<cfset BO.setCurrentRow(1) />
				</cfif>
				<cfreturn True />

			<!--- if next record exists, increment current row, return true --->
			<cfelseif CurrentRow lt TotalNumRows AND (EndRow lte 0 OR CurrentRow lt EndRow)>
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

	<!--- get all --->
	<cffunction name="getAll" access="public" output="false" returntype="struct">
		<cfargument name="BO" type="any" required="true" />
		<cfargument name="RowNum" type="numeric" required="true" />
		<cfargument name="NoChildObjects" type="boolean" default="false" hint="If true, excludes child cfcs from result." />

		<cfscript>
			var BO = arguments.BO;
			var CurrentRow = arguments.RowNum;
			var NoChildObjects = arguments.NoChildObjects;

			var Properties = BO.getLoadedObjectsMetadata().Properties;
			var ReturnStruct = StructNew();
			var currentPropertyName = '';
		</cfscript>

		<cfloop collection="#Properties#" item="currentPropertyName">
			<cfif not NoChildObjects OR not BO.getLoadedObjectsMetaData(currentPropertyName, 'IsObject')>
				<cfset ReturnStruct[currentPropertyName] = BO.get(currentPropertyName, CurrentRow) />
			</cfif>
		</cfloop>

		<cfreturn ReturnStruct />
	</cffunction>

	<!--- add all --->
	<cffunction name="addAll" access="public" output="false" returntype="any">
		<cfargument name="BO" type="any" required="true" />
		<cfargument name="RawData" type="any" required="true" hint="Can be a struct or a query or an array of structs" />

		<cfscript>
			var BO = arguments.BO;
			var RawData = arguments.RawData;
		</cfscript>

		<cfreturn setAll(BO, RawData, BO.getTotalRows() + 1) />
	</cffunction>

	<!--- set all --->
	<cffunction name="setAll" access="public" output="false" returntype="any">
		<cfargument name="BO" type="any" required="true" />
		<cfargument name="RawData" type="any" required="true" hint="Can be a struct or a query or an array of structs" />
		<cfargument name="RowNum" type="numeric" required="true" />

		<cfscript>
			var BO = arguments.BO;
			var RawData = arguments.RawData;
			var RowNum = Max(arguments.RowNum, 1);

			var RawDataManager = BO.getRawDataManager();
		</cfscript>

		<!--- if is struct --->
		<cfif isStruct(RawData)>
			<cfreturn setAllFromStruct(BO, RawData, RowNum) />

		<!--- array of structs, set each row --->
		<cfelseif isArray(RawData)>
			<cfreturn setAllFromArrayOfStructs(BO, RawData, RowNum) />

		<!--- if is query --->
		<cfelseif isQuery(RawData)>
			<cfreturn setAllFromQuery(BO, RawData, RowNum) />

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
		<cfargument name="RowNum" type="numeric" required="true" />

		<cfscript>
			var BO = arguments.BO;
			var StructData = arguments.StructData;
			var RowNum = Max(arguments.RowNum, 1);

			var currentPropertyName = '';
		</cfscript>

		<cfloop collection="#StructData#" item="currentPropertyName">
			<cftry>
				<cfset BO.set(currentPropertyName, StructData[currentPropertyName], RowNum) />
				<cfcatch type="LoadedObjects"><!--- do nothing ---></cfcatch>
			</cftry>
		</cfloop>

		<cfreturn BO />
	</cffunction>

	<!--- set all from array of structs --->
	<cffunction name="setAllFromArrayOfStructs" access="private" output="false" returntype="any">
		<cfargument name="BO" type="any" required="true" />
		<cfargument name="ArrayData" type="array" required="true" />
		<cfargument name="RowNum" type="numeric" required="true" />

		<cfscript>
			var BO = arguments.BO;
			var ArrayData = arguments.ArrayData;
			var RowNum = Max(arguments.RowNum, 1);

			var currentIndex = '';
		</cfscript>

		<cfloop from="1" to="#ArrayLen(ArrayData)#" index="currentIndex">
			<cfif IsStruct(ArrayData[currentIndex])>
				<cfset setAllFromStruct(BO, ArrayData[currentIndex], currentIndex + RowNum - 1) />
			</cfif>
		</cfloop>

		<cfreturn BO />
	</cffunction>

	<!--- set all from query --->
	<cffunction name="setAllFromQuery" access="private" output="false" returntype="any">
		<cfargument name="BO" type="any" required="true" />
		<cfargument name="QueryData" type="query" required="true" />
		<cfargument name="RowNum" type="numeric" required="true" />

		<cfscript>
			var BO = arguments.BO;
			var QueryData = arguments.QueryData;
			var ColumnList = QueryData.ColumnList;
			var RowNum = Max(arguments.RowNum, 1);

			var currentColumnName = '';
			var currentIndex = 0;
		</cfscript>

		<cfloop query="QueryData">
			<cfset currentIndex = QueryData.CurrentRow + RowNum - 1 />
			<cfloop list="#ColumnList#" index="currentColumnName">
				<cfif BO.existsLoadedObjectsMetadata(currentColumnName)>
					<cfset BO.set(currentColumnName, QueryData[currentColumnName], currentIndex) />
				</cfif>
			</cfloop>
		</cfloop>

		<cfreturn BO />
	</cffunction>

	<!--- set all from query row --->
	<cffunction name="setAllFromQueryRow" access="public" output="false" returntype="any">
		<cfargument name="BO" type="any" required="true" />
		<cfargument name="QueryData" type="query" required="true" />
		<cfargument name="RowNum" type="numeric" required="true" />
		<cfargument name="QueryRow" type="numeric" required="true" />

		<cfscript>
			var BO = arguments.BO;
			var QueryData = arguments.QueryData;
			var ColumnList = QueryData.ColumnList;
			var RowNum = Max(arguments.RowNum, 1);
			var QueryRow = arguments.QueryRow;

			var currentColumnName = '';
		</cfscript>

		<cfloop list="#ColumnList#" index="currentColumnName">
			<cfif BO.existsLoadedObjectsMetadata(currentColumnName)>
				<cfset BO.set(currentColumnName, QueryData[currentColumnName][QueryRow], RowNum) />
			</cfif>
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

			<!--- if rawdata is a single struct representing a single row, put it in parent struct collection --->
			<cfif StructCount(RawData) AND not StructKeyExists(RawData, '1')>
				<cfset RawData = { 1 = RawData } />
			</cfif>

			<cfif IsObject(DataManager) AND IsStruct(DataManager.getRawData())>
				<cfset DataManager.init(RawData) />
			<cfelse>
				<cfset DataManager = createObject('component', 'types.structofstructs').init(RawData) />
			</cfif>
		<cfelse>
			<cfset DataManager = createObject('component', 'types.structofstructs').init(StructNew()) />
		</cfif>
<!---
		<cfset BO.setTotalRows(DataManager.numRows()) />
--->
		<cfset BO.setRawDataManager(DataManager) />

		<cfreturn BO />
	</cffunction>

	<!--- clear --->
	<cffunction name="clear" access="public" output="false" returntype="any">
		<cfargument name="BO" type="any" required="true" />

		<cfscript>
			var BO = arguments.BO;
			var RawDataManager = BO.getRawDataManager();
		</cfscript>

		<cfif IsObject(RawDataManager)>
			<cfset RawDataManager.clear() />
		<cfelse>
			<cfset setRawData(BO, StructNew()) />
		</cfif>

		<cfset BO.clearHasBeenSet() />

		<cfreturn BO />
	</cffunction>

<!--- * * * * * * * * --->
<!--- * * Rows * * * *--->
<!--- * * * * * * * * --->

	<!--- swap rows --->
	<cffunction name="swapRows" access="public" output="false" returntype="any">
		<cfargument name="BO" type="any" required="true" />
		<cfargument name="RowNum1" type="numeric" required="true" />
		<cfargument name="RowNum2" type="numeric" required="true" />

		<cfset swapRawRows(arguments.BO, arguments.RowNum1, arguments.RowNum2) />
		<cfset swapHasBeenSet(arguments.BO, arguments.RowNum1, arguments.RowNum2) />

		<cfreturn BO />
	</cffunction>

	<!--- remove row --->
	<cffunction name="removeRow" access="public" output="false" returntype="any">
		<cfargument name="BO" type="any" required="true" />
		<cfargument name="RowNum" type="numeric" required="true" />

		<cfscript>
			var BO = arguments.BO;
			var RowNum = arguments.RowNum;
			var TotalRows = BO.getTotalRows();
			var DataManager = BO.getRawDataManager();
		</cfscript>

		<cfif RowNum lte 0 OR RowNum gt TotalRows>
			<cfreturn BO />
		</cfif>

		<cfset DataManager.removeRow(RowNum) />
<!---
		<cfset BO.setTotalRows(DataManager.numRows()) />
--->
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

	<cffunction name="swapHasBeenSet" access="private" output="false" returntype="any">
		<cfargument name="BO" type="any" required="true" />
		<cfargument name="RowNum1" type="numeric" required="true" />
		<cfargument name="RowNum2" type="numeric" required="true" />

		<cfscript>
			var BO = arguments.BO;
			var RowNum1 = arguments.RowNum1;
			var RowNum2 = arguments.RowNum2;

			var HasBeenSet = BO.getHasBeenSet();
			var Data1 = StructNew();
			var Data2 = StructNew();

			if (StructKeyExists(HasBeenSet, RowNum1)) {
				Data1 = HasBeenSet[RowNum1];
			}
			if (StructKeyExists(HasBeenSet, RowNum2)) {
				Data2 = HasBeenSet[RowNum2];
			}

			HasBeenSet[RowNum1] = Data2;
			HasBeenSet[RowNum2] = Data1;
		</cfscript>

		<cfreturn BO />
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

	<!--- swap rows --->
	<cffunction name="swapRawRows" access="private" output="false" returntype="any">
		<cfargument name="BO" type="any" required="true" />
		<cfargument name="RowNum1" type="numeric" required="true" />
		<cfargument name="RowNum2" type="numeric" required="true" />
		<cfreturn arguments.BO.getRawDataManager().swapRows(arguments.RowNum1, arguments.RowNum2) />
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