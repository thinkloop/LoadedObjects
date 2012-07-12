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

		<cfscript>
			var BO = arguments.BO;
			var PropertyName = arguments.PropertyName;
			var Value = arguments.Value;
		</cfscript>

		<!--- if property does not exist, error --->
		<cfif not BO.existsLoadedObjectsMetadata(PropertyName)>
			<cfthrow type="LoadedObjects" errorcode="LoadedObjects.Set.UndefinedProperty" message="Could not set property '#UCase(PropertyName)#' in component '#UCase(BO.getLoadedObjectsBOPath())#'." detail="Ensure that the property is defined, and that it is spelled correctly." />
		</cfif>

		<!--- if there are no rows, add one --->
		<cfif BO.numRows() lte 0>
			<cfset addRow(BO) />
			<cfset BO.setCurrentRow(1) />
		</cfif>

		<!--- set the value --->
		<cfset setRaw(BO, PropertyName, Value, BO.getCurrentRow()) />

		<cfreturn BO />
	</cffunction>

	<!--- get --->
	<cffunction name="get" access="public" output="false" returntype="any">
		<cfargument name="BO" type="any" required="true" />
		<cfargument name="PropertyName" type="string" required="true" />

		<cfscript>
			var BO = arguments.BO;
			var PropertyName = arguments.PropertyName;
		</cfscript>

		<!--- if property does not exist, error --->
		<cfif not BO.existsLoadedObjectsMetadata(PropertyName)>
			<cfthrow type="LoadedObjects" errorcode="LoadedObjects.Get.UndefinedProperty" message="Could not get property '#UCase(PropertyName)#' from component '#UCase(BO.getLoadedObjectsBOPath())#'." detail="Ensure that the property is defined, and that it is spelled correctly." />
		</cfif>

		<!--- if column doesn't exist, set default value --->
		<cfif not existsColumn(BO, PropertyName, BO.getCurrentRow())>
			<cfset set(BO, PropertyName, BO.getLoadedObjectsMetadata(PropertyName, 'Default')) />
		</cfif>

		<cfreturn getRaw(BO, PropertyName, BO.getCurrentRow()) />
	</cffunction>

	<!--- is --->
	<cffunction name="is" access="public" output="false" returntype="boolean">
		<cfargument name="BO" type="any" required="true" />
		<cfargument name="PropertyName" type="string" required="true" />

		<cfscript>
			var BO = arguments.BO;
			var PropertyName = arguments.PropertyName;
		</cfscript>

		<!--- if property is defined in PropertyList, find out if it is null --->
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
			var CurrentRow = BO.getCurrentRow(true);
			var TotalNumRows = BO.numRows();
		</cfscript>

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
		
		<cfscript>
			var BO = arguments.BO;
			var Properties = BO.getLoadedObjectsMetadata().Properties;
			var ReturnStruct = StructNew();
			var currentPropertyName = '';
		</cfscript>

		<cfloop collection="#Properties#" item="currentPropertyName">
			<cfset ReturnStruct[currentPropertyName] = BO.get(currentPropertyName) />
		</cfloop>

		<cfreturn ReturnStruct />
	</cffunction>

	<!--- set all values from provided raw data--->
	<cffunction name="setAll" access="public" output="false" returntype="any">
		<cfargument name="BO" type="any" required="true" />
		<cfargument name="RawData" type="any" required="true" hint="Can be a struct or a query or an array of structs" />
		<cfargument name="Row" type="numeric" default="1" hint="Specifies which row of the query or array of structs to use to populate the object" />

		<cfscript>
			var BO = arguments.BO;
			var Properties = BO.getLoadedObjectsMetadata().Properties;
			var RawData = arguments.RawData;
			var Row = arguments.Row;
			
			var CleanStructForPopulation = '';
			var QueryColumns = '';

			var currentPropertyName = '';
			
			/*
			var SubObjectPropertyNames = listLoadedObjectsPropertyNames({ IsObject : true });
			var currentSubObjectPropertyName = '';
			var currentLeftOfPropertyName = '';
			var currentRightOfPropertyName = '';
			*/
		</cfscript>
		
		<!--- if is struct or array of structs --->
		<cfif isStruct(RawData) OR isArray(RawData)>

			<!--- if is struct, use it --->
			<cfif isStruct(RawData)>
				<cfset CleanStructForPopulation = RawData />

			<!--- if is array get the struct out --->
			<cfelse>
				<cfset CleanStructForPopulation = RawData[Row]>
			</cfif>

			<!--- loop through this object's properties and set values from struct  --->
			<cfloop collection="#Properties#" item="currentPropertyName">
				<cfif StructKeyExists(CleanStructForPopulation, currentPropertyName)>
					<cfset BO.set(currentPropertyName, CleanStructForPopulation[currentPropertyName]) />

				<!--- check if property can be used to populate a sub-object's property --->
				<cfelse>
				<!---
					<cfloop list="#SubObjectPropertyNames#" index="currentSubObjectPropertyName">
						<cfset currentLeftOfPropertyName = Left(currentPropertyName, Len(currentSubObjectPropertyName)) />

						<!--- if current property matches a sub-object property, set it --->
						<cfif Len(currentPropertyName) gt Len(currentSubObjectPropertyName) AND currentLeftOfPropertyName is currentSubObjectPropertyName>
							<cfset currentRightOfPropertyName = Right(currentPropertyName, Len(currentPropertyName) - Len(currentSubObjectPropertyName)) />
							<cfif get(currentSubObjectPropertyName).existsLoadedObjectsMetadata(currentRightOfPropertyName)>
								<cfset get(currentSubObjectPropertyName).set(currentRightOfPropertyName, CleanStructForPopulation[currentPropertyName]) />
							</cfif>
						</cfif>
					</cfloop>	
				--->	
				</cfif>
			</cfloop>

		<!--- if is query --->
		<cfelseif isQuery(RawData)>
			<cfset QueryColumns = RawData.ColumnList />

			<!--- loop through this object's properties and set values from struct  --->
			<cfloop collection="#Properties#" item="currentPropertyName">
				<cfif listFindNoCase(QueryColumns, currentPropertyName)>
					<cfset BO.set(currentPropertyName, RawData[currentPropertyName][Row]) />
				</cfif>
			</cfloop>

		<!--- otherwise error --->
		<cfelse>
			<cfthrow type="LoadedObjects" errorcode="LoadedObjects.SetAll.InvalidRawData" />
		</cfif>

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

	<!--- exists column --->
	<cffunction name="existsColumn" access="public" output="false" returntype="boolean">
		<cfargument name="BO" type="any" required="true" />
		<cfargument name="PropertyName" type="string" required="true" />
		<cfargument name="RowNum" type="numeric" required="true" />
		<cfreturn arguments.BO.getRawDataManager().existsColumn(arguments.PropertyName, arguments.RowNum) />
	</cffunction>

	<!--- add row --->
	<cffunction name="addRow" access="public" output="false" returntype="any">
		<cfargument name="BO" type="any" required="true" />
		<cfset arguments.BO.getRawDataManager().addRow() />
		<cfreturn this />
	</cffunction>
</cfcomponent>