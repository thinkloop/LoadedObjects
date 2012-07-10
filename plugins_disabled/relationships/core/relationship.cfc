<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Baz K. (bk@thinkloop.com) - 01/01/2008
Edited By: Baz K. (bk@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">
	<cfproperty name="SelectProperties" type="string" hint="List of properties to select" />
	<cfproperty name="OrderBy" type="string" hint="List of properties and direction (ASC/DESC) to order by (i.e. UserID DESC, FirstName ASC)" />

	<cfproperty name="StartRow" type="numeric" hint="The first row to retrieve" />
	<cfproperty name="MaxRows" type="numeric" hint="The maximum number of rows to retrieve. A value of 0 (zero) retrieves all rows." />
	
	<cfproperty name="Filters" type="struct" hint="Struct of properties and values to filter by" />
	<cfproperty name="Keywords" type="string" hint="Space-delimted list of keywords to search properties by" />
	<cfproperty name="KeywordProperties" type="string" hint="List of properties to search for keywords" />	
	
	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="SelectProperties" type="string" default="" />
		<cfargument name="OrderBy" type="string" default="" />
		<cfargument name="StartRow" type="string" default="" />
		<cfargument name="MaxRows" type="string" default="" />
		<cfargument name="Filters" type="string" default="" />
		<cfargument name="Keywords" type="string" default="" />
		<cfargument name="KeywordProperties" type="string" default="" />
		
		<cfscript>			
			variables.i=structnew();

			variables.i.SelectProperties='';
			variables.i.Filters=StructNew();
			variables.i.Keywords='';
			variables.i.KeywordProperties='';
			
			variables.i.StartRow=1;
			variables.i.MaxRows=0;
			variables.i.OrderBy='';
		</cfscript>

		<cfreturn this />
	</cffunction>
	
<!--- * * * * * * * * * * * * * * --->
<!--- * * DATA SET MANAGEMENT * * --->
<!--- * * * * * * * * * * * * * * --->

	<!--- filters --->
	<cffunction name="addFilter" access="public" output="false" returntype="any">
		<cfargument name="Property" type="string" required="true" />
		<cfargument name="Value" type="string" required="true" hint="Value to filter by. * (star) can be used as a wildcard. If a struct key value is only * (star), the property must simply be non-empty and not null." />
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

	<!--- keywords --->
	<cffunction name="setKeywords" access="public" output="false" returntype="any">
		<cfargument name="Keywords" type="string" default="" hint="Space-delimted list of keywords to search properties by" />
		<cfargument name="KeywordProperties" type="string" default="" hint="List of properties to search (filter) with the keywords. Default is all." />
		
		<!--- keywords --->
		<cfset variables.i.Keywords=arguments.Keywords />

		<!--- keyword properties --->
		<cfif Len(arguments.KeywordProperties)>
			<cfset variables.i.KeywordProperties=arguments.KeywordProperties />
		</cfif>

		<cfreturn this />
	</cffunction>
	<cffunction name="listKeywords" access="public" output="false" returntype="string">
		<cfreturn variables.i.Keywords />
	</cffunction>
	
	<!--- TODO: this function should be in the DAO plugin somewhere because it is specifically for DB, whereas the other functions can actually be implemented by other plugins like FEED --->
	<cffunction name="listPropertiesAffectedByKeywords" access="public" output="false" returntype="string" hint="Lists the properties that will be searched by the keywrods - db properties">
		<cfreturn variables.i.KeywordProperties />
	</cffunction>

	<!--- select properties: sets the properties that will be selected and returned from the database. select only the columns you need for best performance --->
	<!--- TODO: perhaps these have to be renamed to something less db-oriented since this plugin should be usable by any other plugins like FEED --->
	<cffunction name="setSelectProperties" access="public" output="false" returntype="any">
		<cfargument name="SelectProperties" type="string" default="" hint="List of properties to select from the database for this search. Defaults to all.">
		<cfset variables.i.SelectProperties=arguments.SelectProperties />
		<cfreturn this />
	</cffunction>
	<cffunction name="listSelectProperties" access="public" output="false" returntype="string">
		<cfreturn variables.i.SelectProperties />
	</cffunction>

<!--- * * * * * * * * * *--->
<!--- * * PAGINATION * * --->
<!--- * * * * * * * * * *--->

	<!--- start row --->
	<cffunction name="setStartRow" access="public" output="false" returntype="any">
		<cfargument name="StartRow" type="numeric" required="true" hint="integer" />
		<cfset variables.i.StartRow=arguments.StartRow />
		<cfreturn this />
	</cffunction>
	<cffunction name="getStartRow" access="public" output="false" returntype="numeric">
		<cfreturn variables.i.StartRow />
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
	
	<!--- order by --->
	<!--- TODO: perhaps these have to be renamed to something less db-oriented since this plugin should be usable by any other plugins like FEED --->
	<cffunction name="addOrderBy" access="public" output="false" returntype="any">
		<cfargument name="Property" type="string" required="true" />
		<cfargument name="Direction" type="string" default="ASC" />
		<cfset variables.i.OrderBy=ListAppend(variables.i.OrderBy, '#arguments.Property# #arguments.Direction#') />
		<cfreturn this />
	</cffunction>
	<cffunction name="getOrderBy" access="public" output="false" returntype="string">
		<cfreturn variables.i.OrderBy />
	</cffunction>
</cfcomponent>