<cfcomponent extends="_parenttest">
	
	<!--- generic set/get --->
	<cffunction name="generic_Set_Get" access="public" output="false" returntype="void">
		<cfscript>
			var Post=LoadedObjects.new('Post');
			Post.set('ID', '1234');
			Post.set('Title', 'Post Title');
			
			assertEquals(Post.get('ID'), 1234);
			assertEquals(Post.get('Title'), 'Post Title');
		</cfscript>
		
		<!--- property doesn't exist --->
		<cftry>
			<cfset Post.get('NonExistentProperty') />
			<cfset fail('Attempt to get(''NonExistentProperty'') a non-existent property did not throw an error when it should have')>
			<cfcatch type="any"><!--- should always reach here ---></cfcatch>
		</cftry>
	</cffunction>

	<!--- explicit set/get --->
	<cffunction name="explicit_Set_Get" access="public" output="false" returntype="void">
		<cfscript>
			var Post=LoadedObjects.new('Post');
			Post.setID(1234);
			Post.setTitle('Post Title');
			
			assertEquals(Post.getID(), 1234);
			assertEquals(Post.getTitle(), 'Post Title');
		</cfscript>
		
		<!--- property doesn't exist --->
		<cftry>
			<cfset Post.getNonExistentProperty() />
			<cfset fail('Attempt to getNonExistentProperty() did not throw an error when it should have')>
			<cfcatch type="any"><!--- should always reach here ---></cfcatch>
		</cftry>
	</cffunction>

	<!--- generic isnull --->
	<cffunction name="generic_isnull" access="public" output="false" returntype="void">
		<cfscript>
			var Post=LoadedObjects.new('Post');
			Post.set('ID', 0);
			Post.set('Title', 'title is not null');
			
			assertTrue(Post.isNullValue('ID'));
			assertFalse(Post.isNullValue('Title'));
		</cfscript>
		
		<!--- property doesn't exist --->
		<cftry>
			<cfset Post.isNullValue('NonExistentProperty') />
			<cfset fail('Attempt to isNullValue(''NonExistentProperty'') a non-existent property did not throw an error when it should have')>
			<cfcatch type="any"><!--- should always reach here ---></cfcatch>
		</cftry>
	</cffunction>
	
	<!--- explicit isnull --->
	<cffunction name="explicit_isnull" access="public" output="false" returntype="void">
		<cfscript>
			var Post=LoadedObjects.new('Post');
			Post.setID(0);
			Post.setTitle('title is not null');

			assertTrue(Post.isNullID());
			assertFalse(Post.isNullTitle());
		</cfscript>
	
		<!--- property doesn't exist --->
		<cftry>
			<cfset Post.isNullNonExistentProperty() />
			<cfset fail('Attempt to isNullNonExistentProperty() did not throw an error when it should have')>
			<cfcatch type="any"><!--- should always reach here ---></cfcatch>
		</cftry>
	</cffunction>
	
	<!--- clear --->
	<cffunction name="clear" access="public" output="false" returntype="void">
		<cfscript>
			var Post=LoadedObjects.new('Post');
			Post.setID('123');
			Post.setTitle('title is not clear');

			assertFalse(Post.isNullID() AND Post.isNullTitle());
			Post.clear();
			assertTrue(Post.isNullID() AND Post.isNullTitle());
		</cfscript>
	</cffunction>
	
	<!--- memento struct --->
	<cffunction name="memento_struct" access="public" output="false" returntype="void">
		<cfscript>
			var Post1=LoadedObjects.new('Post');
			var Post2=LoadedObjects.new('Post');
			var Struct=StructNew();
			var Memento=StructNew();
			
			Post1.setID(5678);
			Post1.setTitle('Post Title 2');
			Post1.setDateCreated(now());
			
			Struct=StructNew();
			Struct.ID=Post1.getID();
			Struct.Title=Post1.getTitle();
			Struct.DateCreated=Post1.getDateCreated();
						
			Memento=Post2.setMemento(Struct).getMemento();

			assertEquals('#Memento.ID# + #Memento.Title# + #Memento.DateCreated#', '#Post1.getID()# + #Post1.getTitle()# + #Post1.getDateCreated()#');
		</cfscript>
	</cffunction>

	<!--- memento query --->
	<cffunction name="memento_query" access="public" output="false" returntype="void">
		<cfscript>
			var Post1=LoadedObjects.new('Post');
			var Post2=LoadedObjects.new('Post');
			var Query=QueryNew('ID,Title,DateCreated');
			var Memento=StructNew();			
			
			Post1.setID(5678);
			Post1.setTitle('Post Title 2');
			Post1.setDateCreated(now());

			QueryAddRow(Query);
			QuerySetCell(Query, 'ID', 9999);
			QuerySetCell(Query, 'Title', 'not used title');
			QuerySetCell(Query, 'DateCreated', 'not used date');			
			QueryAddRow(Query);
			QuerySetCell(Query, 'ID', Post1.getID());
			QuerySetCell(Query, 'Title', Post1.getTitle());
			QuerySetCell(Query, 'DateCreated', Post1.getDateCreated());
			
			// assert not equals
			Memento=Post2.setMemento(Query).getMemento();
			assertNotEquals('#Memento.ID# + #Memento.Title# + #Memento.DateCreated#', '#Post1.getID()# + #Post1.getTitle()# + #Post1.getDateCreated()#');
			
			// assert equals
			Memento=Post2.setMemento(Query, 2).getMemento();
			assertEquals('#Memento.ID# + #Memento.Title# + #Memento.DateCreated#', '#Post1.getID()# + #Post1.getTitle()# + #Post1.getDateCreated()#');
		</cfscript>
	</cffunction>
	
	<!--- memento array of struct --->
	<cffunction name="memento_array_of_structs" access="public" output="false" returntype="void">
		<cfscript>
			var Post1=LoadedObjects.new('Post');
			var Post2=LoadedObjects.new('Post');
			var Array=ArrayNew(1);
			var Memento=StructNew();			
			
			Post1.setID(5678);
			Post1.setTitle('Post Title 2');
			Post1.setDateCreated(now());
			
			Array=ArrayNew(1);
			Array[1]=StructNew();
			Array[1].ID=9999;
			Array[1].Title='not used title';
			Array[1].DateCreated='not used date';
			Array[2]=StructNew();
			Array[2].ID=Post1.getID();
			Array[2].Title=Post1.getTitle();
			Array[2].DateCreated=Post1.getDateCreated();
			
			// assert not equals
			Memento=Post2.setMemento(Array).getMemento();
			assertNotEquals('#Memento.ID# + #Memento.Title# + #Memento.DateCreated#', '#Post1.getID()# + #Post1.getTitle()# + #Post1.getDateCreated()#');
			
			// assert equals
			Memento=Post2.setMemento(Array, 2).getMemento();
			assertEquals('#Memento.ID# + #Memento.Title# + #Memento.DateCreated#', '#Post1.getID()# + #Post1.getTitle()# + #Post1.getDateCreated()#');
		</cfscript>
	</cffunction>
</cfcomponent>