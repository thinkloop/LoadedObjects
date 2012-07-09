<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Baz K. (bk@thinkloop.com) - 01/01/2008
Edited By: Baz K. (bk@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">

	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="any">
		
		<cfscript>
			variables.i=StructNew();
			variables.i.Mixin=createObject('component', 'mixin');
			variables.i.DAO=createObject('component', 'dao').init();
		</cfscript>

		<cfreturn this />
	</cffunction>
	
	<!--- get mixin --->
	<cffunction name="getMixin" access="public" output="false" returntype="any" hint="Returns an instance of an object whose methods will be mixed in to newly created business obejcts (it is the plugin's job to instantiate the mixin object at some point, probably in init())">
		<cfreturn variables.i.Mixin />
	</cffunction>
	
	<!--- list dependencies to other plugins --->
	<cffunction name="listDependenciesToOtherPlugins" access="public" output="false" returntype="string" hint="Returns a list of names of other plugins upon which this plugin is dependent">
		<cfreturn '' />
	</cffunction>
	
	<!--- list metadata properties: the metadata properties that this plugin expects or uses --->
	<cffunction name="listMetaDataProperties" access="public" output="false" returntype="string" hint="Returns a list of names of properties that this plugin uses that are not inhereted from other plugins (some may be optional, some may be required)">
		<cfreturn '' />
	</cffunction>
	
	<!--- select --->
	<cffunction name="select" access="public" output="false" returntype="any">
		<cfargument name="BusinessObject" type="any" required="true" />
		<cfargument name="SelectExpression" type="string" required="true" />
		
		<cfscript>
			// shortcut to BO
			var BO=arguments.BusinessObject;
			
			// ** send select expression to amazon **
			var AmazonSelect=variables.i.DAO.select(arguments.SelectExpression);
			
			// loop var
			var current=StructNew();
		</cfscript>		

		<!--- loop through each row --->
		<cfloop array="#AmazonSelect#" index="current.Struct">
			<cfset BO.setMemento(current.Struct) />
			</cfloop>
		</cfloop>
		
		<cfreturn BO />
	</cffunction>
</cfcomponent>