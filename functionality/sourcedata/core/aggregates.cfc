<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Bassil Karam (bassil.karam@thinkloop.com) - 07/06/2008
Edited By: Bassil Karam (bassil.karam@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">

	<!--- TODO: sum(property:string) - use ArraySum I think --->
	
	<!--- TODO: avg(property:string) - use ArrayAvg I think --->

	<!--- TODO: min(property:string) --->
	
	<!--- TODO: max(property:string) --->
	
	<!--- TODO: count(property:string) --->
	
	<!--- list property values: create a list of values from every row of a given property --->
	<cffunction name="listPropertyValues" access="public" output="false" returntype="string">
		<cfargument name="Property" type="string" required="true" />
		
		<cfset var FinalList="" />
		
		<cfloop condition="loop()">
			<cfset FinalList=ListAppend(FinalList, variables.BO.get(arguments.Property) />
		</cfloop>
		
		<cfreturn FinalList />
	</cffunction>
</cfcomponent>