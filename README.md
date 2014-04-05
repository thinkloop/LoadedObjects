LoadedObjects
=============

A ColdFusion micro-framework that declaratively adds new functionality to your business ojects by assigning using attributes assigned to <cfproperty>. Any type of plugin can be developed that uses any attribute assigned on <cfproperty> (whether a made-up property or not).

###Example

*Init:*
```ColdFusion
application.loadedObjects = createObject('component', 'loadedobjects.loadedobjects').init(ObjectPathPrefix = 'model.objects');
```

/model/objects/MyBO.cfc
```ColdFusion
<cfcomponent output="false">
	<cfproperty name="id" type="numeric" />
	<cfproperty name="name" type="string" />
</cfcomponent>
```

Use:
```ColdFusion
var newBO = application.LoadedObjects.new('MyBO');
newBO.set('id', 1).set('name', 'Baz');
newBO.get('id');
```
