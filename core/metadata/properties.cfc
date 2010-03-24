<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Bassil Karam (bassil.karam@thinkloop.com) - 01/01/2008
Edited By: Bassil Karam (bassil.karam@thinkloop.com) - 07/06/2008
Edited By: Bassil Karam (bassil.karam@thinkloop.com) - 08/04/2008
* * --->
<cfcomponent output="false" hint="Manages the user-provided attributes and values for each property defined in a business object.">
	<cfproperty name="Properties" type="struct" hint="A struct of structs that holds all properties data" />
	<cfproperty name="PropertyNamesArray" type="array" hint="A synchronized and sorted array (by name and position) of property names" />
	
	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="any">		
		<cfscript>
			// instance
			variables.i='do not instantiate a default struct'; // purposely not a struct so that if someone tries to set() an atribute without first adding atleat one property an error can be thrown
			
			// properties
			variables.Properties=StructNew();
			
			// index
			variables.Index=StructNew();
			variables.Index.PropertyNamesArray=ArrayNew(1);
			
			// these are defaults from add()
			variables.Index.AttributeNames=StructNew();
			variables.Index.AttributeNames.Name='';
			variables.Index.AttributeNames.DisplayName='';
			variables.Index.AttributeNames.NullValue='';
			variables.Index.AttributeNames.Position='';
			variables.Index.AttributeNames.ReadOnly='';
			
			variables.Index.Cursor=0;
		</cfscript>

		<cfreturn this />
	</cffunction>

<!--- * * * * * * * * * *--->
<!--- * * ATTRIBUTES * * --->
<!--- * * * * * * * * * *--->
	
	<!--- set --->
	<cffunction name="set" access="public" output="false" returntype="any">
		<cfargument name="PropertyAttribute" type="string" required="true" />
		<cfargument name="PropertyAttributeValue" type="string" required="true" />
		
		<cfif not isStruct(variables.i)>
			<cfthrow />
		<cfelse>
			<cfset variables.i[arguments.PropertyAttribute]=arguments.PropertyAttributeValue />
			<cfset variables.Index.AttributeNames[arguments.PropertyAttribute]="" /> <!--- doesn't matter what the value is --->
		</cfif>
		
		<cfreturn this />
	</cffunction>
	
	<!--- get --->
	<cffunction name="get" access="public" output="false" returntype="string">
		<cfargument name="PropertyAttribute" type="string" required="true" />
		
		<cfif StructKeyExists(variables.i, arguments.PropertyAttribute)>
			<cfreturn variables.i[arguments.PropertyAttribute] />
		<cfelse>
			<cfreturn '' />
		</cfif>
	</cffunction>

<!--- * * * * * * * * *--->
<!--- * * PROPERTY * * --->
<!--- * * * * * * * * *--->

	<!--- seek --->
	<cffunction name="seek" access="public" output="false" returntype="any">
		<cfargument name="Property" type="string" required="true" />
		
		<cfif exists(arguments.Property)>
			<cfset variables.i=variables.Properties[arguments.Property] />
		<cfelse>
			<cfthrow />
		</cfif>
		
		<cfreturn this />
	</cffunction>

	<!--- get instance --->
	<cffunction name="getInstance" access="public" output="false" returntype="struct">
		<cfreturn variables.i />
	</cffunction>
	
	<!--- add --->
	<cffunction name="add" access="public" output="false" returntype="any">
		<cfargument name="Property" type="string" required="true" hint="If property already exists it will be overwritten" />

		<cfscript>
			variables.Properties[arguments.Property]=StructNew();
			variables.Properties[arguments.Property]['Name']=arguments.Property;
			variables.Properties[arguments.Property]['DisplayName']=arguments.Property;
			variables.Properties[arguments.Property]['NullValue']='';
			variables.Properties[arguments.Property]['Position']=999;
			variables.Properties[arguments.Property]['ReadOnly']=False;
			
			// sort properties
			variables.Index.PropertyNamesArray=StructSort(variables.Properties, 'numeric', 'ASC', 'Position');
			
			// reference current instance to newly added property
			seek(arguments.Property);
		</cfscript>
		
		<cfreturn this />
	</cffunction>

	<!--- exists --->
	<cffunction name="exists" access="public" output="false" returntype="boolean">
		<cfargument name="Property" type="string" required="true" />
		
		<cfif StructKeyExists(variables.Properties, arguments.Property)>
			<cfreturn True />
		<cfelse>
			<cfreturn False />
		</cfif>
	</cffunction>

<!--- * * * * * * *--->
<!--- * * LOOP * * --->
<!--- * * * * * * *--->
	
	<!--- loop --->
	<cffunction name="loop" access="public" output="false" returntype="boolean">
		<cfargument name="Filter" type="any" default="" hint="Can be a struct or comma-separated list of key-value pairs. A * (star) can be used as a wildcard. If a filter key value is ONLY a * (star) and nothing else, the property must simply exist and be non-empty." />
		
		<cfscript>
			var FilterStruct=StructNew();
			var currentProperty='';
			var currentFilter='';
			
			var ReturnBoolean=False;
		</cfscript>

		<!--- if filter is a list, convert to struct --->
		<cfif not isStruct(arguments.Filter)>
			<cfloop list="#arguments.Filter#" index="currentFilter">
				<cfset FilterStruct[trim(ListFirst(currentFilter, '='))]=trim(ListLast(currentFilter, '=')) />
			</cfloop>
		<cfelse>
			<cfset FilterStruct=arguments.Filter />
		</cfif>
	
		<!--- if next record exists, increment counter, populate object and return true --->
		<cfloop condition="variables.Index.Cursor lt count() AND not ReturnBoolean">
			<cfset variables.Index.Cursor=variables.Index.Cursor+1 />
			<cfset seek(variables.Index.PropertyNamesArray[variables.Index.Cursor]) />
			<cfset ReturnBoolean=True />
	
			<cfloop collection="#FilterStruct#" item="currentFilter">	
				<cfif not REFindNoCase(Replace(FilterStruct[currentFilter], '*', '.'), get(currentFilter))>
					<cfset ReturnBoolean=False />
					<cfbreak />
				</cfif>
			</cfloop>
		</cfloop>
		
		<cfif not ReturnBoolean>
			<cfset variables.Index.Cursor=0 />
			<cfif count() gte 1>
				<cfset seek(variables.Index.PropertyNamesArray[1]) />
			</cfif>
		</cfif>
		
		<cfreturn ReturnBoolean />
	</cffunction>
	
<!--- * * * * * * * * * * * * * * --->
<!--- * * COLLECTION ORIENTED * * --->
<!--- * * * * * * * * * * * * * * --->

	<!--- array --->
	<cffunction name="array" access="public" output="false" returntype="array">
		<cfreturn variables.Index.PropertyNamesArray />
	</cffunction>

	<!--- list --->
	<cffunction name="list" access="public" output="false" returntype="string">
		<cfreturn ArrayToList(variables.Index.PropertyNamesArray) />
	</cffunction>

	<!--- count --->
	<cffunction name="count" access="public" output="false" returntype="numeric">
		<cfreturn ArrayLen(variables.Index.PropertyNamesArray)>
	</cffunction>
	
	<!--- get all --->
	<cffunction name="getAll" access="public" output="false" returntype="struct">
		<cfreturn variables.Properties />
	</cffunction>
</cfcomponent>