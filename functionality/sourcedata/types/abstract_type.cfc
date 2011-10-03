<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Bassil Karam (bassil.karam@thinkloop.com) - 01/01/2008
Edited By: Bassil Karam (bassil.karam@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">
	<cfproperty name="BO" type="any" hint="Business object" />
	<cfproperty name="CurrentRow" type="numeric" hint="Cursor position" />
	
	<!--- init - this will be run after all plugins have been mixed in, then removed from the final business object --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="BusinessObject" type="any" required="true" hint="A reference to the current business object" />
		
		<cfscript>
			variables.i=StructNew();
			variables.i.BO=arguments.BusinessObject;
			variables.i.CurrentRow=0;
			variables.i.LoopStarted=False;
		</cfscript>
		
		<cfreturn this />
	</cffunction>
	
	<!--- set --->
	<cffunction name="set" access="public" output="false" returntype="any">
		<cfargument name="Name" type="string" required="true" />
		<cfargument name="Value" type="any" required="true" />

		<!--- if this property is not supported by this object, throw error --->	
		<cfif not getMetaDataObject().getProperties().exists(arguments.Name)>
			<cfthrow type="LoadedObjects" errorcode="LoadedObjects.Set.UndefinedProperty" message="Could not SET the property #ucase(arguments.Name)# because it was not found in component #ucase(getMetaDataObject().getPath())#" detail="Ensure that the property is defined, and that it is spelled correctly." />
		</cfif>
		
		<!--- if column does not exist, create it --->
		<cfif not existsColumn(arguments.Name)>
			<cfset addColumn(arguments.Name) />
		</cfif>
		
		<!--- if there are no rows, add one --->
		<cfif countRows() lte 0>
			<cfset addRow() />
			<cfset setCurrentRow(1) />
		</cfif>		
		
		<!--- if currentrow is 0, set it to 1 --->
		<cfif getCurrentRow() lte 0>
			<cfset setCurrentRow(1) />
		</cfif>
	
		<!--- set the value --->
		<cfset setValue(arguments.Name, arguments.Value) />

		<cfreturn this />
	</cffunction>
		
	<!--- get --->
	<cffunction name="get" access="public" output="false" returntype="any">
		<cfargument name="Name" type="string" required="true" />				

		<!--- if this property is not supported by this object, throw error --->	
		<cfif not getMetaDataObject().getProperties().exists(arguments.Name)>
			<cfthrow type="LoadedObjects" errorcode="LoadedObjects.Get.UndefinedProperty" message="Could not GET the property #ucase(arguments.Name)# because it was not found in component #ucase(getMetaDataObject().getPath())#" detail="Ensure that the property is defined, and that it is spelled correctly." />
		</cfif>
		
		<!--- if currentrow is good and column is good, return requested value --->
		<cfif getCurrentRow() gte 1 AND existsColumn(arguments.Name)>
			<cfreturn getValue(arguments.Name) />
			
		<!--- if currentrow is bad, return default value --->
		<cfelse>
			<cfreturn getMetaDataObject().getProperties().seek(arguments.Name).get('Default') />
		</cfif>	
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
				<cfset setCurrentRow(countRows()) />
				<cfreturn True />

			<!--- if row is 1 there is no where left to go, return false --->
			<cfelse>
				<cfset setCurrentRow(1) />
				<cfreturn False />
			</cfif>

		<!--- forward --->
		<cfelse>
		
			<!--- if next record exists, increment counter, populate object and return true --->
			<cfif row lt countRows()>
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

		<!--- if the provided position is too high, set it to recordcount instead --->
		<cfif arguments.Position gt countRows()>
			<cfset variables.i.CurrentRow=countRows() />

		<!--- if the provided position is too low, set it to 1 instead --->
		<cfelseif arguments.Position lt 1>
			<cfset variables.i.CurrentRow=1 />

		<!--- if the provided position is just right, use it --->
		<cfelse>
			<cfset variables.i.CurrentRow=arguments.Position />
		</cfif>

		<cfreturn this />
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
	
<!--- * * * * * * * * * * --->
<!--- * * CONVENIENCE * * --->
<!--- * * * * * * * * * * --->
	
	<cffunction name="getMetaDataObject" access="public" output="false" returntype="any">
		<cfreturn variables.i.BO.getMetaDataObject() />
	</cffunction>

</cfcomponent>