<!--- * * (coldfusion comments are completely stripped out at compile time, and have zero impact on performance)
Created By: Bassil Karam (bassil.karam@thinkloop.com) - 01/01/2008
Edited By: Bassil Karam (bassil.karam@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false" extends="abstract_type">

	<!--- init - this will be run after all plugins have been mixed in, then removed from the final business object --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="BusinessObject" type="any" required="true" hint="A reference to the current business object" />
		<cfargument name="Query" type="query" required="true" />
		
		<cfscript>
			super.init(arguments.BusinessObject);
			variables.i.Query=arguments.Query;
		</cfscript>
		
		<cfif numRows() gt 0>
			<cfset setCurrentRow(1) />
		</cfif>
				
		<cfreturn this />
	</cffunction>

	<!--- set value --->
	<cffunction name="setValue" access="private" output="false" returntype="any">
		<cfargument name="Name" type="string" required="true" />
		<cfargument name="Value" type="any" required="true" />
		<cfset QuerySetCell(variables.i.Query, arguments.Name, arguments.Value, getCurrentRow()) />
		<cfreturn this />
	</cffunction>
	
	<!--- get value --->
	<cffunction name="getValue" access="private" output="false" returntype="any">
		<cfargument name="Name" type="string" required="true" />
		<cfset var returnValue = variables.i.Query[arguments.Name][getCurrentRow()] />
		<cfif isSimplevalue(returnValue) AND returnValue is getQueryNullValue()>
			<cfset returnValue = variables.BO.defaultValue(arguments.Name) />
			<cfset setValue(arguments.Name, returnValue) />
		</cfif>
		<cfreturn returnValue />
	</cffunction>	
	
	<!--- add column --->
	<cffunction name="addColumn" access="public" output="false" returntype="any">
		<cfargument name="Name" type="string" required="true" />
		<cfset QueryAddColumn(variables.i.Query, arguments.Name) />
		
		<cfloop query="variables.i.Query">
			<cfset variables.i.Query[arguments.Name] = getQueryNullValue() />
		</cfloop>
				
		<cfreturn this />
	</cffunction>
	
	<!--- exists column --->
	<cffunction name="existsColumn" access="private" output="false" returntype="boolean">
		<cfargument name="Name" type="string" required="true" />
		<cfreturn StructKeyExists(variables.i.Query, arguments.Name) />
	</cffunction>
		
	<!--- add row --->
	<cffunction name="addRow" access="public" output="false" returntype="any">
		<cfset QueryAddRow(variables.i.Query) />
		<cfset setCurrentRow(numRows()) />
		<cfreturn this />
	</cffunction>		
	
	<!--- get query null value: since adding a query column creates a value for each row, there is no concept of null, like with a struct. So rather than populating every row with a potentially heavy default value (i.e. cfc) when adding a query column, we instead set it to this null value then check for it in 'get' --->
	<cffunction name="getQueryNullValue" access="public" output="false" returntype="string">
		<cfreturn 'loadedobjects-xx-ww-@$-loaded-**-objects-++-loaded-%%-objects' />
	</cffunction>
		
	<!--- seek 
	<cffunction name="seek" access="public" output="false" returntype="struct">
		<cfargument name="Row" type="numeric" required="true" />
<cfdump var="#variables.i.Query[arguments.Row]#">
<cfabort>
		<cfreturn variables.i.Query[arguments.Row] />
	</cffunction>
--->
	<!--- count rows --->
	<cffunction name="numRows" access="public" output="false" returntype="numeric">
		<cfreturn variables.i.Query.Recordcount />
	</cffunction>
		
	<!--- raw --->
	<cffunction name="raw" access="public" output="false" returntype="query">
		<cfreturn variables.i.Query />
	</cffunction>	
</cfcomponent>