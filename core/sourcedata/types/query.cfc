<!--- * * (coldfusion comments are completely stripped out at compile time, and have zero impact on performance)
Created By: Baz K. (bk@thinkloop.com) - 01/01/2008
Edited By: Baz K. (bk@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false" extends="abstract_type">

	<!--- init - this will be run after all plugins have been mixed in, then removed from the final business object --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="BO" type="any" required="true" hint="A reference to the current business object" />
		<cfargument name="Raw" type="query" required="true" />
		
		<cfscript>
			super.init(arguments.BO);
			variables.i.Raw = arguments.Raw;
		</cfscript>
		
		<cfif numRows() gt 0>
			<cfset setCurrentRow(1) />
		</cfif>
				
		<cfreturn this />
	</cffunction>

	<!--- set value --->
	<cffunction name="setValue" access="private" output="false" returntype="any">
		<cfargument name="PropertyName" type="string" required="true" />
		<cfargument name="Value" type="any" required="true" />
		<cfargument name="RowNum" type="numeric" default="-1" />
		
		<!--- if row num is no good, use current row --->		
		<cfif arguments.RowNum lte 0>
			<cfset arguments.RowNum = getCurrentRow() />
		</cfif>
				
		<cfset QuerySetCell(variables.i.Raw, arguments.PropertyName, arguments.Value, arguments.RowNum) />
		<cfreturn this />
	</cffunction>
	
	<!--- get value --->
	<cffunction name="getValue" access="private" output="false" returntype="any">
		<cfargument name="PropertyName" type="string" required="true" />
		<cfargument name="RowNum" type="numeric" default="-1" />
		
		<!--- if row num is no good, use current row --->		
		<cfif arguments.RowNum lte 0>
			<cfset arguments.RowNum = getCurrentRow() />
		</cfif>
				
		<cfset var returnValue = variables.i.Raw[arguments.PropertyName][arguments.RowNum] />
		<cfif isSimplevalue(returnValue) AND returnValue is getQueryNullValue()>
			<cfset returnValue = variables.BO.getLoadedObjectsMetadata(arguments.PropertyName, 'Default') />
			<cfset setValue(arguments.PropertyName, returnValue) />
		</cfif>
		
		<cfreturn returnValue />
	</cffunction>	
	
	<!--- add column --->
	<cffunction name="addColumn" access="public" output="false" returntype="any">
		<cfargument name="PropertyName" type="string" required="true" />
		<cfset QueryAddColumn(variables.i.Raw, arguments.PropertyName) />
		
		<cfloop query="variables.i.Raw">
			<cfset variables.i.Raw[arguments.PropertyName] = getQueryNullValue() />
		</cfloop>
				
		<cfreturn this />
	</cffunction>
	
	<!--- exists column --->
	<cffunction name="existsColumn" access="private" output="false" returntype="boolean">
		<cfargument name="PropertyName" type="string" required="true" />
		<cfreturn StructKeyExists(variables.i.Raw, arguments.PropertyName) />
	</cffunction>
		
	<!--- add row --->
	<cffunction name="addRow" access="public" output="false" returntype="any">
		<cfset QueryAddRow(variables.i.Raw) />
		<cfset setCurrentRow(numRows()) />
		<cfreturn this />
	</cffunction>		
	
	<!--- get query null value: since adding a query column creates a value for each row, there is no concept of null (non-existence), unlike with a struct. So rather than populating every row with a potentially heavy default value when adding a query column (i.e. a CFC), we instead set it to this null value then check for it in 'get' --->
	<cffunction name="getQueryNullValue" access="public" output="false" returntype="string">
		<cfreturn 'loadedobjects-xx-ww-@$-loaded-**-objects-++-loaded-%%-objects' />
	</cffunction>

	<!--- count rows --->
	<cffunction name="numRows" access="public" output="false" returntype="numeric">
		<cfreturn variables.i.Raw.Recordcount />
	</cffunction>
		
	<!--- raw --->
	<cffunction name="raw" access="public" output="false" returntype="any">
		<cfreturn variables.i.Raw />
	</cffunction>	
</cfcomponent>