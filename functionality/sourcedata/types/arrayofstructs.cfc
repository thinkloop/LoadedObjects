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
		
		<cfif countRows() gt 0>
			<cfset setCurrentRow(1) />
		</cfif>
		
		<cfreturn this />
	</cffunction>
	
	<!--- set value --->
	<cffunction name="setValue" access="private" output="false" returntype="any">
		<cfargument name="Name" type="string" required="true" />
		<cfargument name="Value" type="any" required="true" />	
		<cfset variables.i.ArrayOfStructs[getCurrentRow()][arguments.Name] = arguments.Value />
		<cfreturn this />
	</cffunction>
	
	<!--- get value --->
	<cffunction name="getValue" access="private" output="false" returntype="any">
		<cfargument name="Name" type="string" required="true" />
		<cfreturn variables.i.ArrayOfStructs[getCurrentRow()][arguments.Name] />
	</cffunction>	
	
	<!--- add column --->
	<cffunction name="addColumn" access="private" output="false" returntype="any">
		<cfargument name="Name" type="string" required="true" />
		<cfset variables.i.ArrayOfStructs[getCurrentRow()][arguments.Name] = getMetaDataObject().getProperties().seek(arguments.Name).get('Default') />
		<cfreturn this />
	</cffunction>
	
	<!--- exists column --->
	<cffunction name="existsColumn" access="private" output="false" returntype="boolean">
		<cfargument name="Name" type="string" required="true" />
		<cfreturn StructKeyExists(variables.i.ArrayOfStructs[getCurrentRow()], arguments.Name) />
	</cffunction>
		
	<!--- add row --->
	<cffunction name="addRow" access="private" output="false" returntype="any">
		<cfset ArrayAppend(variables.i.ArrayOfStructs, StructNew()) />
		<cfset setCurrentRow(countRows()) />
		<cfset clear() />
		<cfreturn this />
	</cffunction>
		
	<!--- seek 
	<cffunction name="seek" access="public" output="false" returntype="struct">
		<cfargument name="Row" type="numeric" required="true" />
		<cfreturn variables.i.ArrayOfStructs[arguments.Row] />
	</cffunction>
--->
	<!--- count rows --->
	<cffunction name="countRows" access="public" output="false" returntype="numeric">
		<cfreturn ArrayLen(variables.i.ArrayOfStructs) />
	</cffunction>
	
	<!--- raw --->
	<cffunction name="raw" access="public" output="false" returntype="array">
		<cfreturn variables.i.ArrayOfStructs />
	</cffunction>	
</cfcomponent>