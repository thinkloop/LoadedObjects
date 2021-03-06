<cfcomponent output="false">

	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="RawData" type="array"  required="true" />

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

		<cfset variables.RawData[RowNum][PropertyName] = Value />

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

		<cfreturn variables.RawData[RowNum][PropertyName] />
	</cffunction>

	<!--- exists raw --->
	<cffunction name="existsRaw" access="public" output="false" returntype="any">
		<cfargument name="PropertyName" type="string" required="true" />
		<cfargument name="RowNum" type="numeric" required="true" />

		<cfscript>
			var PropertyName = arguments.PropertyName;
			var RowNum = arguments.RowNum;
		</cfscript>

		<cfif StructKeyExists(variables.RawData[RowNum], PropertyName)>
			<cfreturn true />
		</cfif>

		<cfreturn false />
	</cffunction>

	<!--- num rows --->
	<cffunction name="numRows" access="public" output="false" returntype="numeric">
		<cfreturn ArrayLen(variables.RawData) />
	</cffunction>

	<!--- get raw with prefix --->
	<cffunction name="getRawWithoutPrefix" access="public" output="false" returntype="struct">
		<cfargument name="Prefix" type="string" required="true" hint="The characters a property name must begin with to be returned." />
		<cfargument name="RowNum" type="numeric" required="true" />

		<cfscript>
			var Prefix = arguments.Prefix;
			var RowNum = arguments.RowNum;
			var PrefixLength = Len(Prefix);

			var currentPropertyName = '';
			var FinalProperties = StructNew();
		</cfscript>

		<cfloop collection="#variables.RawData[RowNum]#" item="currentPropertyName">
			<cfif Len(currentPropertyName) gt PrefixLength AND Left(currentPropertyName, PrefixLength) is Prefix>
				<cfset FinalProperties[Right(currentPropertyName, Len(currentPropertyName) - PrefixLength)] = getRaw(currentPropertyName, RowNum) />
			</cfif>
		</cfloop>

		<cfreturn FinalProperties />
	</cffunction>

	<!--- get raw data --->
	<cffunction name="getRawData" access="public" output="false" returntype="array">
		<cfreturn variables.RawData />
	</cffunction>

	<!--- get raw row (by reference) --->
	<cffunction name="getRawRow" access="public" output="false" returntype="struct">
		<cfargument name="RowNum" type="numeric" required="true" />
		<cfreturn variables.RawData[RowNum] />
	</cffunction>

	<!--- clear --->
	<cffunction name="clear" access="public" output="false" returntype="any">
		<cfset ArrayClear(variables.RawData) />
		<cfreturn this />
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
		<cfif not existsRaw(PropertyName, RowNum)>
			<cfset addColumn(PropertyName, RowNum) />
		</cfif>

		<cfreturn this />
	</cffunction>

	<!--- add row --->
	<cffunction name="addRow" access="private" output="false" returntype="any">
		<cfset ArrayAppend(variables.RawData, StructNew()) />
		<cfreturn this />
	</cffunction>

	<!--- add column --->
	<cffunction name="addColumn" access="private" output="false" returntype="any">
		<cfargument name="PropertyName" type="string" required="true" />
		<cfargument name="RowNum" type="numeric" required="true" />
		<cfset variables.RawData[arguments.RowNum][arguments.PropertyName] = '' />
		<cfreturn this />
	</cffunction>
</cfcomponent>