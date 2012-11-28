<cfcomponent output="false">

	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="RawData" type="struct" required="true" />

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

		<cfif StructKeyExists(variables.RawData, RowNum) AND StructKeyExists(variables.RawData[RowNum], PropertyName)>
			<cfreturn true />
		</cfif>

		<cfreturn false />
	</cffunction>

	<!--- num rows --->
	<cffunction name="numRows" access="public" output="false" returntype="numeric">
		<cfreturn StructCount(variables.RawData) />
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

		<cfif StructKeyExists(variables.RawData, 'RowNum')>
			<cfloop collection="#variables.RawData[RowNum]#" item="currentPropertyName">
				<cfif Len(currentPropertyName) gt PrefixLength AND Left(currentPropertyName, PrefixLength) is Prefix>
					<cfset FinalProperties[Right(currentPropertyName, Len(currentPropertyName) - PrefixLength)] = getRaw(currentPropertyName, RowNum) />
				</cfif>
			</cfloop>
		</cfif>
		<cfreturn FinalProperties />
	</cffunction>

	<!--- get raw data --->
	<cffunction name="getRawData" access="public" output="false" returntype="struct">
		<cfreturn variables.RawData />
	</cffunction>

	<!--- get raw row (by reference) --->
	<cffunction name="getRawRow" access="public" output="false" returntype="struct">
		<cfargument name="RowNum" type="numeric" required="true" />
		<cfreturn variables.RawData[RowNum] />
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

		<cfreturn this />
	</cffunction>

	<!--- add row --->
	<cffunction name="addRow" access="private" output="false" returntype="any">
		<cfset variables.RawData[numRows() + 1] = StructNew() />
		<cfreturn this />
	</cffunction>

	<!--- remove row --->
	<cffunction name="removeRow" access="public" output="false" returntype="any">
		<cfargument name="RowNum" type="numeric" required="true" />
		<cfset StructDelete(variables.RawData, arguments.RowNum, false) />
		<cfreturn this />
	</cffunction>
</cfcomponent>