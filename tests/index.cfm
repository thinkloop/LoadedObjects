<cfinvoke component="mxunit.runner.DirectoryTestSuite"
	method="run"
	directory="/LoadedObjects/tests"
	componentpath="LoadedObjects.tests"
	recurse="true"
	returnvariable="results" />
<cfoutput>#results.getResultsOutput('extjs')#</cfoutput>