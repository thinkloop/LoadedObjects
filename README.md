LoadedObjects
=============

A ColdFusion micro-framework that declaratively adds new functionality to your business ojects by using attributes assigned to `<cfproperty>`. Plugins are built-in for get/set, validation, and collections. New plugins for any type of functionality can be developed that use attributes assigned to `<cfproperty>` (whether real or custom attributes).

###Example

Init:
```ColdFusion
application.loadedObjects = createObject('component', 'loadedobjects.loadedobjects').init(ObjectPathPrefix = 'model.objects');
```

Value Object: /model/objects/MyBO.cfc
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
