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
		</cfscript>
	</cffunction>

	<!--- index get --->
	<cffunction name="indexGet" access="public" output="false" returntype="any">
		<cfargument name="PropertyName" type="string" required="true" />
		<cfargument name="IndexName" type="string" required="true" hint="Name of the index to lookup" />
		<cfargument name="ID" type="string" required="true" />

		<cfscript>
			var PropertyName = arguments.PropertyName;
			var IndexName = arguments.IndexName;
			var ID = arguments.ID;

			var Index = variables.LoadedObjects.Index;
		</cfscript>

		<cfif indexExists(IndexName, ID)>
			<cfreturn get(PropertyName, Index['Data'][IndexName][ID]) />
		<cfelse>
			<cfreturn getLoadedObjectsMetadata(PropertyName, 'Default') />
		</cfif>
	</cffunction>

	<!--- index seek --->
	<cffunction name="indexSeek" access="public" output="false" returntype="any">
		<cfargument name="IndexName" type="string" required="true" hint="Name of the index to lookup" />
		<cfargument name="ID" type="string" required="true" />

		<cfscript>
			var IndexName = arguments.IndexName;
			var ID = arguments.ID;

			var Index = variables.LoadedObjects.Index;
		</cfscript>

		<cfif indexExists(IndexName, ID)>
			<cfreturn setCurrentRow(Index['Data'][IndexName][ID]) />
		<cfelse>
			<cfreturn setCurrentRow(0) />
		</cfif>

		<cfreturn this />
	</cffunction>

	<!--- index exists --->
	<cffunction name="indexExists" access="public" output="false" returntype="boolean">
		<cfargument name="IndexName" type="string" default="" hint="If empty, checks that index was inited, otherwise checks existence of specified indexname." />
		<cfargument name="ID" type="string" default="" hint="If specified, checks existence id." />

		<cfscript>
			var IndexName = arguments.IndexName;
			var ID = arguments.ID;

			var Index = variables.LoadedObjects.Index;
		</cfscript>

		<!--- if index not yet created, return false --->
		<cfif not StructCount(Index.Definitions)>
			<cfreturn false />
		</cfif>

		<!--- if index name specified, check for its existence --->
		<cfif Len(IndexName)>
			<cfif not StructKeyExists(Index.Data, IndexName)>
				<cfreturn false />
			</cfif>
		</cfif>

		<!--- if id specified, check for its existence --->
		<cfif Len(ID)>
			<cfif not StructKeyExists(Index.Data[IndexName], ID)>
				<cfreturn false />
			</cfif>
		</cfif>

		<cfreturn true />
	</cffunction>

	<!--- index remove
	<cffunction name="indexRemove" access="public" output="false" returntype="any">
		<cfargument name="IndexName" type="string" required="true" hint="Name of the index to lookup" />
		<cfargument name="ID" type="string" required="true" />

		<cfscript>
			var IndexName = arguments.IndexName;
			var ID = arguments.ID;

			var Index = variables.LoadedObjects.Index;
		</cfscript>

		<cfif indexExists(IndexName, ID)>
			<cfset removeRow(Index['Data'][IndexName][ID]) />

			<!--- TODO: decrement all index ids whose rows are greater than the one being deleted --->
			<cfset StructDelete(Index['Data'][IndexName], ID) />
		</cfif>

		<cfreturn this />
	</cffunction>
--->
	<!--- index update --->
	<cffunction name="indexUpdate" access="public" output="false" returntype="any">
		<cfscript>
			var Index = StructNew();

			var currentProperty = '';
			var currentIndexName = '';
			var currentKey = '';
			var currentRow = '';
			var TotalRows = getTotalRows();

			Index.Data = StructNew();
			Index.Definitions = variables.LoadedObjects.Index.Definitions;
		</cfscript>

		<!--- create index if it does not exist --->
		<cfif not indexExists()>
			<cfset indexCreate() />
		</cfif>

		<!--- add each record to all indexes --->
		<cfloop from="1" to="#TotalRows#" index="currentRow">
			<cfloop collection="#Index.Definitions#" item="currentIndexName">
				<cfset currentKey = "" />
				<cfloop list="#Index.Definitions[currentIndexName]#" index="currentProperty">
					<cfset currentKey = "#currentKey##get(currentProperty, currentRow)#" />
				</cfloop>
				<cfset Index.Data[currentIndexName][currentKey] = currentRow />
			</cfloop>
		</cfloop>

		<cfscript>
//			StructClear(variables.LoadedObjects.Index.Data);
//			StructAppend(variables.LoadedObjects.Index.Data, Index.Data, true);

			variables.LoadedObjects.Index.Data = Index.Data;
		</cfscript>

		<cfreturn this />
	</cffunction>

	<!--- index create --->
	<cffunction name="indexCreate" access="public" output="false" returntype="any">
		<cfscript>
			var Index = StructNew();

			var Properties = getLoadedObjectsMetaData().Properties;
			var OrderedProperties = StructSort(Properties, 'numeric', 'asc', 'Position');

			var currentProperty = '';
			var currentIndexName = '';
			var currentKey = '';

			Index.Data = StructNew();
			Index.Definitions = StructNew();
		</cfscript>

		<!--- create a collection of index names that define the properties that populate them --->
		<cfloop array="#OrderedProperties#" index="currentProperty">
			<cfif StructKeyExists(Properties[currentProperty], 'index')>
				<cfset currentIndexName = getLoadedObjectsMetaData(currentProperty, 'index') />
				<cfif StructKeyExists(Index.Definitions, currentIndexName)>
					<cfset Index.Definitions[currentIndexName] = ListAppend(Index.Definitions[currentIndexName], currentProperty) />
				<cfelse>
					<cfset Index.Data[currentIndexName] = StructNew() />
					<cfset Index.Definitions[currentIndexName] = currentProperty />
				</cfif>
			</cfif>
		</cfloop>

		<cfscript>
			StructClear(variables.LoadedObjects.Index.Definitions);
			StructAppend(variables.LoadedObjects.Index.Definitions, Index.Definitions, true);

			StructClear(variables.LoadedObjects.Index.Data);
			StructAppend(variables.LoadedObjects.Index.Data, Index.Data, true);
		</cfscript>

		<cfreturn this />
	</cffunction>

	<!--- index dump --->
	<cffunction name="indexDump" access="public" output="false" returntype="any">
		<cfreturn variables.loadedObjects.index />
	</cffunction>
</cfcomponent>