<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Bassil Karam (bassil.karam@thinkloop.com) - 01/01/2008
Edited By: Bassil Karam (bassil.karam@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false" hint="Manages all plugins.">
	<cfproperty name="Plugins" type="array" hint="Each item contains an instance of a plugin" />
	<cfproperty name="NameIndex" type="struct" hint="A struct representation of the plugins array for easy lookup" />
	<cfproperty name="PositionIndex" type="struct" hint="An array index of plugin names" />
		
	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="any" hint="Requires atleast one plugin object as an argument.">
		<cfargument name="Plugins" type="array" required="true" hint="Each item contains an instance of a plugin" />
		
		<cfscript>
			var current=StructNew();
			current.Plugin='';
			current.Position=0;
			current.Metadata='';
			current.Name='';
			current.NameTrimmed='';
			
			variables.i=structNew();
			variables.i.Plugins=arguments.Plugins;
			variables.i.NameIndex=StructNew();
			variables.i.PositionIndex=ArrayNew(1);
		</cfscript>

		<!--- create indexes for easy lookup --->
		<cfloop from="1" to="#ArrayLen(arguments.Plugins)#" index="current.Position">
			<cfscript>
				current.Plugin=arguments.Plugins[current.Position];
				current.Metadata=getMetaData(current.Plugin);
				current.Name=current.Metadata.Name;
				current.NameReversed=Reverse(current.Name);
				current.FirstPeriod=Find('.', current.NameReversed);
				current.SecondPeriod=Find('.', current.NameReversed, Find('.', current.NameReversed) + 1);
				current.NameTrimmed=Reverse(Mid(current.NameReversed, current.FirstPeriod + 1, current.SecondPeriod - current.FirstPeriod - 1));
				variables.i.NameIndex[current.NameTrimmed]=current.Position;
				variables.i.PositionIndex[current.Position]=current.NameTrimmed;
			</cfscript>
		</cfloop>

		<!--- send plugins to on missing method for special processing --->
		<cfset get('onMissingMethod').parseOnMissingMethodFunctions(variables.i.Plugins) />
		
		<cfreturn this />
	</cffunction>

	<!--- get --->
	<cffunction name="get" access="public" output="false" returntype="any" hint="Get an instance of a specific plugin by name or position.">
		<cfargument name="Index" type="any" required="true" hint="The specific plugin name or position to be returned. If a number is provided, position will be used, if a string is provided, name will be used." />
		
		<cfif exists(arguments.Index)>
			<cfif not isValid('integer', arguments.Index)>
				<cfset arguments.Index=variables.i.NameIndex[arguments.Index] />
			</cfif>
			
			<cfreturn variables.i.Plugins[arguments.Index] />
		<cfelse>
			<cfthrow type="LoadedObjects" message="The plugin at index *#arguments.Index#* does not exist." />
		</cfif>
	</cffunction>

	<!--- exists --->
	<cffunction name="exists" access="public" output="false" returntype="boolean" hint="Determine whether a specific plugin exists by name or position.">
		<cfargument name="Index" type="string" required="true" hint="The specific plugin name or position to be returned. If a number is provided, position will be used, if a string is provided, name will be used." />

		<cfif isValid('integer', arguments.Index)>
			<cfreturn arguments.Index gte 1 AND arguments.Index lte ArrayLen(variables.i.Plugins) />
		<cfelse>
			<cfreturn StructKeyExists(variables.i.NameIndex, arguments.Index) />		
		</cfif>
		
	</cffunction>
	
	<!--- get all --->
	<cffunction name="getAll" access="public" output="false" returntype="array" hint="Return an array of all plugins.">
		<cfreturn variables.i.Plugins />
	</cffunction>
	
	<!--- get name index --->
	<cffunction name="getNameIndex" access="public" output="false" returntype="struct">
		<cfreturn variables.i.NameIndex />
	</cffunction>
	
	<!--- get position index --->
	<cffunction name="getPositionIndex" access="public" output="false" returntype="struct">
		<cfreturn variables.i.PositionIndex />
	</cffunction>
	
<!--- * * * * * * * --->
<!--- * * MIXIN * * --->
<!--- * * * * * * * --->

	<!--- mixin plugin --->
	<cffunction name="mixinPlugin" access="public" returntype="void">
		<cfargument name="LoadedObjects" type="any" required="true" />
		<cfargument name="PluginsObject" type="any" required="true" hint="A reference to this object" />
		<cfargument name="BusinessObjectName" type="string" required="true" />
		
		<cfscript>
			var Plugins=arguments.PluginsObject.getAll();
			var inits=ArrayNew(1);
			var current=StructNew();
		</cfscript>

		<!--- loop through each mixin --->
		<cfloop array="#Plugins#" index="current.Plugin">
		
			<!--- current mixin --->
			<cfset current.Mixin=current.Plugin.getMixin() />

			<!--- loop through functions --->
			<cfloop array="#getMetaData(current.Mixin).functions#" index="current.FunctionMetaData">
				
				<!--- if function is init(), save it to run later, but don't mix it in --->
				<cfif current.FunctionMetaData.Name is 'init'>
					<cfset ArrayAppend(inits, current.Mixin[current.FunctionMetaData.Name]) />
					
				<!--- otherwise mix it in (will not overwrite user defined functions with same names) --->
				<cfelseif not StructKeyExists(this, current.FunctionMetaData.Name) AND not StructKeyExists(variables, current.FunctionMetaData.Name)>
					<cfscript>
						StructInsert(this, current.FunctionMetaData.Name, current.Mixin[current.FunctionMetaData.Name], false);
						StructInsert(variables, current.FunctionMetaData.Name, current.Mixin[current.FunctionMetaData.Name], false);
					</cfscript>
				</cfif>
			</cfloop>
		</cfloop>

		<!--- run all inits --->
		<cfloop array="#inits#" index="current.Init">
			<cfscript>
				StructInsert(variables, 'init_LoadedObjects1133557799AAQAASXMMHGFDADSF', current.Init);
				init_LoadedObjects1133557799AAQAASXMMHGFDADSF(arguments.LoadedObjects, arguments.BusinessObjectName);
				StructDelete(variables, 'init_LoadedObjects1133557799AAQAASXMMHGFDADSF');
			</cfscript>
		</cfloop>
	</cffunction>
</cfcomponent>