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

		<cfscript>
			var PropertyName = arguments.PropertyName;
			var Value = arguments.Value;
			var RowNum = arguments.RowNum;

			ensureRowsColumnsExist(PropertyName, RowNum);
		</cfscript>

		<cfset QuerySetCell(variables.RawData, PropertyName, Value, RowNum) />

		<cfreturn this />
	</cffunction>

	<!--- get raw --->
	<cffunction name="getRaw" access="public" output="false" returntype="any">
		<cfargument name="PropertyName" type="string" required="true" />
		<cfargument name="RowNum" type="numeric" required="true" />

		<cfscript>
			var PropertyName = arguments.PropertyName;
			var RowNum = arguments.RowNum;
		</cfscript>

		<cfreturn variables.RawData[PropertyName][RowNum] />
	</cffunction>

	<!--- exists raw --->
	<cffunction name="existsRaw" access="public" output="false" returntype="any">
		<cfargument name="PropertyName" type="string" required="true" />
		<cfargument name="RowNum" type="numeric" required="true" />

		<cfscript>
			var PropertyName = arguments.PropertyName;
			var RowNum = arguments.RowNum;
		</cfscript>

		<cfif RowNum lte numRows() AND StructKeyExists(variables.RawData, PropertyName) AND getRaw(PropertyName, RowNum) neq getQueryNullValue() >
			<cfreturn true />
		</cfif>

		<cfreturn false />
	</cffunction>

	<!--- num rows --->
	<cffunction name="numRows" access="public" output="false" returntype="numeric">
		<cfreturn variables.RawData.Recordcount />
	</cffunction>

	<!--- get raw with prefix --->
	<cffunction name="getRawWithoutPrefix" access="public" output="false" returntype="struct">
		<cfargument name="Prefix" type="string" required="true" hint="The characters a property name must begin with to be returned." />
		<cfargument name="RowNum" type="numeric" required="true" />

		<cfscript>
			var Prefix = arguments.Prefix;
			var RowNum = arguments.RowNum;
			var PrefixLength = Len(Prefix);

			var ColumnList = variables.RawData.ColumnList;
			var currentPropertyName = '';

			var FinalProperties = StructNew();
		</cfscript>

		<cfloop list="#ColumnList#" index="currentPropertyName">
			<cfif Len(currentPropertyName) gt PrefixLength AND Left(currentPropertyName, PrefixLength) is Prefix>
				<cfset FinalProperties[Right(currentPropertyName, Len(currentPropertyName) - PrefixLength)] = getRaw(currentPropertyName, RowNum) />
			</cfif>
		</cfloop>

		<cfreturn FinalProperties />
	</cffunction>

	<!--- get raw data --->
	<cffunction name="getRawData" access="public" output="false" returntype="any">
		<cfreturn variables.RawData />
	</cffunction>

<!--- * * * * * * * * --->
<!--- * * PRIVATE * * --->
<!--- * * * * * * * * --->

	<!--- ensure rows columns exist --->
	<cffunction name="ensureRowsColumnsExist" access="private" output="false" returntype="any">
		<cfargument name="PropertyName" type="string" required="true" />
		<cfargument name="RowNum" type="numeric" required="true" />

		<cfscript>
			var PropertyName = arguments.PropertyName;
			var RowNum = arguments.RowNum;
		</cfscript>

		<!--- make sure there are enough rows --->
		<cfloop condition="numRows() lt RowNum">
			<cfset addRow() />
		</cfloop>

		<!--- make sure column exists --->
		<cfif not StructKeyExists(variables.RawData, PropertyName)>
			<cfset addColumn(PropertyName) />
		</cfif>

		<cfreturn this />
	</cffunction>

	<!--- add row --->
	<cffunction name="addRow" access="private" output="false" returntype="any">
		<cfscript>
			var ColumnList = variables.RawData.ColumnList;
			var QueryNullValue = getQueryNullValue();
			var currentProperty = '';
		</cfscript>

		<cfset QueryAddRow(variables.RawData) />

		<cfloop list="#ColumnList#" index="currentProperty">
			<cfset setRaw(currentProperty, QueryNullValue, numRows()) />
		</cfloop>

		<cfreturn this />
	</cffunction>

	<!--- add column --->
	<cffunction name="addColumn" access="private" output="false" returntype="any">
		<cfargument name="PropertyName" type="string" required="true" />

		<cfscript>
			var PropertyName = arguments.PropertyName;
			var NullArray = ArrayNew(1);
			var QueryNullValue = getQueryNullValue();
		</cfscript>

		<cfloop query="variables.RawData">
			<cfset ArrayAppend(NullArray, QueryNullValue) />
		</cfloop>

		<cfset QueryAddColumn(variables.RawData, PropertyName, 'VarChar', NullArray) />

		<cfreturn this />
	</cffunction>

	<!--- get query null value --->
	<cffunction name="getQueryNullValue" access="private" output="false" returntype="any">
		<cfreturn 'LoadedObjectsQueryNullValue000lasfhiuewypwsduigvbmdassbyjhewqyg238496tfwegbgsdajvhavuy6f7342t9gq78o3fguy' />
	</cffunction>
</cfcomponent>