---
title: "OOP: how to build an object"
description: "Object-oriented programming: primary and secondary constructors. The primary constructor is the default way to build an object with all its dependencies. The secondary constructors provide other ways to build objects depending on use cases."
date: 2021-03-10
image: build-object.webp
image_credit: danist07
tags: [oop, design-patterns]
keywords: "software,oop,design patterns,primary constructor, secondary constructor"
---

In this new blog post, I want to talk about object building more specifically about primary and secondary constructors. The primary constructor is the default way to build an object with all its dependencies. The secondary constructors provide other ways to build objects depending on use cases.

**Note:** I did not work on a PHP8 project yet so that is why I won’t talk about named arguments feature.

## Primary constructor

The PHP language provides a single way to build an object thanks to the  `__construct()`  method. I use this method to define the primary constructor of my classes to encapsulate all their dependencies.

```php
final class Map
{
   private MapName $name;
   private CartographersAllowedToEditMap $cartographersAllowedToEditMap;
   /** @var Marker[] */
   private array $markers;

   public function __construct(
       MapName $name,
       CartographersAllowedToEditMap $cartographersAllowedToEditMap,
       Marker ...$markers
   ) {  
       $this->name = $name;
       $this->cartographersAllowedToEditMap = $cartographersAllowedToEditMap;
       $this->markers = $markers;
   }
}
```

**Tip:** If your objects encapsulate a collection of a specific type (like the `Marker` in this example), you can use variadic arguments to automatically validate each item of this collection. Here, we don’t need to iterate the collection to check the type of its items, the language does it for us.

## Secondary constructor

The PHP language does not ease the data encapsulation because it only provides a single way to build objects but we should be able to define several constructors depending on all our use cases. How to solve this problem? Named constructors! Named constructors are static factories, in other words static methods that build the object itself.
Let’s take an example with the map object. How to initialize a map without any marker?

```php
final class Map
{
    public static function initialize(
       string $name,
       array $cartographerAllowedToEditMap
    ): self {
       return new self(
           new MapName($name),
           new CartographersAllowedToEditMap($cartographerAllowedToEditMap),
       );
    }
}
```

Here, we added a named constructor called  `initialize` to the `Map` class. It uses the primary constructor to build the map object with an empty collection of Marker objects.

**Tip:** Some developers change the visibility of the primary constructor method to private but I am not a big fan of that. I use object comparison to test objects to avoid the usage of getters. I like keeping my primary constructor public because it allows me to build objects in any state to compare them to other ones.

```php
function it adds a marker on the map()
{
   $actualMap = Map::initialize(
       'Bons plans sur Nantes',
       ['Arnaud']
   );

   $actualMap->addMarker('Bubar');

   $expectedMap = new Map(
       new MapName('Bons plans sur Nantes'),
       new CartographersAllowedToEditMap(['Arnaud']),
       new Marker('Bubar')
   );
   
   assertSame($actualMap, $expectedMap);
}
```

Thanks to my proofreader [@LaureBrosseau](https://www.linkedin.com/in/laurebrosseau).
