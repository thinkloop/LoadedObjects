<cfcomponent output="false">
	<cfscript>
		this.name="LoadedObjects";
		this.sessionManagement="false";
		this.sessiontimeout = CreateTimeSpan(0, 0, 0, 0);
		this.applicationtimeout = CreateTimeSpan(1000,0,0,0);
	</cfscript>

</cfcomponent>