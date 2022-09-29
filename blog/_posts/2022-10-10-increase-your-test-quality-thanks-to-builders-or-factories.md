---
title: Increase your test quality thanks to builders or factories
permalink: /:title:output_ext
description: "Bad tests are hard to maintain and they slow down your productivity. Test code quality is as important as production code. The builder or factory patterns can help you to improve your test code quality. It will ease test refactoring and make tests more readable."
layout: post
date: 2022-10-10
image: increase-your-test-quality-thanks-to-builders-or-factories.webp
alt: Increase your test quality thanks to builders or factories
keywords: "testing,software,design pattern,code quality"
tags: [testing, code-quality]
related_posts: ["Why you should not expose objects' state to test them", "Why unit testing can be hard?"]
---

# Increase your test quality thanks to builders or factories

![Increase your test quality thanks to builders or factories](assets/img/posts/increase-your-test-quality-thanks-to-builders-or-factories.webp)[@thoughtcatalog](https://unsplash.com/@thoughtcatalog)

In a previous [blog post](http://arnolanglade.github.io/you-should-not-expose-objects-state-to-test-them.html), I explained why it’s better to compare object instances instead of exposing their state to test them. This avoids breaking encapsulation and it does not have any impact on their design.

Let’s take an example! My side project allows me to create maps to remember places I have been. A map has a name and, as a cartographer, I am allowed to rename it. Real basic use case but more than enough! The following test ensures I can rename this map:

```php
$map = new Map(
    new MapId('e9a01a8a-9d40-476e-a946-06b159cd484a'),
    new Username('Pepito'),
    new MapName('Bordeaux'),
    new Description('Ma vie sur 'Anglet'),
    Tag::travel(),
    MarkerList::empty(),
);

$map->rename('Bons plans sur 'Anglet');

Assert::equals(
    $map,
    new Map(
        new MapId('e9a01a8a-9d40-476e-a946-06b159cd484a'),
        new Username('Pepito'),
        new MapName('Bons plans sur 'Anglet'),
        new Description('Ma vie sur 'Anglet'),
        Tag::travel(),
        MarkerList::empty(),
    )
);
```

We can see that comparing object instances is great for encapsulation because we don’t expose the object’s state but this makes the test less readable. Here, the only thing we want to focus on is the value of `MapName`. The values of the other value object are only noise because they are not useful for this test. But, this is not the only drawback of this test. What happens if you want to add an extra property to the `Map` object? In this case, we will need to refactor all the tests that create a map object. It might be easily doable in small projects but it can become messy for big ones.

Now, let's show how we can improve this test. The title of my blogpost can give you a huge hint on the solution. We will add a named constructor called `whatever` to the `Map` object to centralize the object construction. Named constructors are static factories that build the object itself.

```php
class Map 
{
    /** @internal */
    public static function whatever(
        string $mapId = 'e9a01a8a-9d40-476e-a946-06b159cd484a',
        string $addedBy = 'Pepito',
        string $name = 'Bons plans sur Nantes',
        string $description = 'Ma vie sur Nantes',
        string $tag = 'city',
        array $markers = [],
    ): self {
        return new self(
            new MapId($mapId),
            new Username($addedBy),
            new MapName($name),
            new Description($description),
            new Tag($tag),
            new MarkerList($markers),
        );
    }
}
```

**Tip:** I like to add a `@internal` annotation to remind all teammates that the object constructor should only be used in tests.

The value object instantiation is delegated to the `whatever` constructor. I try to use primitive data types like arguments as much as possible, it makes me write less code and it’s easier to read. All constructor arguments have a default value, then I can override a given value depending on the needs thanks to the named argument feature.

```php
$map =  Map::whatever(name: 'Anglet');

$map->rename('Bons plans sur Anglet');

Assert::equals(
    $map,
    Map::whatever(name: 'Bons plans sur Anglet')
);
```

Now, the test is clear and focuses on the right thing. Everyone can easily understand it, and it will help your teammates to grasp the code you wrote. Refactoring will be simplified as you only have to rewrite the `whatever` constructor if the signature of the primary constructor of `Map` changes.

I know that some people won’t like the idea of adding a method to objects only for testing purposes. If you don’t like that, you can replace this static factory with a builder.

```php
class MapBuilder
{
    private string $mapId = 'e9a01a8a-9d40-476e-a946-06b159cd484a';
    private string $addedBy = 'Pepito';
    private string $name = 'Bons plans sur Nantes';
    private string $description = 'Ma vie sur Nantes';
    private string $tag = 'city';
    private array $markers = [];

    public function identifiedBy(string $mapId): self
    {
        $this->mapId = $mapId;
        
        return $this;
    }

    public function named(string $addedBy): self
    {
        $this->addedBy = $addedBy;

        return $this;
    }

    // ... other setters ....

    public function build(): self {
        return new self(
            new MapId($this->mapId),
            new Username($this->addedBy),
            new MapName($this->name),
            new Description($this->description),
            new Tag($this->tag),
            new MarkerList($this->markers),
        );
    }
}
```

Then your test will look like this:

```php
$map =  (new MapBuilder())->named('Anglet'')->build();

$map->rename('Bons plans sur Anglet');

Assert::equals(
    $map,
    (new MapBuilder())->named('Bons plans sur Anglet')->build()
);
```

**Tip:** Read or anemic models don’t have logic to ensure they are built in a good way. If you use this method for them you can add some logic to your builder/factories to ensure they are created with consistent data. It will make your tests stronger.

## Final thought

Builders or factories ease test refactoring and make tests more readable. Don’t forget that bad test suites are a nightmare to maintain and can drastically slow down your delivery. Taking care of your test quality will help you to ship fast. Moreover, good tests are free documentation.

Thanks to my proofreader [@LaureBrosseau](https://twitter.com/LaureBrosseau).
