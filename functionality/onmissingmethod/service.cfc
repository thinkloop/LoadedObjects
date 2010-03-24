<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Bassil Karam (bassil.karam@thinkloop.com) - 01/01/2008
Edited By: Bassil Karam (bassil.karam@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">

	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfset variables.Mixin=createObject('component', 'mixin') />
		<cfset variables.OnMissingMethodFunctions=ArrayNew(1) />
		<cfreturn this />
	</cffunction>
	
	<!--- parse on missing method functions --->
	<cffunction name="parseOnMissingMethodFunctions" access="public" output="false" returntype="any">
		<cfargument name="Plugins" type="array" hint="Array of all plugins" />
		
		<cfscript>
			var AllPlugins=arguments.Plugins;
			var current=StructNew();
			current.Plugin='';
			current.Mixin='';
			current.Position='';			
		</cfscript>

		<!--- find onmissingmethod functions within each plugin and store them in this plugin (later on they will be overwritten in the final object by the onMissingMethod mixin's onMissingMethod) --->
		<cfloop from="2" to="#ArrayLen(AllPlugins)#" index="current.Position">
			<cfset current.Plugin=AllPlugins[current.Position] />
			<cfset current.Mixin=current.Plugin.getMixin() />
			<cfif StructKeyExists(current.Mixin, 'onMissingMethod')>	
				<cfset ArrayAppend(variables.OnMissingMethodFunctions, current.Mixin.onMissingMethod) />
			</cfif>
		</cfloop>

		<cfreturn this />
	</cffunction>
	
	<!--- get on missing method functions --->
	<cffunction name="getOnMissingMethodFunctions" access="public" output="false" returntype="array">
		<cfreturn variables.OnMissingMethodFunctions />
	</cffunction>
	
	<!--- get mixin --->
	<cffunction name="getMixin" access="public" output="false" returntype="any" hint="Returns an instance of an object whose methods will be mixed in to newly created business obejcts (it is the plugin's job to instantiate the mixin object at some point, probably in init())">
		<cfreturn variables.Mixin />
	</cffunction>
	
	<!--- list dependencies to other plugins --->
	<cffunction name="listDependenciesToOtherPlugins" access="public" output="false" returntype="string" hint="Returns a list of names of other plugins upon which this plugin is dependent">
		<cfreturn '' />
	</cffunction>
	
	<!--- list metadata properties --->
	<cffunction name="listMetaDataProperties" access="public" output="false" returntype="string" hint="Returns a list of names of properties that this plugin uses that are not inhereted from other plugins (some may be optional, some may be required)">
		<cfreturn '' />
	</cffunction>
</cfcomponent>