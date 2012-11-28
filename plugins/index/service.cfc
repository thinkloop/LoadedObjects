<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Baz K. (bk@thinkloop.com) - 01/01/2008
Edited By: Baz K. (bk@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">

	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfset variables.Mixin=createObject('component', 'mixin') />
		<cfreturn this />
	</cffunction>

	<!--- index get --->
	<cffunction name="indexGet" access="public" output="false" returntype="any">
		<cfargument name="BO" type="any" required="true" />
		<cfargument name="IDs" type="string" required="true" />

		<cfscript>
			var BO = arguments.BO;
			var IDs = Trim(arguments.IDs);
			var newBO = BO.new();
		</cfscript>

		<cfif not ListLen(IDs)>
			<cfreturn newBO />
		</cfif>

		<!--- if property has never run through the set routine, set it now to itself so that the raw value is processed --->
		<cfif not hasBeenSetProperty(BO, PropertyName, CurrentRow)>
			<cfif existsRaw(BO, PropertyName, CurrentRow)>
				<cfset RawValue = getRaw(BO, PropertyName, CurrentRow) />
			<cfelse>
				<cfset RawValue = BO.getLoadedObjectsMetadata(PropertyName, 'Default') />
			</cfif>

			<!--- if property is child object, see if raw data from parent could be used to populate it --->
			<cfif BO.getLoadedObjectsMetadata(PropertyName, 'IsObject')>
				<cfset RawValue.setRawData(getRawWithoutPrefix(BO, PropertyName, CurrentRow)) />
			</cfif>

			<!--- set the value manually here rather than using set() to avoid recursive stack overflow when overriding setters and need to call their getters to check the value --->
			<cfset setRaw(BO, PropertyName, RawValue, CurrentRow) />
			<cfset HasBeenSet[CurrentRow][PropertyName] = true />
		</cfif>

		<cfreturn getRaw(BO, PropertyName, CurrentRow) />
	</cffunction>
</cfcomponent>