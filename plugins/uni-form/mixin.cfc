<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Baz K. (bk@thinkloop.com) - 01/01/2008
Edited By: Baz K. (bk@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">
	
	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfscript>
		</cfscript>
		<cfreturn this />
	</cffunction>
	


<!--- * * * * * * * * * * * * * --->
<!--- * * ON MISSING METHOD * * --->
<!--- * * * * * * * * * * * * * --->
		
	<!--- onMissingMethod: provides generic get/set/isnull functionality without having to write out the functions --->
	<cffunction name="onMissingMethod" access="public" output="false" returntype="any" hint="Provides generic get/set/is functionality without having to write out the functions">
		<cfargument name="MissingMethodName" type="string" />
		<cfargument name="MissingMethodArguments" type="struct" />
		
		<cfscript>
			var PropertyName = '';
			var KeyList = '';
			var ReturnVal = '';
		</cfscript>

			
		<!--- display --->
		<cfif left(arguments.MissingMethodName, 7) is 'display'>
			<cfset PropertyName = right(arguments.MissingMethodName, len(arguments.MissingMethodName) - 7) />
			<cfreturn display(PropertyName) />
		</cfif>
	</cffunction>	
</cfcomponent>