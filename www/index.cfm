<!--- setup framework, normally will be done through coldspring --->
<cfscript>

	Plugins=ArrayNew(1);
	ArrayAppend(Plugins, createObject('component', 'LoadedObjects.plugins.validator.validator').init());

	BusinessObjects=StructNew();
	BusinessObjects.Post=createObject('component', 'post');
	BusinessObjects.Comment=createObject('component', 'comment');

	LoadedObjects=createObject('component', 'LoadedObjects.LoadedObjects').init(Plugins=Plugins, BusinessObjects=BusinessObjects);

	Post=LoadedObjects.new('Post');

/*
	Post=LoadedObjects.new('Post');
	Post.getLooper().setKeywords('hip hop');
	Post.getLooper().setStartRow(100);
	Post.getLooper().setMaxRows(100);
	Post.search();
*/
</cfscript>
<!---
<cfdump var="#Post.getMemento()#">
<cfdump var="+++++++++++++">
<cfoutput>#Post.dump(Abort=False)#</cfoutput>
<cfdump var="-------------">
<cfdump var="#LoadedObjects.dumpMetaData()#" expand="false">
--->
<!--- looper functionality --->
<cfscript>
	Post.setID(1);
	Post.setDateCreated(now());
	Post.setTitle('Title ##1');
	Post.setBody('Body ##1');

	tmpQuery=QueryNew('Comment,Name');
	QueryAddRow(tmpQuery);
	QuerySetCell(tmpQuery, 'Comment', 'Comment ##1');
	QuerySetCell(tmpQuery, 'Name', 'Name ##1');
	QuerySetCell(tmpQuery, 'Comment', 'Comment ##2');
	QuerySetCell(tmpQuery, 'Name', 'Name ##2');
	QuerySetCell(tmpQuery, 'Comment', 'Comment ##3');
	QuerySetCell(tmpQuery, 'Name', 'Name ##3');

	Post.setComments(LoadedObjects.new('Comment').setSourceData([{Comment='Comment ##1', Name='Name ##1'}, {Comment='Comment ##2', Name='Name ##2'}, {Comment='Comment ##3', Name='Name ##3'}]));
	//Post.getComments().loop()
</cfscript>
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
		<cfloop condition="#Post.getComments().loop()#">
			<p>
				#Post.getComments().getComment()# <strong>by #Post.getComments().getName()#</strong>
			</p>
		</cfloop>
	</div>
</cfoutput>

<cffunction name="dump" output="true">
	<cfargument name="Variable" type="any" required="true" />
	<cfargument name="Label" type="string" default="" />
	<cfargument name="Abort" type="boolean" default="true" />

	<cfdump var="#arguments.Variable#" label="#arguments.Label#" expand="false" /><hr />
	<cfif arguments.Abort>
		<cfabort />
	</cfif>
</cffunction>