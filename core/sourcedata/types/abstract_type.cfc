<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Baz K. (bk@thinkloop.com) - 01/01/2008
Edited By: Baz K. (bk@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">
	
	<!--- init - this will be run after all plugins have been mixed in, then removed from the final business object --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="BO" type="any" required="true" hint="A reference to the current business object" />
		
		<cfscript>
			variables.BO = arguments.BO;
					
			variables.i = StructNew();
			variables.i.CurrentRow = 0;
			variables.i.LoopStarted = False;
			variables.i.Raw = '';
		</cfscript>
		
		<cfreturn this />
	</cffunction>
	
	<!--- set --->
	<cffunction name="set" access="public" output="false" returntype="any">
		<cfargument name="PropertyName" type="string" required="true" />
		<cfargument name="Value" type="any" required="true" />
		<cfargument name="RowNum" type="numeric" default="-1" hint="A value of -1 will use currentRow instead" />		

		<cfscript>
			var BO = variables.BO;
			var PropertyName = arguments.PropertyName;
			var Value = arguments.Value;
			var RowNum = arguments.RowNum;
		</cfscript>
		
		<!--- if this property is not supported by this object, throw error --->	
		<cfif not BO.existsLoadedObjectsMetadata(PropertyName)>
			<cfthrow type="LoadedObjects" errorcode="LoadedObjects.Set.UndefinedProperty" message="Could not SET the property #ucase(PropertyName)# because it was not found in component #ucase(variables.BO.getLoadedObjectsBOPath())#" detail="Ensure that the property is defined, and that it is spelled correctly." />
		</cfif>
		
		<!--- if column does not exist, create it --->
		<cfif not existsColumn(PropertyName)>
			<cfset addColumn(PropertyName) />
		</cfif>
		
		<!--- if there are no rows, add one --->
		<cfif numRows() lte 0>
			<cfset addRow() />
			<cfset setCurrentRow(1) />
		</cfif>		
		
		<!--- if currentrow is 0, set it to 1 --->
		<cfif getCurrentRow() lte 0>
			<cfset setCurrentRow(1) />
		</cfif>
	
		<!--- set the value --->
		<cfset setValue(PropertyName, Value, RowNum) />

		<cfreturn this />
	</cffunction>
		
	<!--- get --->
	<cffunction name="get" access="public" output="false" returntype="any">
		<cfargument name="PropertyName" type="string" required="true" />
		<cfargument name="RowNum" type="numeric" default="-1" hint="A value of -1 will use currentRow instead" />
		
		<cfscript>
			var BO = variables.BO;
			var PropertyName = arguments.PropertyName;
			var RowNum = arguments.RowNum;
		</cfscript>

		<!--- if this property is not supported by this object, throw error --->	
		<cfif not BO.existsLoadedObjectsMetadata(PropertyName)>			
			<cfthrow type="LoadedObjects" errorcode="LoadedObjects.Get.UndefinedProperty" message="Could not get the property '#UCase(PropertyName)#' from component '#UCase(BO.getLoadedObjectsBOPath())#'." detail="Ensure that the property is defined, and that it is spelled correctly." />
		</cfif>
		
		<!--- if currentrow is bad or column doesn't exist, set and return default value --->
		<cfif getCurrentRow() lte 0 OR not existsColumn(PropertyName)>
			<cfset set(PropertyName, BO.getLoadedObjectsMetadata(PropertyName, 'Default')) />
		</cfif>
		
		<cfreturn getValue(PropertyName, RowNum) />
	</cffunction>
		
	<!--- loop --->
	<cffunction name="loop" access="public" output="false" returntype="boolean">
		<cfargument name="Direction" type="string" default="forward" hint="Can be: forward, reverse" />
		
		<cfset var row = getCurrentRow() />
		
		<!--- if this is the first iteration of the loop, start row at 0 --->
		<cfif not variables.i.LoopStarted>
			<cfset row = 0 />
			<cfset variables.i.LoopStarted = true />
		</cfif>
		
		<!--- reverse --->
		<cfif arguments.Direction is 'Reverse'>
		
			<!--- if next record exists, go to it --->
			<cfif row gte 2>
				<cfset setCurrentRow(row - 1) />
				<cfreturn True />

			<!--- if row is 0, start at the end of the recordset --->
			<cfelseif row lte 0>
				<cfset setCurrentRow(numRows()) />
				<cfreturn True />

			<!--- if row is 1 there is no where left to go, return false --->
			<cfelse>
				<cfset setCurrentRow(1) />
				<cfreturn False />
			</cfif>

		<!--- forward --->
		<cfelse>
		
			<!--- if next record exists, increment counter, populate object and return true --->
			<cfif row lt numRows()>
				<cfset setCurrentRow(row + 1) />
				<cfreturn True />

			<!--- otherwise, reset current row and return false --->
			<cfelse>
				<cfset setCurrentRow(1) />
				<cfset variables.i.LoopStarted = false />
				<cfreturn False />
			</cfif>
		</cfif>

		<cfreturn False />
	</cffunction>

	<!--- current row  --->
	<cffunction name="getCurrentRow" access="public" output="false" returntype="numeric" hint="Returns the current row">
		<cfreturn variables.i.CurrentRow />
	</cffunction>
	<cffunction name="setCurrentRow" access="public" output="false" returntype="any">
		<cfargument name="Position" type="numeric" required="true" />
		
		<cfset var Position = arguments.Position />
		
		<!--- if the provided position is too high, set it to recordcount instead --->
		<cfif Position gt numRows()>
			<cfset variables.i.CurrentRow = numRows() />

		<!--- if the provided position is too low, set it to 1 instead --->
		<cfelseif Position lt 1>
			<cfset variables.i.CurrentRow = 1 />

		<!--- if the provided position is just right, use it --->
		<cfelse>
			<cfset variables.i.CurrentRow = Position />
		</cfif>

		<cfreturn this />
	</cffunction>
	
	<!--- seek: moves the cursor to a specific row based on a value of a given property. If the value is not unique within the sourcedata, it will move to the first instance of the value. This was intended for use with primary keys. --->
	<cffunction name="seek" access="public" output="false" returntype="struct">
		<cfargument name="PropertyName" type="string" required="true" />
		<cfargument name="Value" type="any" required="true" />
		
		<cfset var ReturnStruct = StructNew() />
		<cfloop condition="#loop()#">
			<cfif get(arguments.PropertyName) is arguments.Value>
				<cfset ReturnStruct = variables.BO.getAll() />
				<cfbreak />
			</cfif>
		</cfloop>

		<cfset setCurrentRow(1) />
		<cfreturn ReturnStruct />
	</cffunction>
		
	<!--- total rows --->
	<cffunction name="setTotalRows" access="public" output="false" returntype="this" hint="The total number of rows that *would have* been returned had the source data not been limited by maxrows. This is NOT recordcount of the source data.">
		<cfargument name="TotalRows" type="numeric" required="true" />
		<cfset variables.i.TotalRows=arguments.TotalRows />
		<cfreturn this />
	</cffunction>
	<cffunction name="getTotalRows" access="public" output="false" returntype="numeric">
		<cfreturn variables.i.TotalRows />
	</cffunction>
	<cffunction name="clearTotalRows" access="public" output="false" returntype="any">
		<cfset variables.i.TotalRows=0 />
		<cfreturn this />
	</cffunction>

<!--- * * * * * * * * * *--->
<!--- * * MANAGEMENT (maybe) * * --->
<!--- * * * * * * * * * *--->

	<!--- TODO: newRow(memento:struct): add new row following current cursor position --->

	<!--- TODO: deleteRow(): delete row at current cursor position --->
	

</cfcomponent>