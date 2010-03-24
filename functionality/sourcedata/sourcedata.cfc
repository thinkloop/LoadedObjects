<!--- * * (coldfusion comments are completely stripped out at compile time, and have zero impact on performance)
Created By: Bassil Karam (bassil.karam@thinkloop.com) - 01/01/2008
Edited By: Bassil Karam (bassil.karam@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">
	<cfproperty name="BO" type="any" hint="Business object" />
	<cfproperty name="SourceDataType" type="array" hint="Source data array of structs" />
	<cfproperty name="CurrentRow" type="numeric" hint="Cursor position" />

	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="BusinessObject" type="any" required="true" />
		<cfargument name="SourceDataType" type="any" required="true" hint="Currently supports a query or an array-of-structs">

		<cfscript>
			variables.i=StructNew();
			variables.i.BO=arguments.BusinessObject;
			variables.i.CurrentRow=0;
		</cfscript>

		<!--- instantiate the right object for a query or array-of-structs --->
		<cfif isQuery(arguments.SourceDataType)>
			<cfset variables.i.SourceDataType=createObject('component', 'types.query').init(arguments.SourceDataType) />
		<cfelseif isArray(arguments.SourceDataType)>
			<cfset variables.i.SourceDataType=createObject('component', 'types.arrayofstructs').init(arguments.SourceDataType) />
		<cfelse>
			<!--- TODO: throw an error that the type is unsupported --->
			<cfthrow />
		</cfif>

		<cfreturn this />
	</cffunction>

	<!--- loop --->
	<cffunction name="loop" access="public" output="false" returntype="boolean">
		<cfargument name="Direction" type="string" default="forward" hint="Can be: forward, reverse" />

		<!--- reverse --->
		<cfif arguments.Direction is 'Reverse'>
			<!--- if previous record exists, decrement counter, populate object and return true --->
			<cfif variables.i.CurrentRow gte 2>
				<cfset setCurrentRow(variables.i.CurrentRow-1) />
				<cfreturn True />

			<!--- if current row is 0, set it to recordcount, populate object and return true --->
			<cfelseif variables.i.CurrentRow lte 0>
				<cfset setCurrentRow(getActualRows()) />
				<cfreturn True />

			<!--- otherwise, reset current row and return false --->
			<cfelse>
				<cfset variables.i.CurrentRow=0 />
				<cfreturn False />
			</cfif>

		<!--- forward --->
		<cfelse>
			<!--- if next record exists, increment counter, populate object and return true --->
			<cfif variables.i.CurrentRow lt getActualRows()>
				<cfset setCurrentRow(variables.i.CurrentRow+1) />
				<cfreturn True />

			<!--- otherwise, reset current row and return false --->
			<cfelse>
				<cfset variables.i.CurrentRow=0 />
				<cfreturn False />
			</cfif>
		</cfif>

		<cfreturn False />
	</cffunction>

	<!--- current row  --->
	<cffunction name="getCurrentRow" access="public" output="false" returntype="numeric" hint="Returns the current row">
		<cfreturn variables.i.CurrentRow />
	</cffunction>
	<cffunction name="setCurrentRow" access="private" output="false" returntype="any">
		<cfargument name="Position" type="numeric" required="true" />

		<cfset var ActualRows = getActualRows() />

		<!--- if the provided position is too high, set it to recordcount instead --->
		<cfif arguments.Position gt ActualRows>
			<cfset variables.i.CurrentRow=ActualRows />

		<!--- if the provided position is too low, set it to 1 instead --->
		<cfelseif arguments.Position lt 1>
			<cfset variables.i.CurrentRow=1 />

		<!--- if the provided position is just right, use it --->
		<cfelse>
			<cfset variables.i.CurrentRow=arguments.Position />
		</cfif>

		<!--- ++ set object instance data to source data current row ++ (important) --->
		<cfset variables.i.BO.setMemento(variables.i.SourceDataType.seek(variables.i.CurrentRow)) />

		<cfreturn this />
	</cffunction>
	<cffunction name="isCurrentRowEvenOrOdd" access="public" output="false" returntype="string">
		<cfif variables.i.CurrentRow mod 2>
			<cfreturn 'Odd' />
		<cfelse>
			<cfreturn 'Even' />
		</cfif>
	</cffunction>

	<!--- get actual rows --->
	<cffunction name="getActualRows" access="public" output="false" returntype="numeric" hint="rows in this dataset regardless of the start row, or how many rows would have been returned, etc.">
		<cfreturn variables.i.SourceDataType.countRows() />
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

	<!--- get source data --->
	<cffunction name="getSourceData" access="public" output="false" returntype="any">
		<cfreturn variables.i.SourceDataType.getSourceDataType() />
	</cffunction>

<!--- * * * * * * * * * *--->
<!--- * * MANAGEMENT (maybe) * * --->
<!--- * * * * * * * * * *--->

	<!--- TODO: newRow(memento:struct): add new row following current cursor position --->

	<!--- TODO: deleteRow(): delete row at current cursor position --->
</cfcomponent>