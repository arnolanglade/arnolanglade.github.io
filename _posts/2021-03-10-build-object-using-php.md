---
title: Build an object using PHP
permalink: /:title:output_ext
layout: post
date: 2021-03-04
image: build-object.jpg
alt: Build an object using PHP
---

# Build an object using PHP

![Data validation](assets/img/posts/build-object.jpg)
[@danist07](https://unsplash.com/@danist07)

In this new blog post, I want to talk about object building more specifically about primary and secondary constructors. The primary constructor is the default way to build an object with all its dependencies. The secondary constructors provide other ways to build objects depending on use cases.
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

**Tip:** If your objects encapsulate a collection of a specific type (like the `Marker` in this example) you can use variadic arguments to automatically validate each item of this collection. Here, we don’t need to iterate the collection to check the type of its items, the language does it for us.

## Secondary constructor

The PHP language does not ease the data encapsulation because it only provides a single way to build objects but we should be able to define several constructors depending on all use cases we have. How to solve this problem? Named constructors! Named constructors are static factories: static methods that build the object itself.
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

Here, we added a named constructor called  `initialize` to the map class. It uses the primary constructor to build the map object with an empty collection of Marker objects.

**Tip:** Some developers change the visibility of the primary constructor method to private but I am not a big fan of that. I use object comparison to test objects to avoid the usage of getters. I like keeping my primary constructor public because It allows you to build objects in any state to compare them to other ones.

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


Thanks to my proofreader [@LaureBrosseau](https://twitter.com/LaureBrosseau).