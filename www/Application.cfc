<cfcomponent output="false">
	<cfscript>
		this.name="LoadedObjects";
		this.sessionManagement="false";
		this.sessiontimeout = CreateTimeSpan(0, 0, 0, 0);
		this.applicationtimeout = CreateTimeSpan(1000,0,0,0);
	</cfscript>

	<!--- on error --->
	<cffunction name="onError" output="true">
		<cfargument name="Exception" required="true" />
		<cfargument name="EventName" type="String" required="true" />

		<cfscript>
			var Exception = arguments.Exception;
			var EventName = arguments.EventName;
			var RootDirectory = GetDirectoryFromPath(getBaseTemplatePath());
			var currentIndex = '';
		</cfscript>

		<cfoutput>
			<div style="width:100%; font-size: 12px; font-family:Courier New,Consolas,Monaco,Lucida Console,Liberation Mono,DejaVu Sans Mono,Bitstream Vera Sans Mono, monospace, serif;">
				<div style="padding: 1em; border-bottom: 1px solid ##CCCCCC;">
					<cfif StructKeyExists(Exception, 'Message')>
						<span style="font-size: 1.9em; color: ##990000">#Exception.Message#</span>
						<br />
					</cfif>
					<cfif StructKeyExists(Exception, 'Detail')>
						<span style="font-size: 1.4em;">#Exception.Detail#</span>
						<br />
					</cfif>
					<cfif StructKeyExists(Exception, 'ErrorCode') AND Exception.ErrorCode neq 0>
						<span style="font-size: 1.1em;">#Exception.ErrorCode#</span>
						<br />
					</cfif>
				</div>

				<cfif StructKeyExists(Exception, 'TagContext') AND IsArray(Exception.TagContext) AND ArrayLen(Exception.TagContext)>
					<div style="padding: 0em 1em;">
						<table style="font-size: 12px; padding-top:1em;" cellpadding="0" cellspacing="0">
							<cfloop array="#Exception.TagContext#" index="currentIndex">
								<tr>
									<td align="right" valign="top" style="padding: 0.75em 0.75em 0.25em 0.75em; color: ##0000AA; font-weight: 700;" nowrap>
										<cfif StructKeyExists(currentIndex, 'template') AND Len(currentIndex.template)>
											#ReplaceNoCase(currentIndex.template, RootDirectory, '')#
										</cfif>
									</td>
									<td align="left" valign="top" style="padding: 0.75em 0.75em 0.25em 0.75em; color: ##0000AA; font-weight: 700;" nowrap>
										<cfif StructKeyExists(currentIndex, 'line') AND Len(currentIndex.line)>
											[###ListLast(currentIndex.line, '\')#]
										</cfif>
									</td>
								</tr>
								<tr>
									<td style="border-bottom: 1px solid ##CCCCCC;">&nbsp;</td>
									<td style="padding: 0em 0.75em 0.75em 1.9em; border-bottom: 1px solid ##CCCCCC;">
										<cfif StructKeyExists(currentIndex, 'codePrintHTML') AND Len(currentIndex.codePrintHTML)>
											#currentIndex.codePrintHTML#
										</cfif>
									</td>
								</tr>
							</cfloop>
						</table>
					</div>
				</cfif>
				<cfif StructKeyExists(Exception, 'StackTrace')>
					<div style="padding:1em; padding-bottom: 0.5em;">
						<span style="font-weight:700; font-size: 1.2em;">Stack Trace</span>
						<p>
							#Exception.StackTrace#
						</p>
					</div>
				</cfif>
			</div>

			<cfdump var="#Exception#">
		</cfoutput>
	</cffunction>
</cfcomponent>