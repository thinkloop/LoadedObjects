<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Bassil Karam (bassil.karam@thinkloop.com) - 01/01/2008
Edited By: Bassil Karam (bassil.karam@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">

	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="Datasource" />

		<cfscript>
			variables.Datasource=arguments.Datasource;
		</cfscript>

		<cfreturn this />
	</cffunction>

	<!--- create --->
	<cffunction name="create" access="public" output="false" returntype="boolean">
		<cfargument name="SQLInput" type="struct" hint="Struct of structs of some meta data and current values for easy data retrieval" />
		<cfargument name="TableName" hint="Name of table in string format." />
		<cfargument name="CreateProperties" type="string" hint="Comma-separated list of properties to update" />
		<cfargument name="IsAutoGeneratedPrimaryKey" type="boolean" default="false" />

		<cfset var currentProperty="" />
		<cfset var Query="" />

		<cfquery name="Query" Datasource="#getDatasource().DSN#" Username="#getDatasource().Username#" Password="#getDatasource().Password#">
		INSERT INTO [#arguments.TableName#]
			(
			[#arguments.SQLInput[ListFirst(arguments.CreateProperties)].DBName#]
			<cfif ListLen(ListRest(arguments.CreateProperties))>
				<cfloop list="#ListRest(arguments.CreateProperties)#" index="currentProperty">
					, [#arguments.SQLInput[currentProperty].DBName#]
				</cfloop>
			</cfif>
			)
		VALUES
			(
			<cfqueryparam value="#arguments.SQLInput[ListFirst(arguments.CreateProperties)].Value#" cfsqltype="#arguments.SQLInput[ListFirst(arguments.CreateProperties)].CFSQLType#" null="#arguments.SQLInput[ListFirst(arguments.CreateProperties)].IsNull#" />
			<cfif ListLen(ListRest(arguments.CreateProperties))>
				<cfloop list="#ListRest(arguments.CreateProperties)#" index="currentProperty">
					, <cfqueryparam value="#arguments.SQLInput[currentProperty].Value#" cfsqltype="#arguments.SQLInput[currentProperty].CFSQLType#" null="#arguments.SQLInput[currentProperty].IsNull#" />
				</cfloop>
			</cfif>
			)

		<cfif arguments.IsAutoGeneratedPrimaryKey>
			SELECT SCOPE_IDENTITY() AS [LoadedObjectsTempAutoGeneratedID]
		</cfif>
		</cfquery>

		<!--- get autogenerated primary key --->
		<cfif arguments.IsAutoGeneratedPrimaryKey>
			<cfreturn Query.LoadedObjectsTempAutoGeneratedID />
		<cfelse>
			<cfreturn True />
		</cfif>
	</cffunction>

	<!--- read ---->
	<cffunction name="read" access="public" output="false" returntype="query">
		<cfargument name="BO" type="any" required="true" />
		<cfargument name="SelectProperties" type="string" required="true" hint="List of properties to select" />
		<cfargument name="FromObjects" type="string" required="true" hint="List of objects to query" />
		<cfargument name="WhereProperties" type="string" required="true" hint="List of properties to filter by" />
		
		<cfset var BO=arguments.BO />
		<cfset var currentProperty="" />
		<cfset var Query="" />

		<cfquery name="Query" Datasource="#getDatasource().DSN#" Username="#getDatasource().Username#" Password="#getDatasource().Password#">
		SELECT TOP 1
			[#ListFirst(arguments.SelectProperties)#] = [#BO.getMetaDataObject().getProperty(ListFirst(arguments.SelectProperties), 'DBName')#]
			<cfloop list="#ListRest(arguments.SelectProperties)#" index="currentProperty">
				, [#currentProperty#] = [#BO.getMetaDataObject().getProperty(currentProperty, 'DBName')#]
			</cfloop>

		FROM
			[#arguments.FromObjects#]

		WHERE
			[#BO.getMetaDataObject().getProperty(ListFirst(arguments.WhereProperties), 'DBName')#]=<cfqueryparam value="#BO.get(ListFirst(arguments.WhereProperties))#" cfsqltype="#BO.getMetaDataObject().getProperty(ListFirst(arguments.WhereProperties), 'CFSQLTYpe')#" null="#BO.isNull(ListFirst(arguments.WhereProperties))#" />
			<cfloop list="#ListRest(arguments.WhereProperties)#" index="currentProperty">
				AND [#BO.getMetaDataObject().getProperty(currentProperty, 'DBName')#]=<cfqueryparam value="#BO.get(currentProperty)#" cfsqltype="#BO.getMetaDataObject().getProperty(currentProperty, 'CFSQLTYpe')#" null="#BO.isNull(currentProperty)#" />
			</cfloop>
		</cfquery>

		<cfreturn Query />
	</cffunction>

	<!--- update --->
	<cffunction name="update" access="public" output="false" returntype="boolean">
		<cfargument name="SQLInput" type="struct" hint="Struct of structs of some meta data and current values for easy data retrieval" />
		<cfargument name="TableName" hint="Name of table in string format." />
		<cfargument name="UpdateProperties" type="string" hint="Comma-separated list of properties to update" />
		<cfargument name="FilterProperties" type="string" hint="Comma-separated list of properties to filter by" />

		<cfset var currentProperty="" />
		<cfset var Query="" />

		<cfquery name="Query" Datasource="#getDatasource().DSN#" Username="#getDatasource().Username#" Password="#getDatasource().Password#">
		UPDATE [#arguments.TableName#]
		SET
			[#arguments.SQLInput[ListFirst(arguments.UpdateProperties)].DBName#]=<cfqueryparam value="#arguments.SQLInput[ListFirst(arguments.UpdateProperties)].Value#" cfsqltype="#arguments.SQLInput[ListFirst(arguments.UpdateProperties)].CFSQLType#" null="#arguments.SQLInput[ListFirst(arguments.UpdateProperties)].IsNull#" />
			<cfif ListLen(ListRest(arguments.UpdateProperties))>
				<cfloop list="#ListRest(arguments.UpdateProperties)#" index="currentProperty">
					, [#arguments.SQLInput[currentProperty].DBName#]=<cfqueryparam value="#arguments.SQLInput[currentProperty].Value#" cfsqltype="#arguments.SQLInput[currentProperty].CFSQLType#" null="#arguments.SQLInput[currentProperty].IsNull#" />
				</cfloop>
			</cfif>

		WHERE
			[#arguments.SQLInput[ListFirst(arguments.FilterProperties)].DBName#]=<cfqueryparam value="#arguments.SQLInput[ListFirst(arguments.FilterProperties)].Value#" cfsqltype="#arguments.SQLInput[ListFirst(arguments.FilterProperties)].CFSQLType#" null="#arguments.SQLInput[ListFirst(arguments.FilterProperties)].IsNull#" />
			<cfif ListLen(ListRest(arguments.FilterProperties))>
				<cfloop list="#ListRest(arguments.FilterProperties)#" index="currentProperty">
					AND [#arguments.SQLInput[currentProperty].DBName#]=<cfqueryparam value="#arguments.SQLInput[currentProperty].Value#" cfsqltype="#arguments.SQLInput[currentProperty].CFSQLType#" null="#arguments.SQLInput[currentProperty].IsNull#" />
				</cfloop>
			</cfif>
		</cfquery>

		<cfreturn True />
	</cffunction>

	<!--- delete --->
	<cffunction name="delete" access="public" output="false" returntype="boolean">
		<cfargument name="SQLInput" type="struct" hint="Struct of structs of some meta data and current values for easy data retrieval" />
		<cfargument name="TableName" hint="Name of table in string format." />
		<cfargument name="FilterProperties" type="string" hint="Comma-separated list of properties to filter by" />

		<cfset var currentProperty="" />
		<cfset var Query="" />

		<cfquery name="Query" Datasource="#getDatasource().DSN#" Username="#getDatasource().Username#" Password="#getDatasource().Password#">
		DELETE [#arguments.TableName#]
		WHERE
			[#arguments.SQLInput[ListFirst(arguments.FilterProperties)].DBName#]=<cfqueryparam value="#arguments.SQLInput[ListFirst(arguments.FilterProperties)].Value#" cfsqltype="#arguments.SQLInput[ListFirst(arguments.FilterProperties)].CFSQLType#" null="#arguments.SQLInput[ListFirst(arguments.FilterProperties)].IsNull#" />
			<cfif ListLen(ListRest(arguments.FilterProperties))>
				<cfloop list="#ListRest(arguments.FilterProperties)#" index="currentProperty">
					AND [#arguments.SQLInput[currentProperty].DBName#]=<cfqueryparam value="#arguments.SQLInput[currentProperty].Value#" cfsqltype="#arguments.SQLInput[currentProperty].CFSQLType#" null="#arguments.SQLInput[currentProperty].IsNull#" />
				</cfloop>
			</cfif>
		</cfquery>

		<cfreturn True />
	</cffunction>

	<!--- exists ---->
	<cffunction name="exists" access="public" output="false" returntype="boolean">
		<cfargument name="SQLInput" type="struct" hint="Struct of structs of some meta data and current values for easy data retrieval" />
		<cfargument name="TableName" hint="Name of table in string format." />
		<cfargument name="FilterProperties" type="string" hint="Comma-separated list of properties to filter by" />

		<cfset var currentProperty="" />
		<cfset var Query="" />

		<cfquery name="Query" Datasource="#getDatasource().DSN#" Username="#getDatasource().Username#" Password="#getDatasource().Password#">
		SELECT TOP 1 1
		FROM [#arguments.TableName#]
		WHERE
			[#arguments.SQLInput[ListFirst(arguments.FilterProperties)].DBName#]=<cfqueryparam value="#arguments.SQLInput[ListFirst(arguments.FilterProperties)].Value#" cfsqltype="#arguments.SQLInput[ListFirst(arguments.FilterProperties)].CFSQLType#" null="#arguments.SQLInput[ListFirst(arguments.FilterProperties)].IsNull#" />
			<cfif ListLen(ListRest(arguments.FilterProperties))>
				<cfloop list="#ListRest(arguments.FilterProperties)#" index="currentProperty">
					AND [#arguments.SQLInput[currentProperty].DBName#]=<cfqueryparam value="#arguments.SQLInput[currentProperty].Value#" cfsqltype="#arguments.SQLInput[currentProperty].CFSQLType#" null="#arguments.SQLInput[currentProperty].IsNull#" />
				</cfloop>
			</cfif>
		</cfquery>

		<cfif Query.Recordcount is 1>
			<cfreturn True />
		<cfelse>
			<cfreturn False />
		</cfif>
	</cffunction>

	<!--- search --->
	<cffunction name="search" access="public" output="false" returntype="query">
		<cfargument name="SearchObject" type="any" required="true" />
		<cfargument name="IncludeTotalRows" type="boolean" required="true" />
	
		<cfscript>
			var SO=arguments.SearchObject;
			var PropertiesMetaData=SO.getObject().getMetaDataObject();
			var Filters=SO.getFilters();
			var OrderBy=SO.getOrderBy();
			
			var currentProperty='';
			var currentFilter='';
			var currentKeyword='';
			var currentKeywordProperty='';
			
			var Query='';
		</cfscript>

		<cfquery name="Query" Datasource="#getDatasource().DSN#" Username="#getDatasource().Username#" Password="#getDatasource().Password#">
			WITH Reco AS (
				SELECT
					[RowNumber] = ROW_NUMBER() OVER(
						ORDER BY
						[#ListFirst(ListFirst(OrderBy), ' ')#] #ListLast(ListFirst(OrderBy), ' ')#
						<cfloop list="#ListRest(OrderBy)#" index="currentProperty">
							, [#PropertiesMetaData.getProperty(ListFirst(currentProperty, ' '), 'DBName')#] #ListLast(currentProperty, ' ')#
						</cfloop>					
					)
					<cfloop list="#SO.listReadProperties()#" index="currentProperty">
						, [#currentProperty#] = [#PropertiesMetaData.getProperty(currentProperty, 'DBName')#]
					</cfloop>
						
					FROM 
						#PropertiesMetaData.getDBName()#
						
					WHERE 1=1
					
					<!--- loop through each filter --->
					<cfloop collection="#Filters#" item="currentFilter">
						AND [#PropertiesMetaData.getProperty(currentFilter, 'DBName')#]=<cfqueryparam value="#Filters[currentFilter]#" cfsqltype="#PropertiesMetaData.getProperty(currentFilter, 'CFSQLType')#" />
					</cfloop>
					
					<!--- loop through each keyword --->
					<cfloop list="#So.listKeywords()#" delimiters=" " index="currentKeyword">
						AND (
							1=0						
							<!--- loop through keyword properties --->
							<cfloop list="#So.listKeywordProperties()#" index="currentKeywordProperty">
								OR CAST([#PropertiesMetaData.getProperty(currentKeywordProperty, 'DBName')#] AS VARCHAR) LIKE <cfqueryparam value="%#currentKeyword#%" cfsqltype="cf_sql_varchar" />
							</cfloop>							
						)
					</cfloop>
			)
			
			SELECT *
			FROM Reco
			<cfif SO.getEndRow() gt 0>
				WHERE RowNumber BETWEEN #SO.getStartRow()# AND #SO.getEndRow()#
			</cfif>
			
			<cfif arguments.IncludeTotalRows>
				UNION ALL
	
				SELECT 
					COUNT(*)
					<cfloop list="#SO.listReadProperties()#" index="currentProperty">
						, NULL
					</cfloop>				
				FROM Reco
			</cfif>
		</cfquery>
		
		<cfreturn Query />
	</cffunction>
	
<!--- * * * * * * * * * * * * --->
<!--- * * * * PRIVATE * * * * --->
<!--- * * * * * * * * * * * * --->

	<!--- get Datasource --->
	<cffunction name="getDatasource" access="private" output="false" returntype="struct">
		<cfreturn variables.Datasource />
	</cffunction>
</cfcomponent>