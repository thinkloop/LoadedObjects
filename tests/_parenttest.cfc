<cfcomponent name="maintests" extends="mxunit.framework.TestCase">
	
	<!--- setup --->
	<cffunction name="setup" access="public" output="false" returntype="void">
		<cfscript>
			var Plugins=ArrayNew(1);
			var BusinessObjects=StructNew();
			
			// plugins
			ArrayAppend(Plugins, createObject('component', 'LoadedObjects.plugins.validator.validator').init());
			
			// business objects
			BusinessObjects.Post=createObject('component', 'LoadedObjects.www.post');
			BusinessObjects.Comment=createObject('component', 'LoadedObjects.www.comment');
			
			// LoadedObjects
			LoadedObjects=createObject('component', 'LoadedObjects.LoadedObjects').init(Plugins=Plugins, BusinessObjects=BusinessObjects);
		</cfscript>
	</cffunction>

</cfcomponent>



