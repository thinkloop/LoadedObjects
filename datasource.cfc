<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created On: 06/22/2007
Modified On: 01/01/2008
Developed By: Bassil Karam (bassil.karam@thinkloop.com)
* * --->
<cfcomponent output="false">

	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="DSN" />
		<cfargument name="Username" default="" />
		<cfargument name="Password" default="" />

		<cfscript>
			variables.i=structnew();
			variables.i.DSN=arguments.DSN;
			variables.i.Username=arguments.Username;
			variables.i.Password=arguments.Password;
		</cfscript>

		<cfreturn this />
	</cffunction>

	<!--- get Datasource --->
	<cffunction name="getDatasource" access="public" output="false" returntype="struct">
		<cfreturn variables.i />
	</cffunction>

	<!--- DSN --->
	<cffunction name="getDSN" access="public" output="false" returntype="string">
		<cfreturn variables.i.DSN />
	</cffunction>

	<!--- Username --->
	<cffunction name="getUsername" access="public" output="false" returntype="string">
		<cfreturn variables.i.Username />
	</cffunction>

	<!--- Password --->
	<cffunction name="getPassword" access="public" output="false" returntype="string">
		<cfreturn variables.i.Password />
	</cffunction>
</cfcomponent>