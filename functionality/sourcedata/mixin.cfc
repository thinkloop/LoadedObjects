<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Bassil Karam (bassil.karam@thinkloop.com) - 01/01/2008
Edited By: Bassil Karam (bassil.karam@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">

	<!--- init - this will be run after all plugins have been mixed in, then removed from the final business object --->
	<cffunction name="init" access="public" output="false" returntype="void">
		<cfscript>
			variables.SourceData='';
			variables.MetaDataObject = getMetaDataObject();
			variables.Properties = variables.MetaDataObject.getProperties();
		</cfscript>
		
		<!--- init source data --->
		<cfif not isObject(variables.SourceData)>
			<cfset setSourceData(StructNew()) />			
		</cfif>		
	</cffunction>

	<!--- set --->
	<cffunction name="set" access="public" output="false" returntype="any">
		<cfargument name="Name" type="string" />
		<cfargument name="Value" type="any" />

		<cfset var CustomFunctionName = "set#arguments.Name#" />
		<cfset var CustomFunction = "" />

		<!--- if a real function exists, use it --->
		<cfif existsFunction(CustomFunctionName)>		
			<cfset CustomFunction = variables[CustomFunctionName] />
			<cfset CustomFunction(arguments.Value) />

		<!--- otherwise, set it --->
		<cfelse>	
			<cfset variables.SourceData.set(arguments.Name, arguments.Value) />
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

		<!--- get property from source data (see abstract_type for this logic) --->
		<cfelse>
			<cfreturn variables.SourceData.get(arguments.Name) />
		</cfif>	
	</cffunction>
	
	<!--- default value --->
	<cffunction name="defaultValue" access="public" output="false" returntype="any" hint="Returns the default value of a property">
		<cfargument name="Name" type="string" />
		
		<!--- if the default was specified return it --->
		<cfif variables.Properties.existsAttribute(arguments.Name, 'Default')>
			<cfreturn variables.Properties.getAttribute(arguments.Name, 'Default') />
		</cfif>

		<!--- otherwise get the default from the type --->
		<cfswitch expression="#variables.Properties.getAttribute(arguments.Name, 'Type')#">
			<cfcase value="string,any,binary">
				<cfreturn '' />
			</cfcase>
			<cfcase value="numeric">
				<cfreturn 0 />
			</cfcase>
			<cfcase value="boolean">
				<cfreturn false />
			</cfcase>
			<cfcase value="date">
				<cfreturn Now() />
			</cfcase>
			<cfcase value="struct">
				<cfreturn StructNew() />
			</cfcase>
			<cfcase value="array">
				<cfreturn ArrayNew(1) />
			</cfcase>
			<cfcase value="query">
				<cfreturn QueryNew('') />
			</cfcase>
			<cfcase value="uuid">
				<cfreturn createuuid() />
			</cfcase>
			
			<!--- if nothing else matches, assumes it's a cfc --->
			<!--- TODO: catch error if its not a cfc --->
			<cfdefaultcase>
				<cfreturn variables.LoadedObjects.newFromPath(variables.Properties.getAttribute(arguments.Name, 'Type')) />
			</cfdefaultcase>
		</cfswitch>
	</cffunction>
	
	<!--- clear --->
	<cffunction name="clear" access="public" output="false" returntype="any" hint="Sets all properties to defaults">
		
		<cfset var currentPropertyName = "" />
		
		<!--- init source data --->
		<cfif not isObject(variables.SourceData)>
			<cfset setSourceData(StructNew()) />			
		</cfif>
		
		<!--- set all properties to default --->
		<cfloop array="#variables.Properties.arrayPropertyNames()#" index="currentPropertyName">
			<cfset set(currentPropertyName, defaultValue(currentPropertyName)) />
		</cfloop>

		<cfreturn this />
	</cffunction>
		
	<!--- display --->
	<cffunction name="display" access="public" output="false" returntype="any">
		<cfargument name="Name" type="string" />

		<cfset var CustomFunctionName = "display#arguments.Name#" />
		<cfset var CustomFunction = "" />

		<!--- if a real function exists, use it --->
		<cfif existsFunction(CustomFunctionName)>
			<cfset CustomFunction = variables[CustomFunctionName] />
			<cfreturn CustomFunction() />

		<!--- otherwise, get display name --->
		<cfelse>
			<cfreturn variables.Properties.getAttribute(arguments.Name, 'DisplayName') />
		</cfif>
	</cffunction>	

	<!--- whether is null --->
	<cffunction name="is" access="public" output="false" returntype="boolean">
		<cfargument name="Name" type="string" />

		<cfset var CustomFunctionName = "is#arguments.Name#" />
		<cfset var CustomFunction = "" />

		<!--- if a real function exists, use it --->
		<cfif existsFunction(CustomFunctionName)>
			<cfset CustomFunction = variables[CustomFunctionName] />
			<cfreturn CustomFunction() />

		<!--- if property is defined in PropertyList, find out if it is null --->
		<cfelseif variables.Properties.existsProperty(arguments.Name)>
			<cfreturn get(arguments.Name) neq variables.Properties.getAttribute(arguments.Name, 'NullValue') />

		<!--- otherwise, throw error --->
		<cfelse>
			<cfthrow type="LoadedObjects" errorcode="LoadedObjects.isNullValue.UndefinedProperty" message="The function #CustomFunctionName# does not exist, and property '#(arguments.Name)#' could not be found." />
		</cfif>
	</cffunction>
			
	<!--- source data --->
	<cffunction name="setSourceData" access="public" output="false" returntype="any" hint="Set source data by supplying a query or an array-of-structs.">
		<cfargument name="SourceData" type="any" required="true" hint="struct or query or array-of-structs" />
		<cfset variables.SourceData = getLoadedObjects().getPlugin('SourceData').setSourceData(this, arguments.SourceData) />
		<cfreturn this />
	</cffunction>

	<!--- loop --->
	<cffunction name="loop" access="public" output="false" returntype="boolean">
		<cfargument name="Direction" type="string" default="forward" hint="Can be: forward, reverse" />		
		<cfreturn variables.SourceData.loop(arguments.Direction) />
	</cffunction>
	
	<!--- current row  --->
	<cffunction name="getCurrentRow" access="public" output="false" returntype="numeric" hint="Returns the current row">
		<cfreturn variables.SourceData.getCurrentRow() />
	</cffunction>
	
	<!--- num rows --->
	<cffunction name="numRows" access="public" output="false" returntype="numeric">
		<cfreturn variables.SourceData.numRows() />
	</cffunction>	
		
	<!--- has rows --->
	<cffunction name="hasRows" access="public" output="false" returntype="boolean">
		<cfreturn variables.SourceData.numRows() gt 0 />
	</cffunction>
	
	<!--- seek: moves the cursor to a specific row based on a value of a given property. If the value is not unique within the sourcedata, it will move to the first instance of the value. This was intended for use with primary keys. --->
	<cffunction name="seek" access="public" output="false" returntype="struct">
		<cfargument name="Property" type="string" required="true" />
		<cfargument name="Value" type="any" required="true" />
		
		<cfreturn variables.SourceData.seek(arguments.Property, arguments.Value) />
	</cffunction>
			
	<!--- list property values --->
	<cffunction name="listPropertyValues" access="public" output="false" returntype="array">
		<cfargument name="Name" type="string" required="true" hint="Property/column name" />
		<cfset FinalArray = ArrayNew(1) />
		<cfloop condition="#loop()#">
			<cfset ArrayAppend(FinalArray, get(arguments.Name)) />
		</cfloop>
		<cfreturn FinalArray />
	</cffunction>
		
	<!--- get all properties --->
	<cffunction name="getAll" access="public" output="false" returntype="struct">
		
		<cfset var ReturnStruct = StructNew() />
		<cfset var currentPropertyName = "" />
		
		<!--- set all properties to default --->
		<cfloop array="#variables.Properties.arrayPropertyNames()#" index="currentPropertyName">
			<cfset ReturnStruct[currentPropertyName] = get(currentPropertyName) />
		</cfloop>
		
		<cfreturn ReturnStruct />
	</cffunction>	
	
	<!--- set all properties --->
	<cffunction name="setAll" access="public" output="false" returntype="any">
		<cfargument name="Memento" type="any" required="true" hint="Can be a struct or a query or an array of structs" />
		<cfargument name="Row" type="numeric" default="1" hint="Specifies which row of the query or array of structs to use to populate the object" />

		<cfscript>
			var FinalStruct='';
			var QueryColumns='';
			var currentPropertyName = '';
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
		
			<!--- loop through this object's properties and set values from struct  --->
			<cfloop array="#variables.Properties.arrayPropertyNames()#" index="currentPropertyName">
				<cfif StructKeyExists(FinalStruct, currentPropertyName)>			
					<cfset set(currentPropertyName, FinalStruct[currentPropertyName]) />
				</cfif>
			</cfloop>
		
			<!--- loop through this object's properties and set values from struct 
			<cfloop condition="variables.Properties.loop('ReadOnly=False')">			
				<cfif StructKeyExists(FinalStruct, variables.Properties.get('Name'))>			
					<cfset set(variables.Properties.get('Name'), FinalStruct[variables.Properties.get('Name')]) />
				</cfif>
			</cfloop>
			--->
		<!--- if is query --->
		<cfelseif isQuery(arguments.Memento)>
			<cfset QueryColumns=arguments.Memento.ColumnList />
			
			<!--- loop through this object's properties and set values from struct  --->
			<cfloop array="#variables.Properties.arrayPropertyNames()#" index="currentPropertyName">
				<cfif listFindNoCase(QueryColumns, currentPropertyName)>
					<cfset set(currentPropertyName, arguments.Memento[currentPropertyName][arguments.Row]) />
				</cfif>
			</cfloop>
			
		<!--- otherwise error --->
		<cfelse>
			<cfthrow />
		</cfif>

		<cfreturn this />
	</cffunction>	
	
	<!--- raw --->
	<cffunction name="raw" access="public" output="false" returntype="any">
		<cfreturn variables.SourceData.raw() />
	</cffunction>
		
	<!--- onMissingMethod: provides generic get/set/isnull functionality without having to write out the functions --->
	<cffunction name="onMissingMethod" access="public" output="false" returntype="any" hint="Provides generic get/set/is functionality without having to write out the functions">
		<cfargument name="MissingMethodName" type="string" />
		<cfargument name="MissingMethodArguments" type="struct" />

		<cfset var Property="" />
		<cfset var KeyList="" />
		<cfset var ReturnVal="" />

		<!--- get --->
		<cfif left(arguments.MissingMethodName, 3) is 'get'>
			<cfset Property = right(arguments.MissingMethodName, len(arguments.MissingMethodName) - 3) />
			<cfreturn get(Property) />

		<!--- set --->
		<cfelseif left(arguments.MissingMethodName, 3) is 'set'>
			<cfset Property = right(arguments.MissingMethodName, len(arguments.MissingMethodName) - 3) />
			<cfset KeyList = StructKeyList(arguments.missingMethodArguments) />

			<cfif listlen(KeyList)>
				<cfreturn set(Property, arguments.missingMethodArguments[listfirst(KeyList)]) />
			<cfelse>
				<cfreturn set(Property, '') />
			</cfif>
			
		<!--- display --->
		<cfelseif left(arguments.MissingMethodName, 7) is 'display'>
			<cfset Property = right(arguments.MissingMethodName, len(arguments.MissingMethodName) - 7) />
			<cfreturn display(Property) />			

		<!--- is (null) --->
		<cfelseif Len(arguments.MissingMethodName) gt 2 AND Left(arguments.MissingMethodName, 2) is 'is'>
			<cfset Property = right(arguments.MissingMethodName, len(arguments.MissingMethodName) - 2) />
			<cfinvoke method="is" returnvariable="ReturnVal">
				<cfinvokeargument name="Name" value="#Property#" />
			</cfinvoke>
			<cfreturn ReturnVal />
		</cfif>
	</cffunction>	
</cfcomponent>