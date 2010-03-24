<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Bassil Karam (bassil.karam@thinkloop.com) - 01/01/2008
Edited By: Bassil Karam (bassil.karam@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">
	<cfproperty name="MetaData" type="struct" hint="A struct that holds the metadata for all business objects. Each key contains an instance of metdata.object for one business object" />
	
	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="BusinessObjects" type="struct" required="true" hint="A struct that holds all business objects. Each key contains an instance of one business object" />
		<cfargument name="LoadedObjects" type="any" required="true" hint="A reference to LoadedObjects itself so that we can load and manage the metadata objects through the framework" />

		<!--- set meta data --->
		<cfscript>
			variables.i=StructNew();
			variables.i.MetaData=parseMetaDataFromBusinessObjects(arguments.BusinessObjects);
			variables.i.LoadedObjects=arguments.LoadedObjects;
		</cfscript>

		<cfreturn this />
	</cffunction>	

	<!--- get --->
	<cffunction name="get" access="public" output="false" returntype="any">
		<cfargument name="BusinessObjectName" type="string" required="true" />

		<cfreturn variables.i.MetaData[arguments.BusinessObjectName] />
	</cffunction>

	<!--- exists --->
	<cffunction name="exists" access="public" output="false" returntype="boolean">
		<cfargument name="BusinessObjectName" type="string" required="true" />
		
		<cfif StructKeyExists(variables.i.MetaData, arguments.BusinessObjectName)>
			<cfreturn True />
		<cfelse>
			<cfreturn False />
		</cfif>
	</cffunction>
	
	<!--- list --->
	<cffunction name="list" access="public" output="false" returntype="string">
		<cfreturn StructKeyList(variables.i.MetaData) />
	</cffunction>
	
	<!--- get all --->
	<cffunction name="getAll" access="public" output="false" returntype="struct">
		<cfreturn variables.i.MetaData />
	</cffunction>
	
<!--- * * * * * * * * --->
<!--- * * PRIVATE * * --->
<!--- * * * * * * * * --->

	<!--- parse metadata from business objects --->
	<cffunction name="parseMetaDataFromBusinessObjects" access="private" output="false" returntype="struct" hint="Returns a struct of metadata where each key represents the metadata of one object">
		<cfargument name="BusinessObjects" type="struct" required="true" />
		
		<cfscript>		
			var BO=StructNew();
			
			var Metadata='';

			var currentBO='';
			var currentProperty='';
			var currentPropertyAttribute='';
			
			var MetaDataReturnStruct=structnew();
			
			BO.Object='';
			BO.Metadata='';
			BO.MetadataProperty='';
		</cfscript>
		
		<!--- loop through each business object, parse it's metadata and append a new metadata object instance to the return struct --->
		<cfloop collection="#arguments.BusinessObjects#" item="currentBO">

			<!--- create new metadata object --->
			<cfset Metadata=createObject('component', 'metadata.object').init(currentBO) />

			<!--- get meta data from current object instance --->
			<cfset BO.Object=arguments.BusinessObjects[currentBO] />
			<cfset BO.Metadata=getMetaData(BO.Object) />
	
			<!--- set path --->
			<cfset Metadata.setPath(BO.Metadata.Name) />
			
			<!--- set object display name --->
			<cfif StructKeyExists(BO.Metadata, 'DisplayName')>
				<cfset Metadata.setDisplayName(BO.Metadata.DisplayName) />
			<cfelse>
				<cfset Metadata.setDisplayName(currentBO) />
			</cfif>
			
			<!--- set dependencies --->		
			<cfif StructKeyExists(BO.Object, 'setDependencies')>
				<cfset Metadata.setDependencies(BO.Object.getDependencies()) />
			<cfelse>
				<cfset Metadata.setDependencies(StructNew()) />
			</cfif>
			
			<!--- loop through properties and set metdata --->
			<cfif StructKeyExists(BO.Metadata, 'Properties') AND isArray(BO.Metadata.Properties)>
				<cfloop from="1" to="#ArrayLen(BO.Metadata.Properties)#" index="currentProperty">
					
					<!--- set shortcuts --->
					<cfset BO.MetadataProperty=BO.Metadata.Properties[currentProperty] />

					<!--- add new property --->
					<cfset Metadata.getProperties().add(BO.MetadataProperty.Name) />
			
					<!--- loop through property attributes of property and add them to metadata object --->
					<cfloop collection="#BO.MetadataProperty#" item="currentPropertyAttribute">
						<cfset Metadata.getProperties().set(currentPropertyAttribute, BO.MetadataProperty[currentPropertyAttribute]) />
					</cfloop>
					
					<!--- check for relationship to another object --->
					<cfif ListFindNoCase(StructKeyList(arguments.BusinessObjects), Metadata.getProperties().get('Type'))>
						<cfset Metadata.getProperties().set('LoadedObjectsType', Metadata.getProperties().get('Type')) />
					</cfif>
				</cfloop>
			</cfif>
			
			<!--- append metadata object to return struct --->
			<cfset MetaDataReturnStruct[currentBO]=Metadata />
		</cfloop>		
		
		<cfreturn MetaDataReturnStruct />
	</cffunction>
</cfcomponent>