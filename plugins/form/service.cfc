<!--- * * (coldfusion comments are completely stripped out once at compile time, and have zero impact on performance)
Created By: Bassil Karam (bassil.karam@thinkloop.com) - 01/01/2008
Edited By: Bassil Karam (bassil.karam@thinkloop.com) - 07/06/2008
* * --->
<cfcomponent output="false">

	<!--- init --->
	<cffunction name="init" access="public" output="false" type="any">
		<cfargument name="Datasource" type="struct" />

		<cfreturn this />
	</cffunction>

	<!--- output form --->
	<cffunction name="outputForm" access="public" output="false" type="string">
		<cfargument name="Object" type="any" />
		<cfargument name="FormAction" type="string" />
		<cfargument name="FormMethod" type="string" />
		<cfargument name="SubmitValue" type="string" />

		<!--- get object name --->
		<cfset var ObjectName=arguments.Object.getMetaDataObject().getName() />

		<!--- init form output --->
		<cfset var FormOutput="" />

		<!--- init loop index --->
		<cfset var currentProperty="" />

		<!--- output each form field --->
		<cfloop list="#arguments.Object.getMetaDataObject().listProperties()#" index="currentProperty">
			<cfset FormOutput="#FormOutput##outputFormField(arguments.Object, currentProperty)#" />
		</cfloop>

		<!--- append and prepend form tags --->
		<cfsavecontent variable="FormOutput"><cfoutput>
			<form id="#ObjectName#_Form" class="Form_Generated" action="#HTMLEditFormat(arguments.FormAction)#" method="#arguments.FormMethod#">
				#FormOutput#
				<input type="submit" id="#ObjectName#_Submit" class="Submit" name="#ObjectName#_Submit" value="#arguments.SubmitValue#" />
			</form></cfoutput>
		</cfsavecontent>

		<cfreturn FormOutput />
	</cffunction>

	<!--- output form field --->
	<cffunction name="outputFormField" access="public" output="false" type="string">
		<cfargument name="Object" type="any" />
		<cfargument name="PropertyName" type="string" />

		<!--- get cf data type --->
		<cfset var CFDataType=arguments.Object.getMetaDataObject().getProperty(arguments.PropertyName, 'Type') />

		<!--- init form field output --->
		<cfset var FormFieldOutput="" />

		<!--- determine form field type --->
		<cfswitch expression="#CFDataType#">

			<!--- string --->
			<cfcase value="String,GUID,Date">
				<cfset FormFieldOutput=outputStringField(arguments.Object, arguments.PropertyName) />
			</cfcase>

			<!--- Number --->
			<cfcase value="integer,float">
				<cfset FormFieldOutput=outputNumberField(arguments.Object, arguments.PropertyName) />
			</cfcase>

			<!--- Boolean --->
			<cfcase value="Boolean">
				<cfset FormFieldOutput=outputBooleanField(arguments.Object, arguments.PropertyName) />
			</cfcase>

			<!--- Binary --->
			<cfcase value="Binary">
				<cfset FormFieldOutput=outputBinaryField(arguments.Object, arguments.PropertyName) />
			</cfcase>

			<cfdefaultcase>
				<cfthrow type="LoadedObjects" errorcode="LoadedObjects.Form.InvalidType" message="Could not output form field #UCase(arguments.PropertyName)# because the type #ucase(CFDataType)# is unsupported." detail="The LoadedObjects form service must be updated to support this type." />
			</cfdefaultcase>
		</cfswitch>

		<cfreturn FormFieldOutput />
	</cffunction>

<!--- * * * * * * * * * * --->
<!--- * * * PRIVATE * * * --->
<!--- * * * * * * * * * * --->

	<!--- output String field--->
	<cffunction name="outputStringField" access="private" output="false" returntype="string">
		<cfargument name="Object" type="any" />
		<cfargument name="PropertyName" type="string" />

		<!--- set basic attributes --->
		<cfscript>
			var MetaData=arguments.Object.getMetaDataObject();
			var ObjectName=arguments.Object.getMetaDataObject().getName();
			var Name=arguments.PropertyName;
			var DisplayName=MetaData.getProperty(Name, 'DisplayName');
			var MaxValue=MetaData.getProperty(Name, 'MaxValue');
			var Value=arguments.Object.get(arguments.PropertyName);
		</cfscript>

		<!--- init field output --->
		<cfset var FieldOutput="" />

		<cfsavecontent variable="FieldOutput"><cfoutput>
			<div id="#ObjectName#_#Name#_Group" class="String_Field_Group">
				<label id="#ObjectName#_#Name#_Label" class="String_Field_Label" for="#ObjectName#_#Name#_Input">#DisplayName#</label>
				<input type="text" id="#ObjectName#_#Name#_Input" class="String_Field_Input" name="#Name#" maxlength="#MaxValue#" value="#Value#" />
			</div></cfoutput>
		</cfsavecontent>

		<cfreturn FieldOutput />
	</cffunction>

	<!--- output number field --->
	<cffunction name="outputNumberField" access="private" output="false" returntype="string">
		<cfargument name="Object" type="any" />
		<cfargument name="PropertyName" type="string" />

		<!--- set basic attributes --->
		<cfscript>
			var MetaData=arguments.Object.getMetaDataObject();
			var ObjectName=arguments.Object.getMetaDataObject().getName();
			var Name=arguments.PropertyName;
			var DisplayName=MetaData.getProperty(Name, 'DisplayName');
			var MaxValue=MetaData.getProperty(Name, 'MaxValue');
			var Value=arguments.Object.get(arguments.PropertyName);
		</cfscript>

		<!--- init field output --->
		<cfset var FieldOutput="" />

		<cfreturn FieldOutput />
	</cffunction>

	<!--- output boolean field --->
	<cffunction name="outputBooleanField" access="private" output="false" returntype="string">
		<cfargument name="Object" type="any" />
		<cfargument name="PropertyName" type="string" />

		<!--- set basic attributes --->
		<cfscript>
			var MetaData=arguments.Object.getMetaDataObject();
			var ObjectName=arguments.Object.getMetaDataObject().getName();
			var Name=arguments.PropertyName;
			var DisplayName=MetaData.getProperty(Name, 'DisplayName');
			var MaxValue=MetaData.getProperty(Name, 'MaxValue');
			var Value=arguments.Object.get(arguments.PropertyName);
		</cfscript>

		<!--- init field output --->
		<cfset var FieldOutput="" />

		<cfreturn FieldOutput />
	</cffunction>

	<!--- output date time field --->
	<cffunction name="outputDateTimeField" access="private" output="false" returntype="string">
		<cfargument name="Object" type="any" />
		<cfargument name="PropertyName" type="string" />

		<!--- set basic attributes --->
		<cfscript>
			var MetaData=arguments.Object.getMetaDataObject();
			var ObjectName=arguments.Object.getMetaDataObject().getName();
			var Name=arguments.PropertyName;
			var DisplayName=MetaData.getProperty(Name, 'DisplayName');
			var MaxValue=MetaData.getProperty(Name, 'MaxValue');
			var Value=arguments.Object.get(arguments.PropertyName);
		</cfscript>

		<!--- init field output --->
		<cfset var FieldOutput="" />

		<cfreturn FieldOutput />
	</cffunction>
</cfcomponent>