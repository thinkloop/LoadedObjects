<cfcomponent>
	<cfscript>
		this.name="LoadedObjects_new"; // The application name.
		this.applicationTimeout=createTimeSpan(1,0,0,0); // Life span, as a real number of days, of the application, including all Application scope variables. Use the CFML CreateTimeSpan function to generate this variable's value.

		this.clientManagement="false"; // Whether the application supports Client scope variables.
		this.clientStorage="cookie"; // Where Client variables are stored; can be cookie, registry, or the name of a data source.

		this.sessionManagement="false"; // Whether the application supports Session scope variables.
		this.sessionTimeout=createTimeSpan(0,0,0,0); // Life span, as a real number of days, of the user session, including all Session variables. Use the CFML CreateTimeSpan function to generate this variable's value.

		this.loginStorage="cookie"; // Whether to store login information in the Cookie scope or the Session scope.
		this.setClientCookies="false"; // Whether to send CFID and CFTOKEN cookies to the client browser.
		this.setDomainCookies="false"; // Whether to set CFID and CFTOKEN cookies for a domain (not just a host).

		this.scriptProtect="all"; //Whether to protect variables from cross-site scripting attacks.
	</cfscript>

	<!--- on ApplicationStart --->
	<cffunction name="onApplicationStart" output="false">

	</cffunction>

	<!--- on RequestStart --->
	<cffunction name="onRequestStart" output="false">
		<cfargument name="targetPage" />		
	</cffunction>

	<!--- on RequestEnd --->
	<cffunction name="onRequestEnd" output="true">
		<cfargument name="targetPage" />
	</cffunction>

	<!--- on ApplicationEnd --->
	<cffunction name="onApplicationEnd" output="false">
		<cfargument name="applicationScope" />
	</cffunction>

	<!--- on Error 
	<cffunction name="onError" output="true">
		<cfargument name="exception" />
		<cfargument name="eventName" type="String" />

		<cfset var LoopIndex=0 />

		<cfoutput>
			<style>
				##Exception, ##Exception H1, ##Exception H2, ##Exception H3, ##Exception UL { margin:5px 0px; font-size: 12px; }
				##Exception { float:left; margin:0px auto; padding:20px 0px 0px 20px; font-family:verdana; }
				##Exception H1 { }
				##Exception H2 { font-weight:500; }
				##Exception H3 { color:##AA0000; }
				##Exception UL { padding:0px; list-style:none; }
				##Exception UL LI { margin:3px 0px; font-size: 10px; }
				##Exception HR { border:1px dashed gray; }
			</style>
			<div id="Exception">
				<cfif len(arguments.exception.ErrorCode)>
					<h3>#arguments.exception.ErrorCode#</h3>
				</cfif>
				<h1>#arguments.exception.Message#</h1>
				<h2>#arguments.exception.Detail#</h2>
				<cfif arraylen(arguments.exception.tagcontext)>
					<hr>
					<ul>
						<cfloop from="1" to="#arraylen(arguments.exception.tagcontext)#" index="LoopIndex">
							<li>#arguments.exception.tagcontext[LoopIndex].Template# (<strong>#arguments.exception.tagcontext[LoopIndex].Line#</strong>)</li>
						</cfloop>
					</ul>
				</cfif>
			</div>
			<div style="clear:both;"></div>
		</cfoutput>
	</cffunction>
	--->
	<!--- on MissingTemplate --->
	<cffunction name="onMissingTemplate" returnType="boolean">
		<cfargument name="targetPage" required="true" />
<cfdump var="Missing Template #arguments.TargetPage#">
		<cfreturn False />
	</cffunction>
</cfcomponent>