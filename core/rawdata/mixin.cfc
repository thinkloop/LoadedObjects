<cfcomponent output="false">

	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfscript>
			variables.LoadedObjects.RawData = StructNew();
			variables.LoadedObjects.RawData.Manager = '';
			variables.LoadedObjects.RawData.CurrentRow = 0;
			variables.LoadedObjects.RawData.HasBeenSet = StructNew();

			clear();
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
		<cfargument name="RowNum" type="numeric" default="#getCurrentRow()#" />
		<cfreturn getLoadedObjectsPlugin('RawData').set(this, arguments.PropertyName, arguments.Value, arguments.RowNum) />
	</cffunction>

	<!--- get --->
	<cffunction name="get" access="public" output="false" returntype="any">
		<cfargument name="PropertyName" type="string" required="true" />
		<cfargument name="RowNum" type="numeric" default="#getCurrentRow()#" />
		<cfreturn getLoadedObjectsPlugin('RawData').get(this, arguments.PropertyName, arguments.RowNum) />
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

	<!--- get all --->
	<cffunction name="getAll" access="public" output="false" returntype="struct">
		<cfargument name="RowNum" type="numeric" default="#getCurrentRow()#" />
		<cfreturn getLoadedObjectsPlugin('RawData').getAll(this, arguments.RowNum) />
	</cffunction>

	<!--- get all simple --->
	<cffunction name="getAllSimple" access="public" output="false" returntype="struct">
		<cfargument name="RowNum" type="numeric" default="#getCurrentRow()#" />
		<cfreturn getLoadedObjectsPlugin('RawData').getAll(this, arguments.RowNum, true) />
	</cffunction>

	<!--- set all --->
	<cffunction name="setAll" access="public" output="false" returntype="any">
		<cfargument name="RawData" type="any" default="" hint="Can be a struct, or a query, or an array of structs - defaults to an empty struct." />
		<cfargument name="RowNum" type="numeric" default="#getCurrentRow()#" />
		<cfreturn getLoadedObjectsPlugin('RawData').setAll(this, arguments.RawData, arguments.RowNum) />
	</cffunction>

	<!--- add all --->
	<cffunction name="addAll" access="public" output="false" returntype="any">
		<cfargument name="RawData" type="any" default="" hint="Can be a struct, or a query, or an array of structs - defaults to an empty struct." />
		<cfreturn getLoadedObjectsPlugin('RawData').addAll(this, arguments.RawData) />
	</cffunction>

	<!--- set all from query row --->
	<cffunction name="setAllFromQueryRow" access="public" output="false" returntype="any">
		<cfargument name="RawData" type="any" default="" hint="Query." />
		<cfargument name="QueryRow" type="numeric" default="1" />
		<cfargument name="RowNum" type="numeric" default="#getCurrentRow()#" />
		<cfreturn getLoadedObjectsPlugin('RawData').setAllFromQueryRow(this, arguments.RawData, arguments.RowNum, arguments.QueryRow) />
	</cffunction>

<!--- * * * * * * *--->
<!--- * * LOOP * * --->
<!--- * * * * * * *--->

	<!--- loop --->
	<cffunction name="loop" access="public" output="false" returntype="boolean">
		<cfargument name="Direction" type="string" default="forward" hint="Can be: forward, reverse" />
		<cfargument name="StartRow" type="number" default="0" hint="The row num to start looping from. 0 ignores this property and starts from beginning." />
		<cfargument name="EndRow" type="number" default="0" hint="Last row num to stop looping at. 0 ignores this property and loops entire collection." />
		<cfreturn getLoadedObjectsPlugin('RawData').loop(this, arguments.Direction, arguments.StartRow, arguments.EndRow) />
	</cffunction>

	<!--- current row --->
	<cffunction name="getCurrentRow" access="public" output="false" returntype="numeric" hint="Returns the current row">
		<cfscript>
			var RowNum = variables.LoadedObjects.RawData.CurrentRow;
			var TotalRows = getTotalRows();

			if (RowNum lte 0) {
				return 0;
			}

			if (RowNum gt TotalRows) {
				return TotalRows;
			}

			return RowNum;
		</cfscript>
	</cffunction>
	<cffunction name="setCurrentRow" access="public" output="false" returntype="any" hint="RowNum is usually 0 (which returns 1 from the getter by default), unless we are in the middle of looping.">
		<cfargument name="RowNum" type="numeric" required="true" />
		<cfset variables.LoadedObjects.RawData.CurrentRow = arguments.RowNum />
		<cfreturn this />
	</cffunction>

	<!--- total rows --->
	<cffunction name="getTotalRows" access="public" output="false" returntype="numeric" hint="The total number of rows, whether they actually exist in the underlying rawdata or not.">
		<cfset RawDataManager = getRawDataManager() />
		<cfif IsObject(RawDataManager)>
			<cfreturn RawDataManager.numRows() />
		<cfelse>
			<cfreturn 0 />
		</cfif>
	</cffunction>
