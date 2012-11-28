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
			var Value = variables.RawData[PropertyName][RowNum];
		</cfscript>

		<cfif isSimpleValue(Value) AND Value is getQueryNullValue()>
			<cfthrow message="Property #arguments.PropertyName#[#arguments.RowNum#] has a value of QueryNullValue." detail="An existsRaw() check should be done before getRaw()." />
		<cfelse>
			<cfreturn Value />
		</cfif>
	</cffunction>

	<!--- exists raw --->
	<cffunction name="existsRaw" access="public" output="false" returntype="any">
		<cfargument name="PropertyName" type="string" required="true" />
		<cfargument name="RowNum" type="numeric" required="true" />

		<cfscript>
			var PropertyName = arguments.PropertyName;
			var RowNum = arguments.RowNum;
			var value = '';

			if (RowNum lte numRows() AND StructKeyExists(variables.RawData, PropertyName)) {
				value = variables.RawData[PropertyName][RowNum];

				if (not IsSimplevalue(value) OR not value is getQueryNullValue()) {
					return true;
				}
			}
		</cfscript>

		<cfreturn false />
	</cffunction>

	<!--- num rows --->
	<cffunction name="numRows" access="public" output="false" returntype="numeric">
		<cfreturn variables.RawData.Recordcount />
	</cffunction>

	<!--- get raw with prefix --->
	<cffunction name="getRawWithoutPrefix" access="public" output="false" returntype="struct" hint="Return the query columns whose names start with the given prefix.">
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
			<cfif Len(currentPropertyName) gt PrefixLength AND Left(currentPropertyName, PrefixLength) is Prefix AND existsRaw(currentPropertyName, RowNum)>
				<cfset FinalProperties[Right(currentPropertyName, Len(currentPropertyName) - PrefixLength)] = variables.RawData[currentPropertyName][RowNum] />
			</cfif>
		</cfloop>

		<cfreturn FinalProperties />
	</cffunction>

	<!--- get raw data --->
	<cffunction name="getRawData" access="public" output="false" returntype="any">
		<cfreturn variables.RawData />
	</cffunction>

	<!--- get raw row --->
	<cffunction name="getRawRow" access="public" output="false" returntype="any">
		<cfargument name="RowNum" type="numeric" required="true" />
		<cfthrow message="Function query.getRawRow() not supported - must use structofstructs or arrayofstructs." />
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
	<cffunction name="getQueryNullValue" access="private" output="false" returntype="any" hint="Used to mimic a null value, such as when a struct is missing a key. Primarirly to have feature parity with structofstructs.cfc and arrayofstructs.cfc.">
		<cfreturn 'LoadedObjectsQueryNullValue000lasfhiuewypwsduigvbmdassbyjhewqyg238496tfwegbgsdajvhavuy6f7342t9gq78o3fguy' />
	</cffunction>

	<!--- remove row --->
	<cffunction name="removeRow" access="public" output="false" returntype="any">
		<cfargument name="RowNum" type="numeric" required="true" />
		<cfif numRows() gt 1>
			<cfset variables.RawData.RemoveRows(arguments.RowNum - 1, 1) />
		<cfelse>
			<cfquery name="variables.RawData" dbtype="query">
			SELECT *
			FROM variables.RawData
			WHERE 1=0
			</cfquery>
		</cfif>
		<cfreturn this />
	</cffunction>
</cfcomponent>