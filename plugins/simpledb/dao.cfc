<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Bassil Karam (bassil.karam@thinkloop.com) - 01/01/2008
Edited By: Bassil Karam (bassil.karam@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">

	<!--- init - this will be run after all plugins have been mixed in, then removed from the final business object --->
	<cffunction name="init" access="public" output="false" returntype="any">
<!---		--->		
		<cfscript>					
			variables.SimpleDB=createObject('java', 'com.amazonaws.sdb.AmazonSimpleDBClient').init('02J7D171KK29D91V1582', 'pmNal9Kz4WHL8SLy2r/hoi/hW1Me5PdBS97Zxaaa');
		</cfscript>

<!---
<cfdump var="#createObject('java', 'com.amazonaws.sdb.AmazonSimpleDBClient').init('02J7D171KK29D91V1582', 'pmNal9Kz4WHL8SLy2r/hoi/hW1Me5PdBS97Zxaaa')#">
<cfabort>
--->
		<cfreturn this />
	</cffunction>

	<!--- select --->
	<cffunction name="select" access="public" output="false" returntype="array">
		<cfargument name="SelectExpression" type="string" required="true" hint="A full Amazon SQL statement">
		
		<cfscript>
			var SelectRequest='';
			var SelectResponse='';
			var ReturnArray=ArrayNew(1);
			var currentItemPosition=0;
			var currentItem='';
			var currentAttribute='';
		</cfscript>
		
		<!--- create and set a select request --->
		<cfset SelectRequest=createObject('java', 'com.amazonaws.sdb.model.SelectRequest') />
		<cfset SelectRequest.setSelectExpression(arguments.SelectExpression) />

		<!--- send the request to amazon --->
		<cfset SelectResponse=XMLParse(variables.SimpleDB.select(SelectRequest).toXML()) />
		
		<cftry>
			<!--- pull out the node of items that we are looking for --->
			<cfset ItemArray=SelectResponse.SelectResponse.SelectResult.Item />
	
			<!--- populate return-array --->
			<cfloop from="1" to="#ArrayLen(ItemArray)#" index="currentItemPosition">
				<cfscript>
					currentItem=ItemArray[currentItemPosition];
					ReturnArray[currentItemPosition]=StructNew();
					ReturnArray[currentItemPosition].ID=currentItem.Name.XMLText;
				</cfscript>
	
				<cfloop array="#currentItem.Attribute#" index="currentAttribute">
					<cfset ReturnArray[currentItemPosition][toString(currentAttribute.Name.XMLText)]=currentAttribute.Value.XMLText />
				</cfloop>
			</cfloop>
			
			<cfcatch type="any">
				<cfdump var="#SelectResponse#" label="SelectResponse (from cfcatch)">
			</cfcatch>
		</cftry>
		
		<cfreturn ReturnArray />
	</cffunction>
	
	<!--- save --->
	<cffunction name="save" access="public" output="false" returntype="any">
		<cfreturn this />
	</cffunction>
	
	<!--- delete --->
	<cffunction name="delete" access="public" output="false" returntype="any">
		<cfreturn this />
	</cffunction>
</cfcomponent>