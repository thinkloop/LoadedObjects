<cfcomponent extends="_parenttest">
	
	<!--- test exists function --->
	<cffunction name="existsFunction" access="public" output="false" returntype="void">
		<cfscript>
			var Post=LoadedObjects.new('Post');
			assertTrue(Post.existsFunction('get'), 'The function "get()" should exist');
			assertFalse(Post.existsFunction('getkaka'), 'The function "getkaka()" should NOT exist');
		</cfscript>
	</cffunction>
</cfcomponent>



