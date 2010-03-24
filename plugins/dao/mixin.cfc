<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Bassil Karam (bassil.karam@thinkloop.com) - 01/01/2008
Edited By: Bassil Karam (bassil.karam@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">

	<!--- save --->
	<cffunction name="save" access="public" output="false" returntype="any">
		<cfreturn getLoadedObjects().getPlugin('DAO').save(this) />
	</cffunction>	

	<!--- create --->
	<cffunction name="create" access="public" output="false" returntype="any">
		<cfreturn getLoadedObjects().getPlugin('DAO').create(this) />
	</cffunction>

	<!--- read --->
	<cffunction name="read" access="public" output="false" returntype="any">
		<cfargument name="RelationshipList" type="string" default="" hint="List of OneToMany or ManyToMany relationships to read as well.">
		<cfargument name="UniqueIndex" type="string" default="PrimaryKey" hint="The unique index to use (as defined in the metadata) to isolate a single record. Default is PrimaryKey.">
		<cfargument name="SelectPropertyList" type="string" default="" hint="List of properties to select. Default is all.">
		
		<cfreturn getLoadedObjects().getPlugin('DAO').read(this, arguments.RelationshipList, arguments.UniqueIndex, arguments.SelectPropertyList) />
	</cffunction>

	<!--- update --->
	<cffunction name="update" access="public" output="false" returntype="any">
		<cfreturn getLoadedObjects().getPlugin('DAO').update(this) />
	</cffunction>

	<!--- delete --->
	<cffunction name="delete" access="public" output="false" returntype="any">
		<cfreturn getLoadedObjects().getPlugin('DAO').delete(this) />
	</cffunction>

	<!--- exists --->
	<cffunction name="exists" access="public" output="false" returntype="boolean">
		<cfargument name="PropertyList" type="string" default="" hint="List of properties to use to check existence of a record. If none are specified, primary key(s) are used instead." />

		<cfreturn getLoadedObjects().getPlugin('DAO').exists(this, arguments.PropertyList) />
	</cffunction>


</cfcomponent>