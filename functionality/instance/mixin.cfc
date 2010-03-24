<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Bassil Karam (bassil.karam@thinkloop.com) - 01/01/2008
Edited By: Bassil Karam (bassil.karam@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">

	<!--- init - this will be run after all plugins have been mixed in, then removed from the final business object --->
	<cffunction name="init" access="public" output="false" returntype="void">
		<cfscript>
			variables.i=StructNew();
			clear();
		</cfscript>
	</cffunction>
	
	<!--- set --->
	<cffunction name="set" access="public" output="false" returntype="any">
		<cfargument name="Name" type="string" />
		<cfargument name="Value" type="any" />

		<cfset var CustomFunctionName="set#arguments.Name#" />
		<cfset var CustomFunction="" />

		<!--- if a real function exists, use it --->
		<cfif existsFunction(CustomFunctionName)>
			<cfset CustomFunction=variables[CustomFunctionName] />
			<cfset CustomFunction(arguments.Value) />

		<!--- if property is defined in PropertyList, set it --->
		<cfelseif getMetaDataObject().getProperties().exists(arguments.Name)>
			<cfset variables.i[arguments.Name]=arguments.Value />

		<!--- otherwise, throw error --->
		<cfelse>
			<cfthrow type="LoadedObjects" errorcode="LoadedObjects.Set.UndefinedProperty" message="Could not SET the property #ucase(arguments.Name)# because it was not found in component #ucase(getMetaDataObject().getPath())#" detail="Ensure that the property is defined, and that it is spelled correctly." />
		</cfif>

		<cfreturn this />
	</cffunction>

	<!--- get --->
	<cffunction name="get" access="public" output="false" returntype="any">
		<cfargument name="Name" type="string" />

		<cfset var CustomFunctionName="get#arguments.Name#" />
		<cfset var CustomFunction="" />

		<!--- if a real function exists, use it --->
		<cfif existsFunction(CustomFunctionName)>
			<cfset CustomFunction=variables[CustomFunctionName] />
			<cfreturn CustomFunction() />

		<!--- if property is defined in PropertyList, get it --->
		<cfelseif getMetaDataObject().getProperties().exists(arguments.Name)>
			<cfreturn variables.i[arguments.Name] />

		<!--- otherwise, throw error --->
		<cfelse>
<!--- <cfthrow type="LoadedObjects" errorcode="LoadedObjects.Get.UndefinedProperty" message="Could not GET the property #ucase(arguments.Name)# because it was not found in component '#getMetaDataObject().getPath()#'" detail="Ensure that the property is defined, and that it is spelled correctly." />--->
		</cfif>
	</cffunction>

	<!--- is null value works a little differently than other generic functions like set/get in that to use it generically you use isNullValue(Porperty), whereas explicitly you would exclude 'value' like so: isNullProperty(), and not isNullValueProperty() (in Railo, the function isNull() is reserved) --->
	<cffunction name="isNullValue" access="public" output="false" returntype="boolean">
		<cfargument name="Name" type="string" />

		<cfset var CustomFunctionName="isNull#arguments.Name#" />
		<cfset var CustomFunction="" />

		<!--- if a real function exists, use it --->
		<cfif existsFunction(CustomFunctionName)>
			<cfset CustomFunction=variables[CustomFunctionName] />
			<cfreturn CustomFunction() />

		<!--- if property is defined in PropertyList, find out if it is null --->
		<cfelseif getMetaDataObject().getProperties().exists(arguments.Name)>
			<cfreturn get(arguments.Name) is getMetaDataObject().getProperties().seek(arguments.Name).get('NullValue') />

		<!--- otherwise, throw error --->
		<cfelse>
			<cfthrow type="LoadedObjects" errorcode="LoadedObjects.isNullValue.UndefinedProperty" message="Could not determine if the property #ucase(arguments.Name)# is null because it was not found in component #ucase(getMetaDataObject().getPath())#" detail="Ensure that the property is defined, and that it is spelled correctly." />
		</cfif>
	</cffunction>

	<!--- clear --->
	<cffunction name="clear" access="public" output="false" returntype="any" hint="Sets all properties to null">

		<cfset var Properties=getMetaDataObject().getProperties() />
		
		<!--- set all properties to null --->
		<cfloop condition="Properties.loop()">
			<cfset set(Properties.get('Name'), Properties.get('NullValue')) />
		</cfloop>

		<cfreturn this />
	</cffunction>

	<!--- memento --->
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
	<cffunction name="getMemento" access="public" output="false" returntype="struct">
		
		<cfset var ReturnStruct=StructNew() />
		<cfset var Properties=getMetaDataObject().getProperties() />
		
		<!--- get all properties --->
		<cfloop condition="Properties.loop()">		
			<cfset ReturnStruct[Properties.get('Name')]=get(Properties.get('Name')) />
		</cfloop>
		
		<cfreturn ReturnStruct />
	</cffunction>

	<!--- onMissingMethod: provides generic get/set/isnull functionality without having to write out the functions --->
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

		<!--- isnull --->
		<cfelseif len(arguments.MissingMethodName) gt 6 AND left(arguments.MissingMethodName, 6) is 'isnull'>
			<cfset Property=right(arguments.MissingMethodName, len(arguments.MissingMethodName) - 6) />
			<cfreturn isNullValue(Property) />
		</cfif>
	</cffunction>
	
</cfcomponent>