<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Bassil Karam (bassil.karam@thinkloop.com) - 01/01/2008
Edited By: Bassil Karam (bassil.karam@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">

	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfset variables.Mixin=createObject('component', 'mixin') />
		<cfreturn this />
	</cffunction>
	
	<!--- get mixin --->
	<cffunction name="getMixin" access="public" output="false" returntype="any" hint="Returns an instance of an object whose methods will be mixed in to newly created business obejcts (it is the plugin's job to instantiate the mixin object at some point, probably in init())">
		<cfreturn variables.Mixin />
	</cffunction>
	
	<!--- list dependencies to other plugins --->
	<cffunction name="listDependenciesToOtherPlugins" access="public" output="false" returntype="string" hint="Returns a list of names of other plugins upon which this plugin is dependent">
		<cfreturn '' />
	</cffunction>
	
	<!--- list metadata properties: the metadata properties that this plugin expects or uses --->
	<cffunction name="listMetaDataProperties" access="public" output="false" returntype="string" hint="Returns a list of names of properties that this plugin uses that are not inhereted from other plugins (some may be optional, some may be required)">
		<cfreturn '' />
	</cffunction>
</cfcomponent>