<!---
	<cffunction name="setTotalRows" access="public" output="false" returntype="any" hint="The total number of rows in the recordset.">
		<cfargument name="TotalNumRows" type="numeric" required="true" />
		<cfset variables.LoadedObjects.RawData.TotalRows = arguments.TotalNumRows />
		<cfreturn this />
	</cffunction>
--->
	<!--- should probably not be used, but maybe needed, not used for now
	<cffunction name="getActualTotalRows" access="public" output="false" returntype="numeric" hint="The total number of rows in the underlying rawdata.">
		<cfreturn getRawDataManager().numRows() />
	</cffunction>
	--->

	<cffunction name="swapRows" access="public" output="false" returntype="any">
		<cfargument name="RowNum1" type="numeric" required="true" />
		<cfargument name="RowNum2" type="numeric" required="true" />
		<cfreturn getLoadedObjectsPlugin('RawData').swapRows(this, arguments.RowNum1, arguments.RowNum2) />
		<cfreturn this />
	</cffunction>

<!--- * * * * * * * * --->
<!--- * * Rows * * * *--->
<!--- * * * * * * * * --->

	<!--- remove row --->
	<cffunction name="removeRow" access="public" output="false" returntype="any">
		<cfargument name="RowNum" type="numeric" default="#getCurrentRow()#" />
		<cfreturn getLoadedObjectsPlugin('RawData').removeRow(this, arguments.RowNum) />
	</cffunction>


<!--- * * * * * * * * * *--->
<!--- * * RawData * * * *--->
<!--- * * * * * * * * * *--->

	<!--- get raw data --->
	<cffunction name="getRawData" access="public" output="false" returntype="any">
		<cfreturn getRawDataManager().getRawData() />
	</cffunction>

	<!--- set raw data --->
	<cffunction name="setRawData" access="public" output="false" returntype="any">
		<cfargument name="RawData" type="any" default="" hint="Can be a struct, or a query, or an array of structs - defaults to an empty struct." />
		<cfreturn getLoadedObjectsPlugin('RawData').setRawData(this, arguments.RawData) />
	</cffunction>

	<!--- get raw data manager --->
	<cffunction name="getRawDataManager" access="public" output="false" returntype="any">
		<cfreturn variables.LoadedObjects.RawData.Manager />
	</cffunction>

	<!--- set raw data manager --->
	<cffunction name="setRawDataManager" access="public" output="false" returntype="any">
		<cfargument name="RawDataManager" type="any" required="true" />
		<cfreturn variables.LoadedObjects.RawData.Manager = arguments.RawDataManager />
	</cffunction>

	<!--- clear --->
	<cffunction name="clear" access="public" output="false" returntype="any">
		<cfreturn getLoadedObjectsPlugin('RawData').clear(this) />
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

	<!--- all has been set
	<cffunction name="allHasBeenSet" access="public" output="false" returntype="any">
		<cfscript>
			var Properties = getLoadedObjectsMetadata().Properties;
			var RawDataManager = getRawDataManager();

			var HasBeenSetStruct = StructNew();

			var currentProperty = '';
		</cfscript>

		<cfloop condition="loop()">
			<cfset HasBeenSetStruct[getCurrentRow()] = StructNew() />
			<cfloop collection="#Properties#" item="currentProperty">
				<cfif RawDataManager.existsRaw(currentProperty, getCurrentRow())>
					<cfset HasBeenSetStruct[getCurrentRow()][currentProperty] = true />
				</cfif>
			</cfloop>
		</cfloop>

		<cfset variables.LoadedObjects.RawData.HasBeenSet = HasBeenSetStruct />

		<cfreturn this />
	</cffunction>
--->
<!--- * * * * * * * * * * * * * --->
<!--- * * ON MISSING METHOD * * --->
<!--- * * * * * * * * * * * * * --->

	<!--- onMissingMethod: provides generic get/set/isnull functionality without having to write out the functions
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
			<cfset KeyList = StructKeyList(MissingMethodArguments) />

			<cfif ListLen(KeyList) gte 1>
				<cfreturn get(PropertyName, MissingMethodArguments[ListGetat(KeyList, 1)]) />
			<cfelse>
				<cfreturn get(PropertyName) />
			</cfif>

		<!--- set --->
		<cfelseif MissingMethodNameLength gt SetPrefixLength AND Left(MissingMethodName, SetPrefixLength) is SetPrefix>
			<cfset PropertyName = Right(MissingMethodName, MissingMethodNameLength - SetPrefixLength) />
			<cfset KeyList = StructKeyList(MissingMethodArguments) />

			<cfif ListLen(KeyList) gte 2>
				<cfreturn set(PropertyName, MissingMethodArguments[ListGetat(KeyList, 1)], MissingMethodArguments[ListGetat(KeyList, 2)]) />
			<cfelseif ListLen(KeyList) gte 1>

				<cfreturn set(PropertyName, MissingMethodArguments[ListGetat(KeyList, 1)]) />
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
--->
</cfcomponent>