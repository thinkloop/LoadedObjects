<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created On: 01/01/2008
Developed By: Baz K. (bk@thinkloop.com)
* * --->
<cfcomponent output="false">

	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="Datasource" type="struct" />

		<!--- load db specific sql --->
		<cftry>
			<cfset variables.SQL=createobject('component', 'sql.#arguments.Datasource.DBType#').init(arguments.Datasource) />
			
			<cfcatch type="any">
				<cfthrow type="LoadedObjects" errorcode="LoadedObjects.DAO.Load.InvalidDatabaseType" message="Could not load the database metadata because the database #ucase(arguments.Datasource.DBType)# is not currently supported by LoadedObjects." />
			</cfcatch>
		</cftry>

		<cfreturn this />
	</cffunction>

	<!--- save --->
	<cffunction name="save" access="public" output="false" returntype="any">
		<cfargument name="BO" type="any" />

		<!--- business object --->
		<cfset var BO=arguments.BO />

		<!--- if exists, update --->
		<cfif exists(BO, '')>
			<cfreturn update(BO) />

		<!--- if not exists, create --->
		<cfelse>
			<cfreturn create(BO) />
		</cfif>
	</cffunction>

	<!--- create --->
	<cffunction name="create" access="public" output="false" returntype="any">
		<cfargument name="BO" type="any" />

		<!--- business object --->
		<cfset var BO=arguments.BO />

		<!--- get table name --->
		<cfset var TableName=BO.getMetaDataObject().getDBName() />

		<!--- build sql input query --->
		<cfset var SQLInput=buildSQLInput(BO) />

		<!--- set create properties --->
		<cfset var CreateProperties=getNonAutoGeneratedPropertyList(BO) />

		<!--- determine if primary key is autogenrated --->
		<cfset var IsAutoGeneratedPrimaryKey=isAutoGeneratedPrimaryKey(BO) />

		<!--- create --->
		<cfset var Result=getSQL().create(SQLInput, TableName, CreateProperties, IsAutoGeneratedPrimaryKey) />

		<!--- set autogenerated primary key --->
		<cfif IsAutoGeneratedPrimaryKey>
			<cfset BO.set(getAutoGeneratedPrimaryKey(BO), Result) />
		</cfif>

		<cfreturn BO />
	</cffunction>

	<!--- read --->
	<cffunction name="read" access="public" output="false" returntype="any">
		<cfargument name="BO" type="any" />

		<!--- business object --->
		<cfset var BO=arguments.BO />

		<!--- get table name --->
		<cfset var TableName=BO.getMetaDataObject().getDBName() />

		<!--- build sql input query --->
		<cfset var SQLInput=buildSQLInput(BO) />

		<!--- set read properties --->
		<cfset var ReadProperties=getDBPropertyList(BO) />

		<!--- set filter properties --->
		<cfset var FilterProperties=getPrimaryKeyList(BO) />

		<!--- init result --->
		<cfset var Result="" />

		<!--- init loop index --->
		<cfset var currentProperty="" />

		<!--- read --->
		<cfset Result=getSQL().read(SQLInput, TableName, ReadProperties, FilterProperties) />

		<!--- populate business object --->
		<cfif Result.Recordcount gt 0>
			<cfloop list="#ReadProperties#" index="currentProperty">
				<cfset BO.set(currentProperty, Result[BO.getMetaDataObject().getProperty(currentProperty, 'DBName')][1]) />
			</cfloop>
		<cfelse>
			<cfloop list="#ReadProperties#" index="currentProperty">
				<cfset BO.set(currentProperty, '') />
			</cfloop>
		</cfif>

		<cfreturn BO />
	</cffunction>

	<!--- update --->
	<cffunction name="update" access="public" output="false" returntype="any">
		<cfargument name="BO" type="any" />

		<!--- business object --->
		<cfset var BO=arguments.BO />

		<!--- get table name --->
		<cfset var TableName=BO.getMetaDataObject().getDBName() />

		<!--- build sql input query --->
		<cfset var SQLInput=buildSQLInput(BO) />

		<!--- set update properties --->
		<cfset var UpdateProperties=getDBPropertyList(BO) />

		<!--- set filter properties --->
		<cfset var FilterProperties=getPrimaryKeyList(BO) />

		<!--- update --->
		<cfset var Result=getSQL().update(SQLInput, TableName, UpdateProperties, FilterProperties) />

		<cfreturn BO />
	</cffunction>

	<!--- delete --->
	<cffunction name="delete" access="public" output="false" returntype="any">
		<cfargument name="BO" type="any" />

		<!--- business object --->
		<cfset var BO=arguments.BO />

		<!--- get table name --->
		<cfset var TableName=BO.getMetaDataObject().getDBName() />

		<!--- build sql input query --->
		<cfset var SQLInput=buildSQLInput(BO) />

		<!--- set filter properties --->
		<cfset var FilterProperties=getPrimaryKeyList(BO) />

		<!--- delete --->
		<cfset var Result=getSQL().delete(SQLInput, TableName, FilterProperties) />

		<!--- return business object --->
		<cfreturn BO />
	</cffunction>

	<!--- exists --->
	<cffunction name="exists" access="public" output="false" returntype="boolean">
		<cfargument name="BO" type="any" />
		<cfargument name="PropertyList" type="string" default="" hint="List of properties to use to check existence of a record. If none are specified, primary key(s) are used instead." />

		<!--- business object --->
		<cfset var BO=arguments.BO />

		<!--- get table name --->
		<cfset var TableName=BO.getMetaDataObject().getDBName() />

		<!--- build sql input query --->
		<cfset var SQLInput=buildSQLInput(BO) />

		<!--- init filter proeprties --->
		<cfset var FilterProperties="" />

		<!--- set filter properties --->
		<cfif len(arguments.PropertyList)>
			<cfset FilterProperties=arguments.PropertyList />
		<cfelse>
			<cfset FilterProperties=getPrimaryKeyList(BO) />
		</cfif>

		<!--- exists --->
		<cfreturn getSQL().exists(SQLInput, TableName, FilterProperties) />
	</cffunction>

<!--- * * * * * * * * --->
<!--- * * METADATA* * --->
<!--- * * * * * * * * --->

	<!--- get db properties meta data --->
	<cffunction name="getDBPropertiesMetaData" access="public" output="false" returntype="query">
		<cfargument name="BO" type="any" />

		<!--- init final properties meta data --->
		<cfset var FinalPropertiesMetaData=arguments.BO.getMetaDataObject().getPropertiesMetaData() />

		<cfquery name="FinalPropertiesMetaData" dbtype="query">
		SELECT *
		FROM FinalPropertiesMetaData
		WHERE NOT DBName IS NULL
		</cfquery>

		<cfreturn FinalPropertiesMetaData />
	</cffunction>

	<!--- get db property list --->
	<cffunction name="getDBPropertyList" access="public" output="false" returntype="string">
		<cfargument name="BO" type="any" />

		<!--- init final properties meta data --->
		<cfset var PropertiesMetaData=getDBPropertiesMetaData(arguments.BO) />

		<cfreturn ValueList(PropertiesMetaData.Name) />
	</cffunction>

	<!--- get primary key list --->
	<cffunction name="getPrimaryKeyList" access="public" output="false" returntype="string">
		<cfargument name="BO" type="any" />

		<!--- init properties meta data --->
		<cfset var PropertiesMetaData=getDBPropertiesMetaData(arguments.BO) />

		<!--- init primary key list --->
		<cfset var PrimaryKeyList="" />

		<!--- loop through meta data and build primary key list --->
		<cfloop query="PropertiesMetaData">
			<cfif PropertiesMetaData.PrimaryKey is 'True'>
				<cfset PrimaryKeyList=ListAppend(PrimaryKeyList, PropertiesMetaData.Name[PropertiesMetaData.CurrentRow]) />
			</cfif>
		</cfloop>

		<cfif len(PrimaryKeyList)>
			<cfreturn PrimaryKeyList />
		<cfelse>
			<cfthrow type="LoadedObjects" errorcode="LoadedObjects.DAO.UndefinedPrimaryKey" message="None of the following db related properties for object #UCase(arguments.BO.getMetaDataObject().getDBName())# are defined as a primary key: #ValueList(PropertiesMetaData.Name)#." detail="Please ensure that at least one db property is defined as a primary key." />
		</cfif>
	</cffunction>

	<!--- is auto generated primary key --->
	<cffunction name="isAutoGeneratedPrimaryKey" access="public" output="false" returntype="boolean">
		<cfargument name="BO" type="any" />

		<cfif len(getAutoGeneratedPrimaryKey(arguments.BO))>
			<cfreturn True />
		<cfelse>
			<cfreturn False />
		</cfif>
	</cffunction>

	<!--- get auto generated primary key --->
	<cffunction name="getAutoGeneratedPrimaryKey" access="public" output="false" returntype="string">
		<cfargument name="BO" type="any" />

		<!--- init properties meta data --->
		<cfset var PropertiesMetaData=getDBPropertiesMetaData(arguments.BO) />

		<!--- init primary key list --->
		<cfset var PrimaryKeyList="" />

		<!--- loop through meta data and build primary key list --->
		<cfloop query="PropertiesMetaData">
			<cfif PropertiesMetaData.PrimaryKey is 'True' AND PropertiesMetaData.AutoGenerated is 'True'>
				<cfset PrimaryKeyList=ListAppend(PrimaryKeyList, PropertiesMetaData.Name[PropertiesMetaData.CurrentRow]) />
				<cfbreak />
			</cfif>
		</cfloop>

		<cfreturn PrimaryKeyList />
	</cffunction>

	<!--- get non auto generated property list --->
	<cffunction name="getNonAutoGeneratedPropertyList" access="public" output="false" returntype="string">
		<cfargument name="BO" type="any" />

		<!--- init properties meta data --->
		<cfset var PropertiesMetaData=getDBPropertiesMetaData(arguments.BO) />

		<!--- init property list --->
		<cfset var PropertyList=ValueList(PropertiesMetaData.Name) />

		<!--- determine position of autogenerated primary key --->
		<cfset var PositionOfAutoGeneratedPrimaryKey=ListFindNoCase(PropertyList, getAutoGeneratedPrimaryKey(arguments.BO)) />

		<!--- remove autogenerated primary key --->
		<cfif PositionOfAutoGeneratedPrimaryKey>
			<cfset PropertyList=ListDeleteAt(PropertyList, PositionOfAutoGeneratedPrimaryKey) />
		</cfif>

		<cfreturn PropertyList />
	</cffunction>

<!--- * * * * * * * * --->
<!--- * * PRIVATE * * --->
<!--- * * * * * * * * --->

	<!--- build sql input query --->
	<cffunction name="buildSQLInput" access="private" output="false" returntype="struct">
		<cfargument name="BO" type="any" />

		<!--- init bo --->
		<cfset var BO=arguments.BO />

		<!--- init loop index --->
		<cfset var currentProperty="" />

		<!--- init return query --->
		<cfset var SQLInput=StructNew() />

		<!--- loop through proeprty list and make sql input query --->
		<cfloop list="#getDBPropertyList(BO)#" index="currentProperty">
			<cfscript>
				SQLInput[currentProperty]=StructNew();
				SQLInput[currentProperty].DBName=BO.getMetaDataObject().getProperty(currentProperty, 'DBName');
				SQLInput[currentProperty].CFSQLType=BO.getMetaDataObject().getProperty(currentProperty, 'CFSQLType');
				SQLInput[currentProperty].IsNull=BO.isNull(currentProperty);
				SQLInput[currentProperty].Value=BO.get(currentProperty);
			</cfscript>
		</cfloop>

		<cfreturn SQLInput />
	</cffunction>

	<!--- get sql --->
	<cffunction name="getSQL" access="private" output="false" returntype="any">
		<cfreturn variables.SQL />
	</cffunction>
</cfcomponent>