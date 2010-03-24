<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Bassil Karam (bassil.karam@thinkloop.com) - 01/01/2008
Edited By: Bassil Karam (bassil.karam@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">

	<!--- init - this will be run after all plugins have been mixed in, then removed from the final business object --->
	<cffunction name="init" access="public" output="false" returntype="void">
		<cfscript>
			variables.SourceData='';
		</cfscript>
	</cffunction>

	<!--- set/get source-data --->
	<cffunction name="setSourceData" access="public" output="false" returntype="any" hint="Set source data by supplying a query or an array-of-structs.">
		<cfargument name="SourceData" type="any" required="true" hint="query or array-of-structs" />
		
		<cfset variables.SourceData=createObject('component', 'sourcedata').init(this, arguments.SourceData) />
		
		<cfreturn this />
	</cffunction>
	<cffunction name="getSourceData" access="public" output="false" returntype="any" hint="Returns instance of sourcedata object">		
		<cfreturn variables.SourceData />
	</cffunction>
	
	<!--- loop: this will error if source-data isn't set. I am thinking of taking it out in favor of just: Post.getSourceData().loop() --->
	<cffunction name="loop" access="public" output="false" returntype="boolean">
		<cfargument name="Direction" type="string" default="forward" hint="Can be: forward, reverse" />		
		<cfreturn variables.SourceData.loop(arguments.Direction) />
	</cffunction>
</cfcomponent>