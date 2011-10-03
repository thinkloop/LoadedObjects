<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Bassil Karam (bassil.karam@thinkloop.com) - 01/01/2008
Edited By: Bassil Karam (bassil.karam@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">

	<!--- init - this will be run after all plugins have been mixed in, then removed from the final business object --->
	<cffunction name="init" access="public" output="false" returntype="void">
		<cfscript>
			variables.i=StructNew();
		</cfscript>
	</cffunction>




	<!--- memento 
	<cffunction name="setMemento" access="public" output="false" returntype="any">
		<cfargument name="Memento" type="any" required="true" hint="Can be a struct or a query or an array of structs" />
		<cfargument name="Row" type="numeric" default="1" hint="Specifies which row of the query or array of structs to use to populate the object" />

		<cfscript>
			var FinalStruct='';
			var QueryColumns='';
			
			var Properties=getMetaDataObject().getProperties();
		</cfscript>

		<!--- if is struct or array of structs --->
		<cfif isStruct(arguments.Memento) OR isArray(arguments.Memento)>
			
			<!--- if is struct, use it --->
			<cfif isStruct(arguments.Memento)>
				<cfset FinalStruct=arguments.Memento />

			<!--- if is array get the struct out --->
			<cfelse>
				<cfset FinalStruct=arguments.Memento[arguments.Row]>
			</cfif>

			<!--- loop through this object's properties and set values from struct --->
			<cfloop condition="Properties.loop('ReadOnly=False')">
				<cfif StructKeyExists(FinalStruct, Properties.get('Name'))>
					<cfset set(Properties.get('Name'), FinalStruct[Properties.get('Name')]) />
				</cfif>
			</cfloop>
			
		<!--- if is query --->
		<cfelseif isQuery(arguments.Memento)>
			<cfset QueryColumns=arguments.Memento.ColumnList />
			<cfloop condition="Properties.loop('ReadOnly=False')">
				<cfif listFindNoCase(QueryColumns, Properties.get('Name'))>
					<cfset set(Properties.get('Name'), arguments.Memento[Properties.get('Name')][arguments.Row]) />
				</cfif>
			</cfloop>
			
		<!--- otherwise error --->
		<cfelse>
			<cfthrow />
		</cfif>

		<cfreturn this />
	</cffunction>
	--->

	<!--- onMissingMethod: provides generic get/set/isnull functionality without having to write out the functions 
	<cffunction name="onMissingMethod" access="public" output="false" returntype="any" hint="Provides generic get/set/isnull functionality without having to write out the functions">
		<cfargument name="MissingMethodName" type="string" />
		<cfargument name="MissingMethodArguments" type="struct" />

		<cfset var Property="" />
		<cfset var KeyList="" />

		<!--- get --->
		<cfif left(arguments.MissingMethodName, 3) is 'get'>
			<cfset Property=right(arguments.MissingMethodName, len(arguments.MissingMethodName) - 3) />
			<cfreturn get(Property) />

		<!--- set --->
		<cfelseif left(arguments.MissingMethodName, 3) is 'set'>
			<cfset Property=right(arguments.MissingMethodName, len(arguments.MissingMethodName) - 3) />
			<cfset KeyList=StructKeyList(arguments.missingMethodArguments) />

			<cfif listlen(KeyList)>
				<cfreturn set(Property, arguments.missingMethodArguments[listfirst(KeyList)]) />
			<cfelse>
				<cfreturn set(Property, '') />
			</cfif>
			
		<!--- display --->
		<cfelseif left(arguments.MissingMethodName, 7) is 'display'>
			<cfset Property=right(arguments.MissingMethodName, len(arguments.MissingMethodName) - 7) />
			<cfreturn display(Property) />			

		<!--- isnull --->
		<cfelseif Len(arguments.MissingMethodName) gt 2 AND Left(arguments.MissingMethodName, 2) is 'is'>
			<cfset Property=right(arguments.MissingMethodName, len(arguments.MissingMethodName) - 2) />
			<cfreturn is(Property) />
		</cfif>
	</cffunction>
	--->
</cfcomponent>