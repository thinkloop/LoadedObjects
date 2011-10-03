<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Bassil Karam (bassil.karam@thinkloop.com) - 01/01/2008
Edited By: Bassil Karam (bassil.karam@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">
	<cfproperty name="Name" type="string" hint="The name of the business object" />
	<cfproperty name="Path" type="string" hint="The dot path notation (path.to.cfc) of the business object" />
	<cfproperty name="DisplayName" type="string" hint="The display name of the business object (i.e. 'UserID' displayed as 'User ID')" />
	<cfproperty name="Dependencies" type="struct" hint="A struct that containes an instance of each object that this business object depends on (is composed of)" />
	<cfproperty name="Properties" type="struct" displayname="Properties" hint="The metadata of the properties of a business object" relationship="OneToMany" with="Property" />

	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="Name" type="string" required="true" />
		<cfargument name="Path" type="string" default="" />
		<cfargument name="DisplayName" type="string" default="" />
		<cfargument name="Dependencies" type="struct" default="#StructNew()#" />

		<cfscript>
			variables.i=arguments;
			variables.i.Properties=createObject('component', 'properties').init();
		</cfscript>

		<cfreturn this />
	</cffunction>
	
	<!--- set/get name --->
	<cffunction name="setName" access="public" output="false" returntype="any">
		<cfargument name="Name" type="string" default="" />
		<cfset variables.i.Name=arguments.Name />
		<cfreturn this />
	</cffunction>
	<cffunction name="getName" access="public" output="false" returntype="string">
		<cfreturn variables.i.Name />
	</cffunction>
	
	<!--- set/get path --->
	<cffunction name="setPath" access="public" output="false" returntype="any">
		<cfargument name="Path" type="string" default="" />
		<cfset variables.i.Path=arguments.Path />
		<cfreturn this />
	</cffunction>
	<cffunction name="getPath" access="public" output="false" returntype="string">
		<cfreturn variables.i.Path />
	</cffunction>

	<!--- set/get display name --->
	<cffunction name="setDisplayName" access="public" output="false" returntype="any">
		<cfargument name="DisplayName" type="string" default="" />
		<cfset variables.i.DisplayName=arguments.DisplayName />
		<cfreturn this />
	</cffunction>
	<cffunction name="getDisplayName" access="public" output="false" returntype="string">
		<cfreturn variables.i.DisplayName />
	</cffunction>

	<!--- set/get dependencies --->
	<cffunction name="setDependencies" access="public" output="false" returntype="any">
		<cfargument name="Dependencies" type="struct" default="#StructNew()#" />
		<cfset variables.i.Dependencies=arguments.Dependencies />
		<cfreturn this />
	</cffunction>
	<cffunction name="getDependencies" access="public" output="false" returntype="struct">
		<cfreturn variables.i.Dependencies />
	</cffunction>

	<!--- get properties --->
	<cffunction name="getProperties" access="public" output="false" returntype="any">
		<cfreturn variables.i.Properties />
	</cffunction>
	
	<!--- get memento --->
	<cffunction name="getMemento" access="public" output="false" returntype="struct">
		<cfreturn variables.i />
	</cffunction>

</cfcomponent>