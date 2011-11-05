<!--- * * (coldfusion comments are completely stripped out at compile time, and have zero impact on performance)
Created By: Bassil Karam (bassil.karam@thinkloop.com) - 01/01/2008
Edited By: Bassil Karam (bassil.karam@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">
	<cfproperty name="Filters" type="struct" hint="Struct of properties and values to filter by" />
	<cfproperty name="SearchWords" type="string" hint="Space-delimted list of search words to search properties by" />
	<cfproperty name="SearchWordProperties" type="string" hint="List of properties to search for search words" />
		
	<cfproperty name="SelectProperties" type="string" hint="List of properties to select" />
	<cfproperty name="OrderBy" type="string" hint="List of properties and direction (ASC/DESC) to order by (i.e. UserID DESC, FirstName ASC)" />

	<cfproperty name="CurrentRow" type="numeric" hint="Cursor position" />
	<cfproperty name="StartRow" type="numeric" hint="The first row to retrieve" />
	<cfproperty name="MaxRows" type="numeric" hint="The maximum number of rows to retrieve. A value of 0 (zero) retrieves all rows." />
	<cfproperty name="TotalRows" type="numeric" hint="Total number of rows had thre not been any filters." />
	
	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="any">		
		
		<!--- instance --->
		<cfset variables.i=StructNew() />
		
		<!--- initialize all variables --->
		<cfset clear() />

		<cfreturn this />
	</cffunction>
	
	<!--- clear --->
	<cffunction name="clear" access="public" output="false" returntype="any">
		<cfscript>		
			clearFilters();
			clearSearchWords();
			
			clearSelectProperties();
			clearOrderBy();
			
			clearStartRow();
			clearMaxRows();
			clearTotalRows();
		</cfscript>
		
		<cfreturn this />
	</cffunction>

<!--- * * * * * * * * * * * * * * * --->
<!--- * * FILTERS / SEARCHWORDS * * --->
<!--- * * * * * * * * * * * * * * * 
	the difference between a filter and a search-word is that a filter 
	is applied to a specific property and can be exact. So using a filter 
	is a suitable way of retrieving a record by id, for example. By contrast,
	search-words are matched against all *valid* properties with implied
	wildcards surroundig them.		  
--->

	<!--- filters --->
	<cffunction name="addFilter" access="public" output="false" returntype="any">
		<cfargument name="Property" type="string" required="true" hint="Property to filter." />
		<cfargument name="Value" type="string" required="true" hint="Value to filter by. A * (star) can be used as a wildcard. If only a * is provided, properties that are NOT null (as defined by the 'nullvalue' metadata property) will match." />
		<cfset variables.i.Filters[arguments.Property]=arguments.Value />
		<cfreturn this />
	</cffunction>
	<cffunction name="removeFilter" access="public" output="false" returntype="any">
		<cfargument name="Property" type="string" required="true" />
		<cfset StructDelete(variables.i.Filters, arguments.Property, false) />
		<cfreturn this />
	</cffunction>	
	<cffunction name="getFilters" access="public" output="false" returntype="struct">
		<cfreturn variables.i.Filters />
	</cffunction>
	<cffunction name="clearFilters" access="public" output="false" returntype="struct">
		<cfset variables.i.Filters=StructNew() />
		<cfreturn this />
	</cffunction>

	<!--- search words --->
	<cffunction name="setSearchWords" access="public" output="false" returntype="any">
		<cfargument name="SearchWords" type="string" default="" hint="Space-delimted list of search words to search (filter) properties by. A DB plugin, for example, could use this to make a LIKE '%searchword%' statement, or implement full-text search, etc." />
		<cfargument name="SearchWordProperties" type="string" default="" hint="List of properties to search (filter) with the search words. The Default value of empty string ('') means to search ALL properties." />
		
		<!--- search words --->
		<cfset variables.i.SearchWords=trim(arguments.SearchWords) />

		<!--- search word properties --->
		<cfset variables.i.SearchWordProperties=trim(arguments.SearchWordProperties) />

		<cfreturn this />
	</cffunction>
	<cffunction name="listSearchWords" access="public" output="false" returntype="string">
		<cfreturn variables.i.SearchWords />
	</cffunction>
	<cffunction name="clearSearchWords" access="public" output="false" returntype="struct">
		<cfset variables.i.SearchWords='' />
		<cfset variables.i.SearchWordProperties='' />
		<cfreturn this />
	</cffunction>
	<cffunction name="listSearchWordProperties" access="public" output="false" returntype="string" hint="Lists the properties that will be searched by the search words - db properties">
		<cfreturn variables.i.SearchWordProperties />
	</cffunction>
	
<!--- * * * * * * * * * * --->
<!--- * * ROW NUMBERS * * --->
<!--- * * * * * * * * * * --->
	
	<!--- start row --->
	<cffunction name="setStartRow" access="public" output="false" returntype="any">
		<cfargument name="StartRow" type="numeric" required="true" hint="integer" />
		<cfset variables.i.StartRow=arguments.StartRow />
		<cfreturn this />
	</cffunction>
	<cffunction name="getStartRow" access="public" output="false" returntype="numeric">
		<cfreturn variables.i.StartRow />
	</cffunction>
	<cffunction name="clearStartRow" access="public" output="false" returntype="any">
		<cfset variables.i.StartRow=1 />
		<cfreturn this />
	</cffunction>	
	
	<!--- max rows --->
	<cffunction name="setMaxRows" access="public" output="false" returntype="any">
		<cfargument name="MaxRows" type="numeric" required="true" hint="The maximum number of rows to return from the query - useful for pagination. A value of 0 (zero) returns all." />
		<cfset variables.i.MaxRows=arguments.MaxRows />
		<cfreturn this />
	</cffunction>
	<cffunction name="getMaxRows" access="public" output="false" returntype="numeric">
		<cfreturn variables.i.MaxRows />
	</cffunction>
	<cffunction name="clearMaxRows" access="public" output="false" returntype="any">
		<cfset variables.i.MaxRows=0 />
		<cfreturn this />
	</cffunction>	

<!--- * * * * * * * * * * * * * --->
<!--- * * SELECT / ORDER BY * * --->
<!--- * * * * * * * * * * * * * --->

	<!--- select properties: sets the properties that will be selected and returned (i.e. from a database, but could be from xml files, live QofQ style front-end processing, whatever - its up to the calling code (usually another plugin like a DAO), to make sense of it. A common use is to improve performance by limiting another system (db) from not querying dozens of columns and huge texts just to get at one column of type integer, for example. --->
	<cffunction name="setSelectProperties" access="public" output="false" returntype="any" hint="Sets the properties that will be selected and returned (i.e. from a db, xml files, q-of-q style front-end filtering, etc.). An intended use is to limit interaction with a backend system (i.e. db) such as querying dozens of unnecessary columns (i.e. huge texts, BLOBS, etc.) just to get at one column (i.e. tinyint).">
		<cfargument name="SelectProperties" type="string" default="" hint="List of properties to select from the database for this search. Defaults to all.">
		<cfset variables.i.SelectProperties=arguments.SelectProperties />
		<cfreturn this />
	</cffunction>
	<cffunction name="listSelectProperties" access="public" output="false" returntype="string">
		<cfreturn variables.i.SelectProperties />
	</cffunction>
	<cffunction name="clearSelectProperties" access="public" output="false" returntype="any">
		<cfset variables.i.SelectProperties="" />
		<cfreturn this />
	</cffunction>	
	
	<!--- order by --->
	<cffunction name="addOrderBy" access="public" output="false" returntype="any">
		<cfargument name="Property" type="string" required="true" />
		<cfargument name="Direction" type="string" default="ASC" />
		<cfset variables.i.OrderBy=ListAppend(variables.i.OrderBy, '#arguments.Property# #arguments.Direction#') />
		<cfreturn this />
	</cffunction>
	<cffunction name="getOrderBy" access="public" output="false" returntype="string">
		<cfreturn variables.i.OrderBy />
	</cffunction>
	<cffunction name="clearOrderBy" access="public" output="false" returntype="any">
		<cfset variables.i.OrderBy="" />
		<cfreturn this />
	</cffunction>
</cfcomponent>