<cfcomponent extends="_parenttest">
	
	<!--- get meta data object --->
	<cffunction name="getMetaDataObject" access="public" output="false" returntype="void">
		<cfscript>
			var Post=LoadedObjects.new('Post');
			assertIsTypeOf(Post.getMetaDataObject(), 'LoadedObjects.core.metadata.object');
		</cfscript>
	</cffunction>
</cfcomponent>



