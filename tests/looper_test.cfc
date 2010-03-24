<cfcomponent extends="_parenttest">
	
	<!--- get LoadedObjects --->
	<cffunction name="getLoadedObjects" access="public" output="false" returntype="void">
		<cfscript>
			var Post=LoadedObjects.new('Post');
			assertIsTypeOf(Post.getLoadedObjects(), 'LoadedObjects.LoadedObjects');
		</cfscript>
	</cffunction>
</cfcomponent>