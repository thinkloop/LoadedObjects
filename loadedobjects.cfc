<!--- * * (coldfusion comments are completely stripped out at compile time, and have zero impact on performance)
Created By: Bassil Karam (bassil.karam@thinkloop.com) - 01/01/2008
Edited By: Bassil Karam (bassil.karam@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">
	<cfproperty name="Paths" type="Struct" hint="A struct that contains an 'absolute' path and a 'dot' path of the folder where LoadedObjects is located" />
	<cfproperty name="Plugins" type="any" hint="The object that stores and manages all plugins" />
	<cfproperty name="MetaData" type="any" hint="The object that stores and manages all metadata" />

	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="Config" type="struct" default="#StructNew()#" hint="A structure that defines config settings for LoadedObjects: ServerName" />
		<cfargument name="Plugins" type="array" default="#ArrayNew(1)#" hint="Contains the plugins to use and mixin for the lifetime of this instance" />
		<cfargument name="BusinessObjects" type="struct" required="true" hint="Contains the business objects that will be managed by LoadedObjects" />

		<cfscript>
			var Loader='';
			var RawDatasource='';
			var MetaData='';

			variables.i=StructNew();

			// load paths
			variables.i.Paths=StructNew();
			variables.i.Paths.Absolute=Left(getMetaData(this).Path, findnocase('LoadedObjects.cfc', getMetaData(this).Path) - 1);
			variables.i.Paths.Dot=ReplaceNoCase(getMetaData(this).Name, '.LoadedObjects', '');

			// load business object metadata, including emptybusinessobject
			arguments.BusinessObjects.EmptyBusinessObject=createObject('component', 'core.emptybusinessobject').init();
			variables.i.MetaData=createObject('Component', 'core.metadata').init(arguments.BusinessObjects, this);

			// load plugins
			//ArrayPrepend(arguments.Plugins, createObject('Component', 'functionality.constraints.service').init());
			//ArrayPrepend(arguments.Plugins, createObject('Component', 'functionality.recordsets.service').init());
			ArrayPrepend(arguments.Plugins, createObject('Component', 'functionality.sourcedata.service').init());
			//ArrayPrepend(arguments.Plugins, createObject('Component', 'functionality.instance.service').init());
			ArrayPrepend(arguments.Plugins, createObject('Component', 'functionality.metadata.service').init());
			ArrayPrepend(arguments.Plugins, createObject('Component', 'functionality.base.service').init());
			ArrayPrepend(arguments.Plugins, createObject('Component', 'functionality.onmissingmethod.service').init());
			variables.i.Plugins=createObject('Component', 'core.plugins').init(arguments.Plugins);
		</cfscript>

		<cfreturn this />
	</cffunction>

<!--- * * * * * * *--->
<!--- * * MAIN * * --->
<!--- * * * * * * *--->

	<!--- new --->
	<cffunction name="new" access="public" output="false" returntype="any">
		<cfargument name="BusinessObjectName" type="string" required="true" />
		<cfreturn recurseChildObjects(arguments.BusinessObjectName) />
	</cffunction>

	<!--- recurse child objects (private) --->
	<cffunction name="recurseChildObjects" access="private" output="false" returntype="any">
		<cfargument name="BusinessObjectName" type="string" required="true" />
		<cfargument name="CreatedObjects" default="#StructNew()#" required="false" />
		<!--- CreatedObjects is an optional argument used internally to ensure that we do not enter an infinite
		loop while recursing through the object's properties to create its child objects. When present, it
		is used to know whether an object has been created or not. If it has been created, the property
		should point to that object rather than creating a new one - Autowiring.
		--->

		<cfscript>
			var BO=create(arguments.BusinessObjectName);
			var Properties=BO.getMetaDataObject().getProperties();
			var Type=Properties.get('Type');
			var CO=arguments.CreatedObjects;
			CO[BO.getMetaDataObject().getName()]=BO;
		</cfscript>

		<cfloop condition="Properties.loop()">
			<cfset Type=Properties.get('Type') />
			<cfif ListFindNoCase(listBusinessObjects(), Type)>
				<cfif StructKeyExists(CO, Type)>
					<cfset BO.set(Properties.get('Name'), CO[Type]) />
				<cfelse>
					<cfset BO.set(Properties.get('Name'), recurseChildObjects(Type, CO)) />
				</cfif>
			</cfif>
		</cfloop>

		<!--- return new object --->
		<cfreturn BO />
	</cffunction>

	<!--- create (private) --->
	<cffunction name="create" access="private" output="false" returntype="any">
		<cfargument name="BusinessObjectName" type="string" required="true" />

		<!--- init object instance --->
		<cfset var BO="" />

		<!--- init object instance meta data --->
		<cfset var MetaData="" />

		<!--- init current plugin --->
		<cfset var currentPlugin="" />

		<!--- empty business object --->
		<cfif not len(arguments.BusinessObjectName)>
			<cfset arguments.BusinessObjectName="EmptyBusinessObject" />
		</cfif>

		<!--- throw error if object not defined --->
		<cfif not existsMetaDataObject(arguments.BusinessObjectName)>
			<cfthrow type="LoadedObjects" errorcode="LoadedObjects.Load.UndefinedObject" message="Object #ucase(arguments.BusinessObjectName)# does not exist." detail="Ensure that the object is defined, and that it is spelled correctly." />
		</cfif>

		<!--- get metadata of specific object --->
		<cfset MetaData=getMetaDataObject(arguments.BusinessObjectName) />

		<!--- create object instance --->
		<cfset BO=createobject('component', MetaData.getPath()) />

		<!--- mixin plugins --->
		<cfscript>
			StructInsert(BO, 'mixinPlugin_LoadedObjects1133557799', variables.i.Plugins.mixinPlugin, true);
			BO.mixinPlugin_LoadedObjects1133557799(this, variables.i.Plugins, arguments.BusinessObjectName);
			StructDelete(BO, 'mixinPlugin_LoadedObjects1133557799');
		</cfscript>

		<!--- return new object --->
		<cfreturn BO />
	</cffunction>

<!--- * * * * * * * * --->
<!--- * * HELPERS * * --->
<!--- * * * * * * * * --->

	<!--- get plugin --->
	<cffunction name="getPlugin" access="public" output="false" returntype="any">
		<cfargument name="PluginName" type="string" required="true" />
		<cfreturn variables.i.Plugins.get(arguments.PluginName) />
	</cffunction>

	<!--- exists plugin --->
	<cffunction name="existsPlugin" access="public" output="false" returntype="boolean">
		<cfargument name="PluginName" type="string" required="true" />
		<cfreturn variables.i.Plugins.exists(arguments.PluginName) />
	</cffunction>

	<!--- get all plugins --->
	<cffunction name="getAllPlugins" access="public" output="false" returntype="any">
		<cfreturn variables.i.Plugins.getAll() />
	</cffunction>

	<!--- get meta data object --->
	<cffunction name="getMetaDataObject" access="public" output="false" returntype="any">
		<cfargument name="BusinessObjectName" type="string" required="true" />
		<cfreturn variables.i.Metadata.get(arguments.BusinessObjectName) />
	</cffunction>

	<!--- exists meta data object --->
	<cffunction name="existsMetaDataObject" access="public" output="false" returntype="boolean">
		<cfargument name="BusinessObjectName" type="string" required="true" />
		<cfreturn variables.i.Metadata.exists(arguments.BusinessObjectName) />
	</cffunction>

	<!--- list metadata/business objects --->
	<cffunction name="listMetaDataObjects" access="public" output="false" returntype="string">
		<cfreturn variables.i.Metadata.list() />
	</cffunction>
	<cffunction name="listBusinessObjects" access="public" output="false" returntype="string">
		<cfreturn variables.i.Metadata.list() />
	</cffunction>

	<!--- dump metadata --->
	<cffunction name="dumpMetaData" access="public" output="false" returntype="struct">

		<cfset var loop=StructNew() />
		<cfset var ReturnStruct=StructNew() />

		<cfloop list="#listMetaDataObjects()#" index="loop.MetaDataObject">
			<cfset ReturnStruct[loop.MetaDataObject]=getMetaDataObject(loop.MetaDataObject).getProperties().getAll() />
		</cfloop>

		<cfreturn ReturnStruct />
	</cffunction>

	<!--- dump --->
	<cffunction name="dump" access="public" output="true" returntype="any">
		<cfargument name="Variable" type="any" default="" />
		<cfargument name="Abort" type="boolean" default="true" />

		<cfif isSimpleValue(arguments.Variable) AND len(arguments.Variable)>
			<cfset arguments.Variable=variables />
		</cfif>

		<cfdump var="#arguments.Variable#" expand="false" />

		<cfif arguments.Abort>
			<cfabort />
		</cfif>
	</cffunction>
</cfcomponent>