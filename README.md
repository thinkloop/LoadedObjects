LoadedObjects
=============

A ColdFusion micro-framework that declaratively adds new functionality to your business ojects using attributes assigned to `<cfproperty>`. Base functionality for get/set, validation, and collections exists out of the box. New plugins can be developed to add any type of functionality that leverages attributes on `<cfproperty>`.

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
