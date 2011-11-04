<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Bassil Karam (bassil.karam@thinkloop.com) - 01/01/2008
Edited By: Bassil Karam (bassil.karam@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">

	<!--- init - this will be run after all plugins have been mixed in, then removed from the final business object --->
	<cffunction name="init" access="public" output="false" returntype="void">
		<cfscript>
			variables.SourceData='';
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

		<!--- if property is defined in PropertyList, get it --->
		<cfelse>
			<cfreturn variables.SourceData.get(arguments.Name) />
		</cfif>	
	</cffunction>
	
	<!--- clear --->
	<cffunction name="clear" access="public" output="false" returntype="any" hint="Sets all properties to null">

		<cfset var Properties=getMetaDataObject().getProperties() />
		
		<!--- init source data --->
		<cfif not isObject(variables.SourceData)>
			<cfset setSourceData(StructNew()) />			
		</cfif>
		
		<!--- set all properties to default --->
		<cfloop condition="Properties.loop()">
			<cfset set(Properties.get('Name'), Properties.get('Default')) />
		</cfloop>

		<cfreturn this />
	</cffunction>
		
	<!--- display --->
	<cffunction name="display" access="public" output="false" returntype="any">
		<cfargument name="Name" type="string" />

		<cfset var CustomFunctionName="display#arguments.Name#" />
		<cfset var CustomFunction="" />

		<!--- if a real function exists, use it --->
		<cfif existsFunction(CustomFunctionName)>
			<cfset CustomFunction=variables[CustomFunctionName] />
			<cfreturn CustomFunction() />

		<!--- otherwise, get display name --->
		<cfelse>
			<cfreturn getMetaDataObject().getProperties().seek(arguments.Name).get('DisplayName') />
		</cfif>
	</cffunction>	

	<!--- i am the generic version of is[PropertyName]() (isNull() is a reserved function in Railo) --->
	<cffunction name="is" access="public" output="false" returntype="boolean">
		<cfargument name="Name" type="string" />

		<cfset var CustomFunctionName="is#arguments.Name#" />
		<cfset var CustomFunction="" />

		<!--- if a real function exists, use it --->
		<cfif existsFunction(CustomFunctionName)>
			<cfset CustomFunction=variables[CustomFunctionName] />
			<cfreturn CustomFunction() />

		<!--- if property is defined in PropertyList, find out if it is null --->
		<cfelseif getMetaDataObject().getProperties().exists(arguments.Name)>
			<cfreturn isSimpleValue(get(arguments.Name)) AND get(arguments.Name) is getMetaDataObject().getProperties().seek(arguments.Name).get('NullValue') />

		<!--- otherwise, throw error --->
		<cfelse>
			<cfthrow type="LoadedObjects" errorcode="LoadedObjects.isNullValue.UndefinedProperty" message="Could not determine if the property #UCase(arguments.Name)# is null because it was not found in component #ucase(getMetaDataObject().getPath())#" detail="Ensure that the property is defined, and that it is spelled correctly." />
		</cfif>
	</cffunction>
		
	<!--- source data --->
	<cffunction name="setSourceData" access="public" output="false" returntype="any" hint="Set source data by supplying a query or an array-of-structs.">
		<cfargument name="SourceData" type="any" required="true" hint="struct or query or array-of-structs" />
		
		<cfset var EmptyArrayOfStructs = ArrayNew(1) />
		
		<!--- instantiate the right object for a query or array-of-structs --->
		<cfif isQuery(arguments.SourceData)>
			<cfset variables.SourceData=createObject('component', 'types.query').init(this, arguments.SourceData) />
		<cfelseif isArray(arguments.SourceData)>
			<cfset variables.SourceData=createObject('component', 'types.arrayofstructs').init(this, arguments.SourceData) />
		<cfelseif isStruct(arguments.SourceData)>
			<cfset ArrayAppend(EmptyArrayOfStructs, arguments.SourceData) />
			<cfset variables.SourceData=createObject('component', 'types.arrayofstructs').init(this, EmptyArrayOfStructs) />
		<cfelse>
			<!--- TODO: throw an error that the type is unsupported --->
<cfdump var="#arguments.SourceData#">			
			<cfthrow />
		</cfif>
		
		<cfreturn this />
	</cffunction>
	<cffunction name="getSourceData" access="public" output="false" returntype="any" hint="Returns instance of sourcedata object">		
		<cfreturn variables.SourceData />
	</cffunction>
		
	<!--- loop: this will error if source-data isn't set. I am thinking of taking it out in favor of just: getSourceData().loop() --->
	<cffunction name="loop" access="public" output="false" returntype="boolean">
		<cfargument name="Direction" type="string" default="forward" hint="Can be: forward, reverse" />		
		<cfreturn variables.SourceData.loop(arguments.Direction) />
	</cffunction>
	
	<!--- num rows --->
	<cffunction name="numRows" access="public" output="false" returntype="numeric">
		<cfreturn variables.SourceData.numRows() />
	</cffunction>	
		
	<!--- has rows --->
	<cffunction name="hasRows" access="public" output="false" returntype="boolean">
		<cfreturn variables.SourceData.numRows() gt 0 />
	</cffunction>
	
	<!--- memento --->
	<cffunction name="getMemento" access="public" output="false" returntype="struct">
		
		<cfset var ReturnStruct=StructNew() />
		<cfset var Properties=getMetaDataObject().getProperties() />

		<!--- get all properties --->
		<cfloop condition="Properties.loop()">		
			<cfset ReturnStruct[Properties.get('Name')]=get(Properties.get('Name')) />
		</cfloop>
		
		<cfreturn ReturnStruct />
	</cffunction>	
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
</cfcomponent>