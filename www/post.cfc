<!---
	XX primarykey: contains a comma-delimited list of columns that make up a unique key
	XX foreignkey: contains a comma-delimited list of columns that make up a foreign key

	link, unlike dbname, refers to the object name within LoadedObjects, rather than the table name in the db: Object.Property and not Table.Column
--->
<cfcomponent plugins="all" dbname="Post" displayname="Post" output="false">
	<cfproperty name="ID" dbname="ID" displayname="Post ID" nullvalue="0" />
	<cfproperty name="DateCreated" dbname="Date_Created" displayname="Date Created" minvalue="12/30/2007" type="date" />
	<cfproperty name="Title" dbname="Title" displayname="Title" />
	<cfproperty name="Body" dbname="Body" displayname="Body" />
	<cfproperty name="Views" dbname="Views" displayname="Number of Views" type="struct" />
	<cfproperty name="Shouts" type="array" />
	<cfproperty name="Comment" displayname="Comments" type="comment" />

	<!--- many to one: if 'linkcolumn' is provided, this relationship returns an inline property rather than an object
	<cfproperty name="Category" displayname="Category"
		relationship="ManyToOne" with="Category" localkey="CategoryID" foreignkey="CategoryID" />
	--->
	<!--- one to many: if 'linkcolumn' is provided, this relationship returns an inline list rather than an iterator
	<cfproperty name="Comments" displayname="Comments" type="comment"
		relationship="OneToMany" with="Comment" localkey="ID" foreignkey="PostID" />
	--->
	<!---
		- localkey and foreignkey reference object columnnames, whereas the associativekey references db table.columnnames since no object exists for the associative key
		- multiple key columns can be listed in their respected attributes, but their order is important, for example:
		     + if there are 3 localkeys and 2 foreignkeys, the 1st, 2nd and 3rd localkeys will map to the 1st, 2nd and 3rd associative keys, and the 4th and 5th associativekeys will map to the 1st and 2nd foreignkeys.

	<cfproperty name="Tags" displayname="Tags"
		relationship="ManyToMany" with="Tag" localkey="ID" associativekey="Post_Tag.PostID,Post_Tag.TagID" foreignkey="TagID" />
	--->
<!--- *** OR ***
	<cfproperty name="Tags" displayname="Tags" type="LoadedObjects.core.iterator"
		relationship="Post.PostID = Post_Tag.PostID, Post_Tag.TagID = Tag.TagID" />
--->

	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfreturn this />
	</cffunction>

	<!--- set / get dependencies
	<cffunction name="setDependencies" access="public" output="false" returntype="any">
		<cfargument name="Dependencies" type="struct" required="true" />
		<cfset variables.Dependencies=arguments.Dependencies />
		<cfreturn this />
	</cffunction>
	<cffunction name="getDependencies" access="public" output="false" returntype="struct">
		<cfreturn variables.Dependencies />
	</cffunction>
	--->
</cfcomponent>