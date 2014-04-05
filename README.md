LoadedObjects
=============

Coldfusion micro-framework that declaratively adds new functionality to your business ojects by assigning attributes on <cfproperty>.

###Example

Init:
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
