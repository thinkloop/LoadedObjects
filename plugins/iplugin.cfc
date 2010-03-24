<cfinterface displayName="iPlugin" hint="Every plugin must implement the functions defined in this interface otherwise a run-time error will occur. The interface itself does not have to be implemented as there will be no type-checking for it - it is simply a means of communication">
	
	<cffunction name="init" access="public" output="false" returntype="void">
		<cfargument name="LoadedObjects" type="any" required="true" hint="Automatically passed in by plugin manager" />
		<cfargument name="BusinessObjectName" type="string" required="true" hint="Automatically passed in by plugin manager" />
	</cffunction>
	
	<cffunction name="getMixin" access="public" output="false" returntype="any" hint="Returns an instance of an object whose methods will be mixed in to newly created business obejcts (it is the plugin's job to instantiate the mixin object at some point, probably in init())">
	</cffunction>
	
	<cffunction name="listDependenciesToOtherPlugins" access="public" output="false" returntype="string" hint="Returns a list of names of other plugins upon which this plugin is dependent">
	</cffunction>
	
	<cffunction name="listMetaDataProperties" access="public" output="false" returntype="string" hint="Returns a list of names of properties that this plugin uses that are not inhereted from other plugins (some may be optional, some may be required)">
	</cffunction>
</cfinterface>