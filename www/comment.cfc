<cfcomponent dbname="Comment" displayname="Comment" output="false">
	<cfproperty name="CommentID" dbname="Comment.CommentID" displayname="Comment ID" />
	<cfproperty name="PostID" dbname="Comment.PostID" />
	<cfproperty name="DateCreated" dbname="Comment.DateCreated" displayname="Date Created" minvalue="12/30/2007" />
	<cfproperty name="Comment" dbname="Comment.Comment" displayname="Comment" />
	<cfproperty name="Name" dbname="Comment.Name" displayname="Name" />
	<cfproperty name="Email" dbname="Comment.Email" displayname="Email" />
	<cfproperty name="Subscribe" dbname="Comment.Subscribe" displayname="Subscribe" />

	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="any">

		<cfreturn this />
	</cffunction>
</cfcomponent>