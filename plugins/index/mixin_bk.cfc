<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Baz K. (bk@thinkloop.com) - 01/01/2008
Edited By: Baz K. (bk@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">

	<!--- init - this will be run after all plugins have been mixed in, then removed from the final business object --->
	<cffunction name="init" access="public" output="false" returntype="void">
		<cfscript>
			variables.LoadedObjects.Index = StructNew();
			variables.LoadedObjects.Index.Data = StructNew();
			variables.LoadedObjects.Index.Definitions = StructNew();
			variables.LoadedObjects.Index.LoopNum = 0;
		</cfscript>
	</cffunction>

	<!--- index get --->
	<cffunction name="indexGet" access="public" output="false" returntype="any">
		<cfargument name="IndexName" type="string" required="true" hint="Name of the index to lookup" />
		<cfargument name="IDs" type="string" required="true" hint="List of ids" />

		<cfscript>
			var IndexName = arguments.IndexName;
			var IDs = Trim(arguments.IDs);

			var IndexData = variables.LoadedObjects.Index.Data;

			var NewBO = new();
			var newRawData = Struct();

			var missingIDs = StructNew();
			var missingIDsBO = '';

			var currentID = '';

			var itemsQuery = '';
		</cfscript>

		<!--- if no ids specified or no rows in the object, return empty bo --->
		<cfif not ListLen(IDs) OR getTotalRows() lte 0>
			<cfreturn NewBO />
		</cfif>

		<!--- if index not yet created, create it --->
		<cfif not StructKeyExists(IndexData, IndexName) OR StructCount(IndexData[IndexName]) lt getTotalRows()>
			<cfset indexCreate() />
			<cfset IndexData = variables.LoadedObjects.Index.Data />
			<cfif not StructKeyExists(IndexData, IndexName)>
				<cfreturn NewBO />
			</cfif>
		</cfif>
		<cfset IndexData = IndexData[IndexName] />

		<!--- loop through list of ids and retrieve associated row nums --->
		<cfloop list="#IDs#" index="currentID">
			<cfif StructKeyExists(IndexData, currentID)>
				<cfset newRawData[StructCount(newRawData) + 1] = getRawDataManager().getRawRow(IndexData[currentID]) />
			</cfif>
		</cfloop>

		<!--- set raw data --->
		<cfset NewBO.setRawData(NewRawData).allHasBeenSet() />

		<cfreturn NewBO />
	</cffunction>

	<!--- index loop --->
	<cffunction name="indexLoop" access="public" output="false" returntype="boolean">
		<cfargument name="IndexName" type="string" required="true" hint="Name of the index to lookup" />
		<cfargument name="IDs" type="string" required="true" />

		<cfscript>
			var IndexName = arguments.IndexName;
			var IDs = arguments.IDs;

			var LoopNum = variables.LoadedObjects.Index.LoopNum;
			var TotalNum = ListLen(IDs);

			var SeekRow = '';
		</cfscript>

		<cfif not ListLen(IDs)>
			<cfset setCurrentRow(0) />
			<cfreturn false />
		</cfif>

		<!--- start loop if this is the first iteration --->
		<cfif LoopNum lt 1 OR LoopNum gt TotalNum>
			<cfset variables.LoadedObjects.Index.LoopNum = 1 />

		<!--- if next record exists, increment current row, return true --->
		<cfelseif LoopNum lt TotalNum>
			<cfset variables.LoadedObjects.Index.LoopNum = variables.LoadedObjects.Index.LoopNum + 1 />

		<!--- otherwise reset current row, return false --->
		<cfelse>
			<cfset variables.LoadedObjects.Index.LoopNum = 0 />
			<cfset setCurrentRow(0) />
			<cfreturn False />
		</cfif>

		<cfset SeekRow =  ListGetAt(IDs, variables.LoadedObjects.Index.LoopNum) />
		<cfset indexSeek(IndexName, SeekRow) />

		<!--- if id didn't exists in index, continue looping --->
		<cfif getCurrentRow() lte 0>
			<cfreturn indexLoop(IndexName, IDs) />
		</cfif>

		<cfreturn True />
	</cffunction>

	<!--- index seek --->
	<cffunction name="indexSeek" access="public" output="false" returntype="any">
		<cfargument name="IndexName" type="string" required="true" hint="Name of the index to lookup" />
		<cfargument name="ID" type="string" required="true" />

		<cfscript>
			var IndexName = arguments.IndexName;
			var ID = arguments.ID;

			var IndexData = variables.LoadedObjects.Index.Data;
		</cfscript>

		<cfif not StructKeyExists(IndexData, IndexName) OR StructCount(IndexData[IndexName]) lt getTotalRows()>
			<cfset indexCreate() />
			<cfset IndexData = variables.LoadedObjects.Index.Data />
			<cfif not StructKeyExists(IndexData, IndexName)>
				<cfset setCurrentRow(0) />
				<cfreturn this />
			</cfif>
		</cfif>
		<cfset IndexData = IndexData[IndexName] />

		<!--- set current row --->
		<cfif StructKeyExists(IndexData, ID)>
			<cfset setCurrentRow(IndexData[ID]) />
		<cfelse>
			<cfset setCurrentRow(0) />
		</cfif>

		<cfreturn this />
	</cffunction>

	<!--- index put
	<cffunction name="indexPut" access="public" output="false" returntype="any">
		<cfargument name="IDs" type="string" required="true" hint="List of ids to load and add to collection and index" />

		<cfscript>
			var IDs = arguments.IDs;
			var Index = variables.loadedObjects.Index;
			var IndexDefinitions = variables.loadedObjects.IndexDefinitions;
			var BO = new();

			var currentIndexName = '';
			var currentProperty = '';
			var currentKey = '';

			BO.load(IDs);
		</cfscript>

		<!--- add each record to collection and all indexes --->
		<cfloop condition="BO.loop()">
			<cfloop collection="#IndexDefinitions#" item="currentIndexName">
				<cfset currentKey = "" />
				<cfloop list="#IndexDefinitions[currentIndexName]#" index="currentProperty">
					<cfset currentKey = "#currentKey##get(currentProperty)#" />
				</cfloop>

				<cfif StructKeyExists(Index[currentIndexName], currentKey)>
					<cfset setAll(BO.getAll(), Index[currentIndexName][currentKey]) />
				<cfelse>
					<cfset addAll(BO.getRawData()) />
					<cfset Index[currentIndexName][currentKey] = getCurrentRow() />
				</cfif>
			</cfloop>
		</cfloop>
	</cffunction>
--->
	<!--- index create --->
	<cffunction name="indexCreate" access="public" output="false" returntype="any">
		<cfscript>
			var Index = StructNew();

			var Properties = getLoadedObjectsMetaData().Properties;
			var currentProperty = '';
			var currentKey = '';
			var currentIndexName = '';

			Index.Data = StructNew();
			Index.Definitions = StructNew();
			Index.LoopNum = 0;
		</cfscript>

		<!--- create a collection of index names that define the properties that populate --->
		<cfloop collection="#Properties#" item="currentProperty">
			<cfif StructKeyExists(Properties[currentProperty], 'index')>
				<cfset currentIndexName = getLoadedObjectsMetaData(currentProperty, 'index') />
				<cfif StructKeyExists(Index.Definitions, currentIndexName)>
					<cfset Index.Definitions[currentIndexName] = ListAppend(Index.Definitions[currentIndexName], currentProperty) />
				<cfelse>
					<cfset Index.Data[currentIndexName] = StructNew() />
					<cfset Index.Definitions[currentIndexName] = StructNew() />
					<cfset Index.Definitions[currentIndexName] = currentProperty />
				</cfif>
			</cfif>
		</cfloop>

		<!--- add each record to all indexes --->
		<cfloop condition="loop()">
			<cfloop collection="#Index.Definitions#" item="currentIndexName">
				<cfset currentKey = "" />
				<cfloop list="#Index.Definitions[currentIndexName]#" index="currentProperty">
					<cfset currentKey = "#currentKey##get(currentProperty)#" />
				</cfloop>
				<cfset Index.Data[currentIndexName][currentKey] = getCurrentRow() />
			</cfloop>
		</cfloop>

		<cfset variables.LoadedObjects.Index = Index />

		<cfreturn this />
	</cffunction>

	<!--- index dump --->
	<cffunction name="indexDump" access="public" output="false" returntype="any">
		<cfreturn variables.loadedObjects.index />
	</cffunction>
</cfcomponent>