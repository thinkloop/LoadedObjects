<!--- setup framework, normally will be done through coldspring --->
<cfscript>
	LoadedObjects=createObject('component', 'loadedobjects.loadedobjects').init('loadedObjects.www');

	Post=LoadedObjects.new('post');
	Post2=LoadedObjects.new('post');
</cfscript>

<!--- test setting/getting nested properties --->
<cfscript>
	dump('Set child property Comment.ID to 15, through parent object.');

	Post.setCommentID(15);
	dump(Post.getComment().getID());
abort;

</cfscript>

<!--- set rawdata
<cfscript>
	ArrayData = [
		{ ID : 1, DateCreated : '01/01/2000', Title : 'Title ##1', Body : 'What a body1!' },
		{ ID : 2, DateCreated : '01/01/2010', Title : 'Title ##2', Body : 'What a body2!' },
		{ ID : 30, DateCreated : '01/01/2012', Title : 'Title ##39', Body : 'What a body39!' }
	];

	QueryData = QueryNew('ID,DateCreated,Title,Body');
	QueryAddRow(QueryData, 3);
	QuerySetCell(QueryData, 'ID', 1, 1);
	QuerySetCell(QueryData, 'ID', 2, 2);
	QuerySetCell(QueryData, 'ID', 30, 3);

	/*
	Post.getSourceData().addRow();
	*/
	Post.setAll(ArrayData);
dump(Post.getRawData());
	Post.setAll(QueryData);
dump(Post.getRawData());
abort;
</cfscript>
--->

<cfoutput>
	<div id="Post">
		#Post.getTitle()#
		<br />
		#DateFormat(Post.getDateCreated(), 'full')#
		<p>
			#Post.getBody()#
		</p>
	</div>
	<hr />
	<div id="Comments">
		<cfloop condition="#Post.loop()#">
			<cfset newQuery = QueryNew('CommentID,Comment') />
			<cfset Post.getComments().setRawData(newQuery) />
			<p>
				#Post.getComments().getComment()# <strong>by #Post.getComments().getName()#</strong>
			</p>
		</cfloop>
	</div>
</cfoutput>