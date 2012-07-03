<!--- * * (coldfusion comments are completely stripped out at compile time, and have zero impact on performance)
Created By: Bassil Karam (bassil.karam@thinkloop.com) - 01/01/2008
Edited By: Bassil Karam (bassil.karam@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false" extends="abstract_type">

	<!--- init - this will be run after all plugins have been mixed in, then removed from the final business object --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="BusinessObject" type="any" required="true" hint="A reference to the current business object" />
		<cfargument name="ArrayOfStructs" type="array"  required="true" />
		
		<cfscript>
			super.init(arguments.BusinessObject);
			variables.i.ArrayOfStructs=arguments.ArrayOfStructs;
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
		<cfargument name="RowNum" type="numeric" default="-1" />
		
		<!--- if row num is no good, use current row --->
		<cfif arguments.RowNum lte 0>
			<cfset arguments.RowNum = getCurrentRow() />
		</cfif>
				
		<cfset variables.i.ArrayOfStructs[arguments.RowNum][arguments.Name] = arguments.Value />
		<cfreturn this />
	</cffunction>
	
	<!--- get value --->
	<cffunction name="getValue" access="private" output="false" returntype="any">
		<cfargument name="Name" type="string" required="true" />
		<cfargument name="RowNum" type="numeric" default="-1" />
		
		<!--- if row num is no good, use current row --->		
		<cfif arguments.RowNum lte 0>
			<cfset arguments.RowNum = getCurrentRow() />
		</cfif>
		
		<cfreturn variables.i.ArrayOfStructs[arguments.RowNum][arguments.Name] />
	</cffunction>	
	
	<!--- add column --->
	<cffunction name="addColumn" access="public" output="false" returntype="any">
		<cfargument name="Name" type="string" required="true" />
		<cfset variables.i.ArrayOfStructs[getCurrentRow()][arguments.Name] = variables.BO.defaultValue(arguments.Name) />
		<cfreturn this />
	</cffunction>
	
	<!--- exists column --->
	<cffunction name="existsColumn" access="public" output="false" returntype="boolean">
		<cfargument name="Name" type="string" required="true" />
		<cfreturn StructKeyExists(variables.i.ArrayOfStructs[getCurrentRow()], arguments.Name) />
	</cffunction>
		
	<!--- add row --->
	<cffunction name="addRow" access="public" output="false" returntype="any">
		<cfset ArrayAppend(variables.i.ArrayOfStructs, StructNew()) />
		<cfset setCurrentRow(numRows()) />
		<cfreturn this />
	</cffunction>
		
	<!--- seek 
	<cffunction name="seek" access="public" output="false" returntype="struct">
		<cfargument name="Row" type="numeric" required="true" />
		<cfreturn variables.i.ArrayOfStructs[arguments.Row] />
	</cffunction>
--->
	<!--- num rows --->
	<cffunction name="numRows" access="public" output="false" returntype="numeric">
		<cfreturn ArrayLen(variables.i.ArrayOfStructs) />
	</cffunction>
	
	<!--- raw, untransformed data - should not generally be used/manipulated directly - good for debugging --->
	<cffunction name="raw" access="public" output="false" returntype="array">
		<cfreturn variables.i.ArrayOfStructs />
	</cffunction>
</cfcomponent>