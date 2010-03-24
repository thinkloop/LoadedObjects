<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Bassil Karam (bassil.karam@thinkloop.com) - 07/06/2008
Edited By: Bassil Karam (bassil.karam@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">
	
<!--- * * * * * * * * * *--->
<!--- * * MANAGEMENT * * --->
<!--- * * * * * * * * * *--->

	<!--- add relationsip --->
	<cffunction name="addRelationship" access="public" output="false" returntype="any">
		<cfargument name="Property" type="string" required="true" />
		
		<cfscript>
			var Relationship=getMetaDataObject().getProperty(arguments.Property, 'Relationship');
			var With=getMetaDataObject().getProperty(arguments.Property, 'with');
		</cfscript>
		
		<cfswitch expression="#Relationship#">
			
			<!--- many to one --->
			<cfcase value="ManyToOne">
				<cfset variables.i.Relationships[arguments.Property]=getLoadedObjects().new(With) />
			</cfcase>
			
			<!--- one to many --->
			<cfcase value="OneToMany">
				<cfset variables.i.Relationships[arguments.Property]=createObject('component', variables.i.RelationshipConfigPath).init(With, variables.i.RelationshipConfigPath) />
			</cfcase>
			
			<!--- many to many --->
			<cfcase value="ManyToMany">
				<cfset variables.i.Relationships[arguments.Property]=createObject('component', variables.i.RelationshipConfigPath).init(With, variables.i.RelationshipConfigPath) />
			</cfcase>
			
			<!--- todo: error --->
			<cfdefaultcase>
				<cfthrow />
			</cfdefaultcase>
		</cfswitch>
		
		<cfreturn this />
	</cffunction>
	
	<!--- remove relationsip --->
	<cffunction name="removeRelationship" access="public" output="false" returntype="any">
		<cfargument name="Property" type="string" required="true" />
		<cfset StructDelete(variables.i.Relationships, arguments.Property, false) />
		<cfreturn this />
	</cffunction>
	
	<!--- get relationsip --->
	<cffunction name="getRelationship" access="public" output="false" returntype="any">
		<cfargument name="Property" type="string" required="true" />
		<cfreturn variables.i.Relationship[arguments.Relationship] />
	</cffunction>
</cfcomponent>