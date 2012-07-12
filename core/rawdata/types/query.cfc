<cfcomponent output="false">

	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="RawData" type="query" required="true" />

		<cfscript>
			variables.RawData = arguments.RawData;
		</cfscript>

		<cfreturn this />
	</cffunction>

	<!--- set raw --->
	<cffunction name="setRaw" access="public" output="false" returntype="any">
		<cfargument name="PropertyName" type="string" required="true" />
		<cfargument name="Value" type="any" required="true" />
		<cfargument name="RowNum" type="numeric" required="true" />
		
		<cfif not StructKeyExists(variables.RawData, arguments.PropertyName)>
			<cfset addColumn(arguments.PropertyName) />
		</cfif>
		
		<cfset QuerySetCell(variables.RawData, arguments.PropertyName, arguments.Value, arguments.RowNum) />
		
		<cfreturn this />
	</cffunction>

	<!--- get raw --->
	<cffunction name="getRaw" access="public" output="false" returntype="any">
		<cfargument name="PropertyName" type="string" required="true" />
		<cfargument name="RowNum" type="numeric" required="true" />
		<cfreturn variables.RawData[arguments.PropertyName][arguments.RowNum] />
	</cffunction>

	<!--- add column --->
	<cffunction name="addColumn" access="public" output="false" returntype="any">
		<cfargument name="PropertyName" type="string" required="true" />

		<cfset QueryAddColumn(variables.RawData, arguments.PropertyName) />

		<cfloop query="variables.RawData">
			<cfset variables.RawData[arguments.PropertyName] = getQueryNullValue() />
		</cfloop>

		<cfreturn this />
	</cffunction>

	<!--- exists column --->
	<cffunction name="existsColumn" access="public" output="false" returntype="boolean">
		<cfargument name="PropertyName" type="string" required="true" />
		<cfargument name="RowNum" type="string" required="true" />
		
		<cfscript>
			var PropertyValue = '';
			var IsNullValue = '';
		</cfscript>
		
		<cfif StructKeyExists(variables.RawData, arguments.PropertyName)>
			<cfscript>
				var PropertyValue = getRaw(arguments.PropertyName, arguments.RowNum);
				var IsNullValue = IsSimplevalue(PropertyValue) AND PropertyValue is getQueryNullValue();
			</cfscript>			
			<cfreturn not IsNullValue />
		</cfif>
		
		<cfreturn false />
	</cffunction>

	<!--- add row --->
	<cffunction name="addRow" access="public" output="false" returntype="any">
		<cfscript>
			var QueryRecordCount = 0;
			var QueryColumnNames = '';
			var currentColumnName = '';

			QueryAddRow(variables.RawData);

			QueryRecordCount = variables.RawData.Recordcount;
			QueryColumnNames = variables.RawData.ColumnList;
		</cfscript>

		<!--- set each property with query null value --->
		<cfloop list="#QueryColumnNames#" index="currentColumnName">
			<cfset setRaw(currentColumnName, getQueryNullValue(), QueryRecordCount) />
		</cfloop>

		<cfreturn this />
	</cffunction>

	<!--- num rows --->
	<cffunction name="numRows" access="public" output="false" returntype="numeric">
		<cfreturn variables.RawData.Recordcount />
	</cffunction>

	<!--- get query null value: since adding a query column creates a value for each row, there is no concept of null (non-existence) like with a struct. To make this match with a struct, if we find this value in a column, we treat it like a struct is missing that key --->
	<cffunction name="getQueryNullValue" access="public" output="false" returntype="string">
		<cfreturn 'LoadedObjects_Null_Value_For_Query_TBJYNQKMUYMTIOOQOUUMPLKRJCS4Q32154803729nthkrdnr87tGQGGVSE3573Q64358nvgsjQkvg' />
	</cffunction>

	<!--- get raw data --->
	<cffunction name="getRawData" access="public" output="false" returntype="any">
		<cfreturn variables.RawData />
	</cffunction>
</cfcomponent>