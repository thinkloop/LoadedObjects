<!--- * * (coldfusion comments are completely stripped out at compile time, and have zero impact on performance)
Created By: Bassil Karam (bassil.karam@thinkloop.com) - 01/01/2008
Edited By: Bassil Karam (bassil.karam@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">
	<cfproperty name="ArrayOfStructs" type="array" hint="The primary source data in an array of structs" />

	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="ArrayOfStructs" type="array" required="true" />
		<cfscript>
			variables.i=structnew();
			variables.i.ArrayOfStructs = arguments.ArrayOfStructs;
		</cfscript>

		<cfreturn this />
	</cffunction>

	<!--- seek --->
	<cffunction name="seek" access="public" output="false" returntype="struct">
		<cfargument name="Row" type="numeric" required="true" />
		<cfreturn variables.i.ArrayOfStructs[arguments.Row] />
	</cffunction>

	<!--- count rows --->
	<cffunction name="countRows" access="public" output="false" returntype="numeric">
		<cfreturn ArrayLen(variables.i.ArrayOfStructs) />
	</cffunction>

	<!--- get source data --->
	<cffunction name="getSourceDataType" access="public" output="false" returntype="array">
		<cfreturn variables.i.ArrayOfStructs />
	</cffunction>
</cfcomponent>