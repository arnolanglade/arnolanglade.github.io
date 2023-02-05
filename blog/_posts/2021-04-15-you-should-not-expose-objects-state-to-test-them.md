---
title: Why you should not expose objects' state to test them
permalink: /:title:output_ext
description: Exposing the object's state to test them is not a good idea. Comparing object instances is better because it avoids breaking encapsulation and it does not have any impact on their design.
layout: post
date: 2021-04-13
image: test-comparison.webp
image_alt: Why you should not expose objects' state to test them
image_credit: jdent
tags: [oop, testing]
keywords: "software,testing,unit test,oop,encapsulation,ask don't tell"
related_posts: ["Why unit testing can be hard?", "Increase your test quality thanks to builders or factories"]
---

To introduce this topic, let’s have a look at the PHP documentation to understand how object comparison works using the comparison and identity operators.

> When using the comparison operator (==), object variables are compared in a simple manner, namely: Two object instances are equal if they have the same attributes and values (values are compared with ==), and are instances of the same class.
>
> When using the identity operator (===), object variables are identical if and only if they refer to the same instance of the same class.
>
> [PHP documentation ](https://www.php.net/manual/en/language.oop5.object-comparison.php)


```php
$object = new Object();
$otherObject = new Object();

$object == $otherObject // true
$object === $otherObject // false 
```

I add an `equals` method to objects to handle object comparison. The purpose of this method is to compare an object state with another one. In the following example, I use the comparison operator (==) because I want to check if the objects have the same state no matter their references.

```php
final class Email
{
   private string $email;

   public function __construct(string $email)
   {
       $this->email = $email;
   }

   public function equals(Email $email): bool
   {
       return $this == $email;
   }
}
```

There is another way to compare object state. Do you know that instances of the same class can access each other's private members?

```php
final class Email
{
   public function equals(Email $email): bool
   {
       return $this->email === $email->email;
   }
}
```

**Tip:** This is really useful to compare Doctrine entities that have persistent collections. The error `Error: Nesting level too deep - recursive dependency?` is raised when we compare entities using the comparison operator (==). You should have a look at this [blog post](https://www.richardlord.net/blog/php/php-nesting-level-too-deep-recursive-dependency.html) to understand why this error occured. Accessing private attributes let you use the identity operator (===) to prevent this error.

By the way, entities are a bit special because an entity is an object that has an identity. It means that if we want to compare them we should compare their identities instead of their states.

```php
final class Map
{
   private MapId $mapId;

   public function equals(MapId $mapId): bool
   {
       return $this->mapId->equals($mapId);
   }
}
```

I add an extra method called `hasSameState` to entities to compare their states because entity state comparison remains really useful for testing.

```php
final class Map
{
   public function hasSameState(Map $map): bool
   {
       return $this->map == $map;
   }
}
```

For a long time, I used getters for testing purposes. I only knew this way to ensure objects had the right state.

```php
$map = new Map('Best places at Nantes');

$map->rename('Best places at Bordeaux');

$map->getName()->shouldReturn('Best places at Bordeaux') ;
```

It was a mistake because exposing objects’ state breaks data encapsulation. We should not know how objects work internally, we should only use their public API (public methods) to interact with them. But, if we need to build the `Map` object with something else than a string, this assertion will no longer be true. That will break all application tests and parts that use this getter! That’s not great! Object comparison I described previously helps to get rid of getters.

```php
$map = new Map('Best places at Nantes');

$map->rename('Best places at Bordeaux');

$map->hasSameState(new Map('Best places at Bordeaux'))->shouldReturn(true);
```

Now, the `Map` object is better designed. Its state is not exposed anymore which improves data encapsulation. It follows the "Tell don't ask" principle because I don't need to extract its internal state to test it. I only need to use its public API to check if it meets the business exceptions.

**Tip:** If you don’t want or if you can’t add a method to your objects that handles comparison you can still compare their instances to avoid adding getters.

```php
Assert::equals($map, new Map('Best places at Bordeaux'));
```

Thanks to my proofreader [@LaureBrosseau](https://twitter.com/LaureBrosseau).