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

			var HasBeenSet = BO.getHasBeenSet();
			
			var ListOfLinkedObjects = '';
			var currentLinkedObjectName = '';
			var LinkedObject = '';
			var FragmentName = '';
		</cfscript>

		<!--- if property does not exist, check if it is trying to call a property on a child object --->
		<cfif not BO.existsLoadedObjectsMetadata(PropertyName)>
			<cfset ListOfLinkedObjects = BO.listLoadedObjectsPropertyNames({ IsObject : true }) />
			<cfloop list="#ListOfLinkedObjects#" index="currentLinkedObjectName">

				<!--- check if the property partly matches one of its linked object names --->
				<cfif Len(PropertyName) gt Len(currentLinkedObjectName) AND Left(PropertyName, Len(currentLinkedObjectName)) is currentLinkedObjectName>
					<cfset LinkedObject = get(BO, currentLinkedObjectName) />
					<cfset FragmentName = Right(PropertyName, Len(PropertyName) - Len(currentLinkedObjectName)) />

					<!--- the 'return' statement wrapped in the try/catch runs this 'set' function recursively, digging deeper into each child component until it finds the property it's looking for - or not. When it doesn't find the property, rather than error out, we prefer to continue looping and trying other sub-objects. If nothing is found after that, an error will be thrown below. --->
					<cftry>
						<cfreturn set(LinkedObject, FragmentName, Value) />
						<cfcatch type="LoadedObjects"><!--- do nothing ---></cfcatch>
					</cftry>
				</cfif>
			</cfloop>

			<cfthrow type="LoadedObjects" errorcode="LoadedObjects.Set.UndefinedProperty" message="Could not set property '#UCase(PropertyName)#' in component '#UCase(BO.getLoadedObjectsBOPath())#'." detail="Ensure that the property is defined, and that it is spelled correctly." />
		</cfif>

		<!--- set the value --->
		<cfset setRaw(BO, PropertyName, Value, BO.getCurrentRow()) />

		<!--- mark has been set --->
		<cfset HasBeenSet[BO.getCurrentRow()][PropertyName] = true />

		<cfreturn BO />
	</cffunction>

	<!--- get --->
	<cffunction name="get" access="public" output="false" returntype="any">
		<cfargument name="BO" type="any" required="true" />
		<cfargument name="PropertyName" type="string" required="true" />

		<cfscript>
			var BO = arguments.BO;
			var PropertyName = arguments.PropertyName;
			var HasBeenSet = BO.getHasBeenSet();
			var RawValue = '';

			var ListOfLinkedObjects = '';
			var currentLinkedObjectName = '';
			var LinkedObject = '';
			var FragmentName = '';
		</cfscript>

		<!--- if property does not exist, check if it is trying to call a property on a child object --->
		<cfif not BO.existsLoadedObjectsMetadata(PropertyName)>
			<cfset ListOfLinkedObjects = BO.listLoadedObjectsPropertyNames({ IsObject : true }) />

			<cfloop list="#ListOfLinkedObjects#" index="currentLinkedObjectName">

				<!--- check if the property partly matches one of its linked object names --->
				<cfif Len(PropertyName) gt Len(currentLinkedObjectName) AND Left(PropertyName, Len(currentLinkedObjectName)) is currentLinkedObjectName>
					<cfset LinkedObject = get(BO, currentLinkedObjectName) />
					<cfset FragmentName = Right(PropertyName, Len(PropertyName) - Len(currentLinkedObjectName)) />

					<!--- the 'return' statement wrapped in the try/catch runs this 'get' function recursively, digging deeper into each child component until it finds the property it's looking for - or not. When it doesn't find the property, rather than error out, we prefer to continue looping and trying other sub-objects. If nothing is found after that, an error will be thrown below. --->
					<cftry>
						<cfreturn get(LinkedObject, FragmentName) />
						<cfcatch type="LoadedObjects"><!--- do nothing ---></cfcatch>
					</cftry>
				</cfif>
			</cfloop>

			<cfthrow type="LoadedObjects" errorcode="LoadedObjects.Get.UndefinedProperty" message="Could not get property '#UCase(PropertyName)#' from component '#UCase(BO.getLoadedObjectsBOPath())#'." detail="Ensure that the property is defined, and that it is spelled correctly." />
		</cfif>

		<!--- if property has never run through the set routine, set it now to itself so that the raw value is processed --->
		<cfif not hasBeenSetProperty(BO, PropertyName, BO.getCurrentRow())>
			<cfscript>
				RawValue = getRaw(BO, PropertyName, BO.getCurrentRow());

				if (RawValue is '') {
					RawValue = BO.getLoadedObjectsMetadata(PropertyName, 'Default');
				}

				set(BO, PropertyName, RawValue)
			</cfscript>
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

			var CleanRawData = '';
			var QueryColumns = '';
			var currentPropertyName = '';
		</cfscript>

		<!--- if is struct or array of structs --->
		<cfif isStruct(RawData) OR isArray(RawData)>

			<!--- if is struct, use it --->
			<cfif isStruct(RawData)>
				<cfset CleanRawData = RawData />

			<!--- if is array get the struct out --->
			<cfelse>
				<cfset CleanRawData = RawData[Row]>
			</cfif>

			<!--- loop through this object's properties and set values from struct  --->
			<cfloop collection="#CleanRawData#" item="currentPropertyName">
				<cftry>
					<cfset BO.set(currentPropertyName, CleanRawData[currentPropertyName]) />
					<cfcatch type="LoadedObjects"><!--- do nothing ---></cfcatch>
				</cftry>
			</cfloop>

		<!--- if is query --->
		<cfelseif isQuery(RawData)>
			<cfset QueryColumns = RawData.ColumnList />

			<!--- loop through rawdata and set values from query row  --->
			<cfloop list="#QueryColumns#" index="currentPropertyName">
				<cftry>
					<cfset BO.set(currentPropertyName, RawData[currentPropertyName][Row]) />
					<cfcatch type="LoadedObjects"><!--- do nothing ---></cfcatch>
				</cftry>
			</cfloop>

		<!--- otherwise error --->
		<cfelse>
			<cfthrow type="LoadedObjects" errorcode="LoadedObjects.SetAll.InvalidRawData" />
		</cfif>

		<cfreturn BO />
	</cffunction>

	<!--- create raw data --->
	<cffunction name="createRawData" access="public" output="false" returntype="any" hint="Set appropriate raw data manager based on provided raw type.">
		<cfargument name="BO" type="any" required="true" />
		<cfargument name="RawData" type="any" default="#StructNew()#" hint="Struct or query or array-of-structs" />

		<cfscript>
			var BO = arguments.BO;
			var RawData = arguments.RawData;

			BO.setCurrentRow(0);
			BO.clearHasBeenSet();
		</cfscript>

		<cfif IsQuery(RawData)>
			<cfreturn createObject('component', 'types.query').init(RawData) />
		<cfelseif IsArray(RawData) AND ArrayLen(RawData) AND IsStruct(RawData[1])>
			<cfreturn createObject('component', 'types.arrayofstructs').init(RawData) />
		<cfelseif IsStruct(RawData)>
			<cfreturn createObject('component', 'types.arrayofstructs').init([RawData]) />
		<cfelse>
			<cfreturn createObject('component', 'types.arrayofstructs').init([StructNew()]) />
		</cfif>
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

	<!--- add row --->
	<cffunction name="addRow" access="public" output="false" returntype="any">
		<cfargument name="BO" type="any" required="true" />
		<cfset arguments.BO.getRawDataManager().addRow() />
		<cfreturn this />
	</cffunction>
</cfcomponent